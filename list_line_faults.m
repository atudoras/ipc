function faults = list_line_faults(AC_lines,ACDC_lines,DC_lines)
    Type = cell(1,length(AC_lines)+length(ACDC_lines)+length(DC_lines));
    Fault = Type;
    % AC Line faults
    for j=1:length(AC_lines)
        k = j;
        Type{k} = 'AC';
        Fault{k} = AC_lines{j};
    end
    % ACDC Line faults
    for j=1:length(ACDC_lines)
        k = j+length(AC_lines);
        Type{k} = 'ACDC';
        Fault{k} = ACDC_lines{j};
    end
    % DC Line faults
    for j=1:length(DC_lines)
        k = j+length(AC_lines)+length(ACDC_lines);
        Type{k} = 'DC';
        Fault{k} = DC_lines{j};
    end
    Id=1:length(Type);
    faults = table(Type',Fault',Id','VariableNames', {'Type', 'Fault','Id'});
end