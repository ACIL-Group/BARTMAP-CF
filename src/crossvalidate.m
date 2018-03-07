%% clean up
fclose all; close all; clear; clc;

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

%% load cross-validation folds

load data/ml-100k-folds.mat;

%% open log file

f_log = fopen('cv.log', 'w');

%% loop over the different cross-validation folds
results = cell(1, numel(dataset));
for ix = 1:numel(dataset)
    %% extract the training data
    dx = dataset{ix};
    data = dx.train.matrix;
    
    %% call the BARTMAP algorithm using the training data
    t = tic;
    results{ix} = BARTMAP(data, params);
    results{ix}.train_time = toc(t);

    %% extract the test data
    userIds = dx.test.userIds;
    itemIds = dx.test.itemIds;
    ratings = dx.test.ratings;

    %% calculate the training error
    t = tic;
    results{ix}.predicted = BARTMAP_eval(data, results{ix}, userIds, itemIds);
    results{ix}.test_time = toc(t);
    results{ix}.errors = results{ix}.predicted - ratings;
    
    %% calculate the performance measures
    results{ix}.mean_abs_err = mean(abs(results{ix}.errors));
    results{ix}.mean_sq_err = mean(results{ix}.errors .^ 2);
    results{ix}.root_mean_sq_err = sqrt(results{ix}.mean_sq_err);

    %% write output to log file
    fprintf(f_log, '%d: MAE = %.2f, MSE = %.2f, RMSE = %.2f, T1 = %.2f, T2 = %.2f\n', ...
        ix, results{ix}.mean_abs_err, results{ix}.mean_sq_err, ...
        results{ix}.root_mean_sq_err, results{ix}.train_time, ...
        results{ix}.test_time);

    %% plot the absolute error histogram
    figure(ix); hist(abs(results{ix}.errors), 5);
    title(sprintf('Mean Absolute Error = %.2f', results{ix}.mean_abs_err));
    xlabel('Rating Difference'); 
    ylabel('Number of ratings');
    xlim([0, 5]);
    drawnow;
    
end

%% close log file
fclose(f_log);


