function L = AC_zones(A,B,S)
    comps = connected_components(A);
    nu = mapping_AC(comps);
    
    AC_zones_t = compute_AC_zones(B,comps);
    % Identify empty cells
    %emptyCells = cellfun(@isempty, AC_zones_t);
    
    % Remove empty cells
    %AC_zones_t(emptyCells) = [];

    Snu = S;
    for i=1:length(Snu)
        Snu(i) = nu(S(i));
    end
    id_SG = unique(Snu);
    id_Total = 1:length(AC_zones_t);
    id_NSG = id_Total(~ismember(id_Total, id_SG));
    
    L = cell(1,length(id_NSG));
    for k=1:length(id_NSG)
        L{k} = AC_zones_t{id_NSG(k)};
    end
    % Identify empty cells
    emptyCells = cellfun(@isempty,L);
    
    % Remove empty cells
    L(emptyCells) = [];
end