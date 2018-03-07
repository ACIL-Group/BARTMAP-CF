function [rating] = BARTMAP_eval(data, model, user_id, item_id)
%BARTMAP_EVAL Apply the BARTMAP model to estimate the user-item rating

%% extract the model variables

user_clusters = model.user_clusters;
item_clusters = model.item_clusters;

%% normalize the data to the range [0, 1]

data = minmax_norm(data)';

%% handle multiple user and item indices
rating = zeros(size(user_id));
t = tic;
for ix = 1:numel(user_id)
    if toc(t) > 1
        t = tic;
        fprintf('%d\n', ix);
    end
    
    %% extract loop variables
    uix = user_id(ix);
    iix = item_id(ix);

    %% find the bicluster and separate the user's data
    user_ix = find(user_clusters == user_clusters(uix));
    if numel(user_ix) > 1 
        % guard against single-user clusters
        user_ix = user_ix(user_ix ~= uix);
    end
    item_ix = find(item_clusters == item_clusters(iix));
    bicluster = data(user_ix, item_ix);
    user_data = data(uix, item_ix);
    item_ix = find(item_ix == iix);

    %% predict item rating based on user cluster's mean
    rix = predictRating(bicluster, user_data, item_ix);

    %% map the rating back to the correct range
    if rix < 0
        rix = 0;
    elseif rix > 1
        rix = 1;
    end
    rix = rix * 5;
    
    %% assign the output
    rating(ix) = rix;
    
end
    
end

