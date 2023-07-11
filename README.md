# light-and-the-mPFC-code
  Code used in the "Prefrontal cortex neurons encode ambient light intensity differentially across regions and layers" paper.
  
  we are currently working on documenting the Code and organizing it.
  
  Contact us if you have any questions or if you plan to use it (elyashiv.zangen@mail.huji.ac.il).
  
  The whole dataset used will be available upon publication.

## Pipeline of electrophysiological analysis
### preprocessing Plexon data:
1. short-pass and high-pass filtered at 300Hz use Offline Sorter, Plexon.
2. run pl2kilosort (go to python_preprocessing_analyze_electrophysiology_data - readme for instructions)
3. run Kilosort 3.0 (https://github.com/MouseLand/Kilosort) on the sequence.bin file (from pl2kilosort) for spike sorting
4. run python PSTH  (go to python_preprocessing_analyze_electrophysiology_data - readme for instructions)
5. run cell_display_1 app (matlab_analysis_code/cell_display/cell_display_1.mlapp). load the histogram created from Python PSTH. use the pdf user manual (matlab_analysis_code/USER_MANUAL.pdf)
    

