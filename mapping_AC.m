function nu = mapping_AC(comps)
    keys = [];
    values = [];
    for i=1:length(comps)
        comp = comps{i};
        for j=1:length(comp)
            keys(comp(j))=comp(j);
            values(comp(j))=i;
        end
    end
    nu = dictionary(keys,values);
end