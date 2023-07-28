function A = adj_mat(L,n)
    A = zeros(n,n);
    for k=1:length(L)
        line = L{k};
        A(line(1),line(2))=1;
        A(line(2),line(1))=1;
    end
end