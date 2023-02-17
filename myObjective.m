function f = myObjective(x, meas_data, simulation_seed_folder, collection_dir,  curves_name,zones_names)
    if length(curves_name) == 1
        curve_p_values = py.list({x(1)});
    elseif length(curves_name) == 0
        curve_p_values = py.list({});
    else
        curve_p_values = py.list([x(1:length(curves_name))]);
    end
    if length(zones_names) ==1
        zones_conductivity = py.list({x(length(curves_name)+1)});
    elseif length(zones_names) ==0
        zones_conductivity = py.list();
    else
        zones_conductivity = py.list([x(length(curves_name)+1:length(x))]);
    end
    
    model_output = py.BEASY_IN_OUT_2.get_output_data_for_given_p_values_and_zones_conductivity(curves_name, curve_p_values, zones_names, zones_conductivity, simulation_seed_folder, collection_dir); 
    
    %model_output_table = readtable(model_output(1))
    
    %model_output_data = model_output_table{:,:}(:,[6]);
    %f = meansqr(model_output_data-meas_data);

    %f = Objective_pvalue(meas, simulation_seed_folder,'BU_Jacket_010', collection_dir, curves_name, p_values)
    f= py.model_validation1.get_mean_square_sum_for_different(meas_data, model_output{2});

    %f = Objective_pvalue(meas_data, simulation_seed_folder,'BU_Jacket_010', collection_dir, py.list({'BARE'}), py.list({x(1)}));
end


