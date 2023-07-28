function [Anew,Bnew] = fail_bus(k,A,B)
    Anew = A;
    Anew(k,:) = 0;
    Anew(:,k) = 0;
    Bnew = B;
    Bnew(:,k) = 0;
end