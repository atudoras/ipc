function Dnew = fail_DC_line(i,j,D)
    Dnew = D;
    Dnew(i,j) = 0; Dnew(j,i) = 0;
end