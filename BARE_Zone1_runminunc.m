

meas_dir = "D:\EXPERIMENT\DOE_nd_data_generation\Multilinear_pol_curves\Parameter_BARE_Zone1\Measurement_results3";

meas_data_Internal_Points = csvread(fullfile(meas_dir, 'Internal_Points.csv'),1,1);

IPs_IDs = meas_data_Internal_Points(:,1);

%IPs_IDs1 = IPs_IDs(1:2:end);
%IPs_IDs1 = IPs_IDs(1:3:end);
%IPs_IDs1 = IPs_IDs(1:4:end);

IPs_IDs1 = [32866       32886       32870       32874       32882       32846       32850       32878       32854   32858       32890       32862];

%MP_IDs_normal_current_density = [1225, 4270, 925, 7870, 3709];

MP_IDs_normal_current_density = [14390, 7400, 4060, 16000, 19860, 23802];

%Element_IDs_current_density = [1225        2089        2017        1945];

%IDs = {py.list(IPs_IDs1), py.list(IDs_current_density)};
IDs = {py.list(IPs_IDs1), py.list(MP_IDs_normal_current_density)};
%IDs = {py.list(IPs_IDs1)};

%IDs_mat_arr = {IPs_IDs1, IDs_current_density};
IDs_mat_arr = {IPs_IDs1, MP_IDs_normal_current_density};
%IDs_mat_arr = {IPs_IDs1};

IDs_types = {'Internal Points', 'Mesh Points'};
%IDs_types = {'Internal Points'};

calib_data_type = {'voltage', 'normal current density'};
%calib_data_type = {'voltage'};

%%
source_parameters = {'BARE','Zone1'};

parameters= {'BARE','Zone1'};
%x0 = [1.5, 2.5];

%x0 = [1.25 2.5];
%x0 = [1.5 3];
x0 = [1.75, 3];

%x0 = [2.25 3];

%IDs = meas_data_Internal_Points(:,1);
%%

root_folder = 'D:\EXPERIMENT\DOE_nd_data_generation\Multilinear_pol_curves\Parameter_BARE_Zone1';

simulation_seed_folder = fullfile(root_folder, 'Initial_files');
%simulation_seed_folder  = "C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_linear\Parameter_BARE_Zone1\Initial_files1";

collection_dir = fullfile(root_folder, 'Simulation_results');
%%
calib_dir = fullfile(root_folder,'Calibration_data2');
%calib_dir = fullfile(root_folder,'Calibration_data');

%meas_dir1 = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_nonlinear\Parameter_BARE_BBS\Measurement_results3';

%calib_data_IDs = {IPs_IDs1, IDs_current_density};
%calib_data_type = response_data_type(1:2);

files_name = 'BU_Jacket_newCurves';

%calib_data_file_err_inc = 'data_with_error1.xlsx';
calib_data_file_err_inc = 'data_with_error.xlsx';


if ~isfile(fullfile(calib_dir, calib_data_file_err_inc))
    all_position_dict = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(calib_dir, files_name, py.list(calib_data_type),  py.list({py.list(IPs_IDs), py.list(MP_IDs_normal_current_density)}), py.list(IDs_types));
    all_position_data = convert_pydict2data(all_position_dict,0);
    introduce_error_and_write_file( {IPs_IDs, MP_IDs_normal_current_density.'},all_position_data, calib_dir, calib_data_file_err_inc,1);
end
%model_out = output_from_surrogates([2.0, 3.0], surrogates, [17,6]);

calib_data_inc_error = data_from_tables(fullfile(calib_dir, calib_data_file_err_inc), IDs_mat_arr, 3);
calib_data_no_error = data_from_tables(fullfile(calib_dir, calib_data_file_err_inc), IDs_mat_arr, 2);

%%
%model_out = output_from_surrogates([2.0, 3.0], surrogates, [17,6]);
metric = 'nmsq';

%plot_and_save(meas_dict, meas_data, 'adfa', meas_dir)
%obj_weightage = [0.6 0.3];
%obj_weightage = [2 1];
%obj_weightage = [1 0];
%obj_weightage = [1 5];
%obj_weightage = [1 10];
obj_weightage = [1 2];

[xsol,fval,opt_data] = runfminunc(x0,source_parameters, parameters, calib_data_inc_error, simulation_seed_folder, collection_dir, metric, calib_data_type, IDs, IDs_types, obj_weightage);
%[xsol,fval,opt_data] = runfminunc(x0,source_parameters, parameters, calib_data_no_error, simulation_seed_folder, collection_dir, metric, calib_data_type, IDs, IDs_types, obj_weightage);
  
Objective(x0,source_parameters, parameters,calib_data_no_error, simulation_seed_folder, collection_dir, metric, calib_data_type, IDs, IDs_types, obj_weightage)

                               
%repetitive_calibration_count = 2;
%%

%xssol_Calib2 = [2.1573    3.1385];

testing_par_value = xsol;

solution_folder = '';
for i = 1:length(parameters)
    solution_folder =   strcat(solution_folder, parameters{i},'_', num2str(testing_par_value(i), '%.4f'));
    if i~=length(parameters)
        solution_folder = strcat(solution_folder, '_');
    end
end
solution_colection_dir = fullfile(root_folder,'Simulation_results');

solution_dir = fullfile(solution_colection_dir, solution_folder);

if ~isfolder(solution_dir)
    solution_dict = py.BEASY_IN_OUT1.get_response_data_for_IDs_and_input_parameters( py.list(parameters), py.list(testing_par_value), simulation_seed_folder, solution_colection_dir,  py.list(calib_data_type), py.list(IDs),  py.list(IDs_types));
    solution_data = convert_pydict2data(solution_dict,1);
else

    solution_dict = py.BEASY_IN_OUT1.get_output_data_for_IDs_from_simulation_folder(solution_dir, files_name, py.list(calib_data_type),  py.list(IDs), py.list(IDs_types));
    solution_data = convert_pydict2data(solution_dict,0);
end

%%

%data from initial position

testing_par_value = x0;

initial_folder = '';
for i = 1:length(parameters)
    initial_folder =   strcat(initial_folder, parameters{i},'_', num2str(testing_par_value(i), '%.4f'));
    if i~=length(parameters)
        initial_folder = strcat(initial_folder, '_');
    end
end

initial_dir = fullfile(collection_dir, initial_folder);

if ~isfolder(initial_dir)
    initial_dict = py.BEASY_IN_OUT1.get_response_data_for_IDs_and_input_parameters( py.list(parameters), py.list(testing_par_value), simulation_seed_folder, collection_dir,  py.list(calib_data_type), py.list(IDs),  py.list(IDs_types));
    initial_data = convert_pydict2data(initial_dict,1);
else

    initial_dict = py.BEASY_IN_OUT1.get_output_data_for_IDs_from_simulation_folder(initial_dir, files_name, py.list(calib_data_type),  py.list(IDs), py.list(IDs_types));
    initial_data = convert_pydict2data(initial_dict,0);
end


%%

figure;

ax = gca;

data_count = 1;
%difference_in_bar_chart(ax,solution_data{data_count}(1:2:end,:), calib_data_inc_error{data_count}(1:2:end,:),{'simulation data from calibrated model','calibration data', 'difference'});
%difference_in_bar_chart(ax,solution_data{data_count}(1:2:end,:), calib_data_no_error{data_count}(1:2:end,:),{'simulation data from calibrated model','calibration data', 'difference'});

%difference_in_bar_chart(ax,solution_data{data_count}, calib_data_inc_error{data_count},{'simulation data from calibrated model','calibration data', 'difference'});

difference_in_bar_chart(ax,initial_data{data_count}, calib_data_inc_error{data_count},{'simulation data from initial model','calibration data'});
%difference_in_bar_chart(ax,initial_data{data_count}(1:2:end,:), calib_data_inc_error{data_count}(1:2:end,:),{'simulation data from initial model','calibration data', 'difference'});
%

%set(ax,'XAxisLocation','bottom');

if isequal(data_count, 2)
    %difference_in_bar_chart(ax,solution_data{data_count}, calib_data_inc_error{data_count},{'simulation data from calibrated model','calibration data', 'difference'});

    ylabel('Normal Current Density (mA/m^2)');
    ylim([-2500 -1000]);
else
    ylim([-860 -780]);
    ylabel(ax, 'Potential difference Ag/Agcl/Sea-water (mV)');
end
xlabel(strcat(IDs_types{data_count}, ' IDs'));
%ylabel('Z electric field (micro-V/m)');
%
%}
%%

figure;

ax = gca;

legend_cell = {'calibration data', 'output from calibrated surrogate', 'simulation output of calibrated model'};
%legend_cell = { 'output from calibrated surrogate', 'simulation output of calibrated model'};

data_ID = 4;
%response_in_bar_chart(ax, solution_data{data_ID}(1:3:end,:) , {calib_data_15{data_ID}(1:3:end,:), sol_output_from_surrogate{data_ID}(1:3:end,:),solution_data{data_ID}(1:3:end,:)}, legend_cell);
response_in_bar_chart(ax, solution_data{data_ID} , {calib_data_15{data_ID}, sol_output_from_surrogate{data_ID}, solution_data{data_ID}}, legend_cell);
%response_in_bar_chart(ax, solution_data{data_ID} , { sol_output_from_surrogate{data_ID}, solution_data{data_ID}}, legend_cell);

%%
figure;

ax = gca;

data_indx = 1;
response_plot_3d(ax, calib_data_inc_error, calib_data_inc_error, data_indx, calib_data_type{data_indx},  IDs_types{data_indx}, files_name, calib_dir);


%%
%optimisation_with_step(repetitive_calibration_count, parameters, x0, modules_matched_for_parametes, metric, calibration_data_type, current_density_type, calibration_data_count)


%%

function output_data = convert_pydict2data2(py_dict_data, extra_cell_provided)

output_data = cell(size(py_dict_data,2)-extra_cell_provided,1);

for i = 1:size(py_dict_data,2)-extra_cell_provided
    output_data{i} = convert_py_list_to_mat_arr(py.model_validation1.get_list_of_values(py_dict_data{i+extra_cell_provided}));
end
end


function de_normaised_data = reverse_normalization(normalised_data, value_ranges)

de_normaised_data = zeros(size(normalised_data));

for i = 1:size(normalised_data, 2)
    
    de_normaised_data(:,i) = value_ranges(i,1)+ diff(value_ranges(i,:))/2 * (normalised_data(:,i)-(-1));
    
end
end