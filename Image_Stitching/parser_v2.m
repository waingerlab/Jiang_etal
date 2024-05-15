%% This script accomplishes the same parser function, but for the cytation

% inputs are: filenames, the number of image rows, the number of image
% columns, and the number of wavelengths measured

function [organizedarray,wells] = parser_v2(files,rownumber,columnnumber,wavelengthnumber)

sitenumber = rownumber*columnnumber;
regexpnames = cell(numel(files),1);


%% section handling stitching if one wavelength provided
if wavelengthnumber ==1

for n=1:numel(files)
     longmatch = regexp(files{n},'\D\d\d_\D\d+\w\w\w\w\w\w\w\w-','match');
     longmatch = cell2mat(longmatch);
     regexpnames(n) = {strcat(longmatch(1:end-9),'_')};
end
    
wellinfo = cellfun(@(x) x(1:3),regexpnames,'UniformOutput',false);
wellinfo = cell2mat(wellinfo);
wells = unique(wellinfo,'rows');

organizedarray = cell(numel(wells(:,1)),1);

for n = 1:numel(wells(:,1))
    wellarray = cell(sitenumber,1);
    for nn = 1:sitenumber
        string = strcat(wells(n,:),'_s',int2str(nn),'_');
        index = find(contains(regexpnames,string));
        wellarray(nn)=files(index);
    end
    organizedarray{n} = wellarray;
end





%% section handling stitching if more than 1 wavelength provided
else

for n=1:numel(files)
    temp = regexp(files{n},'_\D\d\d_\D\d+_\D\d','match');
    regexpnames(n) = {temp{1}(2:end)};
end

wellinfo = cellfun(@(x) x(1:3),regexpnames,'UniformOutput',false);
wellinfo = cell2mat(wellinfo);
wells = unique(wellinfo,'rows');

organizedarray = cell(numel(wells(:,1)),1);


for n = 1:numel(wells(:,1))
    wellarray = cell(sitenumber*wavelengthnumber,1);
    for nn = 1:sitenumber
        for nnn = 1:wavelengthnumber
            string = strcat(wells(n,:),'_s',int2str(nn),'_w',int2str(nnn));
            index = find(contains(regexpnames,string));
            wellarray((nn*wavelengthnumber)-wavelengthnumber+nnn)=files(index);
        end
    end
    organizedarray{n} = wellarray;
end

end