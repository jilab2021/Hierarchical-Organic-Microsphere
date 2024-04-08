clear all  
[filename, pathname] = uigetfile('*.gro', '选择 gro 文件');
input_file = fullfile(pathname, filename);  

% Specify the output Excel file name  
excelFileName = [filename(1:end-4), '_dihedral_angles.xlsx'];    
  
% Read the gro file  
fileID = fopen(input_file, 'r');  
  
% Skip the header lines in the gro file  
headerLines = 2;  
for i = 1:headerLines  
    fgetl(fileID);  
end  

% Initialize arrays to store the coordinates of selected atom 
A = [];  
B = [];  
C = [];  
D = [];  
E = [];  
F = [];  
G = [];  
H = [];  
flag =1;  
% Read the coordinates from the gro file  
while ~feof(fileID)  
    line = fgetl(fileID);   % Check if the read line is the coordinate of atom
    line_length = numel(line);
    if  line_length  < 21  
        flag = 0;
        break;  
    end 
    
    moleName = line(6:8);
    
    if ~strcmp(moleName, 'HAM') % Check if the read line is the coordinate of HAM atom
        break;
    end
        
    % Extract the atom name and coordinates from each line  
    atomName = line(13:15);         
    x = str2double(line(22:28));  
    y = str2double(line(30:36));  
    z = str2double(line(38:44));  
      
    % Store the coordinates based on atom name  
    if strcmp(atomName, 'C19') 
        A = [A; x, y, z];  
    elseif strcmp(atomName, 'C14') 
        B = [B; x, y, z];  
    elseif strcmp(atomName, 'N13') 
        C = [C; x, y, z];  
    elseif strcmp(atomName, 'C10')
        D = [D; x, y, z];  
    elseif strcmp(atomName, 'C26')
        E = [E; x, y, z];  
    elseif strcmp(atomName, 'C25')
        F = [F; x, y, z];  
    elseif strcmp(atomName, 'N24')
        G = [G; x, y, z];  
    elseif strcmp(atomName, 'C11')  
        H = [H; x, y, z];      
    
    end  
end  
  
% Close the gro file  
fclose(fileID);  
  
% Calculate the number of sets of coordinates found  
numSets = size(A, 1);  
  
% Initialize an array to store the dihedral angle results  
dihedralAngles1 = zeros(numSets, 1); 
dihedralAngles2 = zeros(numSets, 1); 
sup_angle = 0;  
% Calculate the dihedral angle for each set of coordinates  
for i = 1:numSets  
    % Vectors AB and BC  
    AB = B(i, :) - A(i, :);  
    BC = C(i, :) - B(i, :);  
    
    EF = E(i, :) - F(i, :);  
    FG = F(i, :) - G(i, :); 
    
    % Vector normal to plane ABC  
    normal_ABC = cross(AB, BC); 
    normal_EFG = cross(EF, FG);
  
    % Vectors BC and CD  
    BC = C(i, :) - B(i, :);  
    CD = D(i, :) - C(i, :); 
    
    FG = F(i, :) - G(i, :);  
    GH = G(i, :) - H(i, :); 
  
    % Vector normal to plane BCD  
    normal_BCD = cross(BC, CD);  
    normal_FGH = cross(FG, GH); 
    
    % Calculate the dot product of the two normal vectors  
    dot_product1 = dot(normal_ABC, normal_BCD);  
    dot_product2 = dot(normal_EFG, normal_FGH); 
    
    % Calculate the magnitude of the normal vectors  
    magnitude_ABC = norm(normal_ABC);  
    magnitude_BCD = norm(normal_BCD);  
  
    magnitude_EFG = norm(normal_EFG);  
    magnitude_FGH = norm(normal_FGH);
    
    % Calculate the angle between the two planes using dot product formula  
    angle_rad1 = acos(dot_product1 / (magnitude_ABC * magnitude_BCD));  
    angle_rad2 = acos(dot_product2 / (magnitude_EFG * magnitude_FGH)); 
    
    % Convert the angle from radians to degrees  
    angle_deg1 = rad2deg(angle_rad1);
    angle_deg2 = rad2deg(angle_rad2);
    % If the dihedral angle is greater than 90°, record its supplementary angle
    %
    if angle_deg1 > 90  
       angle_deg1 = 180 - angle_deg1;
       sup_angle = sup_angle+1;
    end  
      if angle_deg2 > 90  
       angle_deg2 = 180 - angle_deg2;
       sup_angle = sup_angle+1;
    end  
    %} 
    
    % Store the dihedral angle result in the array  
    dihedralAngles1(i) = angle_deg1; 
    dihedralAngles2(i) = angle_deg2;
end  

% Create a table with the dihedral angles  
resultsTable1 = table(dihedralAngles1, 'VariableNames', {'Dihedral_Angle'});  
resultsTable2 = table(dihedralAngles2, 'VariableNames', {'Dihedral_Angle'});     
% Display the results in the command window  
%{
disp(resultsTable);
disp(sup_angle);
%}

% Classify the dihedral angles and count the number of angles in each category  
categories = 0:6:90;  
categoryCounts1 = histcounts(dihedralAngles1, categories); 
categoryCounts2 = histcounts(dihedralAngles2, categories); 
categories_fig = 3:6:90;    
% Create a table with the angle categories and their counts  
categoryTable1 = table(categories_fig', categoryCounts1', 'VariableNames', {'Angle_Category', 'Count'});  
categoryTable2 = table(categories_fig', categoryCounts2', 'VariableNames', {'Angle_Category', 'Count'}); 
% Plot the bar chart  
figure;  
bar(categories_fig, [categoryCounts1' categoryCounts2'], 'grouped' );  
xlabel('Dihedral Angle (degrees)');  
ylabel('Count');  
title(filename(1:end-4)); 

% Disable warning messages  
warning('off', 'MATLAB:xlswrite:AddSheet');  
% Write the table to an Excel file  
writetable(resultsTable1, excelFileName, 'Sheet', 1);   
writetable(resultsTable2, excelFileName, 'Sheet', 3);
% Display the category table  
writetable(categoryTable1, excelFileName, 'Sheet', 2);    
writetable(categoryTable2, excelFileName, 'Sheet', 4);
% Enable warning messages  
warning('on', 'MATLAB:xlswrite:AddSheet');    
disp(['Dihedral angles saved to ', excelFileName]);  