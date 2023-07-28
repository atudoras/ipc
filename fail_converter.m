function [Bnew,Dnew] = fail_converter(k,B,D)
    Bnew = B;
    Bnew(k,:) = 0;
    Dnew = D;
    Dnew(:,k) = 0;
    Dnew(k,:) = 0;
end