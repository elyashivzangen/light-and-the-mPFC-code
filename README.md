# light-and-the-mPFC-code
  Code used in the "Prefrontal cortex neurons encode ambient light intensity differentially across regions and layers" paper.
  
  we are currently working on documenting the Code and organizing it.
  
  Contact us if you have any questions or if you plan to use it (elyashiv.zangen@mail.huji.ac.il).
  
  The whole dataset used will be available upon publication.

## Pipeline of electrophysiological analysis
### Preprocessing Plexon data of a signal experiment: 
1. short-pass and high-pass filtered at 300Hz use Offline Sorter, Plexon.
2. run pl2kilosort (go to python_preprocessing_analyze_electrophysiology_data - readme for instructions)
3. run Kilosort 3.0 (https://github.com/MouseLand/Kilosort) on the sequence.bin file (from pl2kilosort) for spike sorting
4. run python PSTH  (go to python_preprocessing_analyze_electrophysiology_data - readme for instructions)
5. run cell_display_1 app (matlab_analysis_code/cell_display/cell_display_1.mlapp). load the histogram created from Python PSTH. use the pdf user manual (matlab_analysis_code/USER_MANUAL.pdf). this app will create a summarizing Matlab file (all_data) used for further analysis.

6. for parameters for cell_type analysis run matlab_analysis_code/get waveforms/call_get_cell_Type_parameters_fun.m to extract the waveforms and cell type paramters (CTP)
7.   then run matlab_analysis_code/get waveforms/add_CTP_to_All_data.m to add the CTP to all_data file

### add mapping
1. download SHARP-TRACK (https://github.com/cortex-lab/allenCCF)
   and add the changes specified in:
   python_preprocessing_analyze_electrophysiology_data/mapping/Sharp_Track_changes.m
2. run Sharp-Track to add register the brain slices to a standard mouse brain.
3. run display_probe_track, that will open clusters_mapping.m and for each probe marked specify the all_data file for the corresponding experimant.
   
### Find responsive and intensity encoding cells:
1. to identify Transient and persistent light-responsive cells run matlab_analysis_code/premutation tests/new_calculate_t_test_prem_3_int_3_windows.m and choose the relevant all_data files
   
2. to identify light-intensity-encoding neurons run matlab_analysis_code/calculate_IE_responsive_fun.m and choose the relevant all_data files


### Response type clustering analysis
1. save only light-responsive intensity encoding cells using matlab_analysis_code/intensity encoding/save_only_Intensity_encoding_and_IR.m
2. run the clustering app matlab_analysis_code/clustering/clustring3.mlapp. use the pdf user manual (matlab_analysis_code/USER_MANUAL.pdf).






   
