function [xsol,fval,xval] = runfmincon(x0, lower_limits, upper_limits, parameters, meas_data_dict, simulation_seed_folder, collection_dir, obj_fun)

history.x = [];
history.fval = [];
%searchdir = [];
fv = [];
xval = [];
%{
%meas_data = meas_table{:,:}(:,[2,3,4,5,6]);
%meas_table = readtable('C:\Users\msapkota\EXPERIMENT\Optimisation_problem\Multi_linear_polar_curves\Multi_parameter\Parameter_BARE_BBS1_Zone1\Measurement_data\Internal_Points.csv');
meas_data = py.BEASY_IN_OUT_2.convert_csv_file_to_dictionary_with_ID_key('C:\Users\msapkota\EXPERIMENT\Optimisation_problem\Linear_polar_curves\Parameter_BARE_ZONE1\meas_simu\Internal_Points.csv','Output_value');
%meas_data = meas_table{:,:}(:,[6]);
%}
if isequal(obj_fun, 'msq')
    fun = @(x) Objective1(x, parameters,meas_data_dict, simulation_seed_folder, collection_dir);
elseif isequal(obj_fun,'ccr')
    fun = @(x) Objective_coefficient_of_correlation(x, parameters, meas_data_dict, simulation_seed_folder, collection_dir);
elseif isequal(obj_fun,'compre_sum')
    fun = @(x) Obj_comprehen(x, parameters, meas_data_dict, simulation_seed_folder, collection_dir, 1E6);
else
    fun = @(x) Obj_compre_prod(x, parameters, meas_data_dict, simulation_seed_folder, collection_dir);
end

x0
obj_fun
lower_limits
upper_limits

%unconstrained minimization function fminunc
%options = optimoptions('fminunc','FiniteDifferenceStepSize',1e-2, 'Display','iter','PlotFcn','optimplotfvalconstr', 'Tolfun' , 1e-3);

options = optimoptions('fmincon','FiniteDifferenceStepSize',5e-2,'OutputFcn',@myOutput, 'Display','iter', 'Tolfun' , 1e-5);
%{
x0 = [2.5 1.0];
lower_limits = [1 0.7];
upper_limits = [3 4];
%}

[xsol, fval] = fmincon(fun,x0,[],[],[],[],lower_limits,upper_limits,[], options);
 
function stop = myOutput(x,optimvalues,state)
     stop = false;
     if isequal(state, 'iter')
         xval = [xval;x];
         history.x = [history.x;x];
         history.fval = [history.fval;optimvalues.fval];
         %searchdir = [searchdir; optimvalues.searchdirection']
     end
end
end