function faults = list_faults(n,C,AC_lines,ACDC_lines,DC_lines)
    Type = cell(1,n+C+length(AC_lines)+length(ACDC_lines)+length(DC_lines));
    Fault = Type;
    % Node faults
    for k=1:n
        Type{k} = 'Node';
        Fault{k} = k;
    end
    % Converter faults
    for j=1:C
        k = j+n;
        Type{k} = 'Converter';
        Fault{k} = j;
    end
    % AC Line faults
    for j=1:length(AC_lines)
        k = j+n+C;
        Type{k} = 'AC';
        Fault{k} = AC_lines{j};
    end
    % ACDC Line faults
    for j=1:length(ACDC_lines)
        k = j+n+C+length(AC_lines);
        Type{k} = 'ACDC';
        Fault{k} = ACDC_lines{j};
    end
    % DC Line faults
    for j=1:length(DC_lines)
        k = j+n+C+length(AC_lines)+length(ACDC_lines);
        Type{k} = 'DC';
        Fault{k} = DC_lines{j};
    end
    Id=1:length(Type);
    faults = table(Type',Fault',Id','VariableNames', {'Type', 'Fault','Id'});
end