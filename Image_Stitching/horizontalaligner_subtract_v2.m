function [mergedimage,otherimagesout] = horizontalaligner_subtract_v2(baseimage,imagetoadd,tempindex,imagetoaddindex,stitchwavelength,otheralignedwavelengths,otherwavelengths);
%fixes other wavelength outputs if alignmentwavelength ~=1

dimensions = size(imagetoadd);
basedimensions = size(baseimage);

right10p = baseimage(:,(basedimensions(2)-floor(dimensions(2)*.1)):basedimensions(2)); %this line takes the part of mergedimage that overlaps with the image to be matched (10% of one FOV)
left10p = imagetoadd(:,1:ceil(.1*dimensions(2)));

[optimizer, metric] = imregconfig('multimodal'); % configures alignment conditions, which should be pretty straightforward
optimizer.InitialRadius = .00001;
optimizer.Epsilon = 1.5e-8;

alignment = imregtform(left10p,right10p,'translation',optimizer,metric);
rightshift = floor(alignment.T(3,1)); % this is the amount to shift to the right to not overly crop added image
sizeref = imref2d([dimensions(1),(dimensions(2)+rightshift)]); %I'm adding the rightshift here to allow a little wiggle room to the right- that way it doesn't crop the image too much
alignedimagetoadd = imwarp(imagetoadd,alignment,'OutputView',sizeref);
trimmedimagetoadd = alignedimagetoadd(:,ceil(.1*dimensions(2))+1:dimensions(2)+rightshift);

mergedimage = [baseimage,trimmedimagetoadd];

%section that aligns other wavelengths based on the chosen wavelength
otherimagesout = cell(numel(otherwavelengths),1);
if numel(otherwavelengths)>=1

for n = 1:numel(otherwavelengths)
    oldimage = otheralignedwavelengths{n};
    newimage = imwarp(tifread_subtract(tempindex{imagetoaddindex + otherwavelengths(n)-stitchwavelength}),alignment,'OutputView',sizeref); %loads in the correct image and then warps based on alignment
    trimmednewimage = newimage(:,ceil(.1*dimensions(2))+1:dimensions(2)+rightshift);
    otherimagesout{n} = [oldimage,trimmednewimage];
end

end
    
    