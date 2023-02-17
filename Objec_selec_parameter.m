function fun1 = Objec_selec_parameter(x, indexes, x0, parameters, meas_data_dict, simulation_seed_folder, collection_dir, metric_type, modules, calibration_data_involved,current_density_type, calibration_data_count)

par_values = x0;
%
for i = 1:length(x)
    %if x(i) <=0
        %par_values(indexes(i)) = 0.3;
    %else
        par_values(indexes(i)) = x(i);
    %end
end

if length(par_values) == 1
    par_values = py.list({par_values});
else 
    par_values = py.list(par_values);
end

model_output = py.BEASY_IN_OUT.get_output_data_for_given_parameters(parameters, par_values, simulation_seed_folder, collection_dir, py.list(calibration_data_involved), modules,  current_density_type, py.list(calibration_data_count));

if isequal(metric_type, 'msq')
    fun1 = mean_sq_diff(model_output, meas_data_dict, calibration_data_involved);
elseif isequal(metric_type,'ccr')
    fun1 = coefficient_of_correlation(model_output, meas_data_dict, calibration_data_involved);
elseif isequal(metric_type,'compre_sum')
    fun1 = Obj_comprehen(model_output,  meas_data_dict, 1E6);
else
    fun1 = Obj_compre_prod(model_output,  meas_data_dict);  
end


function f = mean_sq_diff(model_output, meas_data, data_involved)

    if length(data_involved) > 1
        f = 0;
        for i = 1:length(data_involved)
            if i == 1
                f = f + py.model_validation1.get_mean_square_sum_for_different(meas_data{i}, model_output{i+1});
            else
                f = f + 0.5* py.model_validation1.get_mean_square_sum_for_different(meas_data{i}, model_output{i+1});
            end
        end
    elseif strcmp(data_involved{1}, 'voltage')
        f = py.model_validation1.get_mean_square_sum_for_different(meas_data{1}, model_output{2});
    elseif strcmp(data_involved{1}, 'current density')
        f = py.model_validation1.get_mean_square_sum_for_different(meas_data{1}, model_output{2});
    end
   
end


function f = coefficient_of_correlation(model_output, meas_data, data_involved)
     
    if length(data_involved) > 1
        meas_data_combined = meas_data{1};
        model_output_combined = model_output{2};
        for i = 1:length(data_involved)-1
            meas_data_combined = py.model_validation1.merge_two_dict(meas_data_combined, meas_data{i+1});
            model_output_combined = py.model_validation1.merge_two_dict(model_output_combined, model_output{i+2});
        end
        
        f = py.model_validation1.coefficient_of_correlation_R2(meas_data_combined, model_output_combined);
    
    elseif strcmp(data_involved{1}, 'voltage')
        f = py.model_validation1.coefficient_of_correlation_R2(meas_data{1}, model_output{2});
        
    elseif strcmp(data_involved{1}, 'current density')
        f = py.model_validation1.coefficient_of_correlation_R2(meas_data{1}, model_output{3});
    end
        
    f = 1/(1-f);
    
end

end