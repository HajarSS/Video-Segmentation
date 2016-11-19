
%########################################################################## 21 Feb 2012
% The second video, 000200
r= 288;               % the number of rows
c= 512;               % the number of columns
space= 10;            % every how many frames! :)
reSize= 0.4;          % How much should resize frames
aveSize= 400;
%***************************************************************************
Vhr= 51.7222;   %329.8812 :for 50100 Video
load background_200;

objects= ['VIRAT_000200_06.mp4';'VIRAT_000201_01.mp4';'VIRAT_000202_00.mp4';'VIRAT_000203_01.mp4';...
	  'VIRAT_000203_04.mp4';'VIRAT_000204_04.mp4';'VIRAT_000204_09.mp4';'VIRAT_000205_01.mp4';...
	  'VIRAT_000205_05.mp4';'VIRAT_000206_03.mp4';'VIRAT_000206_08.mp4'];

for haj=1:11

dirName= ['./video',num2str(haj)];
cd(dirName);
listFiles = dir('*.mat');
numFrames = numel(listFiles)

object= mmreader(objects(haj,:));

[x_min, ~]= im2real(-(c/2), (r/2));
[~, z_min]= im2real(-(c/2), -(r/2));
[x_max, z_max]= im2real((c/2), (r/2));
scale= (x_max-x_min)/(z_max-z_min);  % to convert top-down image from rectangle to square

clear mag
clear dirV
clear dirP

objSize= zeros(r,c);   % the size of objects
smalObj= zeros(r,c);   % Small objects
bigObj= zeros(r,c);    % Big objects
numberObj= zeros(r,c);
numberSmal= zeros(r,c);
numberBig= zeros(r,c);
sj= zeros(r,c);
number= zeros(r,c);
people= zeros(r,c);
vehicle= zeros(r,c);
crossRoad= zeros(r,c);
stopPixels= zeros(r,c);
temp1= zeros(r,c); 

frameStart=1;
t = cputime; 
for i=frameStart:numFrames
	fprintf('.......... %i\n', i);
	% Optical Flow............................
	load(num2str(i));
	u= uv(:,:,1);
	v= uv(:,:,2);
	uv_M= sqrt(u.^2+v.^2);

	% The current frame
	im= read(object, space*i); 
	im= imresize(im,reSize); 
	im= rgb2gray(im); 

	% The last Frame
	temp= read(object, space*i-1); 
	temp= imresize(temp,reSize); 
	temp= rgb2gray(temp); 

	% Frame Difference........................
	temp= imabsdiff(im, temp);
	temp(temp<5)= 0;

	% Connection .............................
	blob= connection(im, temp, u, v);
	se = strel('ball',4,4);     
	temp = imdilate(blob,se);
	blob= imerode(temp, se);
        blob= medfilt2(blob, [3 3]);  % median filtering to remove noise
	blob(:,1:2)= 0;

	if(i==frameStart)
	% finding threshold******************************  
	% just once, because it's not changing over frames! :)
	x1= RatioCalculation(background);
	x2= RatioCalculation(im);
	temp= imabsdiff(x1,x2);

	temp= reshape(temp, 1, r*c);
	m= mean(temp);
	label= zeros(1, r*c);
	label(temp<m)= 1;
	label(temp>=m)= 2;

	label= kmeans(temp,2,label);
	thr= (mean(temp(label==1))+mean(temp(label==2)))/2
	% ***********************************************
	end

	% Delete top half of each object, to remove Perspective problem
	mask= blob;
	temp= bwlabel(blob,8);
	numBlobs= max(max(temp));
	for j=1:numBlobs
    		[s1, s2]= find(temp==j);
		if(length(s1)<=5) mask(s1, s2)=0; continue; end
		rL= min(s1);
		rH= max(s1);
		mask(rL:(round(((rH-rL+1)/2)+rL)-1),s2)= 0;
	end

	% Calculating the object size
	ma= zeros(r,c);         % magnitude
	sizeBef= temp1>0;          % keep them for stop points
	temp1= temp1.*0;        % the size of objects
	temp = bwlabel(blob,8);
	numBlobs= max(max(temp));
	for j=1:numBlobs
		[s1,s2]= find(temp==j);
		size2= sum(sum(temp==j));
		v_2B= (r/2)-max(s1);
		v_2T= (r/2)-min(s1);
		if((size2<5) || (v_2B==v_2T))   continue;   end

		h2= v_2T - v_2B;
		h1= (h2*(Vhr+(r/2))*(h2+v_2B+(r/2)))/(h2*(Vhr+(r/2))+(Vhr-v_2B-h2)*(v_2B+(r/2)));
		x= h1/h2;
		temp1(temp==j)= x*x*size2;  % the size of j'th object

		ma(temp==j)= x*uv_M(temp==j);
	end

	temp1= temp1.*double(mask);   %to Delete top half of each object
	ma= ma.*double(mask);

	sj= sj.*0; % to clean it
	sj(temp1<aveSize)= temp1(temp1<aveSize);
	sj(temp==0)= 0;
	smalObj= smalObj+sj;
	numberSmal= numberSmal+(sj>0);

	bigObj(temp1>=aveSize)= bigObj(temp1>=aveSize)+temp1(temp1>=aveSize);
	numberBig= numberBig+(temp1>=aveSize);

	objSize= objSize + temp1;
	numberObj= numberObj+(temp1>0);

	%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ People, Vehicle
	temp2= 	sj>0;
	temp2(ma>=0.6)= 0;
	people(temp2)= people(temp2)+1;	

	temp3= (temp1>=aveSize);
	temp3(ma<0.6)= 0;
	vehicle(temp3)= vehicle(temp3)+1;
	
	%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Direction
	di= zeros(r,c);
	for f1=1: r
	    for f2=1:c
	        if (ma(f1,f2)>0) 
		    [x1,z1]= im2real(f2-(c/2), (r/2)-f1);
		    [x2,z2]= im2real(f2+u(f1,f2)-(c/2), (r/2)-f1);
		    [x3,z3]= im2real(f2-(c/2), (r/2)-(f1+v(f1,f2)));
		    x= (x2-x1); 
		    y= scale*(z3-z1);
	            %di(f1, f2)= Direction_Stimate(u(f1, f2), -v(f1, f2)); 
	            di(f1, f2)= Direction_Stimate(x,y); 
	        end
	    end
	end

	mag(i,:)= reshape(ma,1, r*c);
	dirP(i,:)= reshape(di.*temp2,1, r*c);   % for people
	dirV(i,:)= reshape(di.*temp3,1, r*c);    % for vehicle
	number= number+(ma>0);

	%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ < Stop Points
	if (i>(frameStart+1))
	magBef= reshape(mag(i-1,:), r,c);
	mag2Bef= reshape(mag(i-2,:), r,c);

	temp= stopFind(im,background,ma,magBef,mag2Bef,thr);
	temp= temp.*sizeBef;
	stopPixels= stopPixels + temp;  % stop should be happen just for vehicles
	end
