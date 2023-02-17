function individual_parameter_calibration()

parameters= {'BARE','Zone1','CM00','BBS1', 'Zone2'};
x0 = [2.5, 3.0, 3.0, 3.0, 0.5];
%tru_sol_x0 = [2.0, 3.33333, 7.0, 7.0, 0.66667];

for i = 1: length(parameters)
    modules_matched_for_parametes{i} = get_module_idx_for_parameter(parameters{i});
end

[meas_dir, simulation_root_folder, collection_dir] = get_simulation_input_for_parameters(parameters, 'multi_linear');

metric = 'msq';

data_type = {'voltage', 'current density'};
%data_type = {'current density'}



%obj_fun = @(x) Objective(x, parameters, meas_dict, simulation_root_folder, collection_dir, metric, data_type, modules_ivolved);

obj_fun = @(x) Objec_selec_parameter(x, parameters, meas_dict, simulation_root_folder, collection_dir, metric, data_type, modules_ivolved);

x = x0;

for j = 1: length(parameters)
    
    parameter = parameters{j};
    
    indexes = [j];
    
    modules_involved = modules_matched_for_parametes{j};
    
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
    
    obj_fun = @(x_inv) Objec_selec_parameter(x_inv, indexes, x, parameters, meas_dict, simulation_root_folder, collection_dir, metric, data_type, modules_involved);
    
    fun_corr = @(x) Objective(x, parameters, meas_dict, simulation_root_folder, collection_dir, 'ccr', data_type, modules_involved);
    fun_msqr = @(x) Objective(x, parameters, meas_dict, simulation_root_folder, collection_dir, 'msq', data_type, modules_involved);
    
    
    
    [xsol,fval,xval] = runfminunc(x0(j), obj_fun);
    
    fprintf('optimisation for %s is over \n', parameter);
    %opt_results = return_result_together(xval, xsol, fun_corr, fun_msqr);
    
    x(j) = xsol
    
    
end
%[xsol,fval,xval] = runfminunc(x0_BARE_CM00_Zone1, parameters, meas_dict, simulation_root_folder, collection_dir, metric, data_type);
%[xsol,fval,xval] = runfminunc(x0_CM00_Zone2, obj_fun);

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
        
