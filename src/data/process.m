%% initialize variables
dataset = cell(1,5);

num_users = 943;
num_items = 1682;
num_classes = 5;
file_prefix = 'ml-100k/u';

%% read the data files u1 through u5
for ix = 1:5
    dataset{ix} = struct('train', [], 'test', []);
    
    %% import the training file
    dataset{ix}.train = processfile(sprintf('%s%d.base', file_prefix, ix), ...
        num_users, num_items);

    %% import the testing file
    dataset{ix}.test = processfile(sprintf('%s%d.test', file_prefix, ix), ...
        num_users, num_items);
    
end
