function [Homography, inliers] = RANSAC(threshold, M, xy, xyp)
N = length(xy);

NinlierMax = 0;
inlier = zeros(N, 1);
inlierMax = zeros(N, 1);
HMax = zeros(3);
TMax = zeros(3);
TpMax = zeros(3);
for m=1:M
    p = randperm(N);
    q = p(1:4);

    % normalized by similarity transform
    [T, x] = similarity(q, xy);
    [Tp, xp] = similarity(q, xyp);
    H = Homography4(x(q, :), xp(q, :));
 
    % find inliers
    Ninlier = 0;
    for i=1:N
        Hx = H * [x(i, :)'; 1];
        Hx = Hx/Hx(3);
        xdelta = xp(i, :)' - Hx(1:2);
        dist = sqrt(xdelta' * xdelta);
        if(dist < threshold)
            Ninlier = Ninlier + 1;
            inlier(Ninlier) = i;
        end
    end
    fprintf('[%d] Ninlier: %d\n', m, Ninlier);
    
    if(NinlierMax < Ninlier)
        NinlierMax = Ninlier;
        inlierMax = inlier;
        HMax = H;
        TMax = T;
        TpMax = Tp;
        hmax = [H(1,:) H(2,:) H(3,:)]
        fprintf("NinlierMax: %d\n", NinlierMax);
    end
end

inliers = inlierMax(1:NinlierMax);
s = TpMax(1,1);
r = 1/s;
Tpinv = [r 0 -r*TpMax(1,3); 0 r -r*TpMax(2,3); 0 0 1];
TMax
TpMax
Homography = Tpinv * HMax * TMax;  % xp = H x