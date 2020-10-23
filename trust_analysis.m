function [f t2b] = trust_fit(trust_fname)
% dS is the signal decay acquired at each echo in the Saggital Sinus
% TE is the effective echo time and is currently hard coded

TE = [0 40 80 160]'; % effective echo time in ms

%% Fit exponential to signal in Sag Sinus

dS = load (['meantc.dM.' trust_fname]);

f = fit(TE,dS,'exp1');

%figure,
%plot(f,TE,dS,'+')
%xlabel('TE_{eff} [ms]')
%ylabel('MR signal in Saggital Sinus [a.u.]')

%% Calc T2b
t1b = 1624; %t1 of blood assumed to be 1624ms
%t1b = 1500;
t2b = 1/((1/t1b)-(f.b));
Y = t2_to_Y_converter(t2b/1000);
Y = Y*100;

fprintf('TE used [ms] ... \n')
disp(TE)
fprintf('T2b = %0.1f [ms] \n',t2b)
fprintf('Assuming Hct of 0.42 \n')
fprintf('Y = %0.3f [%%] \n',Y)

% save fig and mat
%print('trust','-depsc2','-r300');
%save('trust','dS','TE','t2b','Y');
dlmwrite(['T2b.' trust_fname '.txt'],t2b);
dlmwrite(['Y.' trust_fname '.txt'],Y);


function Y = t2_to_Y_converter(T2)

%% Taken from "Qin et al. MRM 65:471 (2011)"
% assumes Hct between 0.40 - 0.46
% A = 7.18;
% C = 59.6;
% Y = 1-sqrt(((1./T2)-A)./C);


%% Taken from "Lu et al. MRM 67:42 (2012)"
%  these are values specifically for tau_cpmg = 10 ms
%  Hct between 
a1 = -13.5; % [s-1]
a2 = 80.2;  % [s-1]
a3 = -75.9; % [s-1]
b1 = -0.5;  % [s-1]
b2 = 3.4;   % [s-1]
c1 = 247.4; % [s-1]
hct = 0.42;

A = a1 + a2*hct + a3*hct^2;
B = b1*hct + b2*hct^2;
C = c1*hct*(1 - hct);

r = roots([C B A-(1/T2)]);

x = r( r>=0 );

if length(x) == 1
    Y = 1-x;
else
    fprintf('Root of quadratic equation problematic')
end

return;