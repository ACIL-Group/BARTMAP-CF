function [output] = minmax_norm(input, range)
%MINMAX_NORM Normalize the input to map it to range, [0, 1] by default

%% set default argument values
if nargin < 2
    range = [0, 1];
end

%% find the range of input values
x = input(:);
xmin = min(x);
xmax = max(x);

ymin = range(1);
ymax = range(2);

output = (ymax - ymin) * (input - xmin) / (xmax - xmin) + ymin;

end

