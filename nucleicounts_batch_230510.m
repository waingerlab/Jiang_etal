%% Image stitching
addpath('H:\Scripts\Universal_functions','H:\Scripts\Image_Stitching') %make sure this is pointed to the correct directory
folders = glob('I:\Live cell imaging\TR-MN-hNIl-FA11-C9*\*\*\*\TimePoint_1'); %all the folders you would like to be stitched; can use wildcards in glob function to get multiple

rownumber = 5; %number of images per row
columnnumber =5; %number of images per column
wavelengthnumber = 2; %number of wavelengths
stitchwavelength = 1; %wavelength to use for stitching

for n=1:numel(folders)
    cd(folders{n});
    delete('*_thumb*.tif'); %deletes thumb files
    files = glob('*.tif');
    Stitcher_subtract_bgr_v2(files,rownumber,columnnumber,wavelengthnumber,stitchwavelength);
end

%stack images across timepoints (per well)
startfolder = glob('I:\Live cell imaging\TR-MN-hNIl-FA11-C9-D3-052223-BFPTL\TR-MN-FA11C9-D4-052223\2023-05-23\16304\TimePoint_1\Stitched_Images\*.tif');
newfolders = glob('I:\Live cell imaging\TR-MN-hNIl-FA11-C9*\*\*\*\TimePoint_1\Stitched_Images');
newfolders(1)=[]; %need to get rid of first folder
newfolders = [newfolders(4);newfolders(1);newfolders(2);newfolders(3)]; %Hi Tommaso, I actually had to re-order your files because matlab wasn't ordering them correctly. This line fixes that.
Stitch_Across_Time_v5(startfolder, newfolders,'color') %make sure to write 'color' here since there are multiple wavelengths
movefile('TimeStack_2','TR-P2-stacked','f'); %this just renames the folder

%% count nuclei number
addpath('H:\Scripts\Nuclei_counts','H:/Scripts/Universal_functions');
cd('I:\Live cell imaging\TR-MN-hNIl-FA11-C9-D3-052223-BFPTL\TR-P2-stacked');

files = glob('*.tif'); %can be changed

data = cell(numel(files),1);
channel=1; %this is which channel to count on

parfor n=1:numel(files)
    n
    workingfile = tifread(files{n});
    dimensions = size(workingfile);
    if numel(dimensions)==2
        dimensions(3:4)=1;
    end
    temp = zeros(1,dimensions(4),3);
    for nn=1:dimensions(4)
        [objectarray, objectmask, objectnumber, binarymask, estimatedmissedcells, meansize, multiobjectcenters] = object_mask_hist_v2(workingfile(:,:,channel,nn),3,2); %changed to 1st channel
        temp(1,nn,1) = objectnumber + estimatedmissedcells;
        temp(1,nn,2) = objectnumber;
        temp(1,nn,3) = estimatedmissedcells;
    end
    data{n} = temp;
end

data2 = cell2mat(data);    
xlswrite('nuclei_counts.xlsx',files,'Nuclei_Count','A1');
xlswrite('nuclei_counts.xlsx',data2(:,:,2),'Nuclei_Count','B1');