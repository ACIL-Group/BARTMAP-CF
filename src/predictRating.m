function [result] = predictRating(bicluster, user_data, item_ix)
%PREDICTRATING Predict user's rating for item based on bicluster data

%% compute the correlation for each pair of users
[~, bicorr] = biclusterCorr(bicluster, user_data);

%% calculate the user's average rating
ix = find(user_data > 0);
ix = ix(ix ~= item_ix);
if ~isempty(ix)
    % guard against users with no ratings in cluster
    user_mean = mean(user_data(ix));
else
    user_mean = 0.5;
end

%% calculate the item's weighted average rating
user_ix = bicluster(:, item_ix) > 0;
item_data = bicluster(user_ix, item_ix);
corr_data = bicorr(user_ix)';
if ~isempty(item_data) && nnz(corr_data) > 0
    % guard against items with no ratings in cluster and zero correlations
    item_mean = mean(item_data);
    result = sum(corr_data .* (item_data - item_mean)) / sum(abs(corr_data));
else
    result = 0;
end

%% compute the final prediction for this item
result = user_mean + result;

end

