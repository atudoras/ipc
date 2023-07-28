function [data,id_faults_valid_n,id_faults_critical,Roles_combs,Ns] = n_faults_nr(k,A,B,D,S,id_faults_valid,faults,Roles_list)
    data = [];
    N = length(faults.Fault);
    subsets = []; count=0;
    Nv = length(id_faults_valid);
    subsets(1,:) = zeros(1,k);
    for i=1:Nv
        subset_i = id_faults_valid(i,:);
        for kkk=1:N
            if ~ismember(kkk, subset_i) %Si la falta x no esta en subset_i
                newsubset = sort([subset_i kkk]);
                if ~ismember(newsubset, subsets, 'rows') %Si el newsubset no esta dins dels subsets
                    %Si els subsets k-1 del newsubset estan com a valid faults
                    subsets_eval = nchoosek(newsubset, k-1);
                    if all(ismember(subsets_eval,id_faults_valid, 'rows'))
                        count=count+1;
                        subsets(count,:) = newsubset;
                    end
                end
            end
        end
    end
    Ns = length(subsets);
    y = zeros(1,Ns);
    N_out = zeros(1,Ns);
    Roles_combs = cell(1,length(Roles_list(:,1)));
    Fault_collection = cell(1, Ns);
    for i=1:Ns
        Fault_arr = cell(1,k);
        set = subsets(i,:);
        Anew = A; Bnew = B; Dnew = D;
        Nodes = [];
        for j=1:k
            ind = set(j);
            action = faults(ind,:);
            Fault_arr{j} = action;
            type = action.Type{1};
            fault = action.Fault{1};
            if strcmp(type,'Node')
                Nodes = [Nodes fault(1)];
            end
            [Anew,Bnew,Dnew] = fail_general(type,fault,Anew,Bnew,Dnew);
        end
        Fault_collection{i} = Fault_arr;
        [n_out,Anew,Bnew,Dnew] = invalid_nodes(Anew,Bnew,Dnew,S,length(Anew),[],Nodes);
        N_out(i) = n_out;
        ACz_new = AC_zones(Anew,Bnew,S);
        DCz_new = connected_components(Dnew);
        y(i) = num_valid_comb(length(Dnew),ACz_new,DCz_new);
        [~,~,ids_n] = valid_rolescomb(Roles_list,ACz_new,DCz_new);
        for idd = 1:length(ids_n)
            Roles_combs{ids_n(idd)} = [Roles_combs{ids_n(idd)};set];
        end
    end
    data.Faults = Fault_collection;
    data.lost_nodes = N_out;
    data.n_combinations = y;
    idx_n0 = find(data.lost_nodes >= length(A)-length(S));
    idx_c0 = find(data.n_combinations <= 0);
    idx_total = 1:length(data.lost_nodes);
    %idx_cr = unique([idx_n0 idx_c0]);
    idx_cr = unique([idx_n0]);
    idx_val = idx_total(~ismember(idx_total, idx_cr));
    id_faults_valid_n = zeros(length(idx_val),k);
    for ii=1:length(idx_val)
        faults_valid = data.Faults(idx_val(ii));
        faults_valid = faults_valid{1};
        idv = zeros(1,k);
        for jj=1:length(faults_valid)
            faultj = faults_valid{jj};
            idv(jj) = faultj.Id;
        end
        id_faults_valid_n(ii,:) = idv;
    end
    id_faults_critical = zeros(length(idx_cr),k);
    for ii=1:length(idx_cr)
        faults_crit = data.Faults(idx_cr(ii));
        faults_crit = faults_crit{1};
        idc = zeros(1,k);
        for jj=1:length(faults_crit)
            faultj = faults_crit{jj};
            idc(jj) = faultj.Id;
        end
        id_faults_critical(ii,:) = idc;
    end
end