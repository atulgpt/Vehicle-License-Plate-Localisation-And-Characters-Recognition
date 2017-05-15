close all
clc
%cd dataset;
%temp = ls;
sample_size = 3;
%sample_size = size(temp,1);
DEBUG = 1;
for i =1:sample_size-2
    %img_name = temp(i+2,:);
    %img_name = 'dataset/60.jpg';
    img_name = '89.jpg';
    %imshow(img_name);
    hold on
    img = imread(img_name);
    img = im2double(img);
    img_red = img(:,:,1);
    img_blue = img(:,:,2);
    img_green = img(:,:,3);
    img_grey = 0.114*img_red + 0.587*img_green + 0.299*img_blue;
    figure,imshow(img_grey)
    img_edge = edge(img_grey);
    if DEBUG == 1
        figure, imshow(img_edge);
        title('Edge');
    end
    img_dilated = imdilate(img_edge,[1;1]);
    img_dilated = imdilate(img_dilated,[1,1]);
    if DEBUG == 1
        figure, imshow(img_dilated);
        title('Dilated: Vert & Horz');
    end
    %figure, imshow(img_dilated);
    img_dilated2 = bwareaopen(img_dilated,500,8);
    % figure, imshow(img_dilated2);
    img_filled = imfill(img_dilated2,'holes');
    img_filled = imerode(img_filled,ones(7));
    img_filled = imdilate(img_filled,ones(7));
    if DEBUG == 1
        figure, imshow(img_filled);
        title('image filled');
    end
    conn_matrix = ones(3);
    %size(padarray(zeros(size(img_filled) -200),[100 100],1))
    img_filled = img_filled + padarray(zeros(size(img_filled) -100),[50 50],1);
    figure, imshow(img_filled);
    img_clearborder = imclearborder(img_filled,conn_matrix);
    if DEBUG == 1
        figure, imshow(img_clearborder);
        title('border clear');
    end
    
    figure, imshow(img_clearborder);
    %img_largest = bwareafilt(img_clearborder,1,'largest');
    img_largest = img_clearborder;
    if DEBUG == 1
        figure, imshow(img_largest);
        title('largest selected');
    end
    figure,imshow(img_grey.*img_largest);
    title('Final Image');
    break;
end
close all
figure, imshow(img_largest);
img_largest = bwareaopen(img_largest,500,8);
figure, imshow(img_largest);
[B L] = bwboundaries(img_largest,'noholes');
stats = regionprops(L, 'all');

temp = zeros(size(L));
for i = 1 : length(stats)
    if (stats(i).Extent) > 0.80
        temp = temp + (L == i);
    end
end
close all
img_final = img_grey .* logical(temp);


figure,imshow(img_final);

bw = im2bw(img_final);
bw = bw(100 : size(bw,1) - 100, 100 : size(bw,2) - 100);
bw = impyramid(bw,'expand');
bw = impyramid(bw,'expand');
% find both black and white regions
stats = [regionprops(not(bw))];
% show the image and draw the detected rectangles on it
imshow(bw); 
hold on;
for i = 1:numel(stats)
    rectangle('Position', stats(i).BoundingBox, ...
    'Linewidth', 0.25, 'EdgeColor', 'r', 'LineStyle', '-');
end