import numpy as np
import os
import pandas as pd
import shutil
import re


class Polarisation_Curve_P_value:
    def __init__(self, name, p_value):
        self.name = name
        self.p_value = p_value

class Polarisation_Curve:
    def __init__(self, name, current_unit, voltage_unit, current_list, voltage_list):
        self.name = name
        self.current_unit = current_unit
        self.voltage_unit = voltage_unit
        self.current_values = current_list
        self.voltage_values = voltage_list

def update_mat_file_with_p_value(mat_file,material_code, p_value):
    
    with open(mat_file) as f:
        s = f.read()
        string_list = [st for st in s.splitlines()]
        f.close()
            
    replacing_start = False
        
    corres_mat_voltage_line_index = -1
    
    for line_count, line in enumerate(s.splitlines()):

        if material_code in line:
            replacing_start = True
        
        current_line_index = -1
        
        if replacing_start: 
            #the voltage line is not splitted by space
            if len(line.split()) == 1:
                corres_mat_voltage_line_index = line_count
                #print(corres_mat_voltage_line_index)
                break
            
    if corres_mat_voltage_line_index != -1:
        current_index_in_file = s.splitlines()[corres_mat_voltage_line_index-1].split()[0]
        #continue to change value unless the current line index changes 
        for idx in  range(corres_mat_voltage_line_index-1, 0, -1):
            if current_index_in_file != string_list[idx].split()[0]:
                break
            
            line_list = s.splitlines()[idx].split()
            
            temp_line = s.splitlines()[idx]
            
            replacing_terms = [value for idx1, value in enumerate(line_list) if idx1%5 == 0 and idx1 !=0]
         
            replace_with = [format(float(value)*p_value, '.4E') for value in replacing_terms]
            #print(replace_with)
            #print(replace_with)
            for str1, str2 in zip(replacing_terms, replace_with):
                temp_line = temp_line.replace(str1,str2)
                #print(temp_line)
            
            #string_list[idx] = ' '.join([str(a) for a in line_list])
            string_list[idx] = temp_line
        
    with open(mat_file, 'w') as fw:
        [[fw.write(new_line), fw.write('\n')] for new_line in string_list]
        fw.close()


def update_dat_file_with_zone_and_conductivity(dat_file,zone_name, conductivity):

    with open(dat_file) as f:
        s = f.read()
            
    replacing_start = False
        
    string_list = [st for st in s.splitlines()]
    
    
    for line_count, line in enumerate(s.splitlines()):

        if line.startswith('CONDUCTIVITY'):

            # check if the zone ID is corresponding from the previous line

            if s.splitlines()[line_count-1].split()[-1] ==  re.sub('[a-zA-Z]', '', zone_name):
           
            
                temp_line = s.splitlines()[line_count]
            
                replacing_term = s.splitlines()[line_count].split()[-1]
           
                replace_with = format(float(conductivity), '.7E')
                
            
                #string_list[idx] = ' '.join([str(a) for a in line_list])
                string_list[line_count] = temp_line.replace(replacing_term, replace_with)
        
    with open(dat_file, 'w') as fw:
        [[fw.write(new_line), fw.write('\n')] for new_line in string_list]


def get_polarisation_curve_from_mat_file(curve_name_list, mat_file):
    
    with open(mat_file) as f:
        s = f.read()
            
    current_curve_name = ''
        
    string_list = [st for st in s.splitlines()]
    
    result = []
    
    corres_mat_voltage_line_index = -1
    current_line_idx = -1 
    
    for line_count, line in enumerate(s.splitlines()):
        if current_curve_name == '':
            for curve in curve_name_list:
                if curve in line:
                    current_curve_name = curve
                    current_curve = Polarisation_Curve(current_curve_name, 'Amp/m2', 'mV', [], [])
        
        if current_curve_name == '':
            continue
        #print(line_count)
        #print(current_curve_name)
        
        #current data is stored in line with length 1 + multiple of 5 
        if (len(line.split())-1)%5 == 0 and len(line.split()) != 1:
            
            #first string hold line index
            
            current_line_idx = int(line.split()[0].replace('-',''))
            line_list = s.splitlines()[line_count].split()
            
            for idx1, value in enumerate(line_list):
                if idx1%5 == 0 and idx1 !=0:
                    #print(current_curve.__dict__)
                    current_curve.current_values.append(float(value))
        
        #volatage data are saved in a single line without given space
        elif len(line.split()) ==1 and len(line) > 4:
            #print(line.replace(' ','').split('-'))
            current_curve.voltage_values.extend([float(value)*-1 for value in line.split('-')[2:]])
        
        elif line == '' or len(line.split()) == 2:
            current_curve_name = ''
            result.append(current_curve)
            
    return result


