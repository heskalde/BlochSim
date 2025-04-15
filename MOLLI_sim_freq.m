function [p, estT1_vs_B0] = MOLLI_sim_freq(pm)
    %% Simulating changes in T1 due to B0 inhomogeneity in a MOLLI sequence
    %tic
    fit_func = @(p, tvec) p(1) - p(2)*exp(-tvec / p(3)); % Exponential recovery curve to fit data points to
    fit_options = optimoptions('lsqcurvefit', 'Display', 'off', 'Algorithm','levenberg-marquardt');
    
    %% Step 1: simulate T1 relaxation under different B0 conditions
    delta_freq = linspace(-160,160,101);
    estT1_vs_B0 = zeros(length(delta_freq),2);
    for k=1:length(delta_freq)
        df = delta_freq(k);
    
        [Msig, Mz, Mi_idx] = MOLLI_sim(pm,df);
    
        %post bloch sim work
        Mi = zeros(8,2);
        for y=1:8
            sig = Msig(Mi_idx(y));
            if Mz(Mi_idx(y))<0
                sig = -1*sig;
            end
            Mi(y,:) = [pm.tvec(Mi_idx(y)) sig];
        end
    
        Mi(6,1) = Mi(6,1)-7.5*pm.RR;
        Mi(7,1) = Mi(7,1)-7.5*pm.RR;
        Mi(8,1) = Mi(8,1)-7.5*pm.RR;
        Mi = sortrows(Mi, 1);
        
        % Fit the simulated signal to extract apparent T1 using non-linear least squares
        params = lsqcurvefit(fit_func, [0.5,1.5,pm.T1], Mi(:,1), Mi(:,2), [], [], fit_options);
        x1 = params(1);
        x2 = params(2);
        T1_star = params(3);
        IE = 1-(1-Mz(1))*exp((pm.sigma/2)/(2*pm.T1)); % inversion efficiency
        % estT1 = T1_star*((x1-x2)/(x1*IE));
        % estT1 = T1_star;
        estT1 = T1_star*(x2/x1 - 1);
        % M0 = (x1-x2)/IE;
        % estT1 = T1_star/(x1/M0);
        estT1_vs_B0(k,:) = [df, estT1];
    end
    
    
    %% Step 2: Model the relationship between apparent T1 and B0 (off-resonance frequency)
    p = polyfit(estT1_vs_B0(:, 1), estT1_vs_B0(:, 2), 2);
    % toc
end
