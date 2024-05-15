%% This function concatenates uneven vectors into a matrix using NaNs to square them
function matrix_out = unevencat(cellarray_in)

celldim = max(size(cellarray_in));

vectordim = size(cellarray_in{1});
vectorsize = cellfun(@numel,cellarray_in);

if vectordim(1) ==1
    matrix_out = NaN(celldim, max(vectorsize));
    for n=1:celldim
        matrix_out(n,1:vectorsize(n))=cellarray_in{n};
    end
    
elseif vectordim(2) ==1
    matrix_out = NaN(max(vectorsize),celldim);
    for n=1:celldim
        matrix_out(1:vectorsize(n),n)=cellarray_in(n);
    end
else display('error: cellarray contents are not vectors');
end