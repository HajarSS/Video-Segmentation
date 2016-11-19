%########################################################################################## 30 Jan 2012
function connIm= connection(Im, cI, u, v)
% After doing "Frame Difference", this function connects and fills the 
% holes in the image, then the image looks more concrete.

%...................................
mag= sqrt(u.^2 + v.^2);
%figure(50), imagesc(mag);
mag(mag<0.1)= 0;
cI(mag<0.1)= 0;
cI(cI>0)= 1; % like a mask

[r,c]= size(Im);

%................................... Direction
direction= zeros(r,c);
for f1=1: r
    for f2=1:c
        if (mag(f1,f2)) 
            direction(f1, f2)= Direction_Stimate(u(f1, f2), -v(f1, f2)); 
        end
    end
end
%figure(40), imagesc(direction);
%...................................

for i=2:r-1
    for j=2:c-1
        if (cI(i,j)>0) 
	    jnew= j;
	    %................. In column
            k1= j;
	    while(k1<c && cI(i,k1+1)==0)  k1= k1+1;       end
	    if(k1>j && k1<c)
		x=0;
		for k=j+1:k1
			%b(i,k)>0
			if(direction(i,j)== direction(i,k) && mag(i,k) && abs(mag(i,k)-mag(i,k-1))<0.3)  x= x+1;
			else x=0;
			end
		end
		if(x==(k1-j) && x>0)   cI(i,j+1:k1)=1; jnew=k1+1;   end		
            end
	    %................. In row
	    k2= i;
	    while(k2<r && cI(k2+1,j)==0)  k2= k2+1;       end
	    if(k2>i && k2<r)
		x=0;
		for k=i+1:k2
			if(direction(i,j)== direction(k,j) && mag(k,j) && abs(mag(k,j)-mag(k-1,j))<0.3)  x= x+1;
			else x=0;
			end
		end
		if(x==(k2-i) && x>0)   cI(i+1:k2, j)=1;           end		
            end
	    %................. In diameter
	    k1= i;  k2=j;
	    while(k1<r && k2<c && cI(k1+1,k2+1)==0)  k1= k1+1; k2= k2+1;    end
	    if(k2>j && k1<r && k2<c)
		x=0;  k1= i+1;
		for k=j+1:k2
		      if(direction(i,j)== direction(k1,k) && mag(k1,k) && abs(mag(k1-1,k-1)-mag(k1-1,k-1))<0.3) x= x+1;
		      else x=0;
		      end
			k1=k1+1;
		end
		if(x==(k2-j) && x>0)   
			x2= j+1;
			for x1=i+1:k1
			    cI(x1, x2)=1;  x2=x2+1;
			end           
		end		
            end
	    %................. End
	    j= jnew;
        end
    end
end

connIm= cI;

%########################################################################################## 20 Dec 2011
%{
function connIm= connection(Im, cI, u, v, k)

load backGround_OF;
%load background_200;
background= double(background);

d= imabsdiff(double(Im),background);
b= zeros(size(d));
b(find(d>30))= 1; 
b= imfill(b);

uv_M= sqrt(u.^2 + v.^2);

[r,c]= size(Im);

for i=2:r-1
    for j=2:c-1
        if (cI(i,j)==1) 
            if(cI(i,j+1)==0 && b(i,j+1)==1 && uv_M(i,j+1)>0.5 && abs(uv_M(i,j)-uv_M(i,j+1))<1 && Direction_Stimate(u(i,j),-v(i,j))== Direction_Stimate(u(i,j+1),-v(i,j+1)))        cI(i,j+1)= 1;     end
            if(cI(i+1,j)==0 && b(i+1,j)==1 && uv_M(i+1,j)>0.5 && abs(uv_M(i,j)-uv_M(i+1,j))<1 && Direction_Stimate(u(i,j),-v(i,j))== Direction_Stimate(u(i+1,j),-v(i+1,j)))        cI(i+1,j)= 1;     end
            if(cI(i+1,j+1)==0 && b(i+1,j+1)==1 && uv_M(i+1,j+1)>0.5 && abs(uv_M(i,j)-uv_M(i+1,j+1))<1 && Direction_Stimate(u(i,j),-v(i,j))== Direction_Stimate(u(i+1,j+1),-v(i+1,j+1)))    cI(i+1,j+1)= 1;   end
            if(cI(i,j-1)==0 && b(i,j-1)==1 && uv_M(i,j-1)>0.5 && abs(uv_M(i,j)-uv_M(i,j-1))<1 && Direction_Stimate(u(i,j),-v(i,j))== Direction_Stimate(u(i,j-1),-v(i,j-1)))        cI(i,j-1)= 1;     end
            if(cI(i+1,j-1)==0 && b(i+1,j-1)==1 && uv_M(i+1,j-1)>0.5 && abs(uv_M(i,j)-uv_M(i+1,j-1))<1 && Direction_Stimate(u(i,j),-v(i,j))== Direction_Stimate(u(i+1,j-1),-v(i+1,j-1)))    cI(i+1,j-1)= 1;   end
        end
    end
end

connIm= cI;
%}