def xyz_coordinates_for_element_IDS(IDs, gdf_file):
    
    result = {'IDs':[], 'x_pos':[], 'y_pos':[],'z_pos':[]}
    
    with open(gdf_file) as f1:
        s = f1.read()
        all_lines = s.splitlines()
        
        first_ID_line_count = -1
 
        
        for line_idx, line in enumerate(all_lines):
            if all(word in line for word in ['NORMAL_CURRENT', 'AREA']):
                first_ID_line_count = line_idx+1
            
            if not  first_ID_line_count == -1:
                break
            
            
        if first_ID_line_count == -1:
            raise Exception("no clue word is founf")
        
        for ID in IDs:
            temp_line = all_lines[int(ID)+first_ID_line_count-1]
            
            if not str(ID) == str(temp_line.split()[0]):
                for idx in range(first_ID_line_count, len(all_lines)):
                    temp_line = all_lines[idx]
                    if str(ID) == str(temp_line.split()[0]):
                        break
                
            for idx, key, split in zip(range(0,4), result, temp_line.split()):
                if idx == 0:
                    #print(split)
                    result[key].append(split)
                else:
                    result[key].append(float(split))
        return result


def xyz_coordinates_for_Mesh_point_IDS(IDs, dat_file):
    
    result = {'IDs':[], 'x_pos':[], 'y_pos':[],'z_pos':[]}
    
    with open(dat_file) as f1:
        s = f1.read()
        all_lines = s.splitlines()
        
        first_ID_line_count = -1
        Internal_points_first_ID_Count = -1
        first_internal_point = -1
        
        for line_idx, line in enumerate(all_lines):
            if 'MESH POINT COORDINATES' in line:
                first_ID_line_count = line_idx+1
            elif 'INTERNAL POINTS' in line:
                Internal_points_first_ID_Count = line_idx+1
                first_internal_point = int(all_lines[Internal_points_first_ID_Count].split()[0])
            
            if not (Internal_points_first_ID_Count ==-1 or first_ID_line_count == -1):
                break
            
            
        if first_ID_line_count == -1 or Internal_points_first_ID_Count ==-1:
            raise Exception("no clue word is founf")
        
        for ID in IDs:
            temp_line = all_lines[int(ID)+first_ID_line_count-1]
 
            if not str(ID) == str(temp_line.split()[0]):
                temp_line = all_lines[int(ID)+Internal_points_first_ID_Count-first_internal_point]
            
            if not str(ID) == str(temp_line.split()[0]):
                for idx in range(first_ID_line_count, len(all_lines)):
                    temp_line = all_lines[idx]
                    if str(ID) == str(temp_line.split()[0]):
                        break
                
            for idx, key, split in zip(range(0,4), result, temp_line.split()):
                if idx == 0:   
                    #print(split)
                    result[key].append(int(split))
                else:
                    result[key].append(float(split))
        return result


def create_simulation_set_with_changed_polarisation_curve(existing_root_folder, new_directory, file_name_to_edit, polarisation_curve_list):
    #creating copy folder
    if not os.path.isdir(new_directory):
        shutil.copytree(existing_root_folder, new_directory) 
    
    #make the change in the needed file
        for polarisation_curve in polarisation_curve_list:
            #print(os.path.join(new_directory,file_name_to_edit))
            #change_linear_input_parameter_eqn_in_given_mat_cp_file(parameter, os.path.join(new_directory,file_name_to_edit))
            update_mat_file_with_p_value(os.path.join(new_directory,file_name_to_edit), polarisation_curve.name, polarisation_curve.p_value)


def run_file_in_directory(directory, file_name):
    os.chdir(directory)
    os.system(os.path.join(directory,file_name))


