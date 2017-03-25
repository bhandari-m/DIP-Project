I = imread('bill3.jpg');
I = imrotate(I,-90);
III=I;
%I = domi(I);
%I = imdilate(I,strel('diamond',2));
I=rgb2gray(I);
[mserRegions, mserConnComp] = detectMSERFeatures(I, ...
    'RegionAreaRange',[40 800],'ThresholdDelta',4);

% figure, imshow(I)
% hold on
% plot(mserRegions, 'showPixelList', true,'showEllipses',false)
% title('MSER regions')
% hold off

mserStats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...
    'Solidity', 'Extent', 'Euler', 'Image');

bboxes = vertcat(mserStats.BoundingBox);
xmin = bboxes(:,1);
ymin = bboxes(:,2);
xmax = xmin + bboxes(:,3) - 1;
ymax = ymin + bboxes(:,4) - 1;

expansionAmount = 0.02;
xmin = (1-expansionAmount) * xmin;
% ymin = (1-expansionAmount) * ymin;
xmax = (1+expansionAmount) * xmax;
% ymax = (1+expansionAmount) * ymax;

xmin = max(xmin, 1);
ymin = max(ymin, 1);
xmax = min(xmax, size(I,2));
ymax = min(ymax, size(I,1));

exbox = [xmin ymin xmax-xmin+1 ymax-ymin+1];
%Boxes = insertShape(I, 'Rectangle', exbox, 'LineWidth' , 3);


overlapRatio = bboxOverlapRatio(exbox, exbox);

n = size(overlapRatio,1);
overlapRatio(1:n+1:n^2) = 0;

g = graph(overlapRatio);

componentIndices = conncomp(g);

xmin = accumarray(componentIndices', xmin, [], @min);
ymin = accumarray(componentIndices', ymin, [], @min);
xmax = accumarray(componentIndices', xmax, [], @max);
ymax = accumarray(componentIndices', ymax, [], @max);

tbx = [xmin ymin xmax-xmin+1 ymax-ymin+1];

%Iexbox = insertShape(I,'Rectangle',exbox,'LineWidth',3);

numRegionsInGroup = histcounts(componentIndices);
tbx(numRegionsInGroup == 1, :) = [];

%ITextRegion = insertShape(I, 'Rectangle', tbx,'LineWidth',3);
Boxes = insertShape(I, 'Rectangle', tbx, 'LineWidth' , 3);

%figure;
imshow(Boxes)
title('Detected Text')
IM={};
for i=1:size(tbx)
    IM{i}=I(floor(tbx(i,2)):floor(tbx(i,2)+tbx(i,4)),floor(tbx(i,1)):floor(tbx(i,1)+tbx(i,3)));
end
o = ocr(I, tbx);
