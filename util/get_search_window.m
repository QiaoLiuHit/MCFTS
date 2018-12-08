function window_sz = get_search_window( target_sz, im_sz, padding)

    % For objects with large height, we restrict the search window with padding.height
    if target_sz(1)/target_sz(2)>2
        window_sz = floor(target_sz.*[1+padding.height, 1+padding.generic]);

    % For objects with large height and width and accounting for at least 10 percent of the whole image,
    % we only search 2x height and width
    elseif prod(target_sz)/prod(im_sz(1:2))>0.05
        window_sz=floor(target_sz*(1+padding.large));  
        
    %otherwise, we use the padding configuration    
    else        
        window_sz = floor(target_sz * (1 + padding.generic));
    end
    

end

