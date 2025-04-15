function [Msig, Mz, Mi_idx] = MOLLI_sim(pm,df)
    %initial magnetization and vectors
    M = [0 0 1]';
    Mz = zeros(1,pm.N);
    Msig = zeros(1,pm.N);
    Mi_idx = zeros(1,8);
    
    %loop timings
    tIR = 7.5*pm.RR; % at the 8th heartbeat, assuming we are sampling around mid diastole the second IR pulse would be about 7.5*RR after the first
    timings = [pm.TIR (pm.TIR+pm.RR) (pm.TIR+pm.RR*2) (pm.TIR+pm.RR*3) (pm.TIR+pm.RR*4) (tIR + 3*pm.TIR) (tIR + pm.RR + 3*pm.TIR) (tIR + 2*pm.RR + 3*pm.TIR)];
    for p=1:length(timings)
        differences = abs(pm.tvec-timings(p));
        [~, t_index] = min(differences);
        timings(p) = t_index;
    end
    j = 1;
    %finding the t_index for tIR
    tIR = interp1(pm.tvec,pm.tvec,tIR,'nearest');
    tIR = find(pm.tvec == tIR);
    
    omega = 2*pi*df;
    %RF pulse prep
    dalpha = pm.alpha/length(pm.RF_time);
    RF = [1 0 0; 0 cos(dalpha) sin(dalpha); 0 -sin(dalpha) cos(dalpha)]; % RF nutation about x-axis for small flip angle dalpha
    RF_df = [cos(omega*pm.dtRF) sin(omega*pm.dtRF) 0; -sin(omega*pm.dtRF) cos(omega*pm.dtRF) 0; 0 0 1]; % rotation matrix with off-resonance for timestep dtRF
    RF_tot = RF_df*RF;


    %IR pulse prep
    dbeta = pm.beta/length(pm.IR_time);
    IR = [1 0 0; 0 cos(dbeta) sin(dbeta); 0 -sin(dbeta) cos(dbeta)]; % IR nutation about x-axis for small flip angle dbeta
    IR_df = [cos(omega*pm.dtIR) sin(omega*pm.dtIR) 0; -sin(omega*pm.dtIR) cos(omega*pm.dtIR) 0; 0 0 1]; % rotation matrix with off-resonance for timestep dtIR
    IR_tot = IR_df*IR;

    % IR pulse at start
    for i=1:length(pm.IR_time)
        M = IR_tot*M;
    end
    Msig(1) = sqrt(M(1)^2 + 1i*M(2)^2);
    Mz(1) = M(3);
    
    % free precession matrixes
    [A,B] = freeprecess(pm.dt,pm.T1,pm.T2,df);

    for t=2:pm.N
        if ismember(t, timings)
            for r=1:length(pm.RF_time)
                M = RF_tot*M;
            end
            Mz(t) = M(3);
            Msig(t) = abs(sqrt(M(1)^2 + 1i*M(2)^2));
            Mi_idx(j) = t + round(pm.TE/pm.dt,0);
            j = j + 1;
        % second IR at t = 8*RR
        elseif t == tIR
            for i=1:length(pm.IR_time)
                M = IR_tot*M;
            end
            Mz(t) = M(3);
            Msig(t) = abs(sqrt(M(1)^2 + 1i*M(2)^2));

        else
            M = A*M+B;
            Mz(t) = M(3);
            Msig(t) = abs(sqrt(M(1)^2 + 1i*M(2)^2));
        end
    end
end