def extract_information_from_file(files_name_with_path, exporting_location, identifying_string):
    
    dat_file = files_name_with_path+'.dat'
    
    dict1 = {'ID':[ ], 'x_pos':[ ], 'y_pos':[ ], 'z_pos':[ ]}
    
    with open(dat_file) as f1:
        s = f1.read()
        term_identied = False

        for line in s.splitlines():
            if identifying_string in line:
                term_identied = True
                continue
            
            if not term_identied:
                continue

            list_from_line = line.split()
            
            if not list_from_line[0].isdigit():
                break
            for idx, value in enumerate(list_from_line):
                if idx == 0:
                    dict1['ID'].append(value)
                
                elif idx == 1:
                    dict1['x_pos'].append(value)
                elif idx == 2:
                    dict1['y_pos'].append(value)
                else:
                    dict1['z_pos'].append(value)
                    
                #adding parameters value in the dictionary
                
    starting_ID = dict1['ID'][0]
    ending_ID = dict1['ID'][-1]
    #[print(key, len(value)) for key, value in dict1.items()]         
    df = pd.DataFrame(dict1)
    
    result_from_result_file = []
    
    #print('starting ID is ', starting_ID)
    res_file = files_name_with_path+'.post.res'
    with open(res_file) as f2:
        s1 = f2.read()
        starting_id_found = False
        
        idx_for_ID = 0 
        for line in s1.splitlines():
            list_from_line = line.split()
            
            if not starting_id_found and list_from_line[0] != starting_ID:
                continue
            
            elif list_from_line[0] == starting_ID and len(list_from_line) == 2:
                #print(line)
                starting_id_found = True
            
            if not starting_id_found:
                continue
            
            if dict1['ID'][idx_for_ID] == list_from_line[0]:
                result_from_result_file.append(list_from_line[-1])
                idx_for_ID+=1
                
            if list_from_line[0] == ending_ID:
                break
    
    df['Output_value'] = result_from_result_file
    

    df.to_csv(exporting_location+'\Internal_Points.csv')


    
def add_extracted_values_excel_file_in_the_folder(folder_directory, name_for_files, clue_word, overwrite):

    if any(file.split('.')[-1] == 'res' for file in os.listdir(folder_directory)):
    #if any(file.split('.')[-1] == 'res' for file in os.listdir(folder_directory)) and not any (file.split('.')[-1] == 'csv' for file in os.listdir(folder_directory)):
        files_name_with_path = '{}\{}'.format(folder_directory,name_for_files)
        
        if not files_name_with_path in os.listdir(folder_directory) or overwrite:        
            extract_information_from_file(files_name_with_path, folder_directory, clue_word)
            
    return
            

def IDs_from_internal_points_module(dat_file, modules):
    
    res = []
    
    modules.sort()
    
    height_range = [(8-modules[len(modules)-1])*10, (9-modules[0])*10]
    
    with open(dat_file) as f1:
        s = f1.read()
        term_identied = False

        for line in s.splitlines():
            if 'INTERNAL' in line:
                term_identied = True
                continue
            
            if not term_identied:
                continue

            list_from_line = line.split()
            
            if not list_from_line[0].isdigit():
                break
            
            if height_range[0] <= float(list_from_line[3]) < height_range[1]:
                res.append(float(list_from_line[0]))
            
      
    return res    
    
    

    
def extract_data_related_dict(file_dir, file_name, information_related_word, ending_word_clue, dict_keys):
    
    res_file = os.path.join(file_dir, file_name)   
    
    result_dict = {}
    
    with open(res_file) as f2:
        s1 = f2.read()
        starting_id_found = False
        
        line_count = 0

        for line in s1.splitlines():
            line_count +=1
            
            temp_list_from_line = line.split()
            
            if not (starting_id_found or information_related_word in line):
                continue
            
            elif information_related_word in line:
                #print(line)
                starting_id_found = True
            
            elif ending_word_clue in line:
                starting_id_found = False
            
            if not starting_id_found:
                continue
            
            if temp_list_from_line[0] in dict_keys and len(temp_list_from_line) ==2:
                #print('matched')
                result_dict[temp_list_from_line[0]] = float(temp_list_from_line[1])
            
    return result_dict


