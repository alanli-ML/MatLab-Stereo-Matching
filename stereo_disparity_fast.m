function [Id] = stereo_disparity_fast(Il, Ir, bbox)
% STEREO_DISPARITY_FAST Fast stereo correspondence algorithm.
%
%  Id = STEREO_DISPARITY_FAST(Il, Ir, bbox) computes a stereo disparity image
%  from left stereo image Il and right stereo image Ir.
%
%  Inputs:
%  -------
%   Il    - Left stereo image, m x n pixels, colour or greyscale.
%   Ir    - Right stereo image, m x n pixels, colour or greyscale.
%   bbox  - Bounding box, relative to left image, top left corner, bottom
%           right corner (inclusive). Width is v.
%
%  Outputs:
%  --------
%   Id  - Disparity image (map), m x v pixels, greyscale.


    %convert images to int
    left = int32(Il);
    right = int32(Ir);
    %crop to bounding boxes
    left_crop = left(bbox(2,1):bbox(2,2),bbox(1,1):bbox(1,2));
    right_crop = right(bbox(2,1):bbox(2,2),bbox(1,1):bbox(1,2));
    
    max_disparity = 64;
    kernel_size = 5;
    kernel_w = floor(kernel_size/2);
    [h,w] = size(left_crop);
    dispMap = zeros(h,w);
    costs = zeros(1,max_disparity);
    
    
    %iterate over y and x
    for y=1:h
        for x=1:w
            for disparity=1:min(max_disparity,x+bbox(1,1)-kernel_w-1)
                %get SAD error for line of patches
                costs(disparity) = sad(left,right,y+bbox(2,1),x+bbox(1,1),disparity,kernel_w);
            end
            %get min cost
            [m,i] = min(costs);
            dispMap(y,x)=i;%round(dot(costs,1:max_disparity));
        end
    end
    %crop to bounding box
    %scale to ground truth range
    Id = uint8(dispMap*4);
    
end