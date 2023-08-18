# Analyzing Electrophysiology Data

## When running this code the first time
Run the following steps only in the first time you are using this code

1. Open the terminal 
    1. In the search bar type *cmd* and open the *Command Prompt*
2. Navigate to the a folder in which you want to run the code in
    1. `cd PATH_TO_FOLDER`
3. Run the following commands inorder to create the environment in which the code will run
    1. `conda create -n env python=3.8`
    2. `conda activate env`
4. Download this project
    1. `git clone https://github.com/shira-hadar/electrophysiology.git`
    2. `cd electrophysiology\analyze_electrophysiology_data`
5. Prepare python environment with the need packages
    1. `pip install -r requirements.txt`
6. Prepare Django 
    1. `python manage.py migrate`

## Analysing the Data
Run the following steps everytiem you want to analyze the data

1. Perform stage 1 and 2 from *"When running this code the first time"*
2. Activate the environment 
    1. `conda activate env`
3. Go into the code directory
    1. `cd electrophysiology\analyze_electrophysiology_data`
4. Run django
    1. `python manage.py runserver`
5. **pl2kilosrt**
    1. In the browser, in the search bar type http://127.0.0.1:8000/pl2kilosort/ (or press the link)
    2. Fill in the relevant data and submit
    3. The output files will be in the following path
        1. *PATH_TO_FOLDER\electrophysiology\analyze_electrophysiology_data\pl2kilosort\files\TRIAL_TYPE*
6. Run kilosort on a computer with GPU
    1. When finished, move kilosort output files to **pl2kilosort** output directory
        1. *PATH_TO_FOLDER\electrophysiology\analyze_electrophysiology_data\pl2kilosort\files\TRIAL_TYPE*
        2. Since **psth** looks for the files in that directory
7. **psth**
    1. In the browser, in the search bar type http://127.0.0.1:8000/psth/ (or press the link)
    2. Make sure the following files are present in *PATH_TO_FOLDER\electrophysiology\analyze_electrophysiology_data\pl2kilosrt\files\TRIAL_TYPE*:
        1. cluster_info.tsv - phy output file
        2. events_ts.csv - pl2kilosrt output file
        3. files_extracted_data.csv - pl2kilosrt output file
        4. spike_clusters.npy - kilosrt output file
        5. spike_times.npy - kilosrt output file
    4. Fill in the relevant data and submit
    	1. In the field named Split Chunks fill in an array of indices you want for each file seperating files with ';' and indices with ',' 
    		1. For example:
    			1. If you want the indices 0, 2, 4 to be in 1 file and indices 1, 3 in another file put in 0, 2, 4; 1, 3
    			2. If you want everything in the same file and you have 7 intensities then you shold use 0, 1, 2, 3, 4, 5, 6
    7. The output files will be in the following path
        1. *PATH_TO_FOLDER\electrophysiology\analyze_electrophysiology_data\psth\files*
    8. An image viewing window will open with the relevent plots (after the *completed successfully* appears)
8. Run the following script in order to move all output files to the experiment directory
    1. `python move_output_files.py`
9. When finished, close the server by `Ctrl+c` in the cmd window in which the server is running in
10. **mapping**
	1. Make the changes in SHARP_TRACK according to the content of *Sharp_Track_changes.m* file (exists in the mapping directory)
	2. Run SHARP_TRACK to register your slices after the changes
		1. If you already regisered the slices you can run only the *Display_probe_track.m* file in order to create the updated files
    3. In the browser, in the search bar type http://127.0.0.1:8000/mapping/ (or press the link)
    4. Fill in the relevant data and submit
    5. Probe number is the registration number of the probe in SHARP_TRACK
    6. The output files will be in the following path
        1. *PATH_TO_FOLDER\electrophysiology\analyze_electrophysiology_data\mapping\files*
    7. **Make sure you run this section before the clustering**
11. **brain_render**
    1. In the browser, in the search bar type http://127.0.0.1:8000/brain_render/ (or press the link)
    2. Fill in the relevant data and submit
        1. The *probes_files* is NOT mandatory
            1. If you don't want to specify a file then put a 0 in *probes_number*
        2. *Cluster sets number* should equal the **number of files** you put in *clusers_sets_files*
    4. The output files will be in the following path
        1. *PATH_TO_FOLDER\electrophysiology\analyze_electrophysiology_data\brain_render\files*
    5. The brain_render scene with be exported into a file named *SCENE_TITLE.html* (Where SCENE_TITLE is the title you gave the scene) 
12. **clustering**
    1. In the browser, in the search bar type http://127.0.0.1:8000/clustering/ (or press the link)
    2. Fill in the relevant data and submit
        1. The *histogram_data_files* and *cluster_coordinates_files* should have the same prefix (should be the experiment name and sequence)
        2. The *clustering_data_file* is NOT mandatory 
            1. Specifiy a file only if you ran clustering before and you want to add to it new data
    3. The output files will be in the following path
        1. *PATH_TO_FOLDER\electrophysiology\analyze_electrophysiology_data\clustering\files*
