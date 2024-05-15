%% Function that stitches a folder of images together
function TIF = Stitcher_subtract_bgr_v2(files,rownumber,columnnumber,wavelengthnumber,stitchwavelength,coloroption)

%this version trims the bottom of horizontalmerge output so that the
%vertical aligner doesn't stitch with black space errors

%Example Inputs
%rownumber = 6;
%columnnumber = 6;
%wavelengthnumber = 3;
%stitchwavelength = 1;
%color = 'color'
%files = glob('AH*');

%% function
[orderedfiles, wellnames] = parser_v2(files,rownumber,columnnumber,wavelengthnumber);

mkdir('Stitched_Images');
if exist('coloroption','var') & strcmp(coloroption,'color') %this allows saveastiff to save the image in RGB
    options.color = true;
else options.color = false;
end

%loop that begins stitching
parfor n = 1:numel(orderedfiles) %THIS CAN BE MADE INTO A PARFOR LOOP IF RAM IS LARGE ENOUGH
    horizontalmergecell = cell(rownumber,2);
    tempindex = orderedfiles{n}; %this is  used when the stitcher is called
    for nn = 1:rownumber
        
        %this section sets up the wavelength being used to merge images
        baseimageindex = (nn*columnnumber*wavelengthnumber)-(wavelengthnumber*columnnumber)+stitchwavelength;
        otherwavelengthsindex = setdiff((1:wavelengthnumber),stitchwavelength);
        baseimage = tifread_subtract(orderedfiles{n}{baseimageindex});
        
        %this section sets up other wavelengths for stitching
        otherimagesout = cell(1,numel(otherwavelengthsindex));
        for nnn = 1:numel(otherwavelengthsindex)
            otherimagesout{nnn} = tifread_subtract(orderedfiles{n}{(nn*columnnumber*wavelengthnumber)-(wavelengthnumber*columnnumber)+otherwavelengthsindex(nnn)});
        end
        
        %this section calls to the stitcher
        for nnn = 1:columnnumber-1
            imagetoaddindex = baseimageindex+(wavelengthnumber*nnn);
            imagetoadd = tifread_subtract(orderedfiles{n}{baseimageindex+(wavelengthnumber*nnn)});
            [baseimage,otherimagesout] = horizontalaligner_subtract_v2(baseimage,imagetoadd,tempindex,imagetoaddindex,stitchwavelength,otherimagesout,otherwavelengthsindex);
        end
        horizontalmergecell{nn,1}= baseimage;
        horizontalmergecell{nn,2}= otherimagesout;        
    end
    
    %this section now does vertical merging
    baseimage = horizontalmergecell{1,1}(1:end-1,:);
    otherimagesout = cell(1,numel(otherwavelengthsindex));
    for nn = 1:numel(otherwavelengthsindex)
        otherimagesout{nn} = horizontalmergecell{1,2}{nn}(1:end-1,:);
    end
    
    for nn = 1:rownumber-1
        imagetoadd = horizontalmergecell{nn+1,1}(1:end-1,:);
        [baseimage,otherimagesout] = verticalaligner_v3(baseimage,imagetoadd,horizontalmergecell,nn,otherimagesout);
    end
    
    %this section takes previous stitching and makes a TIF
    dimensions = size(baseimage);

    
    %% WORKING HERE TO GET WRITING COLOR CORRECT
    if options.color == true & wavelengthnumber == 3
        TIF = zeros(dimensions(1),dimensions(2),3,'uint16'); %TIF color needs three dimensions
        if stitchwavelength == 1; 
            TIF(:,:,1) = baseimage;
            TIF(:,:,2) = otherimagesout{1};
            TIF(:,:,3) = otherimagesout{2};
        elseif stitchwavelength == 2; 
            TIF(:,:,1) = otherimagesout{1};
            TIF(:,:,2) = baseimage;
            TIF(:,:,3) = otherimagesout{2};
        elseif stitchwavelength == 3; 
            TIF(:,:,1) = otherimagesout{1};
            TIF(:,:,2) = otherimagesout{2};
            TIF(:,:,3) = baseimage;
        end
    
    elseif options.color == true & wavelengthnumber == 2
        TIF = zeros(dimensions(1),dimensions(2),3,'uint16'); %TIF color needs three dimensions
        if stitchwavelength == 1;
            TIF(:,:,1) = baseimage;
            TIF(:,:,2) = otherimagesout{1};
        elseif stitchwavelength == 2;
            TIF(:,:,1) = otherimagesout{1};
            TIF(:,:,2) = baseimage;
        end
        
    elseif options.color ==true & wavelengthnumber == 4
        TIF = zeros(dimensions(1),dimensions(2),4,'uint16');    
        if stitchwavelength == 1; 
            TIF(:,:,1) = baseimage;
            TIF(:,:,2) = otherimagesout{1};
            TIF(:,:,3) = otherimagesout{2};
            TIF(:,:,4) = otherimagesout{3};
        elseif stitchwavelength == 2; 
            TIF(:,:,1) = otherimagesout{1};
            TIF(:,:,2) = baseimage;
            TIF(:,:,3) = otherimagesout{2};
            TIF(:,:,4) = otherimagesout{3};
        elseif stitchwavelength == 3; 
            TIF(:,:,1) = otherimagesout{1};
            TIF(:,:,2) = otherimagesout{2};
            TIF(:,:,3) = baseimage;
            TIF(:,:,4) = otherimagesout{3};
        elseif stitchwavelength == 4;
            TIF(:,:,1) = otherimagesout{1};
            TIF(:,:,2) = otherimagesout{2};
            TIF(:,:,3) = otherimagesout{3};
            TIF(:,:,4) = baseimage;
        end
        
    else
        TIF = zeros(dimensions(1),dimensions(2),numel(otherimagesout)+1,'uint16');
        TIF(:,:,1)=baseimage;
        if numel(otherimagesout)>0;
            for nn=1:numel(otherimagesout)
                TIF(:,:,nn+1)=otherimagesout{nn};
            end
        end
    end
    
    saveastiff(TIF,strcat('Stitched_Images/',wellnames(n,:),'.tif'),options)
end
