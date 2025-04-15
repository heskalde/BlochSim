function pm = MOLLI_params()
    % Setting the main parameters used in the MOLLI bloch simulation into a
    % the struct [pm]

    % MR parameters
    pm.T1 = 1000e-3; % T1 relaxation in seconds
    pm.T2 = 45e-3; % T2 relaxation in seconds
    pm.TE = 10e-3; % Echo time in seconds
    gamma = 42.577e6; % gyromagnetic ratio Hz/T

    % Heart parameters
    HR = 60; %bpm
    pm.RR = HR/60; %length of R-R interval in s rounded to no decimals 
    % to avoid arithmetic decimal errors

    pm.TR = 16*pm.RR; % s
    pm.dt = 1e-3; % 1 ms timestep for simulation
    pm.TIR = 40e-3; % inversion time for first image after IR in ms

    % RF pulse prep
    B1 = 20e-6; % amplitude of RF pulse in Tesla
    pm.alpha = 3*(pi/18); % desired flip angle (pi/18 = 10 degrees)
    tau = (pm.alpha/(2*pi*gamma*B1)); % duration of RF pulse in s
    pm.dtRF = tau/1000;
    pm.RF_time = linspace(0,tau,1001);
    
    % IR pulse prep
    pm.beta = pi; % desired ir angle
    pm.sigma = (pm.beta/(2*pi*gamma*B1)); % duration of IR pulse in s
    pm.dtIR = pm.sigma/1000;
    pm.IR_time = linspace(0,pm.sigma,1001);

    pm.tvec = linspace(0,pm.TR,pm.TR*1000+1);
    pm.N = length(pm.tvec);

end