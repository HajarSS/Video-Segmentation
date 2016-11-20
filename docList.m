% 7 Jun 2012
% Making a text-file as input for GibbsLDA++
% Making Document-List,"dir,mag,objS" perFrame, k-means for whole features:

% Video= 50100-11 (the first 1000 frames) 

r= 324;           
c= 576;
row= r*c;
n= 1000;              % the number of clusters 

% making the whole dataset without zero values: X
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
load objSize
t= size(objSize,1);   % the number of frames
objSize= reshape(objSize,t*row,1);
nonZind= find(objSize>0);

load magnitude;
magnitude= reshape(magnitude,t*row,1);

X= cat(2,objSize(nonZind),magnitude(nonZind));
clear objSize magnitude

load direction;
direction= reshape(direction,t*row,1);
X= cat(2,X,direction(nonZind));
clear  direction

% RGB features...
im= imread('im.jpg');
im= imresize(im,0.3);
im= im2double(im);

%convert to lab
%labTransformation = makecform('srgb2lab');
%im = applycform(im,labTransformation);

red= reshape(im(:,:,1),1,row);  
red= (red-mean(red))/std(red);   % Normalizing
red= repmat(red,t,1);
red= reshape(red,t*row,1);
X= cat(2,X,red(nonZind));
clear  red

gre= reshape(im(:,:,2),1,row);   
gre= (gre-mean(gre))/std(gre);
gre= repmat(gre,t,1);
gre= reshape(gre,t*row,1);
X= cat(2,X,gre(nonZind));
clear  gre

blu= reshape(im(:,:,3),1,row);   
blu= (blu-mean(blu))/std(blu);
blu= repmat(blu,t,1);
blu= reshape(blu,t*row,1);
X= cat(2,X,blu(nonZind));
clear  blu

save('nonZind','nonZind');
clear nonZind im;

% pick a subset: data
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SUBSET_SIZE = 200000;            % subset size
ind = randperm(size(X,1));
data = X(ind(1:SUBSET_SIZE),:);
clear ind

% cluster the subset data
[~,centers]= kmeans(data,n,'emptyaction','singleton');
clear data

% calculate distance of each instance to all cluster centers
clustIDX= zeros(size(X,1),1);
for i=1:size(X,1)
    fprintf('pixel:%i...\n', i);
    D= zeros(1,n);
    for j=1:n
        D(1,j) = sum((X(i,:)-centers(j,:)).^2);
    end
    [~,clustIDX(i,1)]= min(D);
end
clear D X centers

load nonZind;
labels= zeros(t*row,1);
labels(nonZind)= clustIDX;
clear nonZind clustIDX;

labels= reshape(labels,t,row); % No.frames x No.pixels per frame
numLines= 0;
mask= zeros(1,row);
fid = fopen('11-motionRGB-docList.dat', 'wt'); % input to LDA
for i=1:row
    fprintf('Writing in file, Pixel: %i ...\n',i);
    if(labels(:,i)==0) 
        continue;
    end
    
    for j=1:t % t: num of frames
        if(labels(j,i)>0)
            fprintf(fid,[num2str(labels(j,i)),' ']);  % write in the file
        end
    end
          
    fprintf(fid,'\n');
    numLines= numLines+1;
    mask(i)= 1;
end


fclose(fid);
save('mask','mask');
