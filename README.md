# Hierarchical-Organic-Microsphere

This is the data file for the artcile "Hierarchical Organic Microspheres from Diverse Molecular Building Blocks", containing the code mentioned in the article and the corresponding data for testing.

All the code is based on the MATLAB R2021a.

System requirements：Any operation system that is compatible with MATLAB R2021a

Installation guide: Directly run on MATLAB R2021a without installation

Instructions for use: 
  For "Delaunay triangulation" part, we recommended to use the merged code directly (Delaunay_triangulation_with_Z_estimation.m) to avoid some potential bug. You can directly run the code on MATLAB and choose a ".csv" file when the dialog box appeared. You will get the result in command line window, as well as a "_extended.csv" file.

  For "Radial distribution function" part, you can directly run the code on MATLAB. You can modify the parameter for statius when the first dialog box appeared, and then choose a ".csv" file. You will get a "_RD.csv” file which needs further smoothing in other software (such as Origin) to get the final RDF curve.

  For "Dihedral Angle statistics" part, you can directly run the code on MATLAB and choose a ".csv" file when the dialog box appeared. You will get a distribution figure, as well as a "_dihedral_angles.csv" file.
