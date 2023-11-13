function [xsol,fval,xval] = runfminunc(x0, parameters, calib_data, simulation_seed_folder, collection_dir, metric_type, data_involved, data_ids, Ids_types, weightage_constant)
 
% Set up shared variables with OUTFUN
history.x = [];
history.fval = [];
%searchdir = [];
fv = [];
xval = [];


if isequal(metric_type, 'nmsq')
    fun = @(x) Objective(x, parameters,calib_data, simulation_seed_folder, collection_dir,metric_type, data_involved, data_ids, Ids_types, weightage_constant );
elseif isequal(obj_fun,'ccr')
    fun = @(x) Objective_coefficient_of_correlation(x, parameters, meas_data_dict, simulation_seed_folder, collection_dir, weightage_constant);
elseif isequal(obj_fun,'compre_sum')
    fun = @(x) Obj_comprehen(x, parameters, meas_data_dict, simulation_seed_folder, collection_dir, 1E6);
else
    fun = @(x) Obj_compre_prod(x, parameters, meas_data_dict, simulation_seed_folder, collection_dir);
    
end

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
[xsol, fval,exitflag, history] = fminunc(fun, x0, options);


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