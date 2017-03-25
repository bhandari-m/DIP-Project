function iml = thresh(imm)
im=rgb2gray(imm);
imc=imgaussfilt(im);
filt=fspecial('gaussian',5,2);
% mm=floor(size(im)/10);
% fil=ones(mm);
%imn=zeros(size(im));
imn=abs(imm(:,:,1)-imm(:,:,2))+abs(imm(:,:,1)-imm(:,:,3))+abs(imm(:,:,2)-imm(:,:,3));
% imn=imn(mm(1):size(im,1)+mm(1)-1,mm(2):size(im,2)+mm(2)-1);
imc=conv2(double(im),filt);
imc=imc(5:4+size(im,1),5:4+size(im,2));
iml=logical(zeros(size(im)));
% imn=imn/(mm(1)*mm(2));
mx=max(max(imm))
mn=sum(sum(im));
mn=mn/(size(im,1)*size(im,2));
x=abs(mx(1)-mx(2))+abs(mx(1)-mx(3))+abs(mx(2)-mx(3));
for i=1:size(im,1)
    for j=1:size(im,2)
        if double(im(i,j))>imc(i,j)-5 && imc(i,j)>mn-15 && imn(i,j)<0.3*mn
            iml(i,j)=1;
        end
    end
end
%figure,imshow(iml);
% s=strel('disk',1);
% iml=imclose(iml,s);
% s=strel('disk',2);
% iml=imopen(iml,s);
%imlc=imcomplement(iml);
% imlc=imopen(imlc,s);
%figure,imshow(iml);
%figure,imshow(imlc);
end

