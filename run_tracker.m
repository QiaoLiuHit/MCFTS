function  [positions_8]=run_tracker(video)

addpath(genpath('./util'));
addpath(genpath('./sequences'));
addpath(genpath('./matconvnet1.08'));
addpath(genpath('./cnnnet'));
run('./matconvnet1.08/matlab/vl_setupnn.m')
pathModel = './cnnnet/vgg-verydeep-19.mat'; % please download this model
base_path='./sequences';
show_visualization = 1;

%initial target's state
[img_files, pos, target_sz]=load_video_info(base_path,video);

% extra area surrounding the target
padding = struct('generic', 1.5, 'large', 1, 'height', 0.4);
lambda = 1e-4;  %regularization
output_sigma_factor = 0.1;  %spatial bandwidth (proportional to target)
interp_factor = 0.01;  
cell_size = 4;
bSaveImage = 0;

[positions] = tracker_ensemble(img_files, pos, target_sz, ...
                                padding, lambda, output_sigma_factor, interp_factor, ...
                                cell_size, show_visualization, bSaveImage, pathModel);

%postions(y,x,h,w)
%vottir2015 bounding box
positions_8=[ positions(:,2)-1/2*positions(:,4),positions(:,1)+1/2*positions(:,3),positions(:,2)-1/2*positions(:,4),positions(:,1)-1/2*positions(:,3),positions(:,2)+1/2*positions(:,4),positions(:,1)-1/2*positions(:,3),...  
     positions(:,2)+1/2*positions(:,4),positions(:,1)+1/2*positions(:,3)];
 



