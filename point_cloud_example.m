% Simple script to demonstrate point cloud plotting.
Il = imread('../images/cones_image_02.png');
Id = imread('../images/cones_disp_02.png');

% Generic K matrix ... typical camera.
K = [500, 0, 320; 0, 500, 240; 0, 0, 1];

% Baseline and bounding box.
b = 0.2;
bbox = [1, 450; 1, 375];

% Try plotting - adjust internally for speed if needed.
plot_point_cloud(Il, Id, bbox, K, b);