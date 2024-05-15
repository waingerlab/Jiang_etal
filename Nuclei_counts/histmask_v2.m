function [mask] = histmask_v2(image,stdevs)

%avg = mean(image(:));
avg = 0; %the histogram is only one sided and centers around 0 after the image subtraction
stdev = std(double(image(image(:)<10000))); %this takes only values <10000 to prevent artifacts from high fluorescence pixels. The point is to find the stdev of the background
thresh = avg + (stdevs*stdev);
mask = image>thresh;