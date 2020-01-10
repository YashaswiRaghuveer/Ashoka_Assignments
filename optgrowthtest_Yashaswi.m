%Optimum growth problem class test_Yashaswi

clc            
clear all      
close all     

% Set parameter values
beta   = 0.95;              % discount factor 
alpha = 0.5;                % share of capital
A = 1;                      % total factor productivity (TFP) parameter

%  state variable(s)

mink =  0.0001;                   % minimum value 
maxk =  30;                       % maximum value    
ink  =  0.01;                     % size of grid increments
kgrid = mink:ink:maxk;            % row vector
[rk ck] = size(kgrid);            % column size of the Wgrid 
                                  
kprime = repmat(kgrid',1,ck);    % kprime = possible future states matrix
k = repmat(kgrid,ck,1);          % possible current states matrix
                                 % basically k = transpose of kprime

cons = A*(k.^alpha) - kprime; % consumption matrix (note: c<=0 are infeasible)
ctiny=1e-10;                  % a teeny tiny number
cons(cons==0)=ctiny;          % this helps in getting rid of too many NaNs
cons(find(cons<0)) = NaN;        % replacing c < 0 with Not a Number (NaN)
util =  log(cons);               % utility matrix
util(find(isnan(util))) = -inf;  % replacing NaN values with -infinity

% Value function iteration
v = zeros(1,ck);          % initial guess
tol  = 1;                 % tolerance level 'tol'
iter = 0;                 % this will count the number of iterations
tme = cputime;       

while tol > 0.0001          % <= 0.0001 is the desired tolerance/ deviation
  [tv, i]=max(util + beta*repmat(v',1,ck));           
  tol=max(abs(tv-v));                      
  v=tv;                                       % updating the value function
iter = iter+1;
end

%Visualization and summary
disp('fixed point solved via value function iteration took');
disp([ iter ]);        
disp('iterations and');
disp([ cputime-tme ]);
disp('seconds');

%Plot value function
figure(1)
plot(kgrid, v)
title('Value function')
xlabel('capital today, k')
ylabel('value function, V(k)')

% Plot policy functions
coptapprox = A*(kgrid.^alpha)-kgrid(i); 
copttheo = (1-alpha*beta)*A*(kgrid.^alpha);   

figure(2)
plot(kgrid, copttheo)
hold on;
plot(kgrid, coptapprox)
title('Policy function')
xlabel('capital today, k')
ylabel('optimal consumption, c = \phi(k)')
legend('\phi(k): theoretical','\phi(k): approximated','Location','southeast')

