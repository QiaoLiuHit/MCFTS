function [scale_3]=Cal_scale(response)
 
    response(:,:,2)= response(:,:,2)*0.94;   %1.05 size
    response(:,:,3)= response(:,:,3)*0.94;   %0.95 size
    maxr=max(response(:));
  %  a=response(:,:,1); 
    b=response(:,:,2);
    c=response(:,:,3);
  %  max1=max(a(:));
    max2=max(b(:));
    max3= max(c(:));
    
    if max2==maxr
         scales=2;
    elseif max3==maxr
         scales=3;
    else 
         scales=1;
    end
    scale_3=scales;
end