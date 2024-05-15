%% This function converts numbers to excel columns
function [excelcolumn] = num2excelcolumn(inputnumber)
alphabet = ['A':'Z']';
excelcolumn = num2cell(alphabet(1+rem(inputnumber-1,26)));
overflow = fix((inputnumber-1)/26);

while any(overflow)
    excelcolumn(overflow>0) = strcat(alphabet(1+rem(overflow(overflow>0)-1,26)),excelcolumn(overflow>0));
    overflow = fix((overflow-1)/26);
end

excelcolumn = char(excelcolumn);
