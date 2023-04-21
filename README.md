# Readme
## Introduction
The project is about enabling simulator-based Structural Digital Twin 

It requires the core process simulator, simulation model enabling like geometrical model and discretization tools in advance as this tool is about validating and calibration of the simulator based DT.


The codes are designed to perform a specific task that requires certain input data. The purpose of this readme is to explain the input data required to run the code successfully.

## Input Data

The following input data is required to run the code:

- `source_parameters`: A list of two strings representing the parameters used as source in the parameter file. Example: `['BARE', 'Zone1']`

- `parameters`: A list of two strings representing the parameters considered for calibration. Example: `['BARE', 'Zone1']`

- `calib_data_type`: A list of two strings representing the types of calibration data. Example: `['voltage', 'normal current density']`

- `IDs`: A cell array of python lists, where each list consist of IDs for the corresponding calibration data type. 

- `IDs_types`: A cell array of strings that contains the types of the data IDs (IDs types are given in the simulation files, such as 'Internal Points' , 'Mesh Points' , 'Element Points') .

- `IDs_mat_arr`: An array of IDs lists, where each list consist of IDs for the corresponding calibration data type. . Example: `[{IPs_IDs1, MP_IDs_normal_current_density}]`


- `root_folder`: A string representing the root folder for the experiment. Example: `'D:\EXPERIMENT\DOE_nd_data_generation\Multilinear_pol_curves\Parameter_BARE_Zone1'`

- `simulation_seed_folder`: A string representing the simulation seed folder. Example: `'D:\EXPERIMENT\DOE_nd_data_generation\Multilinear_pol_curves\Parameter_BARE_Zone1\Initial_files'`

- `collection_dir`: A string representing the collection directory for the simulation results. Example: `'D:\EXPERIMENT\DOE_nd_data_generation\Multilinear_pol_curves\Parameter_BARE_Zone1\Simulation_results'`

- `files_name`: A string representing the name of the files in the simulation folder. Example: `'BU_Jacket_newCurves'`

- `calib_dir`: A string representing the calibration directory.

- `x0`: A list of two floats representing the initial guess of the parameter values for the optimisation. Example: `[1.75, 3]`

After providing the necessary inputs, run the code in the `main.m` file. The code will generate simulation data continuously until it finds its best solution parameter based upon the calibration data provided and the suggestion from `fminunc` algorithm, and plot the results.

## Dependencies

This project requires the following MATLAB (or External) modules:

- `BEASY_IN_OUT1`: User built python module to obtain and modify Input-Output dataset to the BEASY model.
- `fminunc` 
- `PYTHON software` (installed in the system)

## References

For more information on the modules used in this project, please refer to the following resources:

- `fminunc`: [(https://uk.mathworks.com/help/optim/ug/fminunc.html)](https://uk.mathworks.com/help/optim/ug/fminunc.html)
