I=imread('bill2.jpg');
I1 = rgb2gray(I);
final=I1;
sz =size(I1);

%horizontal histogram
a=zeros(sz(1),1);
 for i = 1:sz(1)
     for j =1:sz(2)
         a(i) = a(i) + double(I1(i,j));
     end
 end;
 
f_id = fopen('Result1.txt','w');

%vertical histogram
 b=zeros(sz(2),1);
 for i = 1:sz(2)
     for j=1:sz(1)
         b(i) = b(i) + double(I1(j,i));
     end
 end
smooth = gausswin(12);
smooth = smooth/sum(smooth);
smooth_hor = conv2(a,smooth);
smooth_ver = conv2(b,smooth);
var=60;

[Maxima_hor,MaxIdx_hor] = findpeaks(smooth_hor,'MinPeakDistance',var);
DataInv_hor = 1.01*max(smooth_hor) - smooth_hor;
[Minima_hor,MinIdx_hor] = findpeaks(DataInv_hor,'MinPeakDistance',var);


[Maxima_ver,MaxIdx_ver]=findpeaks(smooth_ver,'MinPeakDistance',var);
DataInv_ver = 1.01*max(smooth_ver) - smooth_ver;
[Minima_ver,MinIdx_ver] = findpeaks(DataInv_ver,'MinPeakDistance',var);

I1 = double(I1);

MinIdx_hor = cat(1,1,MinIdx_hor);
MinIdx_ver = cat(1,1,MinIdx_ver);
MinIdx_hor = cat(1,MinIdx_hor,sz(1));
MinIdx_ver = cat(1,MinIdx_ver,sz(2));

for i = 1 : length(MinIdx_hor)-1
    s1 = MinIdx_hor(i);
    s2 = MinIdx_hor(i+1);
    for j = 1: length(MinIdx_ver)-1
        s3 = MinIdx_ver(j);
        s4 = MinIdx_ver(j+1);    
        m = median(I1(s1:s2,s3:s4));
        m1=median(m)-16;

          for k =s1:s2
               for l =s3:s4
                   if(I1(k,l)< m1)
                       I1(k,l)=0;
                   else
                        I1(k,l)=255;
                   end;
               end;
          end;
          final(s1:s2,s3:s4) = I1(s1:s2,s3:s4);
    end;
end;

final=imcomplement(final);
ocrResults = ocr(final);
% figure,imshow(final);
final_f =imcomplement(final);
% figure,imshow(final_f);

sz=size(final_f);
se=strel('rectangle',[floor(sz(1)*1/4),floor(sz(2)*1/30)]);
BW=imopen(final_f,se);
BW1=BW;

CC = bwconncomp(BW);
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);
BW(CC.PixelIdxList{idx}) = 0;
BW=BW1-BW;
% imshow(BW);

flag=0;
for i=1:sz(1)
    for j=1:sz(2)
        if BW(i,j)==255
            f_r=i;
            f_c=j;
            flag=1;
        end
        if flag==1
            break
        end
    end
    if flag==1
        break
    end
end
for i=1:sz(1)
    for j=1:sz(2)
        if BW(i,j)==255
            l_r=i;
            l_c=j;
        end
    end
end
wordBBoxes = ocrResults.WordBoundingBoxes;
words = ocrResults.Words;
item_idx = -1;

table_entries_id = zeros(200);
entries = 0;

for i=1:size(wordBBoxes)
    if  f_r < wordBBoxes(i,2)...
            && l_r > wordBBoxes(i,2) + wordBBoxes(i,4)
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
