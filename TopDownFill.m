% In the Name of GOD
%*******************

%~~~~~~~~~~ filled top-down view image, for "VIRAT_050100_11.mp4":
%{
% Requirements ...
f= 10000; 
H= 22.0716; 
Vhr= 329.8812;

[x_min, ~]= im2real(-288, 162);
[~, z_min]= im2real(-288, -162);
[x_max, z_max]= im2real(288, 162);

row= z_max - z_min;
col= x_max - x_min;

TopImg1= zeros(row+1,col+1);
TopImg2= zeros(row+1,col+1);
TopImg3= zeros(row+1,col+1);

object= mmreader('video.mp4');
RGBimg= read(object, 900);
%RGBimg= im2double(imread('im.jpg'));
RGBimg= imresize(RGBimg, 0.3);


% Computation ....
[r,c,~]= size(RGBimg);

for i=1:r
   for j=1:c
    [x, z]= im2real(j-288, 162-i);

    TopImg1(z_max-z+1, x-x_min+1)= RGBimg(i, j, 1); 
    TopImg2(z_max-z+1, x-x_min+1)= RGBimg(i, j, 2); 
    TopImg3(z_max-z+1, x-x_min+1)= RGBimg(i, j, 3); 
   end
end
Cat_image= cat(3, TopImg1, TopImg2, TopImg3);
figure(3); imshow(uint8(Cat_image));

[r,c]= size(TopImg1);
t=TopImg1;
for i=1:r-1
	for j=1:c-1
		if(t(i,j)==0) t(i,j)=t(i, j+1); end
	end
end

for i=4:r-3
	for j=4:c-3
		for k=1:4
		if(t(i,j)==0) t(i,j)=t(i-1, j); end
		end
	end
end
TopImg1= t;

t=TopImg2;
for i=1:r-1
	for j=1:c-1
		if(t(i,j)==0) t(i,j)=t(i, j+1); end
	end
end

for i=4:r-3
	for j=4:c-3
		for k=1:4
		if(t(i,j)==0) t(i,j)=t(i-1, j); end
		end
	end
end
TopImg2= t;

t=TopImg3;
for i=1:r-1
	for j=1:c-1
		if(t(i,j)==0) t(i,j)=t(i, j+1); end
	end
end

for i=4:r-3
    for j=4:c-3
       for k=1:4
           if(t(i,j)==0) t(i,j)=t(i-1, j); end
       end
    end
end
TopImg3= t;


[rowTop,colTop]= size(TopImg1); 
for z=1:rowTop
	for x=1:colTop
        j= round((f*(x+x_min-1))/(15*(H*sin(atan(Vhr/f))+(1+z_max-z))))+288; % row in Image(i)
        i= 162-round(((1+z_max-z)*Vhr-H*f)/((1+z_max-z)+H*(Vhr/f)));         % col in image(j)
        if(j<0 || j>576 || i<0 || i>324)
            TopImg1(z,x)= 0;
            TopImg2(z,x)= 0;
            TopImg3(z,x)= 0;
        end
	end
end

Cat_image= cat(3, TopImg1, TopImg2, TopImg3);
figure(4); imshow(uint8(Cat_image));
%}


% A top-down image for segmentation results
% Requirements ...
f= 10000; 
H= 22.0716; 
Vhr= 329.8812;

[x_min, ~]= im2real(-288, 162);
[~, z_min]= im2real(-288, -162);
[x_max, z_max]= im2real(288, 162);

row= z_max - z_min;
col= x_max - x_min;

TopImg= zeros(row+1,col+1);

load segments;
segments= segments+1;

% Computation ....
[r,c]= size(segments);

for i=1:r
   for j=1:c
    [x, z]= im2real(j-288, 162-i);

    TopImg(z_max-z+1, x-x_min+1)= segments(i, j); 
   end
end
figure(2); imagesc(TopImg);


[r,c]= size(TopImg);
t=TopImg;
for i=1:r-1
	for j=1:c-1
        if(t(i,j)==0) 
            t(i,j)=t(i, j+1);
        end
	end
end

for i=4:r-3
	for j=4:c-3
		for k=1:4
            if(t(i,j)==0) 
                t(i,j)=t(i-1, j); 
            end
		end
	end
end
TopImg= t;


[rowTop,colTop]= size(TopImg); 
for z=1:rowTop
	for x=1:colTop
        j= round((f*(x+x_min-1))/(15*(H*sin(atan(Vhr/f))+(1+z_max-z))))+288; % row in Image(i)
        i= 162-round(((1+z_max-z)*Vhr-H*f)/((1+z_max-z)+H*(Vhr/f)));         % col in image(j)
        if(j<0 || j>576 || i<0 || i>324)
            TopImg(z,x)= 0;
        end
	end
end

figure(3); imagesc(TopImg);

