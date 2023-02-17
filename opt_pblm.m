
%fsurf(f,[-2,2],'ShowContours','on')
simulation_seed_folder = 'E:\BEASY_Model_Related\Gradient_method_parameter_update\Linear_pol_curves\Initial_files'

collection_dir = 'E:\BEASY_Model_Related\Gradient_method_parameter_update\Linear_pol_curves\opt_outputs'

meas_data = py.BEASY_IN_OUT_2.convert_csv_file_to_dictionary_with_ID_key('E:\BEASY_Model_Related\Gradient_method_parameter_update\Linear_pol_curves\meas_simu\Internal_Points.csv','Output_value')

fun = @(x) myObjective(x, meas_data, simulation_seed_folder, collection_dir);

x0 = [2.0 0.5]


%unconstrained minimization function fminunc
%options = optimoptions('fminunc','FiniteDifferenceStepSize',1e-2, 'Display','iter','PlotFcn','optimplotfvalconstr', 'Tolfun' , 1e-3);

options = optimoptions('fmincon','FiniteDifferenceStepSize',1e-2, 'Display','iter','PlotFcn','optimplotfvalconstr', 'Tolfun' , 1e-1);

[x, fval] = fmincon(fun,x0,[],[],[],[],[0.2],[3],[],options);