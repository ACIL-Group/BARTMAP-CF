function [result] = BARTMAP(data, params)
%BARTMAP Run the Biclustering ARTMAP algorithm on the given data

%% extract algorithm parameters

rho_items = params.rho_items;
alpha_items = params.alpha_items;
beta_items = params.beta_items;
max_epochs_items = params.max_epochs_items;

correlation_threshold = params.correlation_threshold;

rho_users = params.rho_users;
alpha_users = params.alpha_users;
beta_users = params.beta_users;
max_epochs_users = params.max_epochs_users;

step_size = params.step_size;


%% read dataset attributes

[num_items, num_users] = size(data);

%% normalize the data to the range [0, 1]

data = minmax_norm(data);

%% call the Fuzzy ART algorithm for ART_b

[W_b, item_clusters, num_item_clusters, ~] = fuzzyART(data, ...
    rho_items, alpha_items, beta_items, max_epochs_items);

%% perform the biclustering using the ART_a module

num_user_clusters = 0;
W_a = ones(num_user_clusters+1, num_items*2);
user_clusters = zeros(num_users, 1);

data = data';   % transpose the data to look at the other dimension

t = tic;
%% present the user data one by one to ART_a
for ix=1:num_users
    % fprintf('%4d: %2d [', ix, num_user_clusters);
    if toc(t) > 1
        t = tic;
        fprintf('%d\n', ix);
    end
    
    %% initialize inner loop variables
    rho_init = rho_users;
    
    %% Fuzzy ARTMAP training loop per user
    while true
        %% present user data to ART_a module
        [W_a_temp, user_clusters_temp, num_user_clusters_temp, ~] = ...
            fuzzyART(data(ix,:), rho_init, alpha_users, beta_users, ...
            max_epochs_users, W_a, num_user_clusters);
        
        user_clusters(ix) = user_clusters_temp;
        % fprintf(' %d', user_clusters_temp);

        %% check if the user was assigned to an existing or new cluster
        if num_user_clusters == num_user_clusters_temp 
            %% the user was assigned to an existing cluster
            % compute the average correlations between this user and
            % each user/item bicluster
            correlations = zeros(1, num_item_clusters);
            user_ix = find(user_clusters == user_clusters_temp);
            user_ix = user_ix(user_ix ~= ix);
            for jx = 1:num_item_clusters
                item_ix = find(item_clusters == jx);
                bicluster = data(user_ix, item_ix);
                user_data = data(ix, item_ix);
                correlations(jx) = biclusterCorr(bicluster, user_data);
            end
            
            %% check the correlation threshold
            if ~isempty(find(correlations > correlation_threshold, 1))
                % carry out the weight update and go to next user
                W_a = W_a_temp;
                break;
            else
                % increase the vigilance threshold and try again
                rho_init = rho_init + step_size;
                if rho_init > 1
                    rho_init = 1;
                end
            end
            
        else
            %% new cluster created; always allow new clusters
            W_a = W_a_temp;
            num_user_clusters = num_user_clusters_temp;
            % fprintf(' *');
            break;
        end
    end
    % fprintf(' ]\n');
end

%% return results

result = struct();

result.W_b = W_b;
result.item_clusters = item_clusters;
result.num_item_clusters = num_item_clusters;

result.W_a = W_a;
result.user_clusters = user_clusters;
result.num_user_clusters = num_user_clusters;

end

