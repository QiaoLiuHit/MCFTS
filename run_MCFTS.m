
%error('Note: you need  to compile the Matconvnet according to Readme.txt, and then comment the FIRST line in run_HDT.m')
function  [positions_8]=run_MCFTS()
addpath(genpath('E:\VOT\vottirworkspace2016\Trackers\MCFTS'))
run('E:\VOT\vottirworkspace2016\Trackers\MCFTS/matconvnet1.08/matlab/vl_setupnn.m')
pathModel = 'E:\VOT\vottirworkspace2016\Trackers\MCFTS\cnnnet/vgg-verydeep-19.mat';

show_visualization = 1;

load region.txt;
fid=fopen('images.txt');
filename=textscan(fid,'%s');
img_files = filename{1};
fclose(fid);
[pos, target_sz]=initialize_region(region);

%load region.txt and images.txt end
e=mod(floor(target_sz),2);
if e(2)==1
    target_sz(2)=target_sz(2)+1;
end
if e(1)==1
    target_sz(1)=target_sz(1)+1;
end

% extra area surrounding the target
padding = struct('generic', 1.5, 'large', 1, 'height', 0.4);

lambda = 1e-4;  %regularization
output_sigma_factor = 0.1;  %spatial bandwidth (proportional to target)
interp_factor = 0.01;  
cell_size = 4;
bSaveImage = 0;

[positions] = tracker_ensemble1(img_files, pos, target_sz, ...
                                padding, lambda, output_sigma_factor, interp_factor, ...
                                cell_size, show_visualization, bSaveImage, pathModel);

%postions(y,x,h,w)
 positions_8=[ positions(:,2)-1/2*positions(:,4),positions(:,1)+1/2*positions(:,3),positions(:,2)-1/2*positions(:,4),positions(:,1)-1/2*positions(:,3),positions(:,2)+1/2*positions(:,4),positions(:,1)-1/2*positions(:,3),...  
     positions(:,2)+1/2*positions(:,4),positions(:,1)+1/2*positions(:,3)];
 
% save results
% rects = [positions(:,2) - target_sz(2)/2, positions(:,1) - target_sz(1)/2];
% rects(:,3) = target_sz(2);
% rects(:,4) = target_sz(1);
% res.type = 'rect';
% res.res = rects;
% results=res;


