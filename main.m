clearvars; close all;
Path = input("Image source path = ",'s')
Path = strcat(Path, "\")
ImageName = ["1_data3.jpg", "2_data3.jpg", "3_data3.jpg"];
KPTS = ["k12.txt", "k23.txt"];

NumPictures = length(ImageName);
pano3(strcat(Path, ImageName(1)), strcat(Path, ImageName(2)), strcat(Path, ImageName(3)), strcat(Path, KPTS(1)), strcat(Path, KPTS(2)), Path);