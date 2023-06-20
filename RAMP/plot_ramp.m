clear;
clc;

binsize = 1; %sec
samp_rate = 40000;
 ploting = 1;
%%
[file_cell_display, path] = uigetfile('*.mat'); %LOAD CELL_DISPLAY FILE
datafile_cell_display = fullfile(path, file_cell_display);
load(datafile_cell_display)
cd(path)
[file, path] = uigetfile('spike_clusters.npy');
datafile = fullfile(path, file);
spike_clusters = readNPY(datafile);
cd(path)

[file, path] = uigetfile('spike_times.npy');
datafile = fullfile(path, file);
spike_times = readNPY(datafile);

% find relevant part of recoording
[file, path] = uigetfile('files_extracted_data.csv');
datafile = fullfile(path, file);
files_extracted_data = readtable(datafile);

[ramp_samples, ramp_pos] = max(files_extracted_data.plexon_samples_num); 

befor_ramp_samples = sum(files_extracted_data.plexon_samples_num(1:ramp_pos-1)); %all samples before the ramp

% ramp_samples = files_extracted_data.plexon_samples_num(end);

%% extract relevant spike_times and spike clusters
start_ramp = find(spike_times >befor_ramp_samples, 1);
end_ramp = find(spike_times >befor_ramp_samples+ramp_samples, 1);
if ramp_pos == length(files_extracted_data.plexon_samples_num); end_ramp = length(spike_times); end
spike_clusters = spike_clusters(start_ramp:end_ramp);
spike_times = spike_times(start_ramp:end_ramp)-befor_ramp_samples;

spike_train = zeros(ramp_samples, 1);
cells = unique(spike_clusters);
%%
%extract good cells
cells = fieldnames(all_data);
cell_name = cellfun(@(x) x(6:end) ,cells ,'UniformOutput' ,false);

for i = 1:length(cell_name)
    cell_num(i) = str2num(cell_name{i});
    spike_train = zeros(ramp_samples, 1);
    spike_indices = spike_times(spike_clusters == cell_num(i));
    spike_train(spike_indices) = 1;
    % bin spike train
    spike_train = spike_train(1: floor(ramp_samples/(binsize*samp_rate))*(binsize*samp_rate)); %cut end
    psth(i, :) =(sum(reshape(spike_train,[], length(spike_train)/(binsize*samp_rate))))/binsize; %bin spike train
    clusters(i) = all_data.(cells{i}).cluster;
    binned_psth =  bin_psth(psth(i, :), 10);
    tran_psth{i} = all_data.(cells{i}).intensities(1).psth; %transient__psth
    if ploting
        time = 1:length(binned_psth);
        time = time/(60/binsize);
        figure
        plot(time, smooth(binned_psth))
        xlabel('time')
        ylabel('firing rate (Hz)')
        title(cells{i})
        subtitle(['cluster number ' num2str(clusters(i))])
        all_data.(cells{i}).ramp = psth(i, :);
    end
end
%% save table

exp_id = repmat(file_cell_display(1:end-4), length(cell_name), 1);
cell_id = cell_num';
clusters = clusters';
tran_psth =tran_psth';
ramp_psth = table(exp_id, cell_id, clusters,tran_psth);
ramp_psth.psth = psth;
all_datafile = fullfile('E:\2022\ramp_psth', file_cell_display);
save(datafile_cell_display, 'all_data')
save(all_datafile, 'ramp_psth')

%%
% % PLOT CLUSTERS PSTH
% % cluster_num = unique(clusters);
% % for i = 1:length(cluster_num)
% %     cluster_psth(cluster_num(i), :) = mean(psth(clusters == cluster_num(i), :), 1);
% %     binned_psth =  bin_psth(cluster_psth(cluster_num(i), :), 60);
% %      time = 1:length(binned_psth);
% %     time = time/(60/binsize);
% %     figure
% %     plot(time, smooth(binned_psth))
% %     xlabel('time')
% %     ylabel('firing rate (Hz)')
% %     title({'cluster ' cluster_num(i)})
% % save nuber of cells    
% %         
% % end
