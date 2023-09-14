% find similarity transformation using 4-point normalization
function [T, Txy] = similarity(p, x0) % x0: N x 2

if(length(p) ~= 4)
    fprintf("Error: number of points must be 4\n")
    return
end
x = x0(p, :);  % x: 4 x 2
xmean = [mean(x(:, 1)) mean(x(:, 2))];

dist = 0;
for i=1:4
    dx = x(i, :) - xmean;  
    dist = dist + sqrt(dx * dx');
end
s = 4 * sqrt(2) / dist;
tx = -s*xmean(1);
ty = -s*xmean(2);

T = [s 0 tx; 0 s ty; 0 0 1];
Txy = [s*x0(:, 1) + tx, s*x0(:, 2) + ty];