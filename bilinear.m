function fxy = bilinear(a, b, fA, fB, fC, fD)

% A[x0, y0]               B[x0, y0+1]
%              [x,y]
% C[x0+1, y0]             D[x0+1, y0+1]

fxy = fA*(1-a)*(1-b) + fB*(1-a)*b + fC*a*(1-b) + fD*a*b;