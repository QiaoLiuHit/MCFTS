function x = get_features_gray(im, cos_window)
%GET_FEATURES
%   Extracts dense features from image.
%
%   X = GET_FEATURES(IM, FEATURES, CELL_SIZE)
%   Extracts features specified in struct FEATURES, from image IM. The
%   features should be densely sampled, in cells or intervals of CELL_SIZE.
%   The output has size [height in cells, width in cells, features].
%
%   To specify HOG features, set field 'hog' to true, and
%   'hog_orientations' to the number of bins.
%
%   To experiment with other features simply add them to this function
%   and include any needed parameters in the FEATURES struct. To allow
%   combinations of features, stack them with x = cat(3, x, new_feat).
%
%   Joao F. Henriques, 2014
%   http://www.isr.uc.pt/~henriques/

    sz_window=size(cos_window);
	%gray-level (scalar feature)
	x = single(im) / 255;
		
	x = x - mean(x(:));
    x = imResample(x, sz_window(1:2));
	
	%process with cosine window if needed
	if ~isempty(cos_window),
		x = bsxfun(@times, x, cos_window);
	end
	
end
