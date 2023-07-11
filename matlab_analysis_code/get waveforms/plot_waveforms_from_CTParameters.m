% load a CTparams file

[file, path] = uigetfile('CTparameters.mat');
datafile = fullfile(path, file);
load(datafile)
%%
for i = 1:length(CTparameters.id)
    figure
    title(CTparameters.id(i))
    subtitle({'half valley duration '  CTparameters.half_valley_duration(i) ...
        'half peak: ' CTparameters.half_peak_duration(i)  'firing rate: ' CTparameters.firing_rate(i)})
    hold on
    
    plot(CTparameters.waveforms{i})
    plot( CTparameters.m2v(i), CTparameters.waveforms{i}(CTparameters.m2v(i)), 'o')
    plot( CTparameters.m2p(i), CTparameters.waveforms{i}(CTparameters.m2p(i)), 'o')
    plot( CTparameters.mav(i), CTparameters.waveforms{i}(CTparameters.mav(i)), 'o')
    plot( CTparameters.map(i), CTparameters.waveforms{i}(CTparameters.map(i)), 'o')

end
%%
save(datafile, 'CTparameters')


all_datafile = fullfile('E:\2022\all_cell_parameters', filename); %save in folder with all cell type files
save(all_datafile, 'CTparameters')

