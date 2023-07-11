clear
[file, path] = uigetfile('*.mat');%When the user clicks the load data button, a window should open to enable the user to select a file.
datafile = fullfile(path, file); %save path
load(datafile)
close all
cd(path)
clc
%%
f1 = figure;
set(f1,'color', [1 1 1]);

dark_colors = {[0.3010 0.7450 0.9330] [0.4940 0.1840 0.5560] [0.6350 0.0780 0.1840]	  [0.4660 0.6740 0.1880]	[0.9290 0.6940 0.1250] [0.9290 0.6940 0.1250]	};
[~, A] = sort(clusters.num_of_cells,'descend'); %so i can flip the positions and plot each bar in the order of the number of cells.
[~, I] = sort(A);

f2 = figure;
set(f2,'color', [1 1 1]);
set(f2,'position',[50 50 500 750]);

data = clusters.cluster_cells;
fields = fieldnames(data);
for i = 1:length(fields)
    cells = data.(fields{i});
    cells = cells(1, 1:(end-1));
    %itirate over cells in cluster
    for j = 1:length(cells)
        baselines{i}(j) = mean(cells{j}.baseline_vector.mean);
    end
    set(0, 'CurrentFigure', f1)
    errorbar(I(i), mean(baselines{i}),std(baselines{i}), 'o', 'Color', dark_colors{i},  'LineWidth', 4)
    hold on
    
    set(0, 'CurrentFigure', f2)
    subplot(3, 2, i)
    histogram(baselines{i}, 10)
    ylim([0 20]);
    xlim([0 1]);
    xticks(0:0.2:1);
    box off
    set(gca,'FontSize',14);

end





set(0, 'CurrentFigure', f1)

xlabel('cluster number')
ylabel('mean basline fiirng rate')
xlim([0 6])
ylim([0 20])
xticks([1:size(6, 1)])
box off
set(gca,'FontSize',16);
    
    
