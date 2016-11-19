% In the name of GOD...

%........................................................................... 10 Feb 2012
% This finction finds the pixels that one moving object has stopped on it!
% the output is a matrix. in pixels: the number of votes for one pixel to be stopped point!
% We should distinguish between "noMotion" pixels and "stop" pixels!

function stop_filled = stopFind(im,background,magCur,magBef,mag2Bef,thr)
% mag==0: noMotion pixels
[r,c]= size(im);

stop= zeros(r, c);
x1= RatioCalculation(background);
x2= RatioCalculation(im);
x= imabsdiff(x1,x2);

% connect the close pixels 
se = strel('ball',4,4);
Ix = imdilate(x,se);
x= imerode(Ix, se);

%difMagBefore= magCur;
difMagBefore= magBef - mag2Bef;

difMagBefore(difMagBefore> 0)= 0;
difMagBefore(difMagBefore<= 0)= 1;
difMagBefore= difMagBefore.*magBef;

magBef(magBef>0.5)= 0;

for i=3:(r-2)
    for j=3:(c-2)
        if (NeighbourMag(magCur, i, j, 0) && NeighbourMag(magBef, i, j, 1) && x(i,j)>thr)
        % in this condition, we don't know actually, the pixel is stopped for parking or stop sign!
		stop(i,j)= 1;  	
	end
    end
end

stop_filled= stop;

%{
% connect the close pixels 
se = strel('line',5,90); %se = strel('ball',2,2);
I = imdilate(stop,se);
se = strel('line',5,0); %se = strel('ball',2,2);
I = imdilate(I,se);
%figure(4), imshow(I), title('stop_imdilate');
stop_filled= imerode(I, se);
%figure(5), imshow(stop_filled), title('stop_imerode');

% remove components with the small size
L = bwlabel(stop_filled,8);
numBlobs= max(max(L));
for j=1:numBlobs
    [s1, s2]= find(L==j);
    if (length(s1)<20)   % Delete small objects (smaller than 20 pixels)
       stop_filled(s1, s2)= 0;
    end
end
%}


function result = NeighbourMag(frame, a, b, x)
% x: '0(means: mag==0)' OR '1(means: mag~=0)'
% a,b: indexes of the center pixel
% frame: matrix of magnitudes
result= 0;
s= 0;

l1= -1;    h1= 1;   l2= -1;    h2= 1;
if (x==0)
   for i=(a+l1):(a+h1)
       for j=(b+l2):(b+h2)
           if(frame(i, j)==0) s= s+1; end % pixel isn't moving
       end
   end
else
   for i=(a+l1):(a+h1)
       for j=(b+l2):(b+h2)
           if(frame(i, j)> 0) s= s+1; end % pixel is moving
       end
   end
end

if (s==9) result= 1; % we have 8 neighbours!
end
