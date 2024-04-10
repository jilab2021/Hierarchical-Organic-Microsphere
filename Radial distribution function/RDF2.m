clear all
% 从 CSV 文件中读取坐标  
[filename, pathname] = uigetfile('*.csv', '选择 csv 文件');
% 如果用户取消选择，则停止执行
if isequal(filename, 0)
    return;
end
data = readmatrix(filename); % 假设 CSV 文件没有标题行  

% 提取坐标列  
x = data(:, 1);  
y = data(:, 2); 
%z = data(:, 3);

% 获取原子数量  
numAtoms = size(data, 1);  
   
% 定义参数  
rMax = 1; % 最大半径  
dr = 0.001; % 半径步长  
  
% 初始化径向分布函数  
r = 0:dr:rMax;  
g = zeros(size(r));  
number = 0;  
% 计算径向分布函数  
for i = 1:numAtoms  
    for j = i+1:numAtoms  
        % 计算两个原子之间的距离  
        dx = x(i) - x(j);  
        dy = y(i) - y(j);  
        dist = sqrt(dx^2 + dy^2);  
          
        % 找到对应的半径范围并增加计数器  
        index = floor(dist / dr) + 1;  
        if index <= numel(g)  
            g(index) = g(index) + 2; % 每对原子都会增加2个计数器，因为是双向的  
        end 
        if dist <= rMax 
            number = number + 2; % 每对原子都会增加2个计数器，因为是双向的  
        end 
    end  
end  
  
% 归一化径向分布函数  
areaFraction = pi * (2*r*dr + dr^2); % 每个微分圆环的面积  
numberDensity = number / (pi * rMax^2); % 原子数密度  
gNormalized = g ./ (areaFraction * numberDensity);areaFraction = pi * (2*r*dr + dr^2); % 每个微分圆环的面积  
numberDensity = number / (pi * rMax^2); % 原子数密度  
gNormalized = g ./ (areaFraction * numberDensity);
%g2 = g./ areaFraction;

% 将数据写入 Excel 表格  
filename = 'RDF.xlsx';  % Excel 文件名  
sheet = 'Sheet1';        % 工作表名  
result = [r', gNormalized'];  
% 使用 writematrix 函数将数值矩阵写入 Excel  
writematrix(result, filename, 'Sheet', sheet);  
   

% 平滑处理径向分布函数  
smoothed_gNormalized = smooth(gNormalized, 1); % 这里使用窗口大小为10的移动平均进行平滑处理  
%smoothed_g2 = smooth(g2, 80);  
figure;
% 绘制平滑后的径向分布函数
%plot(r, smoothed_g2); 
plot(r, smoothed_gNormalized);  
%title('Smoothed Radial Distribution Function');  
xlabel('Radius / μm', 'FontSize', 24, 'FontName', 'Arial');  
ylabel('g(r)', 'FontSize', 24, 'FontName', 'Arial'); 
ax = gca;  
  
% 设置 X 和 Y 坐标刻度的字号和字体  
ax.XAxis.FontSize = 24;  
ax.XAxis.FontName = 'Arial';  
ax.YAxis.FontSize = 24;  
ax.YAxis.FontName = 'Arial';  
xlim([0 3]); 