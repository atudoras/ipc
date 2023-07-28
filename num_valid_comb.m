function n = num_valid_comb(C,AC_ns,DC)
    AC_sizes = Sizes(AC_ns);
    DC_sizes = Sizes(DC);
    c_Abar = num_abar(C,AC_sizes);
    c_Bbar = num_bbar(C,DC_sizes);
    c_ABbar = num_abbar(C,AC_ns,DC);
    c_S = 3^C;
    
    n = c_S-c_Abar-c_Bbar+c_ABbar;
end