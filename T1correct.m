%% Load B0 map
clear all

start_folder = 'C:\Users\heskalde\OneDrive - Universitetet i Oslo\Dokumenter\Diverse prosjekter\RELAX'; % Change to your starting folder path
if ~isfolder(start_folder)
    errorMessage = sprintf('Error: The following starting folder does not exist:\n%s', start_folder);
    uiwait(warndlg(errorMessage));
    start_folder = pwd;
end
cd(start_folder);

[B0_file, path] = uigetfile('*.*', 'Select B0 map');
if isequal(B0_file, 0)
    disp('User selected Cancel');
end

B0_name = fullfile(path, B0_file);
B0 = dicomread(B0_name);
B0 = squeeze(B0);

%% Load T1 map
[T1_file, path] = uigetfile('*.*', 'Select T1 map');
if isequal(T1_file, 0)
    disp('User selected Cancel');
end

T1_name = fullfile(path, T1_file);
T1 = dicomread(T1_name);
T1 = squeeze(T1);

%% Co-register maps

% Find phase images from B0 map file and calculate slice locations
n_B0 = size(B0, 3);
B0meta = dicominfo(B0_name);
B0_pfSeq = B0meta.PerFrameFunctionalGroupsSequence;
B0_locs = []; % find slice position of B0 maps along SA
B0_slices = []; % actual image data of B0 maps

j = 1;
for k = 1:n_B0
    B0_frame = B0_pfSeq.(sprintf('Item_%d', k));
    if B0_frame.MRImageFrameTypeSequence.Item_1.ComplexImageComponent == "REAL"
        B0_slices(:,:,j) = B0(:,:,k);
        B0_pos = B0_frame.PlanePositionSequence.Item_1.ImagePositionPatient; % [x, y, z]
        B0_R = B0_frame.PlaneOrientationSequence.Item_1.ImageOrientationPatient(1:3); % row vector orientation
        B0_C = B0_frame.PlaneOrientationSequence.Item_1.ImageOrientationPatient(4:6); % column vector orientation
        B0_locs(j) = dot(cross(B0_R,B0_C), B0_pos);
        j = j+1;
    end
end

% Find T1 slices and calculate slice locations
n_T1 = size(T1, 3);
T1meta = dicominfo(T1_name);
T1_pfSeq = T1meta.PerFrameFunctionalGroupsSequence;
T1_locs = []; % location of T1 slices along SA
T1_slices = []; % actual image data of T1 slices

h = 1;
for d = 1:n_T1
    T1_frame = T1_pfSeq.(sprintf('Item_%d', d));
    T1_dim = T1_frame.FrameContentSequence.Item_1.DimensionIndexValues;
    if isequal(T1_dim(end-2:end)', [5,6,1]) % pick up T1 maps (5,6) and corrected for residuals (1)
        T1_slices(:,:,h) = T1(:,:,d);
        T1_pos = T1_frame.PlanePositionSequence.Item_1.ImagePositionPatient; % [x, y, z]
        T1_R = T1_frame.PlaneOrientationSequence.Item_1.ImageOrientationPatient(1:3); % row vector orientation
        T1_C = T1_frame.PlaneOrientationSequence.Item_1.ImageOrientationPatient(4:6); % column vector orientation
        T1_locs(h) = dot(cross(T1_R,T1_C), T1_pos);
        h = h+1;
    end
end

B0co = []; % co-registered B0 maps
% Find slices that match eachothers slice position
for s = 1:length(T1_locs)
    diffs = abs(B0_locs-T1_locs(s));
    [~, index] = min(diffs);
    B0co(:,:,s) = B0_slices(:,:,index);
end

%% Visualizing co-registration
[rows, cols] = size(T1_slices(:,:,1));
alpha = 0.1;
for r=1:size(B0co,3)
    B0uw = KaspersUnwrap(B0co(:,:,r));
    resizedB0co = imresize(B0uw,[rows,cols]);
    B0_im = mat2gray(resizedB0co);
    % B0_im = ind2rgb(uint8(B0_im * 255), colormap('jet'));
    
    T1_im = mat2gray(T1_slices(:,:,r));
    if size(T1_im, 3) == 1  % Grayscale image
        T1_im = repmat(T1_im, [1, 1, 3]);
    end
    
    overlay = (1-alpha)*T1_im + alpha*B0_im;
    % figure()
    % imshow(overlay)
    % title("T1 map and B0 map co-registered slice " + r)

    figure()
    imshow(B0_im)
    title("Unwrapped B0 map slice " + r)

    figure()
    imshow(mat2gray(imresize(B0co(:,:,r),[rows,cols])))
    title("Wrapped B0 map slice " + r)

    % figure()
    % imshow(T1_im)
    % title("T1 map slice " + r)
end

%% Calculate off-resonance map


%% Simulate off-resonance effects


%% Correct for off-resonance effects


%% Compare to true T1 map (if available)