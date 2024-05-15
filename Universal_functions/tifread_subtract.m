%% This function reads tif files faster than imread

function [imagematrixout] = tifread_subtract(filename)

imageinfo = imfinfo(filename);
imagewidth = imageinfo(1).Width;
imageheight = imageinfo(1).Height;
imagenumber = numel(imageinfo);
bitdepth = imageinfo(1).BitsPerSample;
imagematrixout = zeros(imageheight,imagewidth,imagenumber,strcat('uint',int2str(bitdepth)));

TifLink = Tiff(filename,'r');

for n = 1:imagenumber
    TifLink.setDirectory(n);
    image = TifLink.read();
    imagematrixout(:,:,n) = (image - imgaussfilt(image,100));
end
TifLink.close();