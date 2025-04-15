clear
%% Block based simulation
T1 = 1000e-3;
T2 = 45e-3;
TR = 5;
a = (3)*pi/18;
df = 100;
omega = 2*pi*df;
TE = 10e-3;
TI_1 = 40e-3;
TI_2 = 120e-3;
HR = 60;
RR = HR/60;


R = [1 0 0; 0 cos(a) sin(a); 0 -sin(a) cos(a)];

I = [1 0 0; 0 cos(pi) sin(pi); 0 -sin(pi) cos(pi)];

P = @(dt) [cos(omega*dt) sin(omega*dt) 0; -sin(omega*dt) cos(omega*dt) 0; 0 0 1];

C = @(dt) [exp(-dt/T2) 0 0; 0 exp(-dt/T2) 0; 0 0 exp(-dt/T1)];

D = @(dt) [0 0 1-exp(-dt/T1)]';

M = zeros(3,8);

M(:,1) = P(TE)*C(TE)*R*P(TI_1-TE)*C(TI_1-TE)*[0 0 -1]' + P(TE)*C(TE)*R*D(TI_1-TE) + D(TE);

M(:,2) = P(TE)*C(TE)*R*P(RR-TE)*C(RR-TE)*M(:,1) + P(TE)*C(TE)*R*D(RR-TE) + D(TE);

M(:,3) = P(TE)*C(TE)*R*P(RR-TE)*C(RR-TE)*M(:,2) + P(TE)*C(TE)*R*D(RR-TE) + D(TE);

M(:,4) = P(TE)*C(TE)*R*P(RR-TE)*C(RR-TE)*M(:,3) + P(TE)*C(TE)*R*D(RR-TE) + D(TE);

M(:,5) = P(TE)*C(TE)*R*P(RR-TE)*C(RR-TE)*M(:,4) + P(TE)*C(TE)*R*D(RR-TE) + D(TE);

paus3 = I*P(3*RR)*C(3*RR)*M(:,5) + I*D(3*RR);

M(:,6) = P(TE)*C(TE)*R*P(TI_2-TE)*C(TI_2-TE)*paus3 + P(TE)*C(TE)*R*D(TI_2-TE) + D(TE);

M(:,7) = P(TE)*C(TE)*R*P(RR-TE)*C(RR-TE)*M(:,6) + P(TE)*C(TE)*R*D(RR-TE) + D(TE);

M(:,8) = P(TE)*C(TE)*R*P(RR-TE)*C(RR-TE)*M(:,7) + P(TE)*C(TE)*R*D(RR-TE) + D(TE);

M

TI = [TI_1 (TI_1+RR) (TI_1+2*RR) (TI_1+3*RR) (TI_1+4*RR) (TI_2) (TI_2+RR) (TI_2+2*RR)];
Msig = abs(sqrt(M(1,:).^2 + 1i*M(2,:).^2));
Mi = zeros(8,2);
for y=1:8
    sig = Msig(y);
    if y == 1 || y == 6
        sig = -1*sig;
    end
    Mi(y,1) = TI(y);
    Mi(y,2) = sig;
    % Mi(y,2) = M(3,y);
end
Mi = sort(Mi,1);


tvec = linspace(0,TI_2+2*RR+4,1000);
fit_func = @(p, tvec) p(1) - p(2)*exp(-tvec / p(3));

% % Fit using non-linear least squares
fit_options = optimoptions('lsqcurvefit', 'Display', 'off', 'Algorithm','levenberg-marquardt');
params = lsqcurvefit(fit_func, [0.5,1.5,T1], Mi(:,1), Mi(:,2), [], [], fit_options);
A = params(1);
B = params(2);
T1_star = params(3);
%%
% est_T1 = T1_star*(B/A -1);
est_T1 = T1_star;
diff = (T1-est_T1)*1000

figure()
plot(Mi(:,1), Mi(:,2), 'go', tvec, fit_func([A B T1_star], tvec), 'g-', tvec, fit_func([1 2 est_T1], tvec), 'b-', tvec, fit_func([1 2 T1], tvec), 'r-')
legend('T1* points', 'T1*', 'Estimated T1', 'Native T1')

