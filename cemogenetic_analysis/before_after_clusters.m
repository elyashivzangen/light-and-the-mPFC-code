[app.file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
app.datafile = fullfile(path, app.file); %save path
file_numes = length(app.datafile);
app.all_files = cell(1, file_numes);
for i = 1:file_numes
    app.all_files{1, i} = load(app.datafile{1,i});
    app.all_files{1, i} = app.all_files{1, i};
end
if ~isa(all_data, 'cell')
    all_data = {all_data};
end
field_names = fieldnames(all_data{1});
for i = 1:length(field_names)
    clusters_idx(i) = all_data{1}.(field_names{i}).cluster;
    max_intensity(i) = all_data{1}.(field_names{i}).max.intensity;
end



%%
bin_size = 0.1;
downsampling_bin = 0.5;
[file, path] = uigetfile('*.mat');%When the user clicks the load data button, a window should open to enable the user to select a file. 
datafile = fullfile(path, file); %save path 
load(datafile)
field_names = fieldnames(all_data{1});
clusters = unique(clusters_idx);


for j = clusters
    clusters_i = find(clusters_idx == j);
    cluster_name = ['cluster_' num2str(j)];
    for i = 1:length(clusters_i)
        clusters_psth_befor.(cluster_name)(i, :) = all_data{1}.(field_names{clusters_i(i)}).intensities(max_intensity(clusters_i(i))).psth.mean;
        clusters_psth_after.(cluster_name)(i, :) = all_data{2}.(field_names{clusters_i(i)}).intensities(max_intensity(clusters_i(i))).psth.mean;
        %interpulate before
        binning = bin_size/downsampling_bin;
        cut_end = floor(clusters_psth_befor.(cluster_name)(i, :))*binning/binning;
        binned_psth = mean(reshape(clusters_psth_befor.(cluster_name)(i, 1:cut_end), 1/binning, []));
        %interpulate PSTH
        y = 1:length(binned_psth);
        xq = 1:bin_Size:length(binned_psth);
        interpulated_psth = interpn(y, binned_psth, xq, 'pchip');
        
        binning = bin_size/downsampling_bin;
        cut_end = floor(clusters_psth_befor.(cluster_name)(i, :))*binning/binning;
        binned_psth = mean(reshape(clusters_psth_befor.(cluster_name)(i, 1:cut_end), 1/binning, []));
        %interpulate PSTH
        y = 1:length(binned_psth);
        xq = 1:bin_Size:length(binned_psth);
        interpulated_psth = interpn(y, binned_psth, xq, 'pchip');
        
    end
    
    subplot(2, length(ceil(clusters/2)), find(clusters == j))
    x = (1:size(clusters_psth_befor.(cluster_name) , 2))*bin_size;
    
    before_mean = mean(clusters_psth_befor.(cluster_name));
    before_ste =  std(clusters_psth_befor.(cluster_name))/sqrt(size(clusters_psth_befor.(cluster_name), 1));
    
    after_mean = mean(clusters_psth_after.(cluster_name));
    after_ste =  std(clusters_psth_after.(cluster_name))/sqrt(size(clusters_psth_after.(cluster_name), 1));
    
    shadedErrorBar(x, before_mean, before_ste, 'lineprops', '-r')
    shadedErrorBar(x, after_mean, after_ste, 'lineprops', '-b')
    
    title(['cluster ' num2str(j)])
    subtitle(['n = ' num2str(i)])
    xline(3)
    xline(13)
end