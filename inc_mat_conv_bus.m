function B = inc_mat_conv_bus(L,n,C)
    B = zeros(C,n);
    for k=1:length(L)
        line = L{k};
        B(line(1),line(2))=1;
    end
end