%% Pick and read file with metadata
clear all

start_folder = 'C:\Users\heskalde\OneDrive - Universitetet i Oslo\Dokumenter\Diverse prosjekter\RELAX'; % Change to your starting folder path
if ~isfolder(start_folder)
    errorMessage = sprintf('Error: The following starting folder does not exist:\n%s', start_folder);
    uiwait(warndlg(errorMessage));
    start_folder = pwd;
end
cd(start_folder);

[files, path] = uigetfile('*.*', 'Select DICOM files', 'MultiSelect','on');
if isequal(files, 0)
    disp('User selected Cancel');
else
    if ischar(files)
        % If only one file is selected, uigetfile returns a char array instead of a cell array
        files = {files};
    end
end

for i = 1:length(files)
    full_file_path = fullfile(path, files{i});

    % Read the DICOM file
    dicom_data = dicomread(full_file_path);
    
    % Read and print metadata
    metadata = dicominfo(full_file_path);
    disp(['File: ', files{i}, ' - Protocol Name: ', metadata.ProtocolName]);
    disp(['Pulse sequence: ', metadata.PulseSequenceName]);
    %disp(metadata.Private_2001_1020);
    disp(['Image type: ', metadata.ComplexImageComponent]);

    %%
    numSlices = size(dicom_data, 4);
    pfSeq = metadata.PerFrameFunctionalGroupsSequence;

    for k = 1:numSlices
        frameData = pfSeq.(sprintf('Item_%d', k));
        imagePositionPatient = frameData.PlanePositionSequence.Item_1.ImagePositionPatient; % [x, y, z]

        % Display the slice position
        fprintf('Slice %d Position (ImagePositionPatient): [%.2f, %.2f, %.2f]\n', ...
                k, imagePositionPatient(1), imagePositionPatient(2), imagePositionPatient(3));

        % Display the image type
        fprintf('Type: %s\n \n', ...
                frameData.MRImageFrameTypeSequence.Item_1.ComplexImageComponent  );
    end

    % Extract Image Position Patient (slice position)
    % slicePosition = metadata.ImagePositionPatient; % [x, y, z] coordinates

    % Display the slice position
    % disp('Slice Position (ImagePositionPatient):');
    % disp(slicePosition);

    % Optional: Handle multi-plane images
    % image_to_display = dicom_data;
    % 
    % size(image_to_display)
    % 
    % % Check if the image has more than 2 dimensions (i.e., it's multi-plane)
    % if ndims(dicom_data) > 2
    %     % Handle grayscale 3D images
    %     if size(dicom_data, 3) > 1 && size(dicom_data, 4) == 1
    %         image_to_display = squeeze(dicom_data(:,:,1));
    %     % Handle true 4D images
    %     elseif size(dicom_data, 4) > 1
    %         for i=1:size(dicom_data, 4)
    %             image_to_display = squeeze(dicom_data(:,:,1,i));
    %             % Display the image
    %             figure()
    %             imshow(image_to_display, []);
    %             pause(0.2)
    %         end
    %     end
    % end
end