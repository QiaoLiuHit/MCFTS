% this function calculates the scaling image patch cetered by pos
function [im_s1]=cal_window(im,pos,sz_ori,scaling)
    
    sz=floor(sz_ori*scaling);
    ww_s=(1:sz(2)) - floor(sz(2)/2);
    hh_s=(1:sz(1)) - floor(sz(1)/2);   
    xs_s = floor(pos(2)) + ww_s;
	ys_s = floor(pos(1)) + hh_s;
    
    xs_s(xs_s < 1) = 1;
	ys_s(ys_s < 1) = 1;
    xs_s(xs_s > size(im,2)) = size(im,2);
	ys_s(ys_s > size(im,1)) = size(im,1);
    im_s1=im(ys_s,xs_s,:);
    im_s1=imresize(im_s1,sz_ori);
    
end