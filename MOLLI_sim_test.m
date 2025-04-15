%% Simulating changes in T1 due to B0 inhomogeneity in a MOLLI sequence
clear
tic

pm = MOLLI_params();

% simulate T1 relaxation with off-resonance df
df = 100;
[Msig, Mz, Mi_idx] = MOLLI_sim(pm,df);

Mi = zeros(8,2);
for y=1:8
    sig = Msig(Mi_idx(y));
    if Mz(Mi_idx(y))<0
        sig = -1*sig;
    end
    Mi(y,:) = [pm.tvec(Mi_idx(y)) sig];
end

figure()
plot(pm.tvec,Mz,'r-',pm.tvec,abs(Msig),'b-',Mi(:,1), Mi(:,2), 'go')
ylim([-1 1.1])
xlim([0 pm.TR])
legend('Mz','Mxy','Readout value')
xlabel('ms')
ylabel('Signal')

Mi(6,1) = Mi(6,1)-7.5*pm.RR;
Mi(7,1) = Mi(7,1)-7.5*pm.RR;
Mi(8,1) = Mi(8,1)-7.5*pm.RR;
Mi = sortrows(Mi, 1);

% fitting of T1 values
% Fit the simulated signal to extract apparent T1
fit_func = @(p, tvec) p(1) - p(2)*exp(-tvec / p(3)); % Exponential recovery curve to fit data points to
% % Fit using non-linear least squares
fit_options = optimoptions('lsqcurvefit', 'Display', 'off', 'Algorithm','levenberg-marquardt');
params = lsqcurvefit(fit_func, [0.5,1.5,pm.T1], Mi(:,1), Mi(:,2), [], [], fit_options);
x1 = params(1);
x2 = params(2);
T1_star = params(3);
IE = 1-(1-Mz(1))*exp(pm.sigma/(2*pm.T1)); % inversion efficiency
estT1 = T1_star*(x2/x1 - 1);
% estT1 = T1_star*((x1-x2)/(x1*IE));
diff_T1 = (pm.T1-estT1)*1000

figure()
plot(pm.tvec(1:ceil(pm.N/2)), fit_func([1 2 pm.T1], pm.tvec(1:ceil(pm.N/2))), 'r-', Mi(:,1), Mi(:,2), 'go', pm.tvec(1:ceil(pm.N/2)), fit_func([x1 x2 T1_star], pm.tvec(1:ceil(pm.N/2))), 'g-', pm.tvec(1:ceil(pm.N/2)), fit_func([1 2 estT1], pm.tvec(1:ceil(pm.N/2))), 'b-')
legend('True T1 curve', 'T1* data points', 'T1* curve', 'Estimated T1 curve')
xlabel('ms')
ylabel('Signal')
ylim([-1.1 1.1])

toc