function all_data = PSTH_fun(selpath, save_all_data_2_direct,exp_name)
%%
if ~exist("selpath")
    selpath = uigetdir;
end
cd(selpath)
 if ~exist("save_all_data_2_direct") %directory to save a version of all PSTH files
     save_all_data_2_direct = "E:\2023 - ledramp\call display";
 end
spike_times = readNPY([selpath '\spike_times.npy']);
spike_clusters = readNPY([selpath '\spike_clusters.npy']);
cluster_info =  tdfread([selpath '\cluster_info.tsv']);
events_ts = readtable([selpath '\events_ts.csv']);
files_extracted_data = readtable([selpath '\files_extracted_data.csv'],"FileType","spreadsheet");
ploting = 1;
old_events_type = 0;
add_shiras_mistake = 0; % add the -1.1 sec that shira used
saveplots2pdf = 1;
create_simple_all_data = 1;
create_histogram_data = 1; %create excel file like shiras old files to be compatible with the cell_dispaly
use_defult_ints = 1;
if use_defult_ints
    instensities= ["9.4"; "11.4"; "12.9"; "13.9"; "14.4"; "14.9";"15.4"];
end

if create_simple_all_data
    if ~exist("exp_name")
    exp_name = inputdlg('exp_name');
    exp_name =exp_name{1};
    end
end
transform7_nds2_10nds = 0;
%%
samp_rate = 40000;
pre_time = 3;
post_time = 7;
if add_shiras_mistake
    post_time = 7.1;
end
reptime = 10;
bin_size = 0.1; %sec
drift = 0.116;
%% find all relevant cells
good_cells = [];


for i = 1:length(cluster_info.id)
    if strcmp(cluster_info.group(i), 'g')
        good_cells(end + 1) =  cluster_info.id(i);
    elseif strcmp(cluster_info.KSLabel(i), 'g') && ~strcmp(cluster_info.group(i), 'n') && ~strcmp(cluster_info.group(i), 'm')
        good_cells(end + 1) =  cluster_info.id(i);
    end
end

%% create PSTH
ND = files_extracted_data.ND;
is_ramp = 0;

for j = 1:length(good_cells)
    cspike = spike_times(spike_clusters == good_cells(j)); %cell spikes
    before_samples = 0;

    for i = 1:length(ND)
        %time sampels to use
        cND = ND(i);
        all_cND = find(ND == cND);%number of trial with this nd
        ND_rep = find(all_cND == i);
        nd_name = ['x' num2str(cND) '_' num2str(ND_rep - 1)];
        fields = fieldnames(events_ts);
        old_events_type = sum(contains(fields, '_0')) == 0;
        if old_events_type
            nd_name = ['x' num2str(cND)];
        end


        nd_on = events_ts.([nd_name '_on']) + drift;
        if add_shiras_mistake
            nd_on = nd_on - 1.1;
        end
        nd_off = events_ts.([nd_name '_off']);
        trial_length = nd_off(end) - nd_on(1);
        if trial_length > 1000 %only in case of ramp
            is_ramp = 1;
            ND(i) = [];
            continue
        end
        

        sampels_end = before_samples + files_extracted_data.plexon_samples_num(i);
        sampels_start = before_samples;
        %extract relevant samples
        rspikes = find(cspike > sampels_start & cspike < sampels_end);
        rspike_times = cspike(rspikes);
        rst = rspike_times - sampels_start; %alighn spike times
        % extract data fro each cell
        %extract cell spikes
        rep_spike = zeros(length(nd_on(~isnan(nd_on))), (pre_time+post_time+reptime)/bin_size);
        for w = 1:length(nd_on(~isnan(nd_on)))
            rep_spike(w, :) = histcounts(rst, (nd_on(w)-pre_time)*samp_rate:bin_size*samp_rate:(nd_on(w)+reptime+post_time)*samp_rate)/bin_size;
        end
        mean_psth = mean(rep_spike , 1);
        baseline = mean(mean_psth(1:30));

        mean_psth = mean_psth- baseline;
        rep_fr.(nd_name) = rep_spike;
        mean_fr.(nd_name) = mean_psth;


        before_samples = sampels_end;
    end
    all_cells_mean{j} = mean_fr;
    all_cells_rep{j} = rep_fr;
