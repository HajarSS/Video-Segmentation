% In the Name of GOD
%*******************

% Visualising segments based on topic-document distribution with GibbsLDA++
% 21 May 2012

function [segments] = segLDA (tdDist,mask)

r= 324;           
c= 576;
row= r*c;
i= 1;
segments= zeros(1,row);     % Final Segments

%load tdDist.dat;          % topic-document Distribution
%load mask.mat;

p= 0;  % the number of pixels with more than one high probability
for j=1:row
    if(mask(j)==0)
        continue;
    end
    [m,idx]= max(tdDist(i,:));
    p = p+((sum(tdDist(i,:)==m))>1);
    i= i+1;
    segments(j)= idx;
end

segments= reshape(segments,r,c);
figure(1), imagesc(segments),
title(['Video:50100-11,1000frames,Iter:100,topics:',num2str(size(tdDist,2)),',pixels-with-more-than-one-high-probability:',num2str(p)]);
