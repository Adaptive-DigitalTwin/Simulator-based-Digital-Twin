function optimisation_with_step()

parameters= {'BARE','CM00','BBS1','Zone1','Zone2'};
x0 = [2.5, 3.0, 3.0, 3.0, 0.5];
%tru_sol_x0 = [2.0, 3.33333, 7.0, 7.0, 0.66667];

for i = 1: length(parameters)
    modules_matched_for_parametes{i} = get_module_idx_for_parameter(parameters{i});
end

[meas_dir, simulation_root_folder, collection_dir] = get_simulation_input_for_parameters(parameters, 'multi_linear');

metric = 'ccr';

data_type = {'voltage', 'current density'};
%data_type = {'current density'}

x = x0;

previous_state = x0;

calib_count = 0;

while 1
    
    calib_count = calib_count+1;
    fprintf('%dth calibration going on \n', calib_count);
    optimised_parameters_represent = zeros(1, length(parameters));

while length(find(optimised_parameters_represent ==0)) > 0
    
    non_optimised_indexes = find(optimised_parameters_represent ==0);
    
    %similar_module_parameters_idx = [next_parameter_idx];
    parameter_indexes_for_optimisation = [];
    
    %optimisation is performed together if the validation data module for
    %the parameters are similar.
    
    for j = 1:length(non_optimised_indexes)
        
        if j ==1
            parameter_indexes_for_optimisation(1) = non_optimised_indexes(j);
        
        elseif isequal(modules_matched_for_parametes{non_optimised_indexes(1)}, modules_matched_for_parametes{non_optimised_indexes(j)})
            
            parameter_indexes_for_optimisation(end+1) = non_optimised_indexes(j);
        end
    end
    
    
    %indexes = [j];
    
    modules_involved = modules_matched_for_parametes{parameter_indexes_for_optimisation(1)}
    modules_involved_arr = modules_involved;
    
    if length(modules_involved) ==1
        modules_involved = py.list({modules_involved});
    else
        modules_involved = py.list(modules_involved);
    end
    
    meas_dict = py.BEASY_IN_OUT.get_output_data_from_simulation_folder(meas_dir, 'BU_Jacket_newCurves', modules_involved)
    
    if length(data_type) == 1
        if strcmp(data_type{1}, 'voltage')
        meas_dict = meas_dict(:,1);
        else
        meas_dict = meas_dict(:,2);
        end
    end
    
    model_ouput = py.BEASY_IN_OUT.get_output_data_for_given_parameters( py.list(parameters),py.list(x), simulation_root_folder, collection_dir, modules_involved);
    
    formatSpec = "plot_before_opt_from_modules_%d_%d_on_%dth_calib.png";
    A = [modules_involved_arr(1), modules_involved_arr(length(modules_involved_arr)), calib_count];
    name_for_plot = compose(formatSpec,A);
    
    %name_for_plot = strjoin({'Plots\','Plot_before_' ,strjoin(string(modules_involved_arr),''),'_modules_on_', string(calib_count), 'th _calib.png'}, '') ;
    
    %plot_and_save(meas_dict, model_ouput, name_for_plot, meas_dir);
    
    obj_fun = @(x_inv) Objec_selec_parameter(x_inv, parameter_indexes_for_optimisation, x, parameters, meas_dict, simulation_root_folder, collection_dir, metric, data_type, modules_involved);
    
    %fun_corr = @(x) Objective(x, parameters, meas_dict, simulation_root_folder, collection_dir, 'ccr', data_type, modules_involved);
    %fun_msqr = @(x) Objective(x, parameters, meas_dict, simulation_root_folder, collection_dir, 'msq', data_type, modules_involved);
    
    fprintf('optimisation is going on for \n');
    disp(parameters(parameter_indexes_for_optimisation));
    
    [xsol,fval,xval] = runfminunc(x(parameter_indexes_for_optimisation), obj_fun);
    
    fprintf('optimisation is over for \n');
    disp(parameters(parameter_indexes_for_optimisation));
    
    optimised_parameters_represent(parameter_indexes_for_optimisation) = 1;
    
    x(parameter_indexes_for_optimisation) = xsol;
    
    disp(x);
    
    model_ouput = py.BEASY_IN_OUT.get_output_data_for_given_parameters( py.list(parameters),py.list(x), simulation_root_folder, collection_dir, modules_involved);
    
    formatSpec = "plot_after_opt_from_modules_%d_%d_on_%dth _calib.png";
    %A = [modules_involved_arr(1), modules_involved_arr(length(modules_involved_arr)), calib_count];
    name_for_plot = compose(formatSpec,A);
    plot_and_save(meas_dict, model_ouput, name_for_plot, meas_dir);
end
%[xsol,fval,xval] = runfminunc(x0_BARE_CM00_Zone1, parameters, meas_dict, simulation_root_folder, collection_dir, metric, data_type);
%[xsol,fval,xval] = runfminunc(x0_CM00_Zone2, obj_fun);

if isequal(previous_state, x)
    break
end

previous_state = x;


end

end

function [meas_dir, simulation_root_folder, collection_dir] = get_simulation_input_for_parameters(Parameters, polar_curve_type)

if isequal(polar_curve_type,'linear')
    dir1 = 'C:\Users\msapkota\EXPERIMENT\Optimisation_problem\Linear_polar_curves';
else
    %dir1 = 'C:\Users\msapkota\EXPERIMENT\Optimisation_problem\Multi_linear_polar_curves\All';
    %dir1 = 'C:\Users\msapkota\EXPERIMENT\Optimisation_problem\New_path2';
    dir1 = 'C:\Users\msapkota\EXPERIMENT\Optimisation_problem\Multi_linear_polar_curves\All';
end

Parameter_dir = 'Parameter';
for k = 1:length(Parameters)
    Parameter_dir = strcat(Parameter_dir, '_' ,string(Parameters{k}));
end

simulation_root_folder = fullfile(dir1, 'Initial_files');

meas_dir = fullfile(dir1, 'Measurement_data');

collection_dir = fullfile(dir1, 'Simulation_results');

if not(isfolder(collection_dir))
    mkdir(collection_dir)
end

%{
if length(modules) ==1
    modules = py.list({modules});
else
    modules = py.list(modules);
end

meas_dict = py.BEASY_IN_OUT.get_output_data_from_simulation_folder(meas_dir, 'BU_Jacket_newCurves', modules);
%}
%updated_polar_meas_data_dict = updated_polar_meas_data{2}
end

function results = return_result_together(xval, xsol, fun_corr, fun_msqr)

results = zeros(size(xval, 1),size(xsol, 2)+2);

for k = 1:size(xval,1)
    results(k,1:length(xsol)) = xval(k,1:length(xsol));
    results(k,length(xsol)+1:length(xsol)+2) = [fun_corr(xval(k,:)) fun_msqr(xval(k,:))];
end
end

function module_idx = get_module_idx_for_parameter(parameter)

switch parameter
    case 'BARE' 
        module_idx = [1,2,3,4,5,6,7,8];
    case 'Zone1'
        module_idx = [1,2,3,4,5,6,7,8];
    case 'CM00'
        module_idx = [1,2,3,4,5,6,7,8];
    case 'BBS1'
        module_idx = [1];
    case 'Zone2'
        module_idx = [1];
end

end
        
