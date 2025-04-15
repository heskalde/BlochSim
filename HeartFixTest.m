%%
clear

[x, y] = meshgrid(linspace(-2, 2, 50), linspace(-2, 2, 50));
heartMask = (x.^2 + (5/4)*y.^2 - 1).^3 - x.^2 .* (-y.^3) <= 0;
heartValue = 1150;

T1_map = 1000+10*rand(50,50);
[rows, cols] = size(T1_map);
T1_map(heartMask) = heartValue;
figure()
imagesc(T1_map);
clim([900 1200]);
colorbar;
title('T1 map of heart [ms]');

FM = 50*rand(50,50); % field map
FM(heartMask) = FM(heartMask)*2;
error_map = -0.0030*FM.^2 - 70;
offT1 = T1_map+error_map;
figure()
imagesc(offT1);
clim([900 1200]);
axis off;
colorbar;
title('T1 map with heart and off resonance [ms]');

figure()
imagesc(FM);
colorbar;
axis off;
title('Field map [Hz]');

%% Creating a dictionary of correction curves
T1_vec = [1000 1050 1100 1150 1200];
CD = zeros(3,length(T1_vec));
CD_m = zeros(rows,cols,length(T1_vec));
pm = MOLLI_params();
for t=1:length(T1_vec)
    pm.T1 = T1_vec(t);
    [p, ~] = MOLLI_sim_freq(pm);
    % Define correction map based on the polynomial fit
    CD(:,t) = p;
    CD_m(:,:,t) = polyval(p,FM); %CurveDictionary maps
    CD_cm(:,:,t) = pm.T1 - CD_m(:,:,t);  % CurveDictionary correction maps
end
%% Make corrections
errors = zeros(rows,cols,length(T1_vec));
for s=1:length(T1_vec)
    errors(:,:,s) = (offT1 - CD_m(:,:,s)).^2;
end

[~, best_fit_index] = min(errors,[], 3);

correction_factors = zeros(rows,cols);
correctedT1 = zeros(rows,cols);
for r=1:rows
    for c=1:cols
        correction_factors(r,c) = CD_cm(r,c, best_fit_index(r,c));
        correctedT1(r,c) = offT1(r,c) + correction_factors(r,c);
    end
end

% correction_map = -polyval(p, FM);
% correctedT1 = offT1 + correction_factors;

%%


figure()
imagesc(correction_factors);
colorbar;
ylabel('ms')
axis off;
title('Correction map [ms]');

figure()
imagesc(correctedT1);
clim([900 1200]);
colorbar;
ylabel('ms')
axis off;
title('Corrected T1 map with heart and off resonance [ms]');


