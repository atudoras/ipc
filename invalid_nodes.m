function [n_out,Anew,Bnew,Dnew] = invalid_nodes(A,B,D,S,n,k,Nodesset)
    Anew = A;
    Bnew = B;
    Dnew = D;
    F = [Anew Bnew';Bnew Dnew];
    Nets = connected_components(F);
    idx = [];
    if exist('Nodesset','var')
        if ~isempty(Nodesset)
            idx = [idx Nodesset];
        end
    end
    for l=1:length(Nets)
        Set = Nets{l};
        result =  ~ismember(S, Set);
        result = all(result);
        if(result)
            idx = [idx Set];
        end
    end
    if exist('k','var')
        if ~isempty(k)
            if ~ismember(k, idx)
                idx = [idx k];
            end
        end
    end
    idx = unique(idx);
    idx_r = [];
    for kk=1:length(idx) %Eliminem aquests nodes de la xarxa
        node = idx(kk);
        if(node<=n) % Is a bus
            idx_r = [idx_r node];
            Anew(node,:) = 0;
            Anew(:,node) = 0;
            Bnew(:,node) = 0;
        else % Is a converter
            Bnew(node-n,:) = 0;
            Dnew(node-n,:) = 0;
            Dnew(:,node-n) = 0;
        end
    end
    n_out = length(idx_r);
end