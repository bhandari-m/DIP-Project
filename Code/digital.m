businessCard = imread('bill3.jpg');
ocrResults = ocr(businessCard);
bboxes = locateText(ocrResults, 'IIIT', 'IgnoreCase', true);
Iocr = insertShape(businessCard, 'FilledRectangle', bboxes);

f_id = fopen('Result.txt','w');

l = size(ocrResults.Words);
for i = 1:l-2
    a=ocrResults.Words(i);
    a=cell2mat(a);
    a=mat2str(a);
    a=a(:,2:size(a,2)-1);
    b=strcmp(a,'Receipt');
    c=strcmp(a,'Date:');
    d=strcmp(a,'Name:');
  
    if b==1
        RecNum_data = ocrResults.Words(i+2);
        RecNum_data=cell2mat(RecNum_data);
        fprintf(f_id, 'Receipt No. : %s \n',RecNum_data);
    elseif c==1
        Date_data = ocrResults.Words(i+1);
        Date_data=cell2mat(Date_data);
        fprintf(f_id, 'Date : %s \n',Date_data);
    elseif d==1
        Name_data = ocrResults.Words(i+1);
        Name_data=cell2mat(Name_data);
        fprintf(f_id, 'Name : %s \n',Name_data);
    end
end

bnw=rgb2gray(businessCard);
I = edge(bnw, 'canny');

[H,T,R] = hough(I);
P = houghpeaks(H, 17);

theta = T(P(:,2));
rho = R(P(:,1));

limit = R(1);
x = zeros([100 2]);
l=1;j=91;
for i = 1:size(H,1)
    if(H(i,j) >= 1/5*(size(I,1)));
        x(l,1)=i+limit;
        x(l,2)=j;
        l=l+1;
    end
end

xfinal = zeros([100 2]);
xfinal_count = 1;
i = 1;
while (i < size(x,1))
    avg = x(i);
    count = 1;
    for j=i+1:size(x,1)
        if abs(x(j)-avg) < 10
            avg = avg + x(j);
            count = count + 1;
        else
            break;
        end
    end
    xfinal(xfinal_count, 1) = avg/count;
    xfinal(xfinal_count, 2) = x(i, 2);
    xfinal_count = xfinal_count + 1;
    i = i+count;
end

xfinal = uint64(xfinal);
items = [];

wordBBoxes = ocrResults.WordBoundingBoxes;
words = ocrResults.Words;
item_idx = -1;

for i=1:size(words)
    if strcmp(words(i), 'Item')
        item_idx = i;
    end
end


table_min_y = wordBBoxes(item_idx, 2);
table_max_y = -100;

for i=1:length(H(:,180))
    if H(i,180) > 100
        table_max_y = i+limit;
    end
end

table_entries_id = zeros(200);
entries = 0;

col_number = find(xfinal(:,1), 1, 'last');

% First Column
for i=1:size(wordBBoxes)
    if xfinal(1,1) < wordBBoxes(i,1) && wordBBoxes(i,1)  + wordBBoxes(i,3) < xfinal(col_number,1) ...
            && wordBBoxes(i,2) > table_min_y && wordBBoxes(i,2) + wordBBoxes(i,4) < table_max_y 
       entries = entries + 1;
       table_entries_id(entries) = i;
    end
end

for i=1:entries
    entry=cell2mat(words(table_entries_id(i)));
    entry=mat2str(entry);
    entry=entry(:,2:size(entry,2)-1);
    fprintf(f_id, '%s \n',entry);
end
fclose(f_id);
