function d = dij_num(A,D)
    A_vec = cat(2,A{:});
    D_vec = cat(2,D{:});
    d = numel(D_vec) - numel(intersect(A_vec,D_vec));
end