end




%%
mkdir("psth_100_ms")
cd('psth_100_ms')
all_psthT = table(good_cells',all_cells_rep',all_cells_mean', VariableNames={'cell_name', 'rep_psth', 'mean_psth'});
save('all_psth_table', 'all_psthT')
    
    



if ploting

    if saveplots2pdf
        if isfile('all_psths.pdf')
            delete all_psths.pdf
        end
    end
    for i = 1:length(all_cells_mean)
        f1 = figure;
        used_nd = [];
        new_all_cells_mean{i} = structfun(@(x) x', all_cells_mean{i}, 'UniformOutput', false);
        new_all_cells_mean{i} = struct2cell(new_all_cells_mean{i});
        for j = 1:length(ND)
            if sum(used_nd == ND(j)) > 0
                figure
                used_nd = [];
            end
            used_nd = [used_nd; ND(j)];
            plot((-pre_time:bin_size:(post_time+reptime-bin_size)), new_all_cells_mean{i}{j}')
            hold on
            
           
        end
        legend(fieldnames(all_cells_mean{1,1}))
        if use_defult_ints
            legend(instensities, "AutoUpdate","off")
        end
        xline(0, 'r')
        xline(10, 'r')

        %         xline(6.5-pre_time-1, 'y')
        %         xline(12.5-pre_time -1, 'y')
        title(['cell' num2str(good_cells(i))])
        
        if saveplots2pdf

            exportgraphics(f1 ,'all_psths.pdf','append', true)
        end
    end
end

%%
    
if create_simple_all_data
    all_data = [];
    for i = 1:length(good_cells)
        cell_name = ['cell_' num2str(good_cells(i))];
        intensty_data = struct2cell(all_cells_rep{i}); 
        ints = [];
        baseline_vector = [];
        for j = 1:length(ND)
            ints(j).intensty_data = intensty_data{end+1-j}';
            ints(j).psth.mean = mean(ints(j).intensty_data,2);
            ints(j).intensty_baseline.mean = mean(ints(j).psth.mean(1:30));
            ints(j).psth.mean = ints(j).psth.mean -  ints(j).intensty_baseline.mean;
            baseline_vector = [baseline_vector, ints(j).intensty_baseline.mean];
        end
        all_data.(cell_name).intensities = ints;
        all_data.(cell_name).baseline_vector= baseline_vector;
        all_data.(cell_name).source_dir = selpath;
    end

    save(exp_name , "all_data")
    if exist("save_all_data_2_direct")
        datafile = fullfile(save_all_data_2_direct,  exp_name);
        save(datafile, "all_data")
    end

end
%% 
if create_histogram_data
    histogram_data = [];
    for i = 1:length(all_cells_rep)

        s = cell2mat(struct2cell(all_cells_rep{i}))';
        s = num2cell(s);
        nds = fieldnames(all_cells_rep{i});
        reps = num2cell(repmat(0:19, [1,length(nds)]));
        nds = cellfun(@(x) x(2:end), nds, 'UniformOutput', false);
        nds = repmat(nds,[1,20]);
        nds = reshape(nds',1, []);
        id = all_psthT.cell_name(i);
        id = num2cell(repmat(id,[1,length(nds)]));
        t = [id; nds; reps; s];
        histogram_data = [histogram_data t];
    end
    index_row = ["id"; "nd"; "rep"; num2cell(0:1:199)'];
    histogram_data = [index_row, histogram_data];
    writematrix(histogram_data, "histogram_data.csv")
end
%%

if is_ramp
    ramp_fun(selpath, all_data,exp_name)
end
cd ..
close all
    % update sampels for net roun 
end