def extract_normal_current_density_data_from_gdf_file(file, total_data_count, modules):
    
    modules.sort()
    
    height_lower_limits= [(8-module)*10 for module in modules]
    height_upper_limits = [(9-module)*10 for module in modules]
    
    with open(file) as f2:
        s1 = f2.read()
        
        key_words_found = False
        
        line_count = 0
        
        data_line_tab_counts = 0
        
        data_col_indx = 0
        
        Ids = []
        
        normal_current_densities = []
        
        key_words = ['NORMAL_CURRENT', 'AREA']
        
        continuing_line_size = 0
        
        key_words_related_column_idx=[-1,-1]
        
        all_lines = s1.splitlines();
        
        for line in all_lines:
            line_count +=1
            
            temp_list_from_line = line.split()


            if all(word in temp_list_from_line for word in key_words):
                continuing_line_size= len(temp_list_from_line)
                
                for idx, key_word in enumerate(key_words):
                    key_words_related_column_idx[idx] = temp_list_from_line.index(key_word)
                break
        
        
        for mod_idx, module in enumerate(modules):
            
            module_related_IDs = []
            module_related_curr_den = []
            
            for line_idx in range(line_count, len(all_lines)):
            
                temp_list_from_line = all_lines[line_idx].split()
            
                if continuing_line_size != len(temp_list_from_line):
                    break
            
                temp_height = float(temp_list_from_line[3])
            
                if height_lower_limits[mod_idx] <= temp_height <= height_upper_limits[mod_idx]:
                
                    module_related_IDs.append(temp_list_from_line[0])
                
                    module_related_curr_den.append(float(temp_list_from_line[key_words_related_column_idx[0]])/float(temp_list_from_line[key_words_related_column_idx[1]]))
        
            Ids.extend(limit_to_count(module_related_IDs, total_data_count))
            normal_current_densities.extend(limit_to_count(module_related_curr_den, total_data_count))
                                  
        
        Ids = limit_to_count(Ids, total_data_count)
            
        normal_current_densities = limit_to_count(normal_current_densities,total_data_count)
            
        res = {Ids[i]: normal_current_densities[i] for i in range(len(Ids))}
            
    return res




def directional_current_density_from_gdf_file(directory, ID_list, keywords):
    
    result_dict = {}
    
    with open(directory) as f2:
        s1 = f2.read()
        
        
        first_key_word_found = False
        
        second_key_word_found = False
        
        line_count = 0
        
        data_line_tab_counts = 0
        
        data_col_indx = 0

        for line in s1.splitlines():
            line_count +=1
            
            temp_list_from_line = line.split()

            
            if keywords[0] in line:
                first_key_word_found = True
                
            if not first_key_word_found:
                continue
                
            else:
                if keywords[1] in line:
                    second_key_word_found = True
                    data_line_tab_counts = len(temp_list_from_line)
                    #print(data_line_tab_counts)
                    
                    for idx, str1 in enumerate(temp_list_from_line):
                        if keywords[1] in str1:
                            data_col_indx = idx
                            break
                    continue
                
                if not second_key_word_found:
                    continue
            
            #print(temp_list_from_line)
            if not len(temp_list_from_line) == data_line_tab_counts:
                break
            
            if float(temp_list_from_line[0]) in ID_list:
                #print('matched')
                result_dict[temp_list_from_line[0]] = float(temp_list_from_line[data_col_indx])
            
    return result_dict



def directional_electric_field_from_gdf_file(directory, ID_list, keywords):
    
    result_dict = {}
    
    with open(directory) as f2:
        s1 = f2.read()
        
        
        first_key_word_found = False
        
        second_key_word_found = False
        
        line_count = 0
        
        data_line_tab_counts = 0
        
        data_col_indx = 0

        for line in s1.splitlines():
            line_count +=1
            
            temp_list_from_line = line.split()

            
            if keywords[0] in line:
                first_key_word_found = True
                
            if not first_key_word_found:
                continue
                
            else:
                if keywords[1] in line:
                    second_key_word_found = True
                    data_line_tab_counts = len(temp_list_from_line)
                    #print(data_line_tab_counts)
                    
                    for idx, str1 in enumerate(temp_list_from_line):
                        if keywords[1] in str1:
                            data_col_indx = idx
                            break
                    continue
                
                if not second_key_word_found:
                    continue
            
            #print(temp_list_from_line)
            if not len(temp_list_from_line) == data_line_tab_counts:
                break
            
            if float(temp_list_from_line[0]) in ID_list:
                #print('matched')
                result_dict[temp_list_from_line[0]] = float(temp_list_from_line[data_col_indx])
            
    return result_dict


def remove_other_files_from_directory(directory, extension_list):
    for f in os.listdir(directory):
        #print(f)
        if not any([f.endswith(extension) for extension in extension_list]):
            os.remove(os.path.join(directory, f))

def convert_csv_file_to_dictionary_with_ID_key(csv_file, value_related_string):
    result = {}
    df = pd.read_csv(csv_file)
    for idx in range(len(df)):
        key = df.loc[idx,'ID']
        value = [df.loc[idx, value] for value in df.columns if value.startswith(value_related_string)]
        if len(value) == 1:
            result[key]= value[0]
        else:
            result[key] = value
    return result


