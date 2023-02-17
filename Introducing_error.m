parameters= {'BARE', 'BBS'};

calibration_data_type = {'voltage', 'normal current density'};

metric = 'nmsq';

[simulation_seed_folder, collection_dir, meas_dir] = get_simulation_input_for_involved_parameters(parameters);

MP_dir = "C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_nonlinear\Parameter_BARE_BBS\Measurement_results1";

selected_Internal_points = csvread(fullfile(MP_dir, 'Internal_Points.csv'),1,1);

IDs_current_density = [14390, 7400, 4060, 16000, 19860, 23802, 30002, 23822,21212, 8437];

files_name = 'BU_014_NoLinear';
selected_mesh_points = py.BEASY_IN_OUT1.xyz_coordinates_for_IDS(py.list(int64(IDs_current_density)),fullfile(meas_dir, strcat(files_name,'.dat')),  'Mesh Points');

selected_mesh_points = convert_py_dict_lists_to_array(selected_mesh_points);

data_coordinates = {selected_Internal_points, selected_mesh_points}; 

DOE_range1 = [1.4, 2.5; 1.5,4.0];

DOE_range2 = [1.6, 2.6; 1.9,4.4];

%result_searching_range = [1.7, 2.2; 2.4, 3.5];
result_searching_range = [1.6, 2.4; 2.4, 3.9];

if ~isequal(length(parameters),1)
    
    Central_composite_points = ccdesign(length(parameters), 'type', 'inscribed', 'center' , 4);
    DOE_sample_points1 = reverse_normalization(Central_composite_points, DOE_range1);
    DOE_sample_points2 = reverse_normalization(Central_composite_points, DOE_range2);
else 
    Central_composite_points = ccdesign(2, 'type', 'inscribed', 'center' , 4);
    composite_points_1d = sort(unique([Central_composite_points(:,1); Central_composite_points(:,1)/2]));
    DOE_sample_points1 = reverse_normalization(composite_points_1d, DOE_range1);
    DOE_sample_points2 = reverse_normalization(composite_points_1d, DOE_range2);
end

IDs_type = {'Internal Points', 'Mesh Points'};

%parameters_np_array1 = convert_arr_to_python_2d_list([DOE_sample_points1(1:9,:); DOE_sample_points2(1:9,:)]);
%parameters_np_array1 = convert_arr_to_python_2d_list(DOE_sample_points1(1:9,:));
parameters_np_array1 = convert_arr_to_python_2d_list(DOE_sample_points2(1:9,:));
no_of_modules = 2;

[modules_MPs, modules_snapshots, modules_ROM] = ROMs_each_modules1(no_of_modules, data_coordinates, parameters,...
    parameters_np_array1, parameters_np_array1, calibration_data_type, simulation_seed_folder, collection_dir, IDs_type);

solutions_par = zeros(no_of_modules, length(parameters));

meas_data_file_name = fullfile(meas_dir, 'meas_data.xlsx');

for i = 1:no_of_modules
    
    IDs_cells = cell(1,length(data_coordinates));
    
    for j = 1:length(data_coordinates)
        if isequal(size(modules_MPs{j,i},1),1)
            IDs_cells{j} = {uint64(modules_MPs{j,i}(:,1))};
        else
            IDs_cells{j} = uint64(modules_MPs{j,i}(:,1));
        end
    end
    
    sub_meas_data = data_from_tables(meas_data_file_name, IDs_cells, 3);
    
    if isequal(i,1)
        mod_result_searching_range = result_searching_range;
    else
        %mod_result_searching_range = [solutions_par(1,1:2)-0.25; solutions_par(1,:)+0.25];
        mod_result_searching_range = result_searching_range;
    end

    %[~ , solutions_par(i,:)] = minimum_with_ROMs(mod_result_searching_range, {modules_ROM{i}}, meas_data, 'nmsq', calibration_data_type, [1,0.5], [0.01, 0.01]);
    [~ , solutions_par(i,:)] = plot_ROM_based_objectives(mod_result_searching_range, {modules_ROM{i}}, sub_meas_data, 'nmsq', calibration_data_type, [1,0.25], [0.01, 0.01]);
end
%}
solution_dir = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_nonlinear\Parameter_BARE_BBS\Optimisation_results\BARE_1.9300_1.8400_BBS_3.1500';

solution_dict = py.BEASY_IN_OUT1.get_output_data_for_IDs_from_simulation_folder(solution_dir, files_name, py.list(calibration_data_type), py.list({py.list(selected_Internal_points(:,1)), py.list(selected_mesh_points(:,1))}), py.list(IDs_type));

solution_data = convert_pydict2data(solution_dict,0);

meas_data_inc_error = data_from_tables(fullfile(meas_dir, 'meas_data.xlsx'), {selected_Internal_points(:,1), selected_mesh_points(:,1)},3);

meas_data_no_error = data_from_tables(fullfile(meas_dir, 'meas_data.xlsx'), {selected_Internal_points(:,1), selected_mesh_points(:,1)},2);


%{
file_name = fullfile(meas_dir, 'meas_data.xlsx');

meas_data_inc_error = meas_data_no_error;
for k = 1:length(sub_meas_data)
    error_range = [-20 ,20];
    if isequal(k,2)
        error_range = error_range*2;
    end
    meas_data_inc_err{k}(:,2) = meas_data_no_error{k}(:,2) + [error_range(1) + rand(1,size(meas_data_no_error{k}(:,2),1))*(error_range(2)-error_range(1))].';
    data = [meas_data_no_error{k}(:,1), meas_data_no_error{k}(:,2), meas_data_inc_err{k}(:,2)];
    variables_name = {'Ids', 'response_data', 'response_data_with_error'};
    %A = {{'Ids', 'response_data', 'response_data_with_error'}; data};
    T = array2table(data, 'VariableNames', variables_name);  
    writetable(T, file_name, 'Sheet', k);
    
end

%}
%plotting_bases_each_modules(modules_MPs, modules_snapshots);

%}

function [simulation_root_folder, collection_dir, measurement_dir] = get_simulation_input_for_involved_parameters(Parameters_involved)
Parameter_dir = 'Parameter';
for k = 1:length(Parameters_involved)
    Parameter_dir = strcat(Parameter_dir, '_' ,string(Parameters_involved{k}));
end

DOE_dir = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_nonlinear';

simulation_root_folder = fullfile(DOE_dir, Parameter_dir, 'Initial_files1');

collection_dir = fullfile(DOE_dir, Parameter_dir, 'Simulation_results');

if not(isfolder(collection_dir))
    mkdir(collection_dir)
end 

measurement_dir = fullfile(DOE_dir,Parameter_dir, 'Measurement_results7');

end

