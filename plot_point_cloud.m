function plot_point_cloud(Il, Id, bbox, K, b)
% PLOT_POINT_CLOUD Plot 3D point cloud from stereo disparity image.
%
%  PLOT_POINT_CLOUD(Il, Id, bbox, K, b) uses stereo data, including the
%  disparity image Id, to generate and plot a 3D poing cloud.
%
%  Inputs:
%  -------
%   Il    - Left stereo image, m x n pixels.
%   Id    - Disparity image, m x n pixels.
%   bbox  - Bounding box, relative to left image, top left, bottom right.
%   K     - Camera 3 x 3 intrinsic calibration matrix.
%   b     - Stereo baseline (e.g., in metres).

% Nested function to compute intersection point.
function [pt] = intersect_rays(tl, l, d)
  z  = K(1, 1)/d*b;  % Depth...
  pt = tl + z*l/l(3);
end  % intersect_rays

Il = double(Il);
Id = double(Id);

% Invert K - we need the ray from the camera centre.
Ki = inv(K);

tl = [-b/2; 0; 0];
tr = [ b/2; 0; 0];
R  = dcm_from_rpy([-pi/2; 0; 0]); % Rotate frame for visualization only.

h = figure; hold on; grid on;
stride = 3;     % Plot fewer points.
pchsz = 0.02;   % Patch size...

% Loop over bounding box - note that Id should have the same size as the
% bounding box.
for i = bbox(1, 1):stride:bbox(1, 2)
  for j = bbox(2, 1):stride:bbox(2, 2)
    xc = bbox(1, 1) + i - 1;
    yc = bbox(2, 1) + j - 1;
    
    % Left ray.
    l = Ki*[xc; yc; 1];
    l = l/norm(l);

    % 3D point (ideal fronto-parallel projection).
    if Id(j, i) ~= 0
      pt = intersect_rays(tl, l, Id(j, i));
      pt = R*pt;
      plot3(pt(1), pt(2), pt(3), 'b.');
 
      % Draw small patch...
      %ulc = [pt(1, 1) - pchsz; pt(2, 1); pt(3, 1) - pchsz];
      %urc = [pt(1, 1) + pchsz; pt(2, 1); pt(3, 1) - pchsz];
      %llc = [pt(1, 1) - pchsz; pt(2, 1); pt(3, 1) + pchsz];
      %lrc = [pt(1, 1) + pchsz; pt(2, 1); pt(3, 1) + pchszs];

      %patch([ulc(1, 1); urc(1, 1); lrc(1, 1); llc(1, 1)], ...
      %      [ulc(2, 1); urc(2, 1); lrc(2, 1); llc(2, 1)], ...
      %      [ulc(3, 1); urc(3, 1); lrc(3, 1); llc(3, 1)], ...
      %      Il(yc, xc, :)/255);
    end
  end
end

% Plot stereo cameras
plot_camera([R, tl; 0, 0 ,0, 1]);
plot_camera([R, tr; 0, 0 ,0, 1]);

end