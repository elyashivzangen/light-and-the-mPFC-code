% plotDistToNearestTip.m:

% lines 213 - 214

% my changes - return the whole table data to the calling function
borders = borders_table;
		
		
% Display_Probe_Track.m

% lines 231 - 238

% my changes - save relevant data to csv files
mm_reference_probe_length_tip = reference_probe_length_tip/100;
mm_probe_length = probe_length;
probe_data = array2table([mm_reference_probe_length_tip mm_probe_length shrinkage_factor]);
probe_data.Properties.VariableNames(1:3) = {'mm_reference_probe_length_tip', 'mm_probe_length', 'shrinkage_factor'};

writetable(probe_data, fullfile(processed_images_folder, ['probe_data_' num2str(selected_probe) '.csv']), 'Delimiter', ',')
writetable(borders_table, fullfile(processed_images_folder, ['borders_table_' num2str(selected_probe) '.csv']), 'Delimiter', ',')  
