%% specify a subset only because 100k takes too long

subset = 1:num_ratings;
userIds = dataset.userIds(subset);
itemIds = dataset.itemIds(subset);
ratings = dataset.ratings(subset);

%% calculate the training error
predicted = BARTMAP_eval(data, result, userIds, itemIds);
errors = predicted - ratings;

%% print some output
fprintf('%8s: %4s \t %4s \t %3s \t %3s \t %3s\n', 'Sample #', ...
    'Ui', 'Xi', 'Ri', 'Pi', 'Ei');
fprintf(repmat('-', 50, 1)); fprintf('\n');
fprintf('%8d: %4d \t %4d \t %0.1f \t %0.1f \t %0.1f\n', [...
    subset; userIds'; itemIds'; ratings'; predicted'; errors' ...
]);

%% plot the errors and calculate the performance measures
mean_abs_err = mean(abs(errors));
mean_sq_err = mean(errors .^ 2);
root_mean_sq_err = sqrt(mean_sq_err);

fprintf('MAE = %.2f, MSE = %.2f, RMSE = %.2f\n', ...
    mean_abs_err, mean_sq_err, root_mean_sq_err);

figure(4); hist(abs(errors), 5);
title(sprintf('Mean Absolute Error = %.2f', mean_abs_err));
xlabel('Rating Difference'); 
ylabel('Number of ratings');
xlim([0, 5]);



