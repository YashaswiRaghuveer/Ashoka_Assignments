% Parameter values 
theta=.36;
gamma=.9;
beta = 0.98;
Hbar = 0.65;
gtfp = 0.02;
npop = 0.01;
Ao = 0.1;
kstar= (beta*(1-theta).*Hbar.^(1-theta).*Ao.^(1-theta)/(1+beta).*(1+gtfp)^(1/1-theta))^(1/(1-theta));

% Three initial capital stocks and productivity variables
K0=[.8*kstar
	kstar
	1.2*kstar];
lambda(1:3,1)=[1 1 1]';
K(1:3,1)=K0;
% Production Function
Y(:,1)=lambda(:,1).*K(:,1).^theta.*Hbar.^(1-theta);
for k=2:240
   lambda(:,k)=(1-gamma)+gamma.*lambda(:,k-1)+.02.*(rand(3,1)-.5);
   K(:,k)=beta.*(1-theta).*lambda(:,k-1).*K(:,k-1).^theta.*Hbar.^(1-theta).*Ao.^(1-theta)./(1+beta).*(1+npop).*(1+gtfp)^(1/1-theta) ;
   Y(:,k)=lambda(:,k).*K(:,k).^theta.*Hbar.^(1-theta);
end
subplot(2,1,1),plot(K') 
xlabel('Time') 
ylabel('Capital') 

subplot(2,1,2),plot(Y')
xlabel('Time') 
ylabel('Output') 