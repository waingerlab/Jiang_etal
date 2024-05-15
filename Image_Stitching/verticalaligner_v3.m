%% This function vertically aligns stitched images

function [mergedimage,otherimagesout] = verticalaligner_v3(baseimage,imagetoadd,horizontalmergecell,count,otherimagesout)

dimensions = size(imagetoadd);
basedimensions = size(baseimage);

top10p = baseimage((basedimensions(1)-floor(dimensions(1)*.1)):basedimensions(1),:);%this line takes the part of mergedimage that overlaps with the image to be matched (10% of one FOV)
bottom10p = imagetoadd(1:ceil(.1*dimensions(1)),:);

[optimizer, metric] = imregconfig('multimodal'); % configures alignment conditions, which should be pretty straightforward
optimizer.InitialRadius = .00001;
optimizer.Epsilon = 1.5e-8;

alignment = imregtform(bottom10p,top10p,'translation',optimizer,metric);
downshift = floor(alignment.T(3,2)); 
sizeref = imref2d([(dimensions(1)+downshift),basedimensions(2)]); %I'm adding the downshift here to allow a little wiggle room downward- that way it doesn't crop the image too much
alignedimagetoadd = imwarp(imagetoadd,alignment,'OutputView',sizeref);
trimmedimagetoadd = alignedimagetoadd(ceil(.1*dimensions(1))-9:dimensions(1)+downshift,:);

mergedimage = [baseimage(1:end-10,:);trimmedimagetoadd];

%section that stitches other wavelengths

if numel(horizontalmergecell{1,2})>=1

for n=1:numel(horizontalmergecell{1,2})
    oldimage = otherimagesout{n};
    newimage = imwarp(horizontalmergecell{count+1,2}{n},alignment,'OutputView',sizeref);
    trimmednewimage = newimage(ceil(.1*dimensions(1))-9:dimensions(1)+downshift,:);
    otherimagesout{n} = [oldimage(1:end-10,:);trimmednewimage];
end

end
    
    
%% temp display images for troubleshooting
%figure;imshow(imadjust(mergedimage))
%figure;imshow(imadjust(alignedimagetoadd))
%figure;imshow(imadjust(imagetoadd))

%figure;imshow(imadjust(top10p))
%figure;imshow(imadjust(bottom10p))
