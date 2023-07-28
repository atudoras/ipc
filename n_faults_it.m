function data = n_faults_it(k,A,B,D,S,id_faults_val,faults)
    data = [];
    N_val = length(faults_val);
    N_tot = height(faults);
    Ns = N_val*N_tot;
    y = zeros(1,Ns);
    N_out = zeros(1,Ns);
    Fault_collection = cell(1,Ns);
    ind=1;
    for i=1:N_val
        fault_vL = id_faults_val{i};
        for ii=1:N_tot
            if ~ismember(ii, fault_vL)
                Fault_arr = cell(1,k);
                Anew = A; Bnew = B; Dnew = D;
                
                for j=1:k-1
                    id_action = fault_vL(j);
                    action = faults(id_action,:);
                    Fault_arr{j} = action;
                    type = action.Type{1};
                    fault = action.Fault{1};
                    [Anew,Bnew,Dnew] = fail_general(type,fault,Anew,Bnew,Dnew);
                end
                for j=k:k
                    action = faults(ii,:);
                    Fault_arr{j} = action;
                    type = action.Type{1};
                    fault = action.Fault{1};
                    [Anew,Bnew,Dnew] = fail_general(type,fault,Anew,Bnew,Dnew);
                end
                Fault_collection{ind} = Fault_arr;
                [n_out,Anew,Bnew,Dnew] = invalid_nodes(Anew,Bnew,Dnew,S,length(Anew));
                N_out(ind) = n_out;
                ACz_new = AC_zones(Anew,Bnew,S);
                DCz_new = connected_components(Dnew);
                y(ind) = num_valid_comb(length(Dnew),ACz_new,DCz_new);
                ind = ind+1;
            end
        end
    end
    data.Faults = Fault_collection;
    data.lost_nodes = N_out;
    data.n_combinations = y;
end