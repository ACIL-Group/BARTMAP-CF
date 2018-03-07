function [result, bicorr] = biclusterCorr(bicluster, user_data)
%BICLUSTERCORR Compute correlation between a user and a user/item bicluster

%% preallocate correlation vector
num_users = size(bicluster, 1);
bicorr = zeros(1, num_users);

%% compute the correlation for each pair of users
for ix = 1:num_users
    %% calculate the co-mean of this pair of users
    [u1_mean, u2_mean, coMask] = coMean(user_data, bicluster(ix, :));
    %% compute the terms for all the item values
    terms1 = user_data(coMask) - u1_mean;
    terms2 = bicluster(ix, coMask) - u2_mean;
    %% compute the sums to find the user-pair correlation
    numerator = sum(terms1 .* terms2);
    root1 = sqrt(sum(terms1 .* terms1));
    root2 = sqrt(sum(terms2 .* terms2));
    if root1 == 0 || root2 == 0
        bicorr(ix) = 0;
    else
        bicorr(ix) = numerator / (root1 * root2);
    end
end

%% compute the final correlation coefficient for bicluster
result = mean(bicorr);

end
