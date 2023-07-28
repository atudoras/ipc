function num = num_abbar(C,AC,DC)
    n = length(AC);
    M = length(DC);
    num = 0;
    % iterate over all possible binary sequences of length n
    for i = 1:2^n-1
        % convert the decimal number to binary
        bin_str = dec2bin(i, n);
        % use the binary sequence to index the elements of the vector
        subset_ac = 1:n;
        subset_ac = subset_ac(bin_str == '1');
        
        for j = 1:2^M-1

            % convert the decimal number to binary
            bin_str = dec2bin(j, M);
            % use the binary sequence to index the elements of the vector
            subset_dc = 1:M;
            subset_dc = subset_dc(bin_str == '1');
            
            sum_a = 0;
            for ia=1:length(subset_ac)
                sum_a = sum_a + aij_num(AC(subset_ac(ia)),DC(subset_dc));
            end

            sum_d = 0;
            for id=1:length(subset_dc)
                sum_d = sum_d + dij_num(AC(subset_ac),DC(subset_dc(id)));
            end

            fIJ = fij_num(AC(subset_ac),DC(subset_dc));

            num = num + ((-1)^(length(subset_ac)+length(subset_dc))) * ...
                (2^(sum_a+sum_d)) * (3^(C-sum_a-sum_d-fIJ));

        end
    end
end