function comps = connected_components(adj_mat)
    
    % Initialize the list of visited nodes and the list of connected components
    visited = false(1, size(adj_mat, 1));
    comps = {};
    
    % Perform a depth-first search for each unvisited node
    for node = 1:size(adj_mat, 1)
        if ~visited(node)
            % Initialize the current connected component
            comp = [];
            stack = node;
            
            % Perform the depth-first search
            while ~isempty(stack)
                curr = stack(end);
                stack(end) = [];
                
                if ~visited(curr)
                    visited(curr) = true;
                    comp = [comp curr];
                    neighbors = find(adj_mat(curr, :));
                    stack = [stack neighbors];
                end
            end
            
            % Add the current connected component to the list of components
            comps{end+1} = comp;
        end
    end
    
    % Compute the number of connected components and their sizes
    % num_comps = length(comps);
    % comp_sizes = cellfun(@length, comps);
    
    % Print the results
    % fprintf('Number of connected components: %d\n', num_comps);
    % fprintf('Size of each connected component: ');
    % disp(comp_sizes);
    
    % Print the list of nodes in each connected component
    % fprintf('List of nodes in each connected component:\n');
    % for i = 1:num_comps
    %     fprintf('Component %d: ', i);
    %     fprintf('%d ', comps{i});
    %     fprintf('\n');
    % end
end