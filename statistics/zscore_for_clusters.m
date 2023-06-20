clear
[file, path] = uigetfile('*.mat');%When the user clicks the load data button, a window should open to enable the user to select a file.
datafile = fullfile(path, file); %save path
load(datafile)
close all
%%
%   response_time = 160:190; %random
% dms_response = {
        response_time = 30:60; %on
        response_time = 130:160; %off

data = clusters.cluster_cells;
fields = fieldnames(data);
counts = 0;
zscore = zeros(length(clusters.num_of_cells), max(clusters.num_of_cells));
sugnificants = zscore;
sugnificants_num = zeros(1, length(clusters.num_of_cells));

for i = 1:2
    cluster_data = data.(fields{i});
    for j = 1:(length(cluster_data)-1)
        basline_std = std(cluster_data{j}.intensities(1).repetition_baseline.mean);
        peak_on_response = max(abs(cluster_data{j}.intensities(1).psth.mean(response_time)));
        zscore(i, j) = peak_on_response/basline_std;
        counts = counts + 1;
    end
    sugnificants(i, :) = abs(zscore(i, :)) > 2;
    sugnificants_num(i) = sum(sugnificants(i, :));
end
response_time = 130:160; %off

for i = 3:5
    cluster_data = data.(fields{i});
    for j = 1:(length(cluster_data)-1)
        basline_std = std(cluster_data{j}.intensities(1).repetition_baseline.mean);
        peak_on_response = max(abs(cluster_data{j}.intensities(1).psth.mean(response_time)));
        zscore(i, j) = peak_on_response/basline_std;
        counts = counts + 1;
    end
    sugnificants(i, :) = abs(zscore(i, :)) > 2;
    sugnificants_num(i) = sum(sugnificants(i, :));
end
%  colores = {'c',[0.3 0.3 0.3], 'm', 'r', 'g', 'y'}; %dms
%  dark_colors = {[0.3010 0.7450 0.9330]	 [0 0 0] [0.4940 0.1840 0.5560] [0.6350 0.0780 0.1840]	  [0.4660 0.6740 0.1880]	[0.9290 0.6940 0.1250]	};	
 colores = {'c', 'm', 'r', 'g'	, 'y'};
 dark_colors = {[0.3010 0.7450 0.9330] [0.4940 0.1840 0.5560] [0.6350 0.0780 0.1840]	  [0.4660 0.6740 0.1880]	[0.9290 0.6940 0.1250]	};


sugnificants_total = sum(sugnificants_num);

% figure
% for i = 1:length(sugnificants_num)

counts = 0; %0
for i = 1:5
    counts = counts +1;
    bar(counts, clusters.num_of_cells(i), 'FaceColor', colores{i} )
    hold on
    bar(counts, sugnificants_num(i), 'FaceColor', dark_colors{i} )
    cell_precent = [num2str(round(sugnificants_num(i)/clusters.num_of_cells(i)*100)) '%'];
    text(counts ,clusters.num_of_cells(i),cell_precent,...
               'HorizontalAlignment','center',...
               'VerticalAlignment','bottom', 'FontWeight', 'bold', 'FontSize',15)
end
% title({'Significance for each cluster (z-score > 2)'})
% subtitle({['Total number of Significant cells = ' num2str(sum(clusters.num_of_cells)) '/' num2str(sum(sugnificants_num)) ' (' num2str(round(sum(sugnificants_num)/sum(clusters.num_of_cells)*100)) '%)']})
xlabel('Cluster number', 'FontWeight', 'bold')
xticks(1:6)
ylabel('Number of cells', 'FontWeight', 'bold')
ylim([0 100])
    set(gca,'FontSize',15);

set(gca,'FontWeight','bold')
box off
        
        