% In the name of GOD...



% ########################################################################## 7 March 2012
% The second video, 000200
r= 288;               % the number of rows
c= 512;               % the number of columns
space= 10;            % every how many frames! :)
reSize= 0.4;          % How much should resize frames
aveSize= 200;
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

temp1= zeros(r,c);
stop= zeros(r,c);
park= zeros(r,c);
stopP= zeros(r,c);
parkP= zeros(r,c);
stopIndex= 1;
parkIndex= 1;
ma= zeros(r,c);         % magnitude
parkPixels= zeros(1,r*c);
stopPixels= zeros(1,r*c);

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
	before= read(object, space*i-1); 
	before= imresize(before,reSize); 
	before= rgb2gray(before); 

	% Frame Difference........................
	temp= imabsdiff(im, before);
	temp(temp<5)= 0;

	% Connection .............................
	blob= connection(im, temp, u, v);
	se = strel('ball',4,4);     
	temp = imdilate(blob,se);
	blob= imerode(temp, se);
        blob= medfilt2(blob, [3 3]);  % median filtering to remove noise
	blob(:,1:2)= 0;

	% Calculating the object size
	ma= ma.*0;
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


	%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Direction
	for f1=1: r
	    for f2=1:c
	        if (ma(f1,f2)>0) 
		    [x1,z1]= im2real(f2-(c/2), (r/2)-f1);
		    [x2,z2]= im2real(f2+u(f1,f2)-(c/2), (r/2)-f1);
		    [x3,z3]= im2real(f2-(c/2), (r/2)-(f1+v(f1,f2)));
		    x= (x2-x1); 
		    y= scale*(z3-z1);
	            %di(f1, f2)= Direction_Stimate(u(f1, f2), -v(f1, f2)); 
	            temp(f1, f2)= Direction_Stimate(x,y); 
	        end
	    end
	end

	mag(i,:)= reshape(ma,1, r*c);
	%dir(i,:)= reshape(temp.*(temp1>=aveSize),1, r*c);    % for possible vehicle
	%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ < Stop Points
	if(i==frameStart)          sizeBef= temp1;
	elseif(i==(frameStart+1))  size2Bef= sizeBef;  sizeBef= temp1;
	elseif (i>(frameStart+1))
		stop= stop.*0;
		park= park.*0;
		magBef= reshape(mag(i-1,:), r,c);
		mag2Bef= reshape(mag(i-2,:), r,c);
		mask= mag2Bef<0.8;

		mask(size2Bef<aveSize)= 0;              % just for vehicles
		Lmask= bwlabel(mask,8);

		numBlobs= max(max(Lmask));
		for j=1:numBlobs
			size1= sum(sum(Lmask==j));
			[r1,c1]= find(Lmask==j); 
			if (size1<=50) continue; end
			temp= (Lmask==j);
			x1= temp.*magBef;
			x2= temp.*mag2Bef;
			x= temp.*ma;         % magCur
			d= x1-x2;

			if ((sum(sum(d<0))>(0.8*size1)) && (sum(sum(x(temp>0)==0))>(0.9*size1)) && ...
			   (sum(sum(x1(temp>0)==0))<(0.8*size1)) && ((max(r1)-min(r1)+1)<(2*(max(c1)-min(c1)+1))))  
				stop= stop+temp ; 
			end
		end
		stopP= stopP + stop;  % stop should be happen just for vehicles
		if (sum(sum(stop))>0) stopPixels(stopIndex,:)= reshape(stop,1,r*c); stopIndex=stopIndex+1;  end

		% Parked Places, out
		%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		mask= ma<0.5;
		mask(temp1<aveSize)= 0;              % just for vehicles

		Lmask= bwlabel(mask,8);
		numBlobs= max(max(Lmask));
		for j=1:numBlobs
			size1= sum(sum(Lmask==j));
			if (size1<=50) continue; end
			temp= (Lmask==j);
			x= temp.*magBef;
			if ((sum(sum(x>0))>(0.5*size1)) && (sum(sum(x>0))>(0.8*size1)) && ...
			   	(sum(sum(mag2Bef(temp>0)==0))>(0.9*size1)))  
					park= park+temp ; 
				end

		end
		parkP= parkP + park;  % park-out should be happen just for vehicles
		if (sum(sum(park))>0) parkPixels(parkIndex,:)= reshape(park,1,r*c); parkIndex=parkIndex+1;  end

		size2Bef= sizeBef;
		sizeBef= temp1;
	end

end
figure(1), imagesc(stopP);
figure(2), imagesc(parkP);

fileName= ['stop',num2str(haj)];
save(fileName,'stopPixels');

fileName= ['park',num2str(haj)];
save(fileName,'parkPixels');

e = cputime-t; 
fprintf('The used time for %i frames in second: %1.2f s\n', numFrames, e);

cd ..
end

