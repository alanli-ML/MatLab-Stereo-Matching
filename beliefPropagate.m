function pixels=beliefPropagate(pixels, direction)
    [height,width,n,num_labels] = size(pixels);

     %propagate beliefs in specified direction
    if direction == 'l'
        for y = 1:height
            for x = width:-1:2
               pixels=sendMessage(pixels, x, y, direction); 
            end
        end
    elseif direction == 'r'
        for y = 1:height
            for x = 1:width-1
               pixels=sendMessage(pixels, x, y, direction); 
            end
        end
    elseif direction == 'u'
        for x = 1:width
            for y = height:2
               pixels=sendMessage(pixels, x, y, direction); 
            end
        end 
    elseif direction == 'd'
        for x = 1:width
            for y = 1:height-1
               pixels=sendMessage(pixels, x, y, direction); 
            end
        end
    end
                
end

function pixels=sendMessage(pixels, x, y , direction)
    %find min cost for given pixel 
    [height,width,box,labels] = size(pixels);
    
    %message is min cost
    min_val = zeros(labels,1);
    label_costs = zeros(labels,1);

    %calculate beliefs of neighbours for label j
    for j=1:labels
        %add up costs at given label
        label_costs(j) = 0;
        
        label_costs(j) = label_costs(j) + sum(pixels(y,x,:,j));
        %ignore neighbour in direction we're propagating
        if direction == 'l'
            label_costs(j) = label_costs(j) - pixels(y,x,1,j);
        elseif direction == 'r'
            label_costs(j) = label_costs(j) - pixels(y,x,2,j);
        elseif direction == 'u'
            label_costs(j) = label_costs(j) - pixels(y,x,3,j);
        elseif direction == 'd'
            label_costs(j) = label_costs(j) - pixels(y,x,4,j);
        end
    end
    
    %calculate belief that pixel y,x is label i
    for i=1:labels
        min_val(i) = 999999999999;
        for j=1:labels
            %
            p = label_costs(j) + smoothCost(i,j);
                        
            min_val(i) = min(min_val(i),p);
            
        end
    end
    %normalize message
    min_val = 5*min_val./norm(min_val);
    %send message
    if direction == 'l'
        pixels(y,x-1,2,:) = min_val;
    elseif direction == 'r'
        pixels(y,x+1,1,:) = min_val;
    elseif direction == 'u'
        pixels(y-1,x,4,:) = min_val;
    elseif direction == 'd'
        pixels(y+1,x,3,:) = min_val;
    end
end



function cost=smoothCost(current,new)
    cost = 10*min(abs(current-new),2);
end
