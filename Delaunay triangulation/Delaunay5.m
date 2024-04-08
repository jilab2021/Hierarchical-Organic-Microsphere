clear all;
%{
dlg_title='计算参数设置';%显示第一个对话框的名称
% 弹出对话框并读取输入值  
prompt = {'参数a:','参数b:'};
num_lines=1;%第一个对话框所需输入栏数量
dlgtitle = '输入参数';  
definput = {'', ''}; % 默认输入值为空
options.Resize='on';%可以调整对话框大小
options.WindowStyle='normal';%如果设置为 'modal'，则用户必须先做出响应，然后才能与其他窗口交互
answer=inputdlg(prompt,dlg_title,num_lines,definput,options); 
% 提取输入值  % 输入球体半径和圆心坐标 
a = str2double(answer{1});    
b = str2double(answer{2});
%}
[filename, pathname] = uigetfile('*.csv', '选择 csv 文件');
input_file = fullfile(pathname, filename);  
% 如果用户取消选择，则停止执行
if isequal(filename, 0)
   return;
end
data = readmatrix(input_file,'NumHeaderLines', 1); % 假设 CSV 文件没有标题行 

[max_x, max_idx] = max(data(:, 6));  % 找到 X 坐标最大值和索引  
[min_x, min_idx] = min(data(:, 6));  % 找到 X 坐标最小值和索引
[max_y, max_idy] = max(data(:, 7));  % 找到 X 坐标最大值和索引  
[min_y, min_idy] = min(data(:, 7));  % 找到 X 坐标最小值和索引
center_x = (min_x+max_x) / 2;
a = max_x-min_x;
center_y = (min_y+max_y) / 2;
b = max_y-min_y;
data([max_idx, min_idx, max_idy, min_idy], :) = [];  
points_x = data(:, 6);  
points_y = data(:, 7);  

disp(['被分析颗粒编号：', filename(1:end-4)]);
disp(['圆心坐标：（', num2str(center_x), ',',num2str(center_y),')']);
if a == b %球状模型
    diameter = a;
    radius = diameter / 2;
    % 从 CSV 文件中读取坐标 
    distance = sqrt((points_x - center_x).^2 + (points_y - center_y).^2);
    filted_data = data(distance <= radius, :); 
    points_x = filted_data(:, 6);  
    points_y = filted_data(:, 7);  
    D = 2*sqrt((points_x - center_x).^2 + (points_y - center_y).^2);
    % 计算已知点的z坐标  
    points_z = sqrt(radius^2 - (points_x - center_x).^2 - (points_y - center_y).^2);
    disp(['直径：', num2str(diameter)]);
else %椭球模型
    A = a/2;
    B = b/2;
    %{
    plot(points_x, points_y, 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');  
    % 创建一个 theta 的角度向量，用于定义椭圆的范围（0 到 2*pi）  
    theta = linspace(0, 2*pi, 100);  
    % 计算椭圆上每个点的坐标  
    x_ellipse = center_x + A*cos(theta);  
    y_ellipse = center_y + B*sin(theta);  
    % 绘制椭圆  
    plot(x_ellipse, y_ellipse, 'r', 'LineWidth', 2); 
   %}
    distance = (points_x - center_x).^2 / A^2 + (points_y - center_y).^2 / B^2;
    filted_data = data(distance <= 1, :);
    points_x = filted_data(:, 6);  
    points_y = filted_data(:, 7);  
    points_z = A * sqrt(1 - ((points_x - center_x).^2 / A^2) - ((points_y - center_y).^2 / B^2));
    disp(['参数A：', num2str(A)]);
    disp(['参数B：', num2str(B)]);
    radius = (A+B)/2;
    disp(['平均半径：', num2str(radius), '±', num2str(abs(A-radius))]);
end

% 将结果写入csv文件    
output_filename = fullfile(pathname, [filename(1:end-4), '_extended.csv']);  
points = [points_x, points_y, points_z];  
csvwrite(output_filename, points);  

%上面为Z轴坐标估算，下面三角分割

edge_threshold = 3.4;  %设置阈值！！！
  
% 计算Delaunay三角形  
triangles = delaunay(points(:,1), points(:,2));  
x = points(:,1);
y = points(:,2);
z = points(:,3);
figure; % 打开新的图形窗口  
% 找到Z的最小值  
z_min = min(z(:));  
% 找到Z的最大值  
z_max = max(z(:)); 
%设置颜色映射
cmap = colormap;
% 统计所有边长  
edge_lengths = [];  
for i = 1:size(triangles, 1)  
    % 获取当前三角形的顶点索引  
    vertex_indices = triangles(i,:);  
  
    % 计算三个边的长度  
    edge1 = norm(points(vertex_indices(1), :) - points(vertex_indices(2), :));  
    edge2 = norm(points(vertex_indices(2), :) - points(vertex_indices(3), :));  
    edge3 = norm(points(vertex_indices(3), :) - points(vertex_indices(1), :));  
  
    % 判断边长是否大于等于阈值，若是则添加到边长列表中  
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
  
% 计算平均边长  
average_edge_length = mean(edge_lengths); 
standard_deviation = std(edge_lengths); 
%trimesh(triangles,x,y,z);
axis equal; 
% 显示结果  
disp(['平均边长：', num2str(average_edge_length)]);  
disp(['标准差：', num2str(standard_deviation)]); 
 %{ 
% 设置图像标题和轴标签  
%hold off;
title('Delaunay三角形');  
xlabel('X');  
ylabel('Y'); 

 %}

% 绘制点  
plot3(x, y, z, 'o', 'MarkerSize', 3, 'MarkerFaceColor', '#F17777', 'MarkerEdgeColor', 'none');  

% 设置坐标轴标题和图标题  
xlabel('Length / nm', 'FontSize', 20, 'FontName', 'Arial');  
ylabel('Length / nm', 'FontSize', 20, 'FontName', 'Arial'); 
zlabel('Length / nm', 'FontSize', 20, 'FontName', 'Arial');
%title('已知点的坐标');
ax = gca; 
set(ax, 'FontName', 'Arial', 'FontSize', 20);  

% 设置X轴和Y轴单位坐标长度一致  
%xlim([550 2450]);
%ylim([-20 470]);
% 将Y轴倒序显示  
set(gca, 'YDir', 'reverse');
%}
grid on;