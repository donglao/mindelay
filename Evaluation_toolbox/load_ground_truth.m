function [tracklets, num_obj, changetime, distime] = load_ground_truth(seq_idx)
addpath('KITTI_dir\devkit_tracking\devkit\matlab');
root_dir = 'KITTI_dir\data_tracking_image_2';
data_set = 'training';

% set camera
cam = 2; % 2 = left color camera

% show data for tracking sequences
nsequences = numel(dir(fullfile(root_dir,data_set, sprintf('image_%02d',cam))))-2;

% get sub-directories
image_dir = fullfile(root_dir,data_set, sprintf('image_%02d/%04d',cam, seq_idx));
label_dir = fullfile(root_dir,data_set, sprintf('label_%02d',cam));
calib_dir = fullfile(root_dir,data_set, 'calib');
P = readCalibration(calib_dir,seq_idx,cam);

% get number of images for this dataset
nimages = length(dir(fullfile(image_dir, '*.png')));

% load labels
tracklets = readLabels(label_dir, seq_idx);
num_obj = 0;
for i = 1:length(tracklets)
    if isempty(tracklets{i}) ~= 1
        for j = 1:length(tracklets{i})
            tracklets{i}(j).id = tracklets{i}(j).id + 1;
            num_obj = max(num_obj,tracklets{i}(j).id);
        end
    end
end
changetime = ones(1, num_obj)*length(tracklets);
distime = ones(1, num_obj);
for i = 1:length(tracklets)
    if isempty(tracklets{i}) ~= 1
        for j = 1:length(tracklets{i})
            if tracklets{i}(j).id>0
                changetime(tracklets{i}(j).id) = min(changetime(tracklets{i}(j).id), i);
                distime(tracklets{i}(j).id) = max(distime(tracklets{i}(j).id), i);
            end
        end
    end
end

end