clear all;

[filename, pathname] = uigetfile('*.csv', '选择 csv 文件');
input_file = fullfile(pathname, filename);  

if isequal(filename, 0)
   return;
end
data = readmatrix(input_file,'NumHeaderLines', 1); 

[max_x, max_idx] = max(data(:, 6));  
[min_x, min_idx] = min(data(:, 6));  
[max_y, max_idy] = max(data(:, 7));    
[min_y, min_idy] = min(data(:, 7)); 
center_x = (min_x+max_x) / 2;
a = max_x-min_x;
center_y = (min_y+max_y) / 2;
b = max_y-min_y;
data([max_idx, min_idx, max_idy, min_idy], :) = [];  
points_x = data(:, 6);  
points_y = data(:, 7);  

disp(['Analyzed particle identification: ', filename(1:end-4)]);
disp(['Center coordinates：(', num2str(center_x), ',',num2str(center_y),')']);
if a == b %spherical model
    diameter = a;
    radius = diameter / 2; 
    distance = sqrt((points_x - center_x).^2 + (points_y - center_y).^2);
    filted_data = data(distance <= radius, :); 
    points_x = filted_data(:, 6);  
    points_y = filted_data(:, 7);  
    D = 2*sqrt((points_x - center_x).^2 + (points_y - center_y).^2); 
    points_z = sqrt(radius^2 - (points_x - center_x).^2 - (points_y - center_y).^2);
    disp(['diameter：', num2str(diameter)]);
else %ellipsoidal model
    A = a/2;
    B = b/2;
    %{
    plot(points_x, points_y, 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');  
    % Creates an Angle vector of theta that defines the range of the ellipse (0 to 2*pi)
    theta = linspace(0, 2*pi, 100);    
    x_ellipse = center_x + A*cos(theta);  
    y_ellipse = center_y + B*sin(theta);   
    plot(x_ellipse, y_ellipse, 'r', 'LineWidth', 2); 
   %}
    distance = (points_x - center_x).^2 / A^2 + (points_y - center_y).^2 / B^2;
    filted_data = data(distance <= 1, :);
    points_x = filted_data(:, 6);  
    points_y = filted_data(:, 7);  
    points_z = A * sqrt(1 - ((points_x - center_x).^2 / A^2) - ((points_y - center_y).^2 / B^2));
    disp(['Parameter A：', num2str(A)]);
    disp(['Parameter B：', num2str(B)]);
    radius = (A+B)/2;
    disp(['Mean radius:', num2str(radius), '±', num2str(abs(A-radius))]);
end
    
output_filename = fullfile(pathname, [filename(1:end-4), '_extended.csv']);  
points = [points_x, points_y, points_z];  
csvwrite(output_filename, points);  
