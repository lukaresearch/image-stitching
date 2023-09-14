# searching matched keypoints in 2 images

import numpy as np
import cv2

ImageName = []
KPTS = []
MinNumberKeypoints = 200
MaxNumberKeypoints = 500
FAIL = 0
SUCCESS = 1
MaxCnt = 20

def detect_keypoints(image):
    image_gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    sift_descriptors = cv2.xfeatures2d.SIFT_create()
    keypoints, features = sift_descriptors.detectAndCompute(image_gray, None)
    keypoints = np.float32([i.pt for i in keypoints])
    return keypoints, features


def search_useful_matches(all_matches, lowe_ratio):
    useful_matches_indices = []
    for coordinate1, coordinate2 in all_matches:
        if(coordinate1.distance <  (lowe_ratio * coordinate2.distance)):
            useful_matches_indices.append((coordinate1.queryIdx, coordinate1.trainIdx))   

    return useful_matches_indices


def match_keypoints(features1, features2, lowe_ratio):
    print("start matching!")
    bf_match_agent = cv2.BFMatcher()
    all_matched_points = bf_match_agent.knnMatch(features1,features2, k=2)

    cnt = 0
    message = FAIL
    while( message == FAIL ):
        useful_matches_indices = search_useful_matches(all_matched_points, lowe_ratio)
        NumberKeypoints = len(useful_matches_indices)        
        if NumberKeypoints < MinNumberKeypoints:
            lowe_ratio *= 1.2 
        elif NumberKeypoints > MaxNumberKeypoints:
            lowe_ratio *= 0.8
        else:
            message = SUCCESS        
        
        print("NumberKeypoints: ", NumberKeypoints)
        cnt += 1
        if(cnt > MaxCnt):
            print("too many trials of keypoints")
            return None

    return useful_matches_indices

def prepare_drawing(image1, image2):
    image1_height, image1_width = image1.shape[:2]
    image2_height, image2_width = image2.shape[:2]

    canvas_height = max(image1_height, image2_height)
    canvas_width = image1_width + image2_width

    complete_image = np.zeros((canvas_height, canvas_width, 3), dtype="uint8")
    complete_image[0:image1_height, 0:image1_width] = image1
    complete_image[0:image2_height, image1_width:] = image2
    img1_hw = (image1_height, image1_width)
    img2_hw = (image2_height, image2_width)
    return img1_hw, img2_hw, complete_image


def draw_matches(cnt, ImageDirectory, image1, keypoints1, image2, keypoints2, matches_indices):
    img1_hw, _, complete_image = prepare_drawing(image1, image2)
    _, image1_width = img1_hw
    useful_keypoints_number = 0
    file1 = open(KPTS[cnt], 'w')
    set_points = []
    for (queryIdx, trainIdx) in matches_indices:
        x1_opencv, y1_opencv = int(keypoints1[queryIdx][0]), int(keypoints1[queryIdx][1])
        x2_opencv, y2_opencv = (int(keypoints2[trainIdx][0]) + image1_width), int(keypoints2[trainIdx][1])
        x1 = int(keypoints1[queryIdx][1])
        y1 = int(keypoints1[queryIdx][0])
        x2 = int(keypoints2[trainIdx][1])
        y2 = int(keypoints2[trainIdx][0])
        image1_point = (x1_opencv, y1_opencv)
        image2_point = (x2_opencv, y2_opencv)
        cv2.line(complete_image, image1_point, image2_point, (0, 0, 255), 1)
        
        useful_keypoints_number += 1
        
        if(len(set_points) == 0):
            set_points.append([x1, y1, x2, y2])
        else:
            flag = True
            for i in range(len(set_points)):
                if(set_points[i] == [x1, y1, x2, y2]):
                    flag = False
                    break
            if(flag is True):
                set_points.append([x1, y1, x2, y2])
    
    for i in range(len(set_points)):
        file1.write(str(set_points[i][0]) + " " + str(set_points[i][1]) + " " + str(set_points[i][2]) + " " + str(set_points[i][3]) + "\n")

    print("no. of matched keypoints: ", useful_keypoints_number)
    cv2.imwrite(ImageDirectory+"\keypoints" + str(cnt) + ".jpg", complete_image)

def search_keypoints(i, ImageDirectory, image1, image2, lowe_ratio=0.25):
    keypoints1, features1 = detect_keypoints(image1)
    keypoints2, features2 = detect_keypoints(image2)

    data = match_keypoints(features1, features2, lowe_ratio) # receive matched keypoints

    if(data is None):
        return None

    matches_indices = data
    draw_matches(i, ImageDirectory, image1, keypoints1, image2, keypoints2, matches_indices)

if __name__ == "__main__":

    NumberImages = int(input("number of images: "))
    ImageDirectory = input("Images Dataset Directory: ")
    for i in range(NumberImages):
        ImageNameVariable = input("Image Name " + str(i+1) + ": ")
        ImageName.append(ImageDirectory + "\\" + ImageNameVariable)

    for i in range(NumberImages-1):
        image1 = cv2.imread(ImageName[i])
        image2 = cv2.imread(ImageName[i+1])
        KPTS.append(ImageDirectory + "\k" + str(i+1) + str(i+2) + ".txt")
        search_keypoints(i, ImageDirectory, image1, image2)