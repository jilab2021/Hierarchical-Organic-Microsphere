clear all;

[filename, pathname] = uigetfile('*.csv', 'select csv file');
input_file = fullfile(pathname, filename);  
% If the user deselects, execution stops
if isequal(filename, 0)
   return;
end
data = readmatrix(input_file,'NumHeaderLines', 1); % Assume that the CSV file does not have a header line

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

edge_threshold = 3.4;  %Set threshold value！！！
  
triangles = delaunay(points(:,1), points(:,2));  
x = points(:,1);
y = points(:,2);
z = points(:,3);
figure; 
% Find the minimum value of Z
z_min = min(z(:));  
% Find the maximum value of Z
z_max = max(z(:)); 
%Set color mapping
cmap = colormap;
% Counts all side lengths  
edge_lengths = [];  
for i = 1:size(triangles, 1)  
    % Gets the vertex index of the current triangle
    vertex_indices = triangles(i,:);  
  
    % Calculates the length of the three sides
    edge1 = norm(points(vertex_indices(1), :) - points(vertex_indices(2), :));  
    edge2 = norm(points(vertex_indices(2), :) - points(vertex_indices(3), :));  
    edge3 = norm(points(vertex_indices(3), :) - points(vertex_indices(1), :));  
  
    % Determines whether the side length is greater than or equal to the threshold. If so, add it to the side length list
    if edge1 <= edge_threshold  
        edge_lengths = [edge_lengths, edge1];  
        hold on; 
        z_values = mean(points(vertex_indices([1, 2]), 3));
        color_index=(z_values-z_min)/(z_max-z_min);
        color_value=cmap(round(color_index*(size(cmap, 1)-1))+1,:); 
        plot3([points(vertex_indices(1), 1), points(vertex_indices(2), 1)], [points(vertex_indices(1), 2), points(vertex_indices(2), 2)], [points(vertex_indices(1), 3), points(vertex_indices(2), 3)], 'Color', color_value);  
    end  
  
    if edge2 <= edge_threshold  
        edge_lengths = [edge_lengths, edge2];  
        hold on;
        z_values = mean(points(vertex_indices([2, 3]), 3));
        color_index=(z_values-z_min)/(z_max-z_min);
        color_value=cmap(round(color_index*(size(cmap, 1)-1))+1,:); 
        plot3([points(vertex_indices(2), 1), points(vertex_indices(3), 1)], [points(vertex_indices(2), 2), points(vertex_indices(3), 2)], [points(vertex_indices(2), 3), points(vertex_indices(3), 3)], 'Color', color_value);  
    end  
  
    if edge3 <= edge_threshold  
        edge_lengths = [edge_lengths, edge3];  
        hold on;  
        z_values = mean(points(vertex_indices([3, 1]), 3));
        color_index=(z_values-z_min)/(z_max-z_min);
        color_value=cmap(round(color_index*(size(cmap, 1)-1))+1,:); 
        plot3([points(vertex_indices(3), 1), points(vertex_indices(1), 1)], [points(vertex_indices(3), 2), points(vertex_indices(1), 2)], [points(vertex_indices(3), 3), points(vertex_indices(1), 3)], 'Color', color_value);  
    end  
  
end  
  
% Calculate the average side length
average_edge_length = mean(edge_lengths); 
standard_deviation = std(edge_lengths); 
%trimesh(triangles,x,y,z);
axis equal; 
% Show results
disp(['Average length: ', num2str(average_edge_length)]);  
disp(['Standard deviation: ', num2str(standard_deviation)]); 

plot3(x, y, z, 'o', 'MarkerSize', 3, 'MarkerFaceColor', '#F17777', 'MarkerEdgeColor', 'none');  

xlabel('Length / nm', 'FontSize', 20, 'FontName', 'Arial');  
ylabel('Length / nm', 'FontSize', 20, 'FontName', 'Arial'); 
zlabel('Length / nm', 'FontSize', 20, 'FontName', 'Arial');
ax = gca; 
set(ax, 'FontName', 'Arial', 'FontSize', 20);  
set(gca, 'YDir', 'reverse');
grid on;
