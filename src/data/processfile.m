function [output] = processfile(filename, num_users, num_items)
%PROCESSFILE Import file and process its data into a matrix

%% process file data

[userIds, itemIds, ratings] = importfile(filename);
data = zeros(num_items, num_users);
data(sub2ind(size(data), itemIds, userIds)) = ratings;

%% generate the output

output = struct( ...
    'userIds', userIds, ...
    'itemIds', itemIds, ...
    'ratings', ratings, ...
    'matrix', data ...
);

end

