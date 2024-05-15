%% Subfunction that takes a matrix, otsu thresholds the matrix, and then outputs masks
%Inputs: channel_matrix (matrix of tifimage to be thresholded),
%minimumradius (minimum size of objects to detect
function [objectarray, objectmask, objectnumber, binarymask, estimatedmissedcells, meansize, multiobjectcenters] = object_mask_hist_v2(channel_matrix,minimumradius,stdevs)

dimensions = size(channel_matrix);
binarymask = histmask_v2(channel_matrix,stdevs);% calculates mask using Otsu method

distancemask = bwdist(~binarymask);% calculates distance from pixel to background

%This block is necessary in case the entire frame is falsely recognized as
%DAPI+
if sum(binarymask,'all')>(dimensions(1)*dimensions(2)*.9)
    distancemask = zeros(dimensions(1),dimensions(2),'single');
end

% use distancemask by comparing maximum values, finding the central one,
% and storing it
peakmask = zeros(dimensions(1),dimensions(2),'double');
[rows, col] = find(distancemask>minimumradius); %minimum radius value

%find if distancemask value is higher than neighbors by making second mask
for n=1:numel(rows)
    xmin = rows(n)-1;
    xmax = rows(n)+1;
    ymin = col(n)-1;
    ymax = col(n)+1;
    if xmin<1; xmin=1;end
    if xmax>dimensions(1); xmax=dimensions(1);end
    if ymin<1; ymin=1;end
    if ymax>dimensions(2); ymax=dimensions(2);end
    area = (xmax-xmin+1)*(ymax-ymin+1);
    value = sum(distancemask(xmin:xmax,ymin:ymax),'all');
    normval = value/area;
    peakmask(rows(n),col(n))=normval;
end

%set range (value +/- 1) to minimum radius
hits = [];
for n=1:numel(rows)
    xmin = rows(n)-10;
    xmax = rows(n)+10;
    ymin = col(n)-10;
    ymax = col(n)+10;
    if xmin<1; xmin=1;end
    if xmax>dimensions(1); xmax=dimensions(1);end
    if ymin<1; ymin=1;end
    if ymax>dimensions(2); ymax=dimensions(2);end
    if peakmask(rows(n),col(n))==max(peakmask(xmin:xmax,ymin:ymax),[],'all') %this will lead to an error if there are multiple peaks with the same value
        hits = [hits; rows(n),col(n)];
    end
end

%identify conflicts where multiple peaks were recognized for the same
%nucleus

%use find approach to identify points that are too close together, use a
%while loop to delete the second point that is too close together. while
%loop is necessary in order to delete as it progresses in order to prevent
%both conflict points from being marked

revisedhits=hits;
n=1;
while n < numel(revisedhits(:,1))
    delta = revisedhits-revisedhits(n,:);
    deltasq = delta.^2;
    distance = (deltasq(:,1)+deltasq(:,2)).^.5;
    if find(distance<10 & distance>0)>0
        delrow = find(distance<10 & distance>0);
        revisedhits(delrow,:)=[];
    else n=n+1;
    end        
end



%% New section that matches pixels to objects using "grow" methodology, may take a bit of time
xcoord = revisedhits(:,1);
ycoord = revisedhits(:,2);
assignment = [1:numel(xcoord)]';
index = sub2ind([dimensions(1) dimensions(2)],xcoord,ycoord);
dmvalues = distancemask(index);
objects = [assignment, dmvalues, xcoord,ycoord];

distancemask(distancemask==Inf) = 0;

for n = floor(max(distancemask,[],'all')):-0.5:0.5;
    assignment = objects(:,1);
    testx1 = objects(:,3)-1;
    testx2 = objects(:,3)+1;
    testy1 = objects(:,4)-1;
    testy2 = objects(:,4)+1;
    
    test = [assignment, testx1, objects(:,4); assignment testx2, objects(:,4); assignment, objects(:,3), testy1; assignment, objects(:,3), testy2]; %this makes matrix of testpoints
    %throw out values of test that don't satisfy conditions
    delind = test(:,2)<1;
    test(delind,:)=[];
    delind = test(:,3)<1;
    test(delind,:)=[];
    delind = test(:,2)>dimensions(1);
    test(delind,:)=[];
    delind = test(:,3)>dimensions(2);
    test(delind,:)=[];
    
    %assign distancemask values to test
    index =sub2ind([dimensions(1) dimensions(2)],test(:,2), test(:,3));
    dmvalues = distancemask(index);
    test = [test(:,1), dmvalues, test(:,2), test(:,3)]; %test is now assignment, distancemask values, xcoordinate, ycoordinate
    
    %delete pixels where dmvalues do not fall within range
    index = test(:,2)>n;
    test= test(index,:);
    
    %delete pixels where assignment is attempted twice or where pixel is
    %already assigned
    if numel(test)>1 %need to include this in case number of test pixels left is 0
    [test2, ia, ic] = unique(test(:,[3 4]),'rows'); %this call+next line removes pixels called by multiple objects
    test = test(ia,:);
    [C, ia, ib] = intersect(objects(:,[3,4]),test(:,[3,4]),'rows');
    test(ib,:) = []; %deletes values where testpixel is already claimed by objects
    objects = [objects;test]; %pixels have passed testing and are now added to the object matrix
    end
end
    
%make mask from objects matrix, may also take a while
objectarray = cell(numel(revisedhits)/2,1); 
for n = 1:numel(revisedhits)/2;
    index = objects(:,1)==n;
    match = objects(index,:);
    objectarray{n} = match;
end
    
%calculate parameters and exclude large objects
cellsize = cellfun(@numel,objectarray)/3;
mediansize = median(cellsize);
multinuclear = find(cellsize>(2.5*mediansize));%no objects larger than 8,000 pixels included- no accurate estimate from these
multinuclearobjects = objectarray(multinuclear);
objectarray(multinuclear) = [];
multinuclearobjects(cellfun(@numel,multinuclearobjects)>8000) = []; %gets rid of objects larger than 8000 pixels (likely errors, not able to estimate accurately)

multiobjectcenters = revisedhits(multinuclear,:);
revisedhits(multinuclear,:) =[];

multinucleararea = sum(cellfun(@numel,multinuclearobjects)/3);
objectnumber = numel(objectarray);
mediansize2 = median(cellfun(@numel,objectarray)/3);
estimatedmissedcells = floor(multinucleararea/mediansize2);
meansize = mean(cellfun(@numel,objectarray)/3);

objectmask = zeros(dimensions(1),dimensions(2),'uint16');

for n=1:numel(objectarray)
    indices = sub2ind([dimensions(1) dimensions(2)],objectarray{n}(:,3),objectarray{n}(:,4));
    objectmask(indices)=n;
end        

%figure
%imshow(label2rgb(objectmask,'jet','k','shuffle'))
%hold on
%scatter(revisedhits(:,2),revisedhits(:,1),'k')            