function er=sad(Il,Ir,y,x,disparity,kernel_w)
    num_pix = (2*kernel_w+1)^2;
    l = reshape(Il(y-kernel_w:y+kernel_w,x-kernel_w:x+kernel_w),[num_pix,1]);


    r = reshape(Ir(y-kernel_w:y+kernel_w,x-kernel_w-disparity:x+kernel_w-disparity),[num_pix,1]);
    %get pixelwise difference
    d = abs(l-r);
    %normalize by number of pixels
    er = sum(d)/num_pix;
end