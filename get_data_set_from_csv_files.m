function [Xin, Yout] = get_data_set_from_csv_files(csv_files_dir)

filePattern = fullfile(csv_files_dir, '*.csv');

thefiles = dir(filePattern);

Xin = [];
Yout = [];

idx = 0;
for k = 1:length(thefiles)
    if length(thefiles(k).name) < 20
        continue;
    end
    idx = idx+1;
    fileName = thefiles(k).name;
    fullFileName = fullfile(thefiles(k).folder,fileName);
    
    output_table = readtable(fullFileName);
    
    input_data = [str2double(fileName(6:11)) str2double(fileName(19:24))];
    
    Xin(:,idx) = input_data;
    %Xin = [Xin; input_data];
    
    output_data = output_table{:,:}(:,[6]);
    
    Yout(:,idx) = output_data;
    %Yout = [Yout; output_data]
    
end
end