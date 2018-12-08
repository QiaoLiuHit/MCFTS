function [positions] = tracker_ensemble(img_files, pos, target_sz, ...
                                                padding, lambda, output_sigma_factor, interp_factor, ...
                                                cell_size, show_visualization, bSaveImage, pathModel)

fprintf('Network initial...\n');
initial_net(pathModel);
nlayers = [37, 34, 32, 28, 25, 23];%37, 34, 32, 28, 25, 23
A = 0.011; % relaxed factor
im_sz = size(imread(img_files{1}));
window_sz = get_search_window(target_sz,im_sz, padding);
output_sigma = sqrt(prod(target_sz)) * output_sigma_factor / cell_size;
base_target_sz=target_sz;
% Create regression labels, gaussian shaped, with a bandwidth
% proportional to target size
l1_patch_num = floor(window_sz / cell_size);
yf = fft2(gaussian_shaped_labels(output_sigma, l1_patch_num));

% Store pre-computed cosine window
cos_window = hann(size(yf,1)) * hann(size(yf, 2))';

if show_visualization
    update_visualization = show_video(img_files,'');
end


% Variables ending with 'f' are in the Fourier domain.
positions  = zeros(numel(img_files), 4); % (y,x,h,w)

alphaf = cell(1,length(nlayers));
model_xf = cell(1,length(nlayers));
model_alphaf = cell(1,length(nlayers));

response1=cell(1,length(nlayers));
response2=cell(1,length(nlayers));
response3=cell(1,length(nlayers));

response_new1=cell(1,sum(length(nlayers)-1));
response_new2=cell(1,sum(length(nlayers)-1));
response_new3=cell(1,sum(length(nlayers)-1));         

%scale variation parameters
scale_3=1;
scaling=1;

fprintf('Start tracking...\n');
for frame = 1:numel(img_files),  
    im = imread(img_files{frame});
    if ismatrix(im),
        im = cat(3, im, im, im);
    end
    if frame >1
        % Obtain a subwindow for detection at the position from last
        % frame, and convert to Fourier domain (its size is unchanged)
     
        patch = get_subwindow(im, pos, window_sz,scaling);
        %
         feat1   = get_features(patch(:,:,:,1), cos_window, nlayers);        
         feat2  = get_features(patch(:,:,:,2), cos_window, nlayers);
         feat3   = get_features(patch(:,:,:,3), cos_window, nlayers);
        [m,n,~]=size(feat1{1});    
        for aa=1:length(nlayers)
            response1{aa}=gpuArray(zeros(m,n));
            response2{aa}=gpuArray(zeros(m,n));
            response3{aa}=gpuArray(zeros(m,n));
        end
        
        % get 3 different scale factor's responses of the weak trackers 
        for ii = 1:length(nlayers)%the first scale window's response      
            zf1   = fft2(gpuArray(feat1{ii}));
            kzf1 = sum(zf1 .* conj(gpuArray(model_xf{ii})), 3) / numel(zf1);
            response1{ii} = real(fftshift(ifft2(gpuArray(model_alphaf{ii}) .* kzf1)));  % weak trackers
        end  

        for ii = 1:length(nlayers) %the second scale window's response                
            zf2   = fft2(gpuArray(feat2{ii}));
            kzf2 = sum(zf2 .* conj(gpuArray(model_xf{ii})), 3) / numel(zf2);
            response2{ii} = real(fftshift(ifft2(gpuArray(model_alphaf{ii}) .* kzf2)));  % weak trackers
        end
        
        for ii = 1:length(nlayers)    %the third scale window's response              
            zf3   = fft2(gpuArray(feat3{ii}));
            kzf3 = sum(zf3 .* conj(gpuArray(model_xf{ii})), 3) / numel(zf3);
            response3{ii} = real(fftshift(ifft2(gpuArray(model_alphaf{ii}) .* kzf3)));  % weak trackers
        end
  
        % storage allocation for new responses
         for bb=1:sum(length(nlayers)-1)
             response_new1{bb}=gpuArray(zeros(size(response1{1})));
             response_new2{bb}=gpuArray(zeros(size(response2{1})));
             response_new3{bb}=gpuArray(zeros(size(response3{1})));
         end

        %filter noise and using KL fusion to get final response
        response_final1=gpuArray(zeros(size(response1{1})));
        nn=1;
        for jj = 1:length(nlayers)-1
            for kk=jj+1:length(nlayers)      
                response_new1{nn}=response1{jj}.*response1{kk};
                response_final1=response_final1+response_new1{nn};
                nn=nn+1;
            end
        end
        
        %filter noise and using KL fusion to get final response
        response_final2=gpuArray(zeros(size(response2{1})));
        nn=1;
        for jj = 1:length(nlayers)-1
            for kk=jj+1:length(nlayers)      
                response_new2{nn}=response2{jj}.*response2{kk};
                response_final2=response_final2+response_new2{nn};
                nn=nn+1;
            end
        end
          
        %filter noise and using KL fusion to get final response
        response_final3=gpuArray(zeros(size(response3{1})));
        nn=1;
        for jj = 1:length(nlayers)-1
            for kk=jj+1:length(nlayers)      
                response_new3{nn}=response3{jj}.*response3{kk};
                response_final3=response_final3+response_new3{nn};
                nn=nn+1;
            end
        end
        
        % concat three scale's responses 
        response_3=cat(4,response_final1, response_final2, response_final3);
        response_3=gather(response_3);
        % calculate the best scale situation
        scale_3=Cal_scale(response_3);
        response_final=response_3(:,:,scale_3);
        if scale_3==2
            scaling=scaling*1.02;
        elseif scale_3==3
            scaling=scaling*0.95;
        end
        maxres   = max(response_final(:));
        [row,col]    = find(response_final==maxres,1);
        vert_delta = row; horiz_delta = col;
        vert_delta = vert_delta - floor(size(zf1,1)/2);
        horiz_delta = horiz_delta - floor(size(zf1,2)/2);  
        pos = pos + cell_size * [vert_delta - 1, horiz_delta - 1]*scaling;
    end
    
    % Obtain a subwindow for training at newly estimated target position  
    patch = get_subwindow(im, pos, window_sz,scaling);
    feat = get_features(patch(:,:,:,scale_3), cos_window, nlayers);
    
    % Fast training with new observations
    for ii = 1:length(nlayers)
        xf{ii} = fft2(feat{ii});
        kf = sum(xf{ii} .* conj(xf{ii}), 3) / numel(xf{ii});
        alphaf{ii} = yf./ (kf + lambda);
    end
    
    if frame == 1,  % First frame, train with a single image
        for ii=1:length(nlayers)
            model_alphaf{ii} = alphaf{ii};
            model_xf{ii} = xf{ii};
        end      
    else % Update trackers
        for ii = 1:length(nlayers)
            model_alphaf{ii} = (1 - interp_factor) * model_alphaf{ii} + interp_factor * alphaf{ii};
            model_xf{ii} = (1 - interp_factor) * model_xf{ii} + interp_factor * xf{ii};
        end
        
    end
    
    % Save position and timing
    target_sz=scaling*base_target_sz;
    positions(frame,:) = [pos target_sz];
    % time=time+toc();
    
    % Visualization
    if show_visualization    
        box = [pos([2,1]) - target_sz([2,1])/2,target_sz([2,1])]; 
        stop = update_visualization(frame, box);
        if stop, break, end  % User pressed Esc, stop early
        drawnow
        if bSaveImage
            imwrite(frame2im(getframe(gcf)), ['./result/' num2str(frame) '.jpg']);
        end
    end
end
close all
end
