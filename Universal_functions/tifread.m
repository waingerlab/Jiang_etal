%% This function reads tif files faster than imread

function [imagematrixout] = tifread(filename)

imageinfo = imfinfo(filename);
imagewidth = imageinfo(1).Width;
imageheight = imageinfo(1).Height;
imagenumber = numel(imageinfo);
bitdepth = imageinfo(1).BitsPerSample(1); %tweaked to be compatible with color images (needs to be a single number)
channels = numel(imageinfo(1).BitsPerSample); %need channel number
imagematrixout = zeros(imageheight,imagewidth,channels,imagenumber,strcat('uint',int2str(bitdepth)));

TifLink = Tiff(filename,'r');

for n = 1:imagenumber
    TifLink.setDirectory(n);
    imagematrixout(:,:,:,n) = TifLink.read();
end
TifLink.close();