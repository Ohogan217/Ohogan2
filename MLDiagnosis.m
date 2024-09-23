files = readtable("StudentNumber_Datasets.xlsx", "ReadRowNames",true);
StuNumber = "19355123";

nosets = size(files, 2);

for i = 1:nosets
    fid = fopen("GaCo01_01.txt");
end