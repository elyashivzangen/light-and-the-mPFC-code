%% interactive create waveforms_file
clear
clc


[file, path] = uigetfile('cluster_info.tsv');
datafile = fullfile(path, file);
w = tdfread(datafile);
cd(path)


gwfparams.dataDir = path;    % KiloSort/Phy output folder
gwfparams.fileName = 'temp_wh.dat';         % .dat file containing the raw
gwfparams.dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
gwfparams.nCh = 32;                      % Number of channels that were streamed to disk in .dat file
gwfparams.wfWin = [-80 150];              % Number of samples before and after spiketime to include in waveform
gwfparams.nWf = 100;                    % Number of waveforms per unit to pull out
gwfparams.spikeTimes = readNPY('spike_times.npy'); % Vector of cluster spike times (in samples) same length as .spikeClusters
gwfparams.spikeClusters = readNPY('spike_clusters.npy'); % Vector of cluster IDs (Phy nomenclature)   same length as .spikeTimes
gwfparams.spiketamplate = readNPY('spike_templates.npy');
gwfparams.good_id = [];
gwfparams.best_channels = [];
gwfparams.fr = [];


for i = 1:length(w.id)
    if strcmp(w.group(i), 'g')
        gwfparams.good_id = [gwfparams.good_id; w.id(i)];
        gwfparams.best_channels = [gwfparams.best_channels; w.ch(i)+1];
        gwfparams.fr = [gwfparams.fr ; w.fr(i)];
    elseif strcmp(w.KSLabel(i), 'g') && ~strcmp(w.group(i), 'n') && ~strcmp(w.group(i), 'm')
        gwfparams.good_id = [gwfparams.good_id; w.id(i)];
        gwfparams.best_channels = [gwfparams.best_channels; (w.ch(i)+1)];
        gwfparams.fr = [gwfparams.fr ; w.fr(i)];
        
        
    end
end


wf = getbestWaveForms(gwfparams);

cd('C:\Users\elyashivz\Dropbox\מחקר\Data for final project\get waveforms\waveform_files')
[file,path] = uiputfile('waveform.mat');
filename = fullfile(path, file);

save(filename, 'wf')


%%
for i = 1:200
    hold on
    wave_form = squeeze(wf.waveForms(1, i, :));
    plot(wave_form)
    
end



