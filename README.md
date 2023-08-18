# Code for the analysis of light sensitivity in the prefrontal cortex
Code used in the "Prefrontal cortex neurons encode ambient light intensity differentially across regions and layers" paper.
We are currently working on a more thorough documentation of the code.
Please contact the leading author, Mr. Elyashiv Zangen (elyashiv.zangen@mail.huji.ac.il), if you have any questions about the code or if you intend using it.
A part of the analyzed dataset (‘experiment_data.7z’), to be used in testing the code, can be found in Figshare (https://figshare.com/s/cf9dd54f122789dcd4a5?file=42059829). The expected output of this analysis (‘output file for demo data.mat’) can be found above. The analysis run time for this part of the dataset is expected to be 3 hours.
The complete dataset used in this study will be available upon publication.

## Requirements
•	MATLAB (https://www.mathworks.com/products/matlab.html, version R2022a or later)

•	Python (https://www.python.org/)

•	The npy-matlab repository (https://github.com/kwikteam/npy-matlab)

•	The Allen Mouse Brain Atlas volume and annotations (http://data.cortexlab.net/allenCCF/, download all 4 files from this link)

Typical install time of the above software and dependencies is estimated to be around 15 min.


## Pipeline of electrophysiological analysis
### Preprocess electrophysiological data of a single experiment 
1.	High-pass filter the analog data stored in .PL2 data files at 300Hz using Offline Sorter, Plexon.
2.	Run ‘pl2kilosort.m’ in Matlab to generate a ‘sequence.bin’ file (more instructions can be found in the ‘readme.txt’ file in ’python_preprocessing_analyze_electrophysiology_data’).
3.	Run Kilosort 3.0 (https://github.com/MouseLand/Kilosort) on the ‘sequence.bin’ file for spike sorting.
4.	Run python PSTH (go to python_preprocessing_analyze_electrophysiology_data - readme for instructions)
5.	Run cell_display_1 app (‘matlab_analysis_code/cell_display/cell_display_1.mlapp’). Load the histogram created from Python PSTH. Use the PDF user manual (‘matlab_analysis_code/USER_MANUAL.pdf’). This app will create a summary Matlab file (‘all_data’) that will be used in further analyses.
6.	To extract the waveforms and cell type parameters (CTP), run ‘matlab_analysis_code/get waveforms/call_get_cell_Type_parameters_fun.m’.
7.	Run ‘matlab_analysis_code/get waveforms/add_CTP_to_All_data.m’ to add the CTP to the ‘all_data’ file.

### Map neurons in a standard mouse brain
1.	Download SHARP-Track (https://github.com/cortex-lab/allenCCF) and apply the changes specified in: ‘python_preprocessing_analyze_electrophysiology_data/mapping/Sharp_Track_changes.m’.
2.	Run SHARP-Track to register the brain slices (with the probe track marked) to a standard mouse brain.
3.	Run ‘display_probe_track’, that will open ‘clusters_mapping.m’, and process the ‘all_data’ file of the corresponding experiment for each probe marked.
   
### Identify light-responsive and intensity-encoding neurons
1.	To identify transient and/or persistent light-responsive neurons run ‘matlab_analysis_code/premutationtests/new_calculate_t_test_prem_3_int_3_windows.m’, and select the relevant ‘all_data’ files.
2.	To identify light-intensity-encoding neurons run ‘matlab_analysis_code/calculate_IE_responsive_fun.m’, and select the relevant ‘all_data’ files.

### Classify response types using clustering analysis
1.	Save only light-responsive intensity encoding cells using the ‘matlab_analysis_code/intensityencoding/save_only_Intensity_encoding_and_IR.m’.
2.	Run the clustering app ‘matlab_analysis_code/clustering/clustring3.mlapp’. Use the PDF user manual (‘matlab_analysis_code/USER_MANUAL.pdf’) to view the results.





   
