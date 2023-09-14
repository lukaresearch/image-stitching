function H = Homography4(x, xp)

A = zeros(8);
b = zeros(8, 1);
for i=1:4
    k = i*2;
    
    A(k-1,:) = [x(i,1) x(i, 2) 1 0 0 0 -x(i,1)*xp(i,1) -x(i,2)*xp(i,1)];
    A(k, :) = [0 0 0 x(i,1) x(i,2) 1 -x(i,1)*xp(i,2) -x(i,2)*xp(i,2)];
    b(k-1) = xp(i,1);
    b(k) = xp(i,2);
end
%A
%b
h = A \ b;
H = [h(1:3)'; h(4:6)'; h(7:8)', 1];
