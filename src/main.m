%% clean up
fclose all; close all; clear; clc;

%% load data

load data/ml-100k.mat;
data = dataset.matrix;
[num_items, num_users] = size(data);
num_classes = numel(unique(nonzeros(data)));
num_ratings = numel(dataset.ratings);

%% set the algorithm parameters

params = struct();

params.rho_items = 0.15;
params.alpha_items = 0.001;
params.beta_items = 1.0;
params.max_epochs_items = 100;

params.correlation_threshold = 0.15;

params.rho_users = 0.35;
params.alpha_users = 0.001;
params.beta_users = 1.0;
params.max_epochs_users = 100;

params.step_size = 0.05;

%% call the BARTMAP algorithm

result = BARTMAP(data, params);

%% plot the data as an image

figure(1); imagesc(data'); colorbar();
title(sprintf('Ratings: %d to %d', min(unique(data)), max(unique(data))));
xlabel(sprintf('Item Index (1-%d)', num_items)); 
ylabel(sprintf('User Index (1-%d)', num_users));

%% show a bar graph of the item clusters

figure(2); bar(result.item_clusters);
title(sprintf('Item Clusters: %d', result.num_item_clusters));
xlabel(sprintf('Item Index (1-%d)', num_items)); 
ylabel(sprintf('Assigned Cluster (1-%d)', result.num_item_clusters));
ylim([0, result.num_item_clusters+1]);

%% show a bar graph of the user clusters

figure(3); bar(result.user_clusters);
title(sprintf('User Clusters: %d', result.num_user_clusters));
xlabel(sprintf('User Index (1-%d)', num_users)); 
ylabel(sprintf('Assigned Cluster (1-%d)', result.num_user_clusters));
ylim([0, result.num_user_clusters+1]);

