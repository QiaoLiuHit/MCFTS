function update_visualization_func = show_video(img_files, video_path, resize_image)
%SHOW_VIDEO
%   Visualizes a tracker in an interactive figure, given a cell array of
%   image file names, their path, and whether to resize the images to
%   half size or not.
%
%   This function returns an UPDATE_VISUALIZATION function handle, that
%   can be called with a frame number and a bounding box [x, y, width,
%   height], as soon as the results for a new frame have been calculated.
%   This way, your results are shown in real-time, but they are also
%   remembered so you can navigate and inspect the video afterwards.
%   Press 'Esc' to send a stop signal (returned by UPDATE_VISUALIZATION).
%
%   Joao F. Henriques, 2014
%   http://www.isr.uc.pt/~henriques/


	%store one instance per frame
	num_frames = numel(img_files);
	boxes = cell(num_frames,1);

	%create window
	[fig_h, axes_h, unused, scroll] = videofig(num_frames, @redraw, [], [], @on_key_press);  %#ok, unused outputs
	set(fig_h, 'Name', ['Tracker - MCFTS' video_path])
	axis off;
	
	%image and rectangle handles start empty, they are initialized later
	im_h = [];
	rect_h = [];
	text_h=[];
    refbox=[];
    ref_h=[];
	update_visualization_func = @update_visualization;
	stop_tracker = false;
	

	function stop = update_visualization(frame, box)
		%store the tracker instance for one frame, and show it. returns
		%true if processing should stop (user pressed 'Esc').
        if iscell(box)
            refbox=box;
            for i=1:length(box)
                boxes{frame} = box{end};
                scroll(frame);
            end
        else
            boxes{frame} = box;
                scroll(frame);
        end
        
		stop = stop_tracker;
	end

	function redraw(frame)
        brushstyle={   struct('color',[1,1,0],'lineStyle',':'),...%yellow
    struct('color',[1,0,1],'lineStyle','-.'),...%pink
    struct('color',[0,1,1],'lineStyle','-.'),...
    struct('color',[136,0,21]/255,'lineStyle','-.'),...%dark red
    struct('color',[255,127,39]/255,'lineStyle','-.'),...%orange
    struct('color',[0,162,232]/255,'lineStyle','-.'),...%Turquoise
    struct('color',[163,73,164]/255,'lineStyle','-.')};%purple
		%render main image
		im = imread([video_path img_files{frame}]);
        
		if isempty(im_h),  %create image
			im_h = imshow(im, 'Border','tight', 'InitialMag',200, 'Parent',axes_h);
		else  %just update it
			set(im_h, 'CData', im)
        end
       
        
		     
        
		%render target bounding box for this frame
		if isempty(rect_h),  %create it for the first time
			rect_h = rectangle('Position',[0,0,1,1], 'LineWidth',1,'EdgeColor','g', 'Parent',axes_h);
        end
        if ~isempty(refbox)
            if isempty(ref_h)
                delete(rect_h);
               for i=1:length(refbox)-1
                  ref_h(i)= rectangle('Position',[0,0,1,1], 'LineWidth',1,'EdgeColor',brushstyle{i}.color, 'Parent',axes_h);
               end
               rect_h = rectangle('Position',[0,0,1,1], 'LineWidth',1,'EdgeColor','r', 'Parent',axes_h);
            end
        end
		if ~isempty(boxes{frame}),
            hold on
			
            if ~isempty(refbox)
               for i=1:length(refbox)-1
                  set(ref_h(i), 'Visible', 'on', 'Position', refbox{i});
               end
            end
            set(rect_h, 'Visible', 'on', 'Position', boxes{frame});
            delete(text_h);
            text_h=text(10,10,num2str(frame),'color','yellow','FontSize',20,'FontWeight','bold','Parent',axes_h);   
		else
			set(rect_h, 'Visible', 'off');
            set(text_h, 'Visible', 'off');
		end
	end

	function on_key_press(key)
		if strcmp(key, 'escape'),  %stop on 'Esc'
			stop_tracker = true;
		end
	end

end

