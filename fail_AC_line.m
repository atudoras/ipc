function Anew = fail_AC_line(i,j,A)
    Anew = A;
    Anew(i,j) = 0; Anew(j,i) = 0;
end