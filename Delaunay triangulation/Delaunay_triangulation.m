dlg_title=' Set calculation parameter ';% The name of the first dialogue box
prompt = {'threshold:'};
num_lines=1; 
dlgtitle = ' Enter the threshold value.'; 
definput = {' '}; % The default input value is empty.
options.Resize='on'; 
options.WindowStyle='normal'; 
answer=inputdlg(prompt,dlg_title,num_lines,definput,options); 
edge_threshold = str2double(answer{1}); 
[filename, pathname] = uigetfile('*.csv', 'select csv file');
input_file = fullfile(pathname, filename); 
if isequal(filename, 0)
return;
end
data = readmatrix(input_file,'NumHeaderLines', 1); %the output file in code 1

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
