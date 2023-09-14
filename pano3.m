function pano3(Left, Middle, Right, kpts1, kpts2, Path)
threshold = 0.01;
M = 100;

image0 = im2double(imread(Left));
image1 = im2double(imread(Middle));
image2 = im2double(imread(Right));

xx1 = dlmread(kpts1);
x1 = xx1(:,1:2);
xp1 = xx1(:,3:4);

xx2 = dlmread(kpts2);
x2 = xx2(:,1:2);
xp2 = xx2(:,3:4);

img0_row = size(image0, 1);
img0_col = size(image0, 2);
img1_row = size(image1, 1);
img1_col = size(image1, 2);
img2_row = size(image2, 1);
img2_col = size(image2, 2);
fprintf('image0: %d x %d, image1: %d x %d,  image2: %d x %d\n', img0_row, img0_col, img1_row, img1_col, img2_row, img2_col);

[H1, inliers1] = RANSAC(threshold, M, xp1, x1);
[H2, inliers2] = RANSAC(threshold, M, x2, xp2);
H1
H2

upper1 = H1* [1; 1; 1];
lower1 = H1 * [img1_row; 1; 1];

H2inv = inv(H2);
upper2 = H2inv * [1; img2_col; 1];
lower2 = H2inv * [img2_row; img2_col; 1];

panorama_col1 = floor(min(upper1(2)/upper1(3), lower1(2)/lower1(3)))
panorama_col2 = floor(min(upper2(2)/upper2(3), lower2(2)/lower2(3)))
panorama_col = panorama_col1 + panorama_col2
panorama_row = img1_row;
panorama = zeros(img1_row, panorama_col, 3);
panorama_begin_col1 = panorama_col1+1
panorama_end_col1 = panorama_col1+img1_col
panorama(:, panorama_begin_col1:panorama_end_col1,  :) = image1;

% RHS
cnt_overflow = 0;
for i=1:panorama_row
    for j=panorama_end_col1+1:panorama_col
        c = [i-1; j-1-panorama_col1; 1];
        cp = H2 * c;
        cx = cp(1)/cp(3);
        cy = cp(2)/cp(3);
        x0 = floor(cx);
        y0 = floor(cy);
        if(x0 < 1 || x0 > img2_row || y0 < 1 || y0 > img2_col)
            %fprintf('(%d, %d) ->  (%d, %d)\n', i,j, x0, y0);
            cnt_overflow = cnt_overflow+1;
        elseif(x0 == img2_row || y0 == img2_col) % points at bottom and right
            panorama(i, j, :) = image2(x0, y0, :);
        else % normal points
            panorama(i, j, :) = bilinear(cx - x0, cy - y0, image2(x0, y0, :), image2(x0, y0+1, :), image2(x0+1, y0, :), image2(x0+1, y0+1, :));
        end
    end
end
fprintf('cnt_overflow = %d\n', cnt_overflow);
%figure, imshow(panorama)

% LHS
cnt_overflow = 0;
for i=1:panorama_row
    for j=panorama_col1:-1:1
        c = [i-1; j-panorama_col1; 1];
        cp = H1 * c;
        cx = cp(1)/cp(3);
        cy = cp(2)/cp(3);
        x0 = floor(cx)+1;
        y0 = floor(cy)+1;
        if(x0 < 1 || x0 > img0_row || y0 < 1 || y0 > img0_col)
            %fprintf('(%d, %d) ->  (%d, %d)\n', i,j, x0, y0);
            cnt_overflow = cnt_overflow+1;
        elseif(x0 == img0_row || y0 == img0_col) % points at bottom and right
            panorama(i, j, :) = image0(x0, y0, :);
        else % normal points
            panorama(i, j, :) = bilinear(cx - x0, cy - y0, image0(x0, y0, :), image0(x0, y0+1, :), image0(x0+1, y0, :), image0(x0+1, y0+1, :));
        end
    end
end
fprintf('cnt_overflow = %d\n', cnt_overflow);
figure, imshow(panorama)

imwrite(panorama, strcat(Path, "panorama.jpg"));