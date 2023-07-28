function f = fij_num(A,D)
    A_vec = cat(2,A{:});
    D_vec = cat(2,D{:});
    f = numel(intersect(A_vec,D_vec));
end