end
e = cputime-t; 
fprintf('The used time for video %s with %i frames in second: %1.2f s\n', objects(haj,:), numFrames, e);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Object size, Small, Big
numberObj= numberObj+1; % to prevent dividing by 0
numberSmal= numberSmal+1;
numberBig= numberBig+1;

objSize= objSize./numberObj;
smalObj= smalObj./numberSmal;
bigObj= bigObj./numberBig;

fig1= figure(1); imagesc(smalObj), title('Small Object');
fig2= figure(2); imagesc(bigObj), title('Big Object');
fig3= figure(3); imagesc(objSize), title('Object');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Direction
% directions: 10,20,30,40,50,60,70,80 and 100:random direction
direction= zeros(1, r*c);
mag(mag==0)= NaN;
magnitude= nanmean(mag);  % to remove zero values in averaging
magnitude(isnan(magnitude))= 0;
dirV(dirV==0)= NaN;
d= mode(dirV);
d(isnan(d))= 0;
d(magnitude==0)= 0;
direction= reshape(d, r,c);
direction(vehicle==0)= 0;


% crossRoad
[rowP,~]= size(dirP);
for k=1:rowP
	cr= zeros(r,c);
	d= dirP(k,:);
	d= reshape(d,r,c);
	cr= d>0;
	cr(direction==0)= 0; % pixels not on the road! :)
	cr(direction==d)= 0;
	cr(abs(direction-d)==40)= 0;
	crossRoad= crossRoad+cr;
end



fig4= figure(4); imagesc(number), title('number');

magnitude= reshape(magnitude, r,c);

number= number+1; % to prevent dividing by 0
%magnitude= (magnitude)./number;

fig5= figure(5); imagesc(direction), title('direction');
fig6= figure(6); imagesc(magnitude), title('magnitude');


fileName= ['res',num2str(haj),'_objSize'];
save(fileName,'objSize');
%saveas(fig3,fileName,'jpg');

fileName= ['res',num2str(haj),'_direction'];
save(fileName,'direction');
%saveas(fig5,fileName,'jpg');

fileName= ['res',num2str(haj),'_magnitude'];
save(fileName,'magnitude');
%saveas(fig6,fileName,'jpg');



cd ..
end
