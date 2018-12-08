function out = get_subwindow(im, pos, sz,scaling)
%GET_SUBWINDOW Obtain sub-window from image, with replication-padding.
%   Returns sub-window of image IM centered at POS ([y, x] coordinates),
%   with size SZ ([height, width]). If any pixels are outside of the image,
%   they will replicate the values at the borders.
%
%   Joao F. Henriques, 2014
%   http://www.isr.uc.pt/~henriques/

	if isscalar(sz),  %square sub-window
		sz = [sz, sz];
    end

    ys = floor(pos(1)) + (1:sz(1)) - floor(sz(1)/2);
	xs = floor(pos(2)) + (1:sz(2)) - floor(sz(2)/2);

	
	%check for out-of-bounds coordinates, and set them to the values at
	%the borders
	xs(xs < 1) = 1;
	ys(ys < 1) = 1;
	xs(xs > size(im,2)) = size(im,2);
	ys(ys > size(im,1)) = size(im,1);
	
	%extract image
    im_s1=cal_window(im,pos,sz,scaling);
    im_s2=cal_window(im,pos,sz,scaling*1.02);
    im_s3=cal_window(im,pos,sz,scaling*0.95);
    out=cat(4,im_s1,im_s2,im_s3);
	%out = im(ys, xs, :);

end

