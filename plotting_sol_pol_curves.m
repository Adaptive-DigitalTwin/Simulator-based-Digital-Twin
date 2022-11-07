%{
solution_dir = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\year_10\previous__updated_model\Simulation_results\BA01_0.7450_______BA08_0.5300';

polar_dir = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\year_10\Polarisation_data';

files_name = 'BU_014_NoLinear';

meas_files_name = 'BU_TimeStepped_01_10';

meas_dir = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\year_10\measurement_data';


%}
figure
%%

materials_invoved = {'BARE'};


mat_file = fullfile(simulation_seed_folder, strcat(files_name,'.mat_cp'));

polarisation_curves = py.BEASY_IN_OUT1.get_polarisation_curve_from_mat_file(py.list(materials_invoved), mat_file);
%%
%{
p = cell(length(meas_pol_curves),1);
plot_lines = zeros(length(meas_pol_curves),1);

for i =1:length(meas_pol_curves)
    pol_curve = meas_pol_curves{i};
    disp(pol_curve.name);
    current_value = convert_py_list_to_mat_arr(pol_curve.current_values);
    potential_value = convert_py_list_to_mat_arr(pol_curve.voltage_values);
    p{i} = plot(current_value, smooth(potential_value));
    plot_lines(i) = p{i}(1);
    if ~isequal(i, length(meas_pol_curves))
        hold on;
   end
end
%legend([p{1}(1);p{2}(1)], 'Material A2 relatd polarisation curve', 'Material A1 related polarisation curve');
%legend(flip(plot_lines), meas_materials_tag);
%legend(plot_lines, meas_materials_tag);

%}
%%
figure;
hold on;
p2 = cell(length(polarisation_curves),1);
plot_lines2 = zeros(length(polarisation_curves),1);
for i =1:length(polarisation_curves)
    pol_curve = polarisation_curves{i};
    current_value = convert_py_list_to_mat_arr(pol_curve.current_values);
    potential_value = convert_py_list_to_mat_arr(pol_curve.voltage_values);
    if isequal(rem(i,2) ,1)
        p2{i} = plot(current_value, smooth(potential_value),'LineWidth' , 1.5, 'LineStyle','-');
    else
        p2{i} = plot(current_value, smooth(potential_value),'LineWidth' , 1.5);
    end
    plot_lines2(i) = p2{i}(1);
    if ~isequal(i, length(polarisation_curves))
        hold on;
   end
end

%legend([plot_lines; plot_lines2],[strcat('True ',parameters), strcat('Solution ', parameters)]);
legend(plot_lines2, strcat('curve for Material__ ', materials_invoved));
xlabel(strcat('Current density (', string(pol_curve.current_unit),')'));
ylabel(strcat('Potential (', string(pol_curve.voltage_unit), ')'));
ylim([-1150 -700])
%}

legend({'Initial polarisation curve(p-value =1.75)', 'Solution Polarisation curve(p-value = 1.99)','Reference Polarisation Curve(p-value = 1.00)'})
