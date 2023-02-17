parameters= {'BARE','Zone1'};
%x0 = [2.5, 3.0];
%x0 = [1.75, 3.0];
%tru_sol_x0 = [2.0, 3.33333, 7.0, 7.0, 0.66667];
x0 = [1.5, 2.5];
metric = 'nmsq';

calibration_data_type = {'voltage', 'current density'};

%calibration_data_count = [20, 15];
%calibration_data_count = [12, 4];
% this is for resources benchmarking chapter
%calibration_data_count = [50, 4];

current_density_type = 'normal';

modules_involved = [1,2,3,4,5,6,7,8];

meas_dir = 'D:\EXPERIMENT\DOE_nd_data_generation\Multilinear_pol_curves\Parameter_BARE_Zone1\Calibration_data2';

meas_dict = py.BEASY_IN_OUT.get_output_data_from_simulation_folder(meas_dir, 'BU_Jacket_newCurves', py.list(calibration_data_type), py.list(modules_involved), current_density_type, py.list(calibration_data_count));

meas_data = convert_pydict2data(meas_dict, 0); 
%%
IP_IDs = 32846:32894;

IPs_IDs1 = [32866       32886       32870       32874       32882       32846       32850       32878       32854   32858       32890       32862];

% for the case of calibration_data_count = [20, 4];
IP_IDs2 = [32864 32880 32866 32868 32870 32872 32874 32876 32882 32846 32848 32850 32852 32878 32854 32856 32884 32858 32860 32862];

Element_IDs_current_density = [1225  2089  2017  1945];

IDs_mat_arr = {IP_IDs, Element_IDs_current_density};

IDs_types = {'Internal Points', 'Element Points'};
%%
root_folder = 'D:\EXPERIMENT\DOE_nd_data_generation\Multilinear_pol_curves\Parameter_BARE_Zone1';

simulation_seed_folder = fullfile(root_folder, 'Initial_files');
%simulation_seed_folder  = "C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_linear\Parameter_BARE_Zone1\Initial_files1";

collection_dir = fullfile(root_folder, 'Simulation_results');

files_name = 'BU_Jacket_newCurves';
%%

%Initial_objective = Objective(x0, [1,2], x0, parameters ,all_position_dict, simulation_seed_folder, collection_dir, metric, py.list(modules_involved), calibration_data_type, current_density_type, calibration_data_count, obj_weightage);

Initial_output =  py.BEASY_IN_OUT.get_output_data_for_given_parameters(parameters, x0, simulation_seed_folder, collection_dir, py.list(calibration_data_type), py.list(modules_involved),  current_density_type, py.list(calibration_data_count));

initial_data = convert_pydict2data(Initial_output,1);
%%
calib_dir = fullfile(root_folder,'Calibration_data2');

calib_data_file_err_inc = 'data_with_error_Element_IDs_Ncd.xlsx';


if ~isfile(fullfile(calib_dir, calib_data_file_err_inc))
    all_position_dict = py.BEASY_IN_OUT.get_output_data_from_simulation_folder(calib_dir, files_name, py.list(calibration_data_type),  py.list(modules_involved), current_density_type, py.list([50 4]));
    all_position_data = convert_pydict2data(all_position_dict,0);
    introduce_error_and_write_file( {IP_IDs.', Element_IDs_current_density.'},all_position_data, calib_dir, calib_data_file_err_inc,1);
end
%model_out = output_from_surrogates([2.0, 3.0], surrogates, [17,6]);

calib_data_inc_error = data_from_tables(fullfile(calib_dir, calib_data_file_err_inc), IDs_mat_arr, 3);
calib_data_no_error = data_from_tables(fullfile(calib_dir, calib_data_file_err_inc), IDs_mat_arr, 2);

%%
%repetitive_calibration_count = 2;
obj_weightage = [1 1];
%optimisation_with_step(repetitive_calibration_count, parameters, x0, modules_involved, metric, calibration_data_type, current_density_type, calibration_data_count)
%x, indexes, x0, parameters, meas_data_dict, simulation_seed_folder, collection_dir, metric_type, modules, calibration_data_involved,current_density_type, calibration_data_count, weightage_constant)


%%

%%
%testing_par_value = [2.0017, 3.3430];
%testing_par_value = [1.8244, 3.1025];
testing_par_value = [1.6051, 2.7871];

solution_dict =  py.BEASY_IN_OUT.get_output_data_for_given_parameters(parameters, testing_par_value, simulation_seed_folder, collection_dir, py.list(calibration_data_type), py.list(modules_involved),  current_density_type, py.list(calibration_data_count));

solution_data = convert_pydict2data(solution_dict,1);


%%
figure;

ax = gca;

data_count = 1;
difference_in_bar_chart(ax,solution_data{data_count}(1:2:end,:), calib_data_inc_error{data_count}(1:2:end,:),{'simulation data from calibrated model','calibration data', 'difference'});
%difference_in_bar_chart(ax,solution_data{data_count}(1:2:end,:), calib_data_no_error{data_count}(1:2:end,:),{'simulation data from calibrated model','calibration data', 'difference'});

%difference_in_bar_chart(ax,solution_data{data_count}, calib_data_inc_error{data_count},{'simulation data from calibrated model','calibration data'});

%difference_in_bar_chart(ax,initial_data{data_count}, calib_data_inc_error{data_count},{'simulation data from initial model','data from reference model with added noise'});
%difference_in_bar_chart(ax,initial_data{data_count}(1:2:end,:), calib_data_inc_error{data_count}(1:2:end,:),{'simulation data from initial model','data from reference model with added noise'});
%

%set(ax,'XAxisLocation','bottom');

if isequal(data_count, 2)
    %difference_in_bar_chart(ax,solution_data{data_count}, calib_data_inc_error{data_count},{'simulation data from calibrated model','calibration data', 'difference'});

    ylabel('Normal Current Density (mA/m^2)');
    ylim([-4000 -2000]);
else
    ylim([-860 -780]);
    ylabel(ax, 'Potential difference Ag/Agcl/Sea-water (mV)');
end
xlabel(strcat(IDs_types{data_count}, ' IDs'));
%ylabel('Z electric field (micro-V/m)');
%
%}



%{
function output_data = convert_pydict2data(py_dict_data, extra_cell_provided)

output_data = cell(size(py_dict_data,2),1);

for i = 1:size(py_dict_data,2)
    output_data{i} = convert_py_list_to_mat_arr(py.model_validation1.get_list_of_values(py_dict_data{i+extra_cell_provided}));
end
end
%}