function [L,p1,p2, M]=preproc(im)
% I=rgb2gray(imread('bill4.jpg'));
% I=histeq(I);
% J=im2bw(I,0.65);
%im=imread('bill8.jpg');
% im(:,:,1)=histeq(im(:,:,1));
% im(:,:,2)=histeq(im(:,:,2));
% im(:,:,3)=histeq(im(:,:,3));
 K=thresh(im);
 %imshow(K);
 M=K;
 K=imclose(K,strel('disk',2));
 tmp=size(K);
 K=imresize(K,0.4);
 Y=edge(K,'canny');
 K=imresize(K,tmp);
% imshow(Y);
 H=hough(Y);
 h=max(H);
 m1=0; m2=0;p1=0;p2=0;
 [h p]=sort(h,'descend'); 
 p1=p(1);p2=0;
 for i=2:size(p)
     if(abs(p(i)-p(1)) > 45)
         p2=p(i)
         break;
     end
 end
 sz=floor(size(K)/20)
 s1=strel('line',sz(1),p1);
 s2=strel('line',sz(1),p2);
 K=padarray(K,[sz(1) sz(1)]);
 L=imclose(imclose(K,s1),s2);
 L=imclose(L,strel('disk',floor(sz(1))));
 L=imopen(L,strel('disk',floor(sz(1))));
 L=L(sz(1)+1:size(L,1)-sz(1),sz(1)+1:size(L,2)-sz(1));
 CC = bwconncomp(L);
 numPixels = cellfun(@numel,CC.PixelIdxList);
 [biggest,idx] = max(numPixels);
 L=L*0;
 L(CC.PixelIdxList{idx}) = 1;
%  figure,imshow(L);
 M=L.*M;
end
