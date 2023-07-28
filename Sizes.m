function v = Sizes(A)
    n = length(A);
    v = zeros(1,n);
    for i=1:n
        v(i) = length(A{i});
    end
end