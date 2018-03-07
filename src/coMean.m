function [Xmean, Ymean, coMask, coCount] = coMean(X, Y)
%COMEAN Find the means of X and Y only for where X and Y are both nonzero

coMask = X > 0 & Y > 0;
Xmean = mean(X(coMask));
Ymean = mean(Y(coMask));
coCount = sum(coMask);

end

