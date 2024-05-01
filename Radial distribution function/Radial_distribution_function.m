clear all
dlg_title=' Set calculation parameter ';% The name of the first dialogue box
prompt = {'Radius:', 'Step:' };
num_lines=2; 
dlgtitle = ' Enter the calculate parameter'; 
definput = {'1', '0.001'}; % The default input value.
options.Resize='on'; 
options.WindowStyle='normal'; 
answer=inputdlg(prompt,dlg_title,num_lines,definput,options); 
rMax = str2double(answer{1}); 
dr = str2double(answer{2});
[filename, pathname] = uigetfile('*.csv', 'select csv file');
input_file = fullfile(pathname, filename); 
if isequal(filename, 0)
return;
end
data = readmatrix(input_file,'NumHeaderLines', 1); 

x = data(:, 1);  
y = data(:, 2); 
%z = data(:, 3);

% Get the number of atoms
numAtoms = size(data, 1);  
     
%Initialize radial distribution function   
r = 0:dr:rMax;  
g = zeros(size(r));  
number = 0;  

% Calculate radial distribution function   
for i = 1:numAtoms  
    for j = i+1:numAtoms  
% Calculate the distance between two atoms
        dx = x(i) - x(j);  
        dy = y(i) - y(j);  
        dist = sqrt(dx^2 + dy^2);  
          
% Find the corresponding radius range and increment the counter
        index = floor(dist / dr) + 1;  
        if index <= numel(g)  
            g(index) = g(index) + 2; %  Each pair of atoms contributes 2 to the counter since it is bidirectional  
        end 
        if dist <= rMax 
            number = number + 2; %  Each pair of atoms contributes 2 to the counter since it is bidirectional
        end 
    end  
end  
  
% Normalize the radial distribution function 
areaFraction = pi * (2*r*dr + dr^2); % Volume of each spherical shell
numberDensity = number / (pi * rMax^2); % Density 
gNormalized = g ./ (areaFraction * numberDensity);

output_filename2 = fullfile(pathname, [filename(1:end-4), '_RDF.csv']);
RDF_result = [r', gNormalized'];  
csvwrite(output_filename2, RDF_result); 
 