def get_output_data_from_simulation_folder(new_folder_dir, files_name, calibration_data_type,  modules, current_density_type, data_counts):
    
    if not any(file.split('.')[-1] == 'res' for file in os.listdir(new_folder_dir)):
        print('running_simulation in:', new_folder_dir )
        bat_file = [file for file in os.listdir(new_folder_dir) if file.endswith('.bat')][0]
        run_file_in_directory(new_folder_dir, bat_file)
    
    add_extracted_values_excel_file_in_the_folder(new_folder_dir, files_name ,'INTERNAL', False)
    
    remove_other_files_from_directory(new_folder_dir, ['res', 'mat_cp','bat','csv','dat', 'gdf']) 
    
    result = []
    
    inter_points_selected_IDs = IDs_from_internal_points_module(os.path.join(new_folder_dir, '{}.dat'.format(files_name)), modules)
    
    gdf_file = os.path.join(new_folder_dir,'{}.gdf'.format(files_name))
    
    for data_type, data_count in zip(calibration_data_type, data_counts):
        if data_type == 'voltage':
            
            potential_related_dict = convert_csv_file_to_dictionary_with_ID_key(os.path.join(new_folder_dir,'Internal_Points.csv'),'Output_value')
    
            result.append(filter_keys(limit_to_count(inter_points_selected_IDs, data_count) ,potential_related_dict))
            
            continue
        elif data_type == 'current density':
            
            if current_density_type == 'normal':
                current_density_related_output_dict= extract_normal_current_density_data_from_gdf_file(gdf_file, data_count, modules)
    
            else:
                current_density_related_output_dict = directional_current_density_from_gdf_file(gdf_file,limit_to_count(inter_points_selected_IDs, data_count) ,['RESULTS_AT_INTERNAL_POINT','Z_CURRENT_DENSITY'])
                
                
            result.append(current_density_related_output_dict)   
            
        else: 
            electric_field_data = directional_electric_field_from_gdf_file(gdf_file, limit_to_count(inter_points_selected_IDs, data_count) , ['RESULTS_AT_INTERNAL_POINT',data_type])
            
            result.append(electric_field_data)
            
    
    #print(filter_keys(position_IDs,potential_related_dict))

    return result
    

def change_simulation_input_set(new_directory, polarisation_curve_list, zones_name, conductivity_list):

    mat_file_address = [os.path.join(new_directory,file) for file in os.listdir(new_directory) if file.endswith('.mat_cp')][0]
   
    for polarisation_curve in polarisation_curve_list:
        update_mat_file_with_p_value(mat_file_address, polarisation_curve.name, polarisation_curve.p_value)

    dat_file_address = mat_file_address.replace('.mat_cp','.dat')

    if not conductivity_list == None:

        for con_count, zone in enumerate(zones_name):
            
            update_dat_file_with_zone_and_conductivity(dat_file_address, zone, conductivity_list[con_count])
        


def get_output_data_for_given_parameters(parameter_names, parameter_values, seed_directory, collection_dir_address,calibration_data_type, modules, current_density_type, data_counts):
    
    
    zip_zone_conductivities = [[parameter_names[idx] , parameter_values[idx]] for idx, parameter in enumerate(parameter_names) if 'Zone' in parameter]
        
    zip_matp_values = [[parameter_names[idx] , parameter_values[idx]] for idx, parameter in enumerate(parameter_names) if 'Zone' not in parameter]
        
    curve_names, p_values = [value[0] for value in zip_matp_values], [value[1] for value in zip_matp_values] 
        
    zones_name, conductivity_list = [value[0] for value in zip_zone_conductivities], [value[1] for value in zip_zone_conductivities]
    

    files_name = [file.replace('.mat_cp','') for file in os.listdir(seed_directory) if file.endswith('.mat_cp')][0]
    
    polarisation_curve_list = [Polarisation_Curve_P_value(curve_names[idx], p_values[idx]) for idx in range(len(curve_names))]
    
    folder_name = ''
        
    for idx, curve in enumerate(curve_names):
        if not folder_name == '':
            folder_name = folder_name + "_"
        
        folder_name = folder_name +str(curve) + "_" + str(format(p_values[idx], '.4f'))

    for idx, zone in enumerate(zones_name):
        folder_name = folder_name + "_" +str(zone) + "_" + str(format(conductivity_list[idx], '.4f'))
                                            
    new_folder_dir = os.path.join(collection_dir_address, folder_name)
    
    result = [new_folder_dir]
    
    #create_simulation_input_set
    if not os.path.isdir(new_folder_dir):
        shutil.copytree(seed_directory, new_folder_dir)
        change_simulation_input_set(new_folder_dir, polarisation_curve_list, zones_name, conductivity_list)
    
    result.extend(get_output_data_from_simulation_folder(new_folder_dir, files_name, calibration_data_type,  modules, current_density_type, data_counts))
    
    return result


def collect_csv_files_from_folders(source_dir, collection_dir):
    if not os.path.exists(collection_dir):
        os.makedirs(collection_dir)
    for sub_folder in os.listdir(source_dir):
        if os.path.join(source_dir, sub_folder) == collection_dir:
            continue
        if any(file.replace('.csv','') == sub_folder for file in os.listdir(collection_dir)):
            continue
        for file in os.listdir(os.path.join(source_dir, sub_folder)):
            if file.endswith('csv'):

                shutil.copy(os.path.join(source_dir, sub_folder, file), collection_dir)
                
                os.rename(os.path.join(collection_dir, file), os.path.join(collection_dir, '{}.csv'.format(sub_folder)))
                
                
def get_combination_set_from_different_values(possible_parameter_values):
    
    total_number_of_parameters = len(possible_parameter_values)
    
    current_indxes = [0 for idx in range(total_number_of_parameters)]

    
    possible_value_lengths = [len(parameter_values) for parameter_values in possible_parameter_values]

    result = []
    for itr in range(np.prod(possible_value_lengths)):
        combination_set = [possible_values[current_indxes[idx]] for idx, possible_values in enumerate(possible_parameter_values)]
        result.append(combination_set)
    
        for idx1, possible_lengths in enumerate(possible_value_lengths):
            if idx1 == total_number_of_parameters-1 or (itr+1)%(np.prod(possible_value_lengths[idx1+1:])) == 0:
                if current_indxes[idx1] == possible_lengths-1:
                    current_indxes[idx1] = 0
                else:
                    current_indxes[idx1] = current_indxes[idx1]+1
                    
    return result


def multi_simulation_run_with_change_in_parameter(root_folder, collection_dir, parameter_list, bounds, step_counts):
    
    step_sizes = [(bound[1]-bound[0])/step_count for bound, step_count in zip(bounds,step_counts)]

    possible_parameter_values = [[bound[0]+idx*step_sizes[idx1] for idx in range(step_counts[idx1]+1)] for idx1, bound in enumerate(bounds)]
    
    new_simulation_dir_list = []
    
    #while any(parameter_current_value <= upper_limit for parameter_current_value, upper_limit in zip(parameter_current_values, [bound[1] for bound in bounds])):
    #while parameter_current_values[-1] <= bounds[-1][1] or changing_parameter_idx < len(parameter_list)-1:
    
    all_combinations = get_combination_set_from_different_values(possible_parameter_values)
            
    for parameter_current_values in all_combinations:     
        
        zip_zone_conductivities = [[parameter_list[idx] , parameter_current_values[idx]] for idx, parameter in enumerate(parameter_list) if 'Zone' in parameter]
        
        zip_matp_values = [[parameter_list[idx] , parameter_current_values[idx]] for idx, parameter in enumerate(parameter_list) if 'Zone' not in parameter]
        
        mat_parameters, p_values = [value[0] for value in zip_matp_values], [value[1] for value in zip_matp_values] 
        
        zone_parameters, conductivities = [value[0] for value in zip_zone_conductivities], [value[1] for value in zip_zone_conductivities]
        
        new_simulation_dir_list.append(get_output_data_for_given_p_values_and_zones_conductivity(mat_parameters, p_values, zone_parameters, conductivities, root_folder, collection_dir)[0])
        
        
    return new_simulation_dir_list


def get_position_ID_for_given_height_range(csv_file, z_pos_range, ID_name, pos_name):
    df = pd.read_csv(csv_file)
    filtered_df = df[df[pos_name].between(z_pos_range[0], z_pos_range[1])]
    
    return list(filtered_df[ID_name])


def limit_to_count(data1, total_data_count):
    denom1 = int(len(data1)/total_data_count)
    #print(denom1)
    
    if denom1 >= 1:
        
        result = [key for idx, key in enumerate(data1) if idx%denom1 == 0 and idx+1 < total_data_count*denom1]

    else:
        result = data1
        
    return result


def filter_keys(filtering, being_filtered):
    return {x:being_filtered[x] for x in being_filtered if x in filtering}