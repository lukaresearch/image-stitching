function pano2_normalized(n, Left, Right, kpts, Path)
threshold = 0.01;
M = 100;

if(n == 1)
    image1 = im2double(imread(Left));
else
    image1 = im2double(imread(strcat(Path, "panorama.jpg")));
    H1 = dlmread(strcat(Path, "H.txt"));
end
image2 = im2double(imread(Right));

xx = dlmread(kpts);
x = xx(:,1:2);
xp = xx(:,3:4);

img1_row = size(image1, 1);
img1_col = size(image1, 2);
img2_row = size(image2, 1);
img2_col = size(image2, 2);
fprintf('image1: %d x %d,  image2: %d x %d\n', img1_row, img1_col, img2_row, img2_col);

[H, inliers] = RANSAC(threshold, M, x, xp);
H

if(n > 1)
    H = H * H1
end

Hinv = inv(H);
upper = Hinv * [1; img2_col; 1];
lower = Hinv * [img2_row; img2_col; 1];

panorama_col = floor(min(upper(2)/upper(3), lower(2)/lower(3)))
panorama_row = img1_row;
panorama = zeros(img1_row, panorama_col, 3);
panorama(:, 1:img1_col,  :) = image1;

cnt_overflow = 0;
for i=1:panorama_row
    for j=img1_col+1:panorama_col
        c = [i-1; j-1; 1];
        cp = H * c;
        cx = cp(1)/cp(3);
        cy = cp(2)/cp(3);
        x0 = floor(cx);
        y0 = floor(cy);
        if(x0 < 1 || x0 > img2_row || y0 < 1 || y0 > img2_col)
%            fprintf('(%d, %d) ->  (%d, %d)\n', i,j, x0, y0);
            cnt_overflow = cnt_overflow+1;
        elseif(x0 == img2_row || y0 == img2_col) % points at bottom and right
            panorama(i, j, :) = image2(x0, y0, :);
        else % normal points
            panorama(i, j, :) = bilinear(cx - x0, cy - y0, image2(x0, y0, :), image2(x0, y0+1, :), image2(x0+1, y0, :), image2(x0+1, y0+1, :));
        end
    end
end
fprintf('cnt_overflow = %d\n', cnt_overflow);

figure, imshow(panorama)
dlmwrite(strcat(Path, "H.txt"), H);
imwrite(panorama, strcat(Path, 'panorama.jpg'));