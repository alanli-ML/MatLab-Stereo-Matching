function [Id] = stereo_disparity_best(Il, Ir, bbox)
% STEREO_DISPARITY_BEST Alternative stereo correspondence algorithm.
%
%  Id = STEREO_DISPARITY_BEST(Il, Ir, bbox) computes a stereo disparity image 
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

    left = int32(Il);
    right = int32(Ir);
    left_crop = left(bbox(2,1):bbox(2,2),bbox(1,1):bbox(1,2));
    right_crop = right(bbox(2,1):bbox(2,2),bbox(1,1):bbox(1,2));
    [h,w] = size(left_crop);
    
    num_disp = 64;
    num_iter = 10;
    rad= 2;
    %create bins for each pixel for 4 directions and a data bin
    %each bin has num_disp elements to keep track of label costs
    pixels = zeros(h,w,5,num_disp);
    
    
    %use SAD to get rough disparities
    for y=1+rad:h-rad
        for x=2+rad:w-rad
            for i=1:min(x+bbox(1,1)-rad-1,num_disp)
                pixels(y,x,5,i) = sad(left,right,y+bbox(2,1),x+bbox(1,1),i,rad);
            end
            pixels(y,x,5,:) = pixels(y,x,5,:)./norm(reshape(pixels(y,x,5,:),[num_disp,1]));
        end
    end
    
    %use markov random field and belief propagation to refine disparity
    for i=1:num_iter
        %propagate beliefs in 4 directions
        pixels=beliefPropagate(pixels,'r');
        pixels=beliefPropagate(pixels,'l');
        pixels=beliefPropagate(pixels,'u');
        pixels=beliefPropagate(pixels,'d');
        [energy,best] = getMAP(pixels);
        imshow(uint8(best)*4);
        disp(energy);
    end
    Id = best*4;
end

function [energy,best_pix]=getMAP(pixels)
    %get lowest cost label
    [height,width,box,labels] = size(pixels);
    best_pix = ones(height,width);
    for y=1:height
        for x=1:width
            [m,i] = min(sum(pixels(y,x,1:5,:),3));
            best_pix(y,x)=i;
        end
    end
    
    energy = 0;
    
    %calculate energy by summing lowest cost and smoothness cost wrt
    %neighbours
    for y=1:height
        for x=1:width
            cur_best = best_pix(y,x);
            energy = energy + pixels(y,x,5,cur_best);
            if x-1 > 0
                energy = energy + smoothCost(cur_best,best_pix(y,x-1));
            end
            if x+1 <= width
                energy = energy + smoothCost(cur_best,best_pix(y,x+1));
            end
            if y-1 > 0
                energy = energy + smoothCost(cur_best,best_pix(y-1,x));
            end
            if y+1 < height
                energy = energy + smoothCost(cur_best,best_pix(y+1,x));
            end

        end
    end
    
end

function cost=smoothCost(current,new)
    %truncated linear cost
    cost = 20*min(abs(current-new),2);
end