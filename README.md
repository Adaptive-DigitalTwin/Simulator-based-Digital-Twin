# Readme
## Introduction
The project is about enabling simulator-based Structural Digital Twin 

It requires the core process simulator, simulation model enabling like geometrical model and discretisation tools in advance as this tool is about validating and calibration of the simulator based DT.

The codes are designed to perform a specific task that requires certain input data. The purpose of this readme is to explain the input data required to run the code successfully. 
While, most of the experiment related procedure are already detailed in the thesis's **Chapter 5**, the necessary technical aspects are also outlined within the MATLAB file _'main.mlx.'_

## Input Data

To run the code, first provide the necessary inputs into the 'main.mlx' file associated with the following variables:

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

After providing the necessary inputs, run the code in the _`main.mlx`_ file. The code will generate simulation data continuously until it finds its best solution parameter based upon the calibration data provided and the suggestion from `fminunc` algorithm, and plot the results.

### Note: 
This experiment utilises the _Cathodic-Protection (CP)_ Model which is constructed using the _BEASY software (V21)_. As a result, the data types primarily pertain to the CP model. However, this experiment can be replicated for similar problems, necessitating the simulation solver and support for data description and retrieval. 

Therefore, users must modify the codes for data retrieval and feeding or build their own for the specific model and simulator they are using. Additionally, the above inputs should be adjusted accordingly.

## Output 

The aim of the experiment is to obtain the solution parameters which will be obtained as _'xsol'_ after the experiment. But also the additional process data can be visualised and seen in the _'main.mlx'_ file itselt while the simulation data will be stored into the collection directory.


## Dependencies

This project requires the following MATLAB (or External) modules:

- `BEASY_IN_OUT1`: User built python module to obtain and modify Input-Output dataset to the BEASY model.
- `fminunc` 
- `PYTHON software with the packages numpy, os, pandas, shutil and re` (should be installed in the system)

## References

For more information on the modules used in this project, please refer to the following resources:

- `fminunc`: [(https://uk.mathworks.com/help/optim/ug/fminunc.html)](https://uk.mathworks.com/help/optim/ug/fminunc.html)
