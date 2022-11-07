function fobj = Objective(x,source_parameters, parameters,validating_data, simulation_seed_folder, collection_dir, metric_type, response_data_type, IDs, IDs_types, weightage_constant)

if length(x) == 1
    par_values = py.list({x});
else 
    par_values = py.list(x);
end

%model_output = py.BEASY_IN_OUT2.get_response_data_for_IDs_and_input_parameters(py.list(source_parameters), py.list(parameters), par_values, simulation_seed_folder, collection_dir,  py.list(response_data_type), py.list(IDs),  py.list(IDs_types));
model_output = py.BEASY_IN_OUT1.get_response_data_for_IDs_and_input_parameters(py.list(parameters), par_values, simulation_seed_folder, collection_dir,  py.list(response_data_type), py.list(IDs),  py.list(IDs_types));


model_output =  convert_pydict2data(model_output, 1);

%weightage_constant = [0.6, 0.3];

if isequal(metric_type, 'nmsq')
    
    %data_involved = calibration_data_type;
    fobj = normalised_mean_sq_diff(model_output, validating_data, response_data_type, weightage_constant);
end

end


function f = normalised_mean_sq_diff(model_output, validating_data, data_involved, weightage_constant)

    if length(data_involved) > 1
        f = 0;
        for i = 1:length(data_involved)
            sub_meas_data = validating_data{i}(:,end);
            [indices_with_zero, ~] = find(sub_meas_data ==0); 
            sub_meas_data(indices_with_zero) = [];
            sub_out_data = model_output{i}(:,end);
            sub_out_data(indices_with_zero) = [];
            %f = f + weightage_constant(i)* sqrt( mean((model_output{i}-meas_data{i}).^2./meas_data{i}.^2 ));
            f = f + weightage_constant(i)* sqrt( mean((sub_out_data-sub_meas_data).^2./sub_meas_data.^2 ));
        end
        
        f = f/length(data_involved);
        
    elseif strcmp(data_involved{1}, 'voltage')
        sub_meas_data = validating_data{1};
        f = sqrt( mean((model_output{1}-sub_meas_data(:,2)).^2./sub_meas_data(:,2).^2 ));
    elseif strcmp(data_involved{1}, 'current density')
        f = sqrt( mean((model_output{2}-meas_data{2}).^2./meas_data{2}.^2));
    end
   
end