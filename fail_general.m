function [Anew,Bnew,Dnew] = fail_general(type,fault,A,B,D)
    if strcmp(type,'Node')
        [Anew,Bnew] = fail_bus(fault,A,B);
        Dnew = D;
    elseif strcmp(type,'Converter')
        [Bnew,Dnew] = fail_converter(fault,B,D);
        Anew = A;
    elseif strcmp(type,'AC')
        Anew = fail_AC_line(fault(1),fault(2),A);
        Bnew = B;
        Dnew = D;
    elseif strcmp(type,'ACDC')
        Bnew = fail_DC_conv_bus(fault(1),fault(2),B);
        Anew=A;
        Dnew=D;
    elseif strcmp(type,'DC')
        Dnew = fail_DC_line(fault(1),fault(2),D);
        Anew=A;
        Bnew=B;
    else
        fprintf('Invalid fault format')
    end
end