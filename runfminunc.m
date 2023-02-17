function [xsol,fval,xval] = runfminunc(x0, obj_fun )
%function [xsol,fval,xval] = runfminunc(x0, parameters,meas_data_dict, simulation_seed_folder, collection_dir, metric_type, data_involved)
 
% Set up shared variables with OUTFUN
history.x = [];
history.fval = [];
%searchdir = [];
fv = [];
xval = [];
% call optimization
%{
simulation_seed_folder = 'C:\Users\msapkota\EXPERIMENT\Optimisation_problem\Linear_polar_curves\Parameter_BARE_Zone1\Initial_files';

collection_dir = 'C:\Users\msapkota\EXPERIMENT\Optimisation_problem\Linear_polar_curves\Parameter_BARE_Zone1\Simulation_results';

%meas_data = meas_table{:,:}(:,[2,3,4,5,6]);
%meas_table = readtable('C:\Users\msapkota\EXPERIMENT\Optimisation_problem\Multi_linear_polar_curves\Multi_parameter\Parameter_BARE_BBS1_Zone1\Measurement_data\Internal_Points.csv');
meas_data = py.BEASY_IN_OUT_2.convert_csv_file_to_dictionary_with_ID_key('C:\Users\msapkota\EXPERIMENT\Optimisation_problem\Linear_polar_curves\Parameter_BARE_ZONE1\meas_simu\Internal_Points.csv','Output_value');
%meas_data = meas_table{:,:}(:,[6]);

%curves = py.list({'BARE', 'BBS1'});
curves = py.list({'BARE'});
zones = py.list({'ZONE1'});

if isequal(obj_fun, 'msq')
    fun = @(x) Objective1(x, parameters,meas_data_dict, simulation_seed_folder, collection_dir);
elseif isequal(obj_fun,'ccr')
    fun = @(x) Objective_coefficient_of_correlation(x, parameters, meas_data_dict, simulation_seed_folder, collection_dir);
elseif isequal(obj_fun,'compre_sum')
    fun = @(x) Obj_comprehen(x, parameters, meas_data_dict, simulation_seed_folder, collection_dir, 1E6);
else
    fun = @(x) Obj_compre_prod(x, parameters, meas_data_dict, simulation_seed_folder, collection_dir);
    
end
%}

%fun = @(x) Objective(x, parameters, meas_data_dict, simulation_seed_folder, collection_dir, metric_type, data_involved);


%fun = @(x) Objective_coefficient_of_correlation(x, meas_data, simulation_seed_folder, collection_dir, curves, zones);
%fun = @(x) Objective1(x, meas_data, simulation_seed_folder, collection_dir);


%unconstrained minimization function fminunc
%options = optimoptions('fminunc','FiniteDifferenceStepSize',1e-2, 'Display','iter','PlotFcn','optimplotfvalconstr', 'Tolfun' , 1e-6);

options = optimoptions('fminunc','FiniteDifferenceStepSize',1e-2,'OutputFcn',@myOutput, 'Display','iter', 'Algorithm', 'quasi-newton', 'Tolfun' , 1e-6);

%lower_limits = [0.2 0.3];
%upper_limits = [3 0.8];
%{
if length(x0)==1
    [xsol, fval,exitflag, history] = fminunc(obj_fun, x0{1}, options);
else
    [xsol, fval,exitflag, history] = fminunc(obj_fun, x0, options);
end
%}
[xsol, fval,exitflag, history] = fminunc(obj_fun, x0, options);




function stop = myOutput(x,optimvalues,state)
     stop = false;
     if isequal(state, 'iter')
        %fv = [fv;fval];
        xval = [xval;x];
         history.x = [history.x;x];
         history.fval = [history.fval;optimvalues.fval];
         %searchdir = [searchdir; optimvalues.searchdirection']
     end
end
end