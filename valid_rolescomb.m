function [Roles_comb_valid,idy,idn] = valid_rolescomb(Roles_list,AC,DC)
    Roles_comb_valid = []; r=0;
    idy = []; idn = [];
    for k=1:length(Roles_list(:,1))
        role_comb = Roles_list(k,:);
        valid = true;
        a = 1;
        while(valid && a <= length(AC))
            acz = AC{a};
            if ~any(role_comb(acz)==1)
                valid = false;
            end
            a = a+1;
        end
        d = 1;
        while(valid && d <= length(DC))
            dcz = DC{d};
            if ~any(role_comb(dcz)==2)
                valid = false;
            end
            d = d+1;
        end
        if(valid)
            r = r+1;
            Roles_comb_valid(r,:) = role_comb;
            idy = [idy k];
        else
            idn = [idn k];
        end
    end
end