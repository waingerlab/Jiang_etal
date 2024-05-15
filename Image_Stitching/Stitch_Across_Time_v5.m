%% This function works similarly to Stitch_Across_Time, but loads in stacks of images
%in version 5, it has been optimized for loading files with multiple colors

function timestack_folder = Stitch_Across_Time_v5(startfolder,newfolders,coloroption)

mkdir('TimeStack_2'); %make folder for writing out stacked images

if exist('coloroption','var') & strcmp(coloroption,'color') %this allows saveastiff to save the image in RGB
    options.color = true;
else options.color = false;
end

wells = cell(numel(startfolder),1);
for n=1:numel(wells)
    wells(n) = regexp(startfolder{n}, '[A-Z]\d+.tif','match');
end

% functional loop for stacking images
for n = 1:numel(wells)
    baseimage = squeeze(tifread(startfolder{n})); % read in previous stack as baseimage
    stacksize = size(baseimage); %must figure out the number of stacks in first image based on whether image is color or not
    if options.color == true
        if numel(stacksize)==3
            stacksize = 1;
        else stacksize = stacksize(4);end
    else
        if numel(stacksize)==3
            stacksize = stacksize(3);
        elseif numel(stacksize)==2;
            stacksize = 1;
        elseif numel(stacksize)==4;
            stacksize = stacksize(4);
        end
        baseimage = squeeze(baseimage); %eliminate the color dimension
    end

    for nn = 1:numel(newfolders)
        basedimensions = size(baseimage);
        basedimensions = basedimensions(1:2);
        newimage = squeeze(tifread(strcat(newfolders{nn},wells{n})));
        newimgdimensions = size(newimage);

        %if images are not the same size, they need to be cropped from the center of the image
        if basedimensions(1)>newimgdimensions(1)
            difference = basedimensions(1)-newimgdimensions(1);
            newXmin = floor(difference/2)+1;
            newXmax = basedimensions(1)-ceil(difference/2);
            if options.color == true
                baseimage = baseimage(newXmin:newXmax,:,:,:);
            else baseimage = baseimage(newXmin:newXmax,:,:); end;
        end

        if newimgdimensions(1)>basedimensions(1)
            difference = newimgdimensions(1)-basedimensions(1);
            newXmin = floor(difference/2)+1;
            newXmax = newimgdimensions(1)-ceil(difference/2);
            if options.color == true
                newimage = newimage(newXmin:newXmax,:,:);
            else newimage = newimage(newXmin:newXmax,:); end;
        end

        if basedimensions(2)>newimgdimensions(2)
            difference = basedimensions(2)-newimgdimensions(2);
            newYmin = floor(difference/2)+1;
            newYmax = basedimensions(2)-ceil(difference/2);
            if options.color == true
                baseimage = baseimage(:,newYmin:newYmax,:,:);
            else baseimage = baseimage(:,newYmin:newYmax,:); end;
        end

        if newimgdimensions(2)>basedimensions(2)
            difference = newimgdimensions(2)-basedimensions(2);
            newYmin = floor(difference/2)+1;
            newYmax = newimgdimensions(2)-ceil(difference/2);
            if options.color == true
                newimage = newimage(:,newYmin:newYmax,:);
            else newimage = newimage(:,newYmin:newYmax); end;
        end
        if options.color == true
            baseimage(:,:,:,nn+stacksize)=newimage;
        else baseimage(:,:,nn+stacksize)=newimage; end
    end
    basedimensions = size(baseimage);
    if basedimensions(3)==2
        baseimage(:,:,3,:)=zeros(basedimensions(1),basedimensions(2),1,basedimensions(4));
    end
    saveastiff(baseimage,strcat('TimeStack_2/','alltimepoints_',wells{n}),options); %I cannot simply append the new files because the original image size may change

end