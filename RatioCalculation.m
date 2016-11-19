function ratioIm= RatioCalculation(im)

[r, c]= size(im);
ratio= zeros(r,c);

im= im2double(im);
for i=2:r-1
   for j=2:c-1
       ratio(i, j)= (im(i,j)/im(i-1,j-1))*10 + (im(i,j)/im(i-1,j  ))*10 + (im(i,j)/im(i-1,j+1))*10 + ...
                    (im(i,j)/im(i  ,j-1))*10 + (im(i,j)/im(i  ,j+1))*10 + (im(i,j)/im(i+1,j-1))*10 + ...
                    (im(i,j)/im(i+1,j  ))*10 + (im(i,j)/im(i+1,j+1))*10;
   end
end

ratioIm= ratio;

