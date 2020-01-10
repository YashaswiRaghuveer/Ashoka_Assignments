clear all
par.theta = 0.4
par.beta = 0.6
par.sigma = -0.7
par.delta = 0.8
par.sbar = 0.2
par.phi = 0.3
par.r = 1- (1-par.sbar)^par.sigma + par.delta
par.p1 = par.theta*par.beta
par.p2 = 1 - par.theta*(1-par.beta)

ggrid = 200
par.gammas = linspace(0,1,ggrid)

x0 = [.1,1]
xone = zeros(50,1)
xtwo = zeros(50,1)

for i = 1:1:ggrid
z = par.gammas(i)
par.Z = z
xsol = fsolve(@(x)solution_eqns(par,x),x0)
xone(i) = xsol(1)
xtwo(i) = xsol(2)
end

figure
subplot(3,1,1);
plot(par.gammas,xone)
title('X ONE'); 
xlabel('Gamma');
subplot(3,1,2);
plot(par.gammas,xtwo)
title('X TWO'); 
xlabel('Gamma');

subplot(3,1,3);
plot(par.gammas,xone)
title('Combine Plots')
hold on
plot(par.gammas,xtwo)
hold off

function [y] = solution_eqns(par,x)
y = zeros(2,1)
x1 = x(1)
x2 = x(2)
y(1) = (1/x1)*(par.r/par.delta)^(1/par.sigma) - par.p1*(par.theta*(1 - par.beta) + par.Z*par.beta)^(par.phi-1)
y(2) = (1/x2)*((x2^par.sigma - (x2 - par.sbar)^par.sigma + par.delta)/par.delta)^(1/par.sigma) - par.p2*(1- par.beta + par.Z*par.p2)^(par.phi-1)
end