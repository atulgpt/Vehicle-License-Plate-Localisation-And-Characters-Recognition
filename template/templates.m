clc
close all
warning('off','MATLAB:images:initSize:adjustingMag');

%% Filenames and paths
FILE_NAME = 'TEMPLATES.PNG'; % Name of the file conatining all alphabets
FILE_PATH = ''; % Place where file is saved
SAVE_PATH = ''; % Place where images will be stored
DISPLAY_ENABLE = 1; % will show the output in image window

%% Making the template for each characters
file_full_name = fullfile(FILE_PATH,FILE_NAME);
img = imread(file_full_name);
img_bw = im2bw(img);
if DISPLAY_ENABLE == 1
    imshow(img_bw)
end
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
    if DISPLAY_ENABLE == 1
        figure, imshow(img_char);
    end
    imwrite(img_char,[SAVE_PATH,num2str(j),'.jpg']);
end