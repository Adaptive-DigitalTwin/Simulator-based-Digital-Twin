function optimisation_with_step(repetitive_calibration_count, parameters, x0,modules_matched_for_parametes, metric, calibration_data_type, current_density_type, calibration_data_count)


[meas_dir, simulation_root_folder, collection_dir] = get_simulation_input_for_parameters(parameters, 'multi_linear');

x = x0;

previous_state = x0;

calibration_count = 1;

msqr_weightage_constant = [1, 1, 1];

while 1

    fprintf('%d th calibration starting \n \n', calibration_count);
    
    optimised_parameters_represent = zeros(1, length(parameters));

    while ~isempty(find(optimised_parameters_represent ==0, 1))
    
        non_optimised_indexes = find(optimised_parameters_represent ==0);
    
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

        modules_involved = modules_matched_for_parametes{parameter_indexes_for_optimisation(1)};
        modules_involved_arr = modules_involved;
    
        if length(modules_involved) ==1
            modules_involved = py.list({modules_involved});
            msqr_weightage_constant(2) = 0.8;
            %msqr_weightage_constant(3) = 1;
        else
            modules_involved = py.list(modules_involved);
            msqr_weightage_constant(2) = 1;
            %msqr_weightage_constant(3) = 0.1;
        end
    
        meas_dict = py.BEASY_IN_OUT.get_output_data_from_simulation_folder(meas_dir, 'BU_Jacket_newCurves', py.list(calibration_data_type), modules_involved, current_density_type, py.list(calibration_data_count));
    
        model_ouput = py.BEASY_IN_OUT.get_output_data_for_given_parameters( py.list(parameters),py.list(x), simulation_root_folder, collection_dir, py.list(calibration_data_type), modules_involved,  current_density_type, py.list(calibration_data_count));
    
        formatSpec = "plot_before_opt_from_modules_%d_%d_on_%dth_calib.png";
        A = [modules_involved_arr(1), modules_involved_arr(length(modules_involved_arr)), calibration_count];
        name_for_plot = compose(formatSpec,A);

        plot_simulation_result(meas_dict, model_ouput, name_for_plot, meas_dir, calibration_data_type);
    
        if length(calibration_data_type) == 1
            if strcmp(data_type{1}, 'voltage')
            meas_dict = meas_dict(:,1);
            else
            meas_dict = meas_dict(:,2);
            end
        end
        obj_fun = @(x_inv) Objective(x_inv, parameter_indexes_for_optimisation, x, parameters, meas_dict, simulation_root_folder, collection_dir, metric, modules_involved, calibration_data_type, current_density_type, calibration_data_count, msqr_weightage_constant);
        %obj_fun = @(x_inv) Objec_selec_parameter(x_inv, parameter_indexes_for_optimisation, x, parameters, meas_dict, simulation_root_folder, collection_dir, metric, modules_involved, calibration_data_type, current_density_type, calibration_data_count);
    
        
        fprintf('optimisation is going on for \n');
        disp(parameters(parameter_indexes_for_optimisation));
    
        [xsol,fval,xval] = runfminunc(x(parameter_indexes_for_optimisation), obj_fun);
    
        fprintf('optimisation is over for \n');
        disp(parameters(parameter_indexes_for_optimisation));
   
        optimised_parameters_represent(parameter_indexes_for_optimisation) = 1;
    
        x(parameter_indexes_for_optimisation) = xsol;
    
        disp(x);
    
        model_ouput = py.BEASY_IN_OUT.get_output_data_for_given_parameters( py.list(parameters),py.list(x), simulation_root_folder, collection_dir, py.list(calibration_data_type),modules_involved,  current_density_type, calibration_data_count);
    
        formatSpec = "plot_after_opt_from_modules_%d_%d_on_%dth _calib.png";
       
        name_for_plot = compose(formatSpec,A);
        plot_simulation_result(meas_dict, model_ouput, name_for_plot, meas_dir, calibration_data_type);
    
    
    end
%[xsol,fval,xval] = runfminunc(x0_BARE_CM00_Zone1, parameters, meas_dict, simulation_root_folder, collection_dir, metric, data_type);
%[xsol,fval,xval] = runfminunc(x0_CM00_Zone2, obj_fun);

if isequal(previous_state, x)
    break
end

if isequal(repetitive_calibration_count, calibration_count)
    fprintf('optimisation is over for calibration count reached\n');
    break;
end

previous_state = x;

calibration_count = calibration_count+1;

end


end


function [meas_dir, simulation_root_folder, collection_dir] = get_simulation_input_for_parameters(Parameters, polar_curve_type)

if isequal(polar_curve_type,'linear')
    dir1 = 'C:\Users\msapkota\EXPERIMENT\Optimisation_problem\Linear_polar_curves';
else
    %dir1 = 'C:\Users\msapkota\EXPERIMENT\Optimisation_problem\Multi_linear_polar_curves\All';
    %dir1 = 'C:\Users\msapkota\EXPERIMENT\Optimisation_problem\New_path2';
    dir1 = 'D:\EXPERIMENT\DOE_nd_data_generation\Multilinear_pol_curves';
end

Parameter_dir = 'Parameter';
for k = 1:length(Parameters)
    Parameter_dir = strcat(Parameter_dir, '_' ,string(Parameters{k}));
end

simulation_root_folder = fullfile(dir1, 'Initial_files');

meas_dir = fullfile(dir1, 'Calibration_data2');

collection_dir = fullfile(dir1, 'Simulation_results');

if not(isfolder(collection_dir))
    mkdir(collection_dir)
end


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
        module_idx = [1,2];
    case 'Zone2'
        module_idx = [1,2];
end

end
        
