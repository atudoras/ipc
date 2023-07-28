function a = aij_num(A,D)
    A_vec = cat(2,A{:});
    D_vec = cat(2,D{:});
    a = numel(A_vec) - numel(intersect(A_vec,D_vec));
end