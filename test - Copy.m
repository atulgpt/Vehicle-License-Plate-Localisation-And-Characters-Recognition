close all
clc
clear all

%% Different threshold and system dependent configs
AREA_THRES = 3000;
AREA_CHAR_THRES = [200, 10000]; %min and max threshold fixed values
RESTRICTED_CHAR = ['d']; %These restricted charcters need not to be printed
CHAR_LEN_WINDOW = 20; %window for adaptive threshold
CHAR_SKIP_LEN = 50; %character having less than 10 pixels length is discarded in adapt_thresh
image_names = ls;
sample_size = 3;
%sample_size = size(image_names,1);
DEBUG = 1; %Will generate many intermediate figures
SHOW_ORIGINAL = 0; % If 1 then original image will be displayed, Overrides DEBUG

%% Loading the image templates and list for the image's name
%templateObj = matfile('templates_folder/temp');
%TEMPLATE_FOLDER = 'templates_folder';
load('temp');
templateObj = matfile('temp');
templateStruct = whos(templateObj);
template_list = {templateStruct.name};
%template_list = 
size_x = size(eval(template_list{1}),1); % Getting the dimension for the template image, X size
size_y = size(eval(template_list{1}),2);


%% Processing the image
for i =1:sample_size-2
    %img_name = image_names(i+2,:)
    %img_name = 'dataset/60.jpg';
    %img_name = '60.jpg';
    img_name = '5.jpg';
    %img_name = '55.jpg';
    img = imread(img_name);
    img = im2double(img);
    img_red = img(:,:,1);
    img_blue = img(:,:,2);
    img_green = img(:,:,3);
    img_grey = 0.114*img_red + 0.587*img_green + 0.299*img_blue;
    if (DEBUG == 1) || (SHOW_ORIGINAL == 1)
        figure,imshow(img_grey)
        title('Original');
    end
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
    img_dilated2 = bwareaopen(img_dilated,1000,8);
    % figure, imshow(img_dilated2);
    img_filled = imfill(img_dilated2,'holes');
    img_filled = imerode(img_filled,ones(7));
    img_filled = imdilate(img_filled,ones(7));
    if DEBUG == 1
        figure, imshow(img_filled);
        title('image filled');
    end
    %size(padarray(zeros(size(img_filled) -200),[100 100],1))
    img_filled = img_filled + padarray(zeros(size(img_filled) -100),[50 50],1);
    if DEBUG == 1
        figure, imshow(img_filled);
        title('Image filled');
    end
    img_clearborder = imclearborder(img_filled,ones(3));
    if DEBUG == 1
        figure, imshow(img_clearborder);
        title('border clear');
    end
    
    %img_largest = bwareafilt(img_clearborder,1,'largest');
    img_largest = img_clearborder;
    %figure,imshow(img_grey.*img_largest);
    %break;
    
    %figure, imshow(img_largest);
    img_largest = bwareaopen(img_largest,1000,8);
    if DEBUG == 1
        figure, imshow(img_largest);
        title('Clear areas below 1000 pixels');
    end
    [B, L] = bwboundaries(img_largest,'noholes');
    stats1 = regionprops(L, 'all');
    
    temp = zeros(size(L));
    selected_regions = 0;
    selected_index = [];
    for j = 1 : numel(stats1)
        %j
        %figure, imshow(stats1(j).Image);
        if (stats1(j).Extent) > 0.80 && (stats1(j).Area > AREA_THRES)
            temp = temp + (L == j);
            selected_regions = selected_regions + 1;
            selected_index = [selected_index, j];
        end
    end
    
    if selected_regions == 1
        license_coordinates = uint16(stats1(selected_index(1)).BoundingBox);
        temp = stats1(selected_index(1)).Image;
        img_final = img_grey(license_coordinates(2):license_coordinates(2) + license_coordinates(4)-1,license_coordinates(1):license_coordinates(1) + license_coordinates(3)-1) .* logical(temp);
    else
        img_final = img_grey.* logical(temp);
    end
    if DEBUG == 1
        figure, imshow(temp);
        title('Slection area based on rectangility and area');
    end
    %figure , imshow(img_final);
    if DEBUG == 1
        figure,imshow(img_final);
        title('License image final');
    end
    bw = im2bw(img_final,graythresh(img_final));
    bw = imdilate(bw,[1,1]);
    %graythresh(img_final)
    if DEBUG == 1
        figure,imshow(bw);
        title('License image final in balck and white');
    end
    %Dilating to make license plate separate from the background
    %bw = imclose(bw,[1,1,1;1,1,1;1,1,1]);
    if DEBUG == 1
        figure, imshow(bw);
        title('Closed to separte license from background');
    end
    %bw = bw(100 : size(bw,1) - 100, 100 : size(bw,2) - 100);
    bw = impyramid(bw,'expand');
    bw = impyramid(bw,'expand');
    bw = ~bwareaopen(~bw,100,8); %removing set containing less than 100 pts in inverted image
    % find both black and white regions
    stats2 = regionprops(not(bw),'all');
    % show the image and draw the detected rectangles on it
    if DEBUG == 1
        figure, imshow(not(bw));
        title('This is used for stats2 geneartion');
    end
    
% find both black and white regions
    length = numel(stats2);
    for j = 1:numel(stats2)
        rectangle('Position', stats2(i).BoundingBox, ...
        'Linewidth', 1, 'EdgeColor', 'r', 'LineStyle', '-');
    end
    
    %% Matching with the template
    finalAns = '';
    % array of length
    length_array = zeros(numel(stats2),1);
    for j = 1:numel(stats2)
        length_array(j) = stats2(j).BoundingBox(4);
    end
    length_mean_index = adapt_thresh(length_array, CHAR_LEN_WINDOW, CHAR_SKIP_LEN);
    for j = 1:numel(stats2)
        
        if stats2(j).Area > AREA_CHAR_THRES(2) || stats2(j).Area < AREA_CHAR_THRES(1)
            j1 = j
            continue;
        end
        if abs(stats2(j).BoundingBox(4) - stats2(length_mean_index).BoundingBox(4)) > 2*CHAR_LEN_WINDOW
            j2 = j
            continue;
        end
        boxDimen = stats2(j).BoundingBox;
        boxDimen = uint32(boxDimen);
        x0 = floor(boxDimen(1));
        y0 = floor(boxDimen(2));
        %figure, imshow(stats2(j).Image);
        %figure, imshow(stats2(j).FilledImage);
        img_char = bw(y0 : y0 + boxDimen(4)-1, x0 : x0 + boxDimen(3)-1);
        %img_char = stats2(j).Image;
        figure, imshow(img_char);
        img_char = imresize(img_char,[size_x,size_y]);
        figure, imshow(img_char);
        tempCorr = -1;
        tempFile = '';
        for k = 1:size(template_list,2)
            corr = corr2(img_char, eval(template_list{k}));
            %corrb = sum(sum(abs(img_char - logical(eval(template_list{k})))));
            %corr = corra/corrb;
            template_list{k}(end);
            corr;
            if corr > tempCorr
                tempCorr = corr;
                tempFile = template_list(k);
            end
        end
        if(ismember(RESTRICTED_CHAR,tempFile{1}(end)))
            'escaped'
            continue
        end
        finalAns = strcat(finalAns,tempFile{1}(end));
    end
    %clc
    fprintf('License Plate Detected: %s\n',finalAns)  % Final Answer
end
%close all