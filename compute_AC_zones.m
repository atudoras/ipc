function zones = compute_AC_zones(B,comps)
    Bbar = [];
    for i=1:length(comps)
        Bbar(:,i) = sum(B(:,comps{i}),2);
    end
    H = @(x) (x > 0);
    Bbar = H(Bbar);

    zones = {};

    % Loop over each column of the matrix
    for i = 1:size(Bbar, 2)
        % Find the row indices of the nonzero elements in the current column
        [row, ~] = find(Bbar(:, i));
        % Store the row indices in the cell array for the current column
        zones{i} = row';
    end
end