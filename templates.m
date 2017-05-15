clc
close all
file_name = 'TEMPLATES.PNG';
%imshow(file_name);
img = imread(file_name);
img_bw = im2bw(img);
imshow(img_bw)
stats2 = regionprops(~img_bw);
    % show the image and draw the detected rectangles on it
    for j = 1:numel(stats2)
        rectangle('Position', stats2(j).BoundingBox, ...
        'Linewidth', 0.25, 'EdgeColor', 'r', 'LineStyle', '-');
    end
    
    flag =0;
    size_x = -1;
    size_y = -1;
    for j = 1:numel(stats2)
        boxDimen = stats2(j).BoundingBox;
        boxDimen = uint32(boxDimen);
        x0 = floor(boxDimen(1));
        y0 = floor(boxDimen(2));
        img_char = img_bw(y0 : y0 + boxDimen(4)-1, x0 : x0 + boxDimen(3)-1);
        if flag ~= 1
            size_x = size(img_char,1);
            size_y = size(img_char,2);
            flag = 1;
        end
        img_char = imresize(img_char,[size_x, size_y]);
        figure, imshow(img_char);
        %imwrite(img_char,'C:\User\atulgupta\Desktop\Fuzzy\test.jpg','jpg');
        imwrite(img_char,[num2str(j),'.jpg']);
        %break;
    end
    %close all;
    %clear all;