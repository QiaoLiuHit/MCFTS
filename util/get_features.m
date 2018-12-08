function feat = get_features(im, cos_window, layers)
%GET_FEATURES
%   Extracts dense features from image.


global net

sz_window=size(cos_window);

img = single(im); % note: 255 range
img = imResample(img, net.normalization.imageSize(1:2));
img = img - net.normalization.averageImage;
img = gpuArray(img);

% run the CNN
res=vl_simplenn(net,img);

feat={};

for ii=1:length(layers)
    
    x=gather(res(layers(ii)).x);
    
    x = imResample(x, sz_window(1:2));
    
    
    %process with cosine window if needed
    if ~isempty(cos_window),
        x = bsxfun(@times, x, cos_window);
    end
    
    feat{ii}=x;
    
end
end
