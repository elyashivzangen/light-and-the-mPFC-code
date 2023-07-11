function ramp_fun(selpath, all_data,exp_name, save_all_data_2_direct)
cd(selpath)
spike_times = readNPY('spike_times.npy');
spike_clusters = readNPY('spike_clusters.npy');
cluster_info =  tdfread('cluster_info.tsv');
events_ts = readtable('events_ts.csv');
files_extracted_data = readtable('files_extracted_data.csv');
%%
samp_rate = 40000;
ramp_datafile_num = 8;
binsize = 1;
triel_length = 120;
ploting = 1;
add2all_data = 1;
ploting2 = 1;
instensities= [9.4; 11.4; 12.9; 13.9; 14.4; 14.9;15.4];
instensities = flip(instensities);
%before2plot = 5; %time before and after the each ramp repetition to plot
%after2plot = 5;

[ramp_samples, ramp_pos] = max(files_extracted_data.plexon_samples_num);
% [ramp_samples, ramp_pos] = min(files_extracted_data.plexon_samples_num);

befor_ramp_samples = sum(files_extracted_data.plexon_samples_num(1:ramp_pos-1)); %all samples before the ramp

start_ramp = find(spike_times >befor_ramp_samples, 1);
end_ramp = find(spike_times >befor_ramp_samples+ramp_samples, 1);

if ramp_pos == length(files_extracted_data.plexon_samples_num); end_ramp = length(spike_times); end
spike_clusters = spike_clusters(start_ramp:end_ramp);
spike_times = spike_times(start_ramp:end_ramp)-befor_ramp_samples;

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



relevant_on = floor(events_ts.(['x' num2str(files_extracted_data.ND(ramp_pos)) '_1_on']));
relevant_on = relevant_on(~isnan(relevant_on));
%relevant_off = floor(events_ts.(['x' num2str(files_extracted_data.ND(ramp_pos)) '_1_off']));
relevant_off = relevant_on + 120;

full_PSTH = [];

id = [];
for i = 1:length(good_cells)
    %     raster = zeros(ramp_samples, 1);
    cell_spike_times = spike_times(spike_clusters == good_cells(i));
    last_bin = ceil(ramp_samples/samp_rate)*samp_rate;
    edges = 0: binsize*samp_rate:last_bin;
    total_PSTH(i, :) = histcounts(cell_spike_times, edges);
    for j = 1:size(relevant_on, 1)
        psth(j, :) = total_PSTH(i, relevant_on(j):relevant_off(j));
    end
    full_PSTH = [full_PSTH  psth'];
    mean_PSTH(i, :) = mean(psth, 1);
    sem_PSTH(i,:) = sem(psth,1);
    id = [id repmat(good_cells(i),[1, j])];
end

%%
rep = repmat((0:length(relevant_on)-1), [1, i]);
nd = repmat(files_extracted_data.ND(ramp_pos), [1, i*j]);
full_PSTH = [id; nd; rep; full_PSTH];

variable_names = {'id', 'nd', 'rep'};
numbers = 1:size(psth, 2);
numbers = num2cell(numbers);
variable_names = [variable_names numbers]';
new_PSTH = [variable_names num2cell(full_PSTH)];
if isfolder("ramp")
    rmdir ramp 's'
end
mkdir("ramp")
cd("ramp")
% T= array2table(mean_PSTH');
%MAT = [good_cells;mean_PSTH' ]
% T.Properties.VariableNames = string(good_cells)
% T_mean_PSTH = table(mean_PSTH, 'VariableNames', cellstr(string(good_cells)))
writecell(new_PSTH,'ramp_PSTH.csv')
save('full_raster.mat', 'total_PSTH')
save('mean_RAMP_PSTH', 'mean_PSTH')
save('sem_RAMP_PSTH', 'sem_PSTH')

ramp_table = array2table(mean_PSTH','VariableNames', strsplit(num2str(good_cells)));
writetable(ramp_table, 'ramp_table.csv')
save('ramp_table', 'ramp_table')
%%
if isfile('ramp.pdf')
    delete('ramp.pdf')
end
if ploting
    for i = 1:size(mean_PSTH, 1)
        figure
        time = 1:size(mean_PSTH, 2);
        plot(time, mean_PSTH(i,:))
        xlabel('time')
        ylabel('firing rate (Hz)')
        title(good_cells(i))
        ax = gca;
        exportgraphics(ax,'ramp_with_7_ints.pdf','Append',true)
    end
end

% %% add to all_data
% if add2all_data
%    readtable("ramp_PSTH.csv")
%% add_ramp_to_all_data
if isfile('ramp_fit2.pdf')
    delete('ramp_fit2.pdf')
end
    

if add2all_data
%     [file, path] = uigetfile('*.mat');%When the user clicks the load data button, a window should open to enable the user to select a file.
%     datafile = fullfile(path, file); %save path
%     load(datafile, "all_data")
    if iscell(all_data)
        all_data = all_data{1,1};
    end
    load('C:\Users\elyashivz\OneDrive - huji.ac.il\מחקר\Data for final project\RAMP\ramp_intensties_120_sec.mat', "ramp_int") %loadramp intensity
    int_colores = {'c','k', 'm', 'r', 'g', 'y', 'b'};

    for i = 1:length(good_cells)
        cell_name = ['cell_' num2str(good_cells(i))];
        if isfield(all_data, cell_name)
            all_data.(cell_name).ramp.total = total_PSTH(i, :);
            all_data.(cell_name).ramp.mean = mean_PSTH(i, :);
            all_data.(cell_name).ramp.sem = sem_PSTH(i, :);

            %calculate fit
            x = ramp_int(1:60)';
            y = mean_PSTH(i, 1:60)';
            fo = fitoptions('Method','NonlinearLeastSquares',...
                'Algorithm','Trust-Region',...
                'Display','final',...
                'TolFun',1.0E-20,...
                'TolX',1.0E-20,...
                'Lower',[-1,min(x),-2],...
                'Upper',[2*max(y),max(x),2],...
                'StartPoint',[max(y),mean(x),0]);

            ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
            [curve1,gof1]=fit(x,y,ft);

            all_data.(cell_name).ramp.fit.original_curve=curve1;

            all_data.(cell_name).ramp.fit.original_gof=gof1;
            all_data.(cell_name).ramp.fit.original_rmse=gof1.rmse;
            all_data.(cell_name).ramp.fit.original_n=curve1.n;

            %plot
            if ploting2

                f1=figure;
                set(f1,'position',[200 200 1600 300])
                set(f1, 'color', [1 1 1]);
                subplot(1,4,1);
                %

                hold on;
                plot(x,y,'o');
                plot(curve1,'m');
                legend off
                title(['rmse = ',num2str(gof1.rmse),'   n = ',num2str(curve1.n), ' R^2: ' num2str(gof1.rsquare)]);
                subplot(1,4,2)
                plot(mean_PSTH(i, :))

                %plot 7 intensites
                x = all_data.(cell_name).intensities;
                subplot(1,4,3)
                count = 0;
                for j = 1:length(x)
                    if ~isempty(x(j).psth)
                        count = count + 1;
                        int_data = x(j).intensty_data;
                        baseline = mean(int_data(1:30, :), 'all');
                        int_data = int_data - baseline;
                        sus_response(count) = mean(int_data(65:125), 'all'); %sustanied response (normlized to basline)

                        smoothed = reshape(bin_psth(int_data(:),10), [], size(int_data, 2)) ;
                        psth = mean(smoothed, 2);
                        ste = sem(smoothed, 2);
                        plot(1:length(psth),psth);
                        hold on
                    end
                end
                title(cell_name)
                legend(num2str(instensities))


                % calculate new sistained fit
                y = sus_response;
                shift = abs(min(y)); %shift so Y will be max
                y = y' + shift;
                x = instensities;
                fo = fitoptions('Method','NonlinearLeastSquares',...
                    'Algorithm','Trust-Region',...
                    'Display','final',...
                    'TolFun',1.0E-20,...
                    'TolX',1.0E-20,...
                    'Lower',[-1,min(x),-5],...
                    'Upper',[2*max(y),max(x),5],...
                    'StartPoint',[max(y),mean(x),0]);

                ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
                [curve1,gof1]=fit(x,y,ft);

                all_data.(cell_name).new_fit3(2).original_curve=curve1;

                all_data.(cell_name).new_fit3(2).original_gof=gof1;
                all_data.(cell_name).new_fit3(2).original_rmse=gof1.rmse;
                all_data.(cell_name).new_fit3(2).original_n=curve1.n;
                all_data.(cell_name).new_fit3(2).shift = shift;
                subplot(1,4,4);
                hold on;
                plot(x,y,'o');
                plot(curve1,'m');
                legend off
                title(['rmse = ',num2str(gof1.rmse),'   n = ',num2str(curve1.n)]);
                exportgraphics(f1,'ramp_fit2.pdf','Append',true)
                close all


            end
        end
    end
    save(exp_name, 'all_data')
    if exist("save_all_data_2_direct")
        datafile = fullfile(save_all_data_2_direct,  exp_name);
        save(datafile, "all_data")
    end

end
end