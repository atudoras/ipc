function num = num_bbar(C,DC_sizes)
    n = length(DC_sizes);
    num = 0;
    % iterate over all possible binary sequences of length n
    for i = 1:2^n-1
        % convert the decimal number to binary
        bin_str = dec2bin(i, n);
        % use the binary sequence to index the elements of the vector
        subset = 1:n;
        subset = subset(bin_str == '1');

        s = sum(DC_sizes(subset));
        num = num + ((-1)^(length(subset)+1)) * (2^s) * (3^(C-s));
    end
end