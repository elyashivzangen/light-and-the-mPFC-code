
clear
[file, path] = uigetfile('*.mat');%When the user clicks the load data button, a window should open to enable the user to select a file.
datafile = fullfile(path, file); %save path
load(datafile)
close all
%%
binsize = 0.1;
downsampling = 5;

[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
datafile = fullfile(path, file); %save path
if isa(datafile, 'cell')
    file_numes = length(datafile);
    all_files = cell(1, file_numes);
    for i = 1:file_numes
        all_files{1, i} = load(datafile{1,i});
        all_files{1, i} = all_files{1, i};
    end
else
    all_files{1, 1} = load(datafile);
    file = {file};
end
%% only for not loading clusters if all the cells are in the reicluster
clusters_psth_before = struct;
for i = 1:length(all_files)
    all_data_before = all_files{i}.all_data{1, 1};
    cell_names = fieldnames(all_data_before);
    for j = 1:length(cell_names)
        cell_data = all_data_before.(cell_names{j});
        cluster_name = ['cluster_' num2str(cell_data.cluster)];
        if ~isfield(clusters_psth_before, (cluster_name))
            clusters_psth_before.(cluster_name)(1, :) = cell_data.intensities(2).psth.mean;
            clusters_psth_after.(cluster_name)(1, :) = all_files{i}.all_data{2}.(cell_names{j}).intensities(2).psth.mean;
        else
            clusters_psth_before.(cluster_name)(end + 1, :) = cell_data.intensities(2).psth.mean;
            clusters_psth_after.(cluster_name)(end + 1, :) = all_files{i}.all_data{2}.(cell_names{j}).intensities(2).psth.mean;
        end
       
        
    end
end
downsampling = 5;
clusters_numbers = fieldnames(clusters_psth_before);
s = figure;
set(s,'color', [1 1 1]);
set(s,'position',[50 50 250*length(clusters_numbers) 250]);
nac_colores = {'c','k', 'm', 'r', 'g', 'y'};
dark_colors = {[0.3010 0.7450 0.9330] [0 0 0] [0.4940 0.1840 0.5560] [0.6350 0.0780 0.1840]	  [0.4660 0.6740 0.1880]	[0.9290 0.6940 0.1250]	};
for j = 1:length(clusters_numbers)
%     figure
%     for i = 1:size(clusters_psth_before.(clusters_numbers{j}),1)
%         interpulated_psth = bin_psth(clusters_psth_before.(clusters_numbers{j})(i,:), downsampling);
%         plot(interpulated_psth)
%         hold on
%     end
    cluster_num = str2num(clusters_numbers{j}(end)) - 2;
    before_mean(j,:) = mean(clusters_psth_before.(clusters_numbers{j}));
    before_ste(j,:) =  std(clusters_psth_before.(clusters_numbers{j}))/sqrt(size(clusters_psth_before.(clusters_numbers{j}), 1));
    after_mean(j,:) =  mean(clusters_psth_after.(clusters_numbers{j}));
    after_ste(j,:) =  std(clusters_psth_after.(clusters_numbers{j}))/sqrt(size(clusters_psth_after.(clusters_numbers{j}), 1));
    
    interpulated_before_psth(j,:) = bin_psth(before_mean(j, :), downsampling);
    interpulated_before_ste(j,:) = bin_psth(before_ste(j, :), downsampling);
    interpulated_after_psth(j,:) = bin_psth(after_mean(j, :), downsampling);
    interpulated_after_ste(j,:) = bin_psth(after_ste(j, :), downsampling);
    set(0, 'CurrentFigure', s)

    
    subplot(1, 3, cluster_num)
    
    x = (1:length(interpulated_after_psth(j,:)))*binsize -3;
    plot(x, interpulated_before_psth(j,:), '-r', 'LineWidth',2)
    hold on
    plot(x, interpulated_after_psth(j,:), '-b', 'LineWidth',2)
    
    
    shadedErrorBar(x, interpulated_before_psth(j,:), interpulated_before_ste(j,:), 'lineprops', '-r')
    shadedErrorBar(x, interpulated_after_psth(j,:), interpulated_after_ste(j,:), 'lineprops', '-b')
    
    
    plot([0 0],[-4 9],'--k');
    plot([10 10],[-4 9],'--k');
    
    xlim([-3 16])
    ylim([-6 9])
    %     title(['cluster ' num2str(j)])
    text(4, 7, ['n = ' num2str(size(clusters_psth_before.(clusters_numbers{j}), 1))], 'FontSize',15, 'FontWeight','bold')
    
    
    set(gca,'XColor', 'none','YColor','none')
    if cluster_num == 1
        plot([-2 -2], [1 6], 'k', 'LineWidth', 4)
    end
    plot([0 10], [-2 -2], 'k', 'LineWidth', 4)
    patch([0 10 10 0],[-4 -4 9 9], [0.9290 0.6940 0.1250]	, 'FaceAlpha', 0.1, 'EdgeColor', 'none' )
    text(2, -3, '10 sec' , 'FontSize',15, 'FontWeight','bold')
    set(gca,'FontSize',15);
    set(gca,'FontWeight','bold')
    
    
%     legend({'before CNO', 'after CNO'}, 'FontSize',20)
    box off
    
    
end



%%
% suffix = '_Nucleus accumbens';
suffix = '_Caudoputamen';
data = clusters.matrix;
%experiment_numbers = {'NAC3L_Nucleus accumbens', 'NAC4_R_Nucleus accumbens'};
% experiment_numbers = { 'DMS1L_Caudoputamen', 'DMS1R_Caudoputamen'};
% experiment_numbers = {'A_NAc12L_Nucleus accumbens', 'A_NAc11L_Nucleus accumbens', 'A_NAc11R_Nucleus accumbens'};
experiment_numbers = file;

idx = cell(1, length(experiment_numbers));
cell_names = idx;
clusters_idx = idx;
for i = 1:length(experiment_numbers)
    idx{i} = find(ismember(data(:, 1), [experiment_numbers{i}(1:end-4) suffix]));
    cell_names{i} = data(idx{i} , 3);
    clusters_idx{i} = data(idx{i} , 4);
end
all_clusters_idx =  cell2mat(clusters_idx{1});
for i = 2:length(experiment_numbers)
    all_clusters_idx = [all_clusters_idx cell2mat(clusters_idx{i})];
end


%%
s = figure;
set(s,'color', [1 1 1]);
set(s,'position',[50 50 750 250]);
nac_colores = {'c', 'm', 'r', 'g'	, 'y'};

% nac_colores = {'k','k', 'm', 'r', 'g', 'y'};
dark_colors = {[0 0 0] [0 0 0] [0.4940 0.1840 0.5560] [0.6350 0.0780 0.1840]	  [0.4660 0.6740 0.1880]	[0.9290 0.6940 0.1250]	};


%  clusters_num = unique(all_clusters_idx);
clusters_num = unique(all_clusters_idx);


%%
subplot(1,3,2)
for j = 5
    cluster_name = ['cluster_' num2str(j)];
    counts = 0;
    for m = 1:length(experiment_numbers)
        all_data = all_files{m}.all_data;
        cell_cluster_names = cell_names{m}(cell2mat(clusters_idx{m})==j);
        for i = 1:length(cell_cluster_names)
            counts = counts + 1;
            clusters_psth_befor.(cluster_name)(counts, :) = all_data{1}.(cell_cluster_names{i}).intensities(1).psth.mean; %+ all_data{1}.(cell_cluster_names{i}).intensities(1).intensty_baseline.mean;
            clusters_psth_after.(cluster_name)(counts, :) = all_data{2}.(cell_cluster_names{i}).intensities(1).psth.mean; %+ all_data{2}.(cell_cluster_names{i}).intensities(1).intensty_baseline.mean;
            
        end
        
        
    end
    
    
    
    %     figure
    %     plot(1:201, clusters_psth_befor.(cluster_name))
    %     hold on
    
    %plot(1:201, clusters_psth_after.(cluster_name) , 'r')
    
    %     xline(3)
    %     xline(13)
    %legend({'before CNO', 'after CNO'})
    %     hold off
    
    %     set(0,'CurrentFigure' ,s)
    
%     subplot(1, 5, j)
%     
    
    before_mean(j,:) = mean(clusters_psth_befor.(cluster_name));
    before_ste(j,:) =  std(clusters_psth_befor.(cluster_name))/sqrt(size(clusters_psth_befor.(cluster_name), 1));
    
    after_mean(j,:) = mean(clusters_psth_after.(cluster_name));
    after_ste(j,:) =  std(clusters_psth_after.(cluster_name))/sqrt(size(clusters_psth_after.(cluster_name), 1));
    
    
    %interpulate before
    cut_end = floor(length(before_mean(j,:))/downsampling)*downsampling;
    
    
    binned_psth_before(j,:) = mean(reshape(before_mean(j, 1:cut_end), downsampling, []));
    binned_ste_before(j, :) = mean(reshape(before_ste(j , 1:cut_end), downsampling, []));
    binned_psth_after(j,:) = mean(reshape(after_mean(j, 1:cut_end), downsampling, []));
    binned_ste_after(j, :) = mean(reshape(after_ste(j, 1:cut_end), downsampling, []));
    
    %interpulate PSTH
    y = 1:length(binned_psth_before(j,:));
    xq = 1:0.2:length(binned_psth_before(j,:));
    
    interpulated_before_psth(j,:) = interpn(y, binned_psth_before(j,:), xq, 'linear');
    interpulated_before_ste(j,:) = interpn(y, binned_ste_before(j,:), xq, 'linear');
    interpulated_after_psth(j,:) = interpn(y, binned_psth_after(j,:), xq, 'linear');
    interpulated_after_ste(j,:) = interpn(y, binned_ste_after(j,:), xq, 'linear');
    
    %interpulate after
    
    
    %interpulate PSTH
    
    
    
    x = (1:length(interpulated_after_psth(j,:)))*binsize -3;
    hold off
    plot(x, interpulated_before_psth(j,:), '-r', 'LineWidth',2)
    hold on
    plot(x, interpulated_after_psth(j,:), '-b', 'LineWidth',2)
    
    
    shadedErrorBar(x, interpulated_before_psth(j,:), interpulated_before_ste(j,:), 'lineprops', '-r')
    shadedErrorBar(x, interpulated_after_psth(j,:), interpulated_after_ste(j,:), 'lineprops', '-b')
    
    
    plot([0 0],[-4 9],'--k');
    plot([10 10],[-4 9],'--k');
    
    xlim([-3 16])
    ylim([-3 5])
    %     title(['cluster ' num2str(j)])
    text(4, 4, ['n = ' num2str(counts)], 'FontSize',15, 'FontWeight','bold')
    
    
    set(gca,'XColor', 'none','YColor','none')
    if j == 2
        plot([-2 -2], [1 6], 'k', 'LineWidth', 4)
    end
    plot([0 10], [-2 -2], 'k', 'LineWidth', 4)
    patch([0 10 10 0],[-4 -4 9 9], [0.9290 0.6940 0.1250]	, 'FaceAlpha', 0.1, 'EdgeColor', 'none' )
    text(1.5, -2.5, '10 sec' , 'FontSize',15, 'FontWeight','bold')
    set(gca,'FontSize',15);
    set(gca,'FontWeight','bold')
    
    
    legend({'before CNO', 'after CNO'}, 'FontSize',20)
    box off
    
    
end
