function index = adapt_thresh( axis_arr, window, skip_size )
%UNTITLED3 Summary of this function goes here
index = 0;
count = 0;
for i = 1:size(axis_arr,1)
    axis = axis_arr(i);
    if axis < skip_size % Discarding value having length less than skip_size
        continue
    end
    temp_count = 0;
    for j = 1:size(axis_arr,1)
        axis2 = axis_arr(j);
        %fprintf('check in diff: %d\n',abs(area - area2));
        if(abs(axis - axis2) < window)
            %fprintf('i = %d\n',i);
            temp_count = temp_count +1;
        end
    end
    if (temp_count > count)
        count = temp_count;
        index = i;
        %fprintf('i = %d\n',i);
    end
end

