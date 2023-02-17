
parameters= {'BARE','Zone1'};

root_folder = 'D:\EXPERIMENT\DOE_nd_data_generation\Multilinear_pol_curves\Parameter_BARE_Zone1';
simulation_seed_folder = fullfile(root_folder, 'Initial_files');
%simulation_seed_folder  = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\year_20\Initial_files';

collection_dir = fullfile(root_folder, 'Simulation_results');

%par_value = [0.0045    0.0045];
par_value = [1.75   3.00];

simulation_folder = '';
for i = 1:length(parameters)
    simulation_folder =   strcat(simulation_folder, parameters{i},'_', num2str(par_value(i), '%.4f'));
    if i~=length(parameters)
        simulation_folder = strcat(simulation_folder, '_');
    end
end
files_name = 'BU_Jacket_newCurves';



mat_file = fullfile(collection_dir, simulation_folder, strcat(files_name,'.mat_cp'));

%mat_file = fullfile(simulation_seed_folder, strcat(files_name,'.mat_cp'));


parameters_pol = {'BARE'};
%meas_pol_curves = py.BEASY_IN_OUT1.get_polarisation_curve_from_mat_file(py.list(parameters), meas_mat_file);

%polarisation_curves = py.BEASY_IN_OUT1.get_polarisation_curve_from_mat_file(py.list({ 'ST15', 'ST25'}), mat_file);
polarisation_curves = py.BEASY_IN_OUT.get_polarisation_curve_from_mat_file(py.list(parameters_pol), mat_file);

%%

%figure
%hold on;
p2 = cell(length(polarisation_curves),1);
plot_lines2 = zeros(length(polarisation_curves),1);
for i =1:length(polarisation_curves)
    pol_curve = polarisation_curves{i};
    current_value = convert_py_list_to_mat_arr(pol_curve.current_values);
    potential_value = convert_py_list_to_mat_arr(pol_curve.voltage_values);
    if isequal(rem(i,2),0)
       p2{i} = plot(current_value, smooth(potential_value),'LineWidth' , 1.5, 'LineStyle', '--');
    else
         p2{i} = plot(current_value, smooth(potential_value),'LineWidth' , 1.5);
    end
   
    plot_lines2(i) = p2{i}(1);
    if ~isequal(i, length(polarisation_curves))
        hold on;
   end
end

%%
legend({'Reference Polarisation curve with p-value = 1', 'Polarisation curve with p-value = 1.75000'});

xlim([0 5500])

xlabel(strcat('Current density (', string(pol_curve.current_unit),')'));
ylabel(strcat('Potential (', string(pol_curve.voltage_unit), ')'));
