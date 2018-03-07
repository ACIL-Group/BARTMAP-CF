function [W, clusters, num_clusters, iterations] = fuzzyART(data, rho, ...
    alpha, beta, max_epochs, W_init, num_clusters_init)
%FUZZYART Run the Fuzzy ART clustering algorithm on the given data
% For more information, see: 
% [1] G. Carpenter, S. Grossberg, and D. Rosen, "Fuzzy ART: Fast stable 
%     learning and categorization of analog patterns by an adaptive 
%     resonance system," Neural networks, vol. 4, no. 6, pp. 759–771, 1991

%% initialize variables

[num_samples, num_features] = size(data); 
num_inputs = num_features * 2;

if nargin > 5
    num_clusters = num_clusters_init;
    W = W_init;
else
    num_clusters = 0;
    W = ones(num_clusters+1, num_inputs);
end
    
W_old = zeros(num_clusters, num_inputs);

clusters = zeros(num_samples, 1);

iterations = 1;

%% complement-code the data

coded_data = zeros(num_samples, num_inputs);
for ix = 1:num_features
    coded_data(:,2*ix-1) = data(:,ix);
    coded_data(:,2*ix) = 1-data(:,ix);
end

%% repeat the learning until either convergence or max_epochs
while ~isequal(W_old, W) && iterations < max_epochs
    W_old = W;
    %% present the input patters to the Fuzzy ART module
    for ix = 1:num_samples
        pattern = coded_data(ix,:);
        %% calculate the category choice values
        matches = zeros(1, num_clusters+1);
        min_norms = zeros(1, num_clusters+1); % we will need those again
        for jx = 1:num_clusters+1
            min_norms(jx) = norm(min(pattern, W(jx,:)), 1);
            matches(jx) = min_norms(jx) ./ (alpha + norm(W(jx,:), 1));
        end
        %% pick the winning category
        % move pattern norm to right side of inequality to speed things up
        vigilance_test = rho * norm(pattern, 1); 
        while true
            %% winner-take-all selection
            % we only care about the index of the winning neuron
            [~, jx] = max(matches);
            
            %% vigilance test
            if min_norms(jx) >= vigilance_test
                % the winning category passed the vigilance test
                clusters(ix) = jx;
                break;
            else
                % shut off this category from further testing
                matches(jx) = 0;
            end
        end
        %% update the weight of the winning neuron
        W(jx,:) = beta * min(pattern, W(jx,:)) + (1-beta) * W(jx,:);
        %% check if the uncommitted node was the winner
        if jx > num_clusters
            % add a new uncommitted node
            num_clusters = num_clusters + 1;
            W = [ W ; ones(1, num_inputs) ];
        end
    end
    iterations = iterations + 1;
end

end

