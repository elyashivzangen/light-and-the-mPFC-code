clear
[file, path] = uigetfile('*.mat');%When the user clicks the load data button, a window should open to enable the user to select a file.
datafile = fullfile(path, file); %save path
load(datafile)
close all
cd(path)
clc

%%
data = clusters.cluster_cells;
fields = fieldnames(data);
types = {'on', 'off', 'sustained'};
%itirate over cluster
counts = 0;
for i = 1:length(fields)
    cells = data.(fields{i});
    cells = cells(1, 1:(end-1));
    %itirate over cells in cluster
    for j = 1:length(cells)
        %itirate over times of the response
        for m = 1:length(types)
            fit_data = cells{j}.fit_data.(types{m});
            fit{i}.(types{m})(j) = fit_data.gof.rsquare;
            % put in r_clust NaN where n-clust is 5 or -5 (reached the bounds) or when it is smaller than 0.05 (represents fits with an unrealistic trend)
            if abs(fit_data.curve.n)>4.9 || abs(fit_data.curve.n)<0.05
                fit{i}.(types{m})(j) = nan;
            end
        end
    end
    
    for  m = 1:length(types)
        counts = counts + 1;
        f1(counts) = figure;
        set(f1(counts),'color', [1 1 1]);
        set(f1(counts),'position',[50 50 500 500]);
        % subplot(1, 3, m)
        histogram(fit{i}.(types{m}), 10)
        %title([fields(i) ' ' types{m}])
        ylim([0 15]);
        xlim([0 1]);
        xticks(0:0.2:1);
        ir_mean(i, m) =  mean(fit{i}.(types{m}),'omitnan');
        ir_std(i, m) =  std(fit{i}.(types{m}),'omitnan');
        ir_std(i, m) = ir_std(i, m)/sqrt(length(fit{i}.(types{m}))-sum(isnan(fit{i}.(types{m})))); %convert std to ste
        
    end
end
close all
%% automaticaly find the best R squre to plot
f1 = figure;
set(f1,'color', [1 1 1]);
dark_colors = {[0.3010 0.7450 0.9330] [0.4940 0.1840 0.5560] [0.6350 0.0780 0.1840]	  [0.4660 0.6740 0.1880]	[0.9290 0.6940 0.1250] [0.9290 0.6940 0.1250]	};
[~, A] = sort(clusters.num_of_cells,'descend'); %so i can flip the positions and plot each bar in the order of the number of cells.
[~, I] = sort(A);
for i = 1:size(ir_std, 1)
    [best_mean(i), best_indice(i)] = max(ir_mean(i,:));
    best_std(i) = ir_std(i, best_indice(i));
    errorbar(I(i), best_mean(i),best_std(i), 'o', 'Color', dark_colors{i},  'LineWidth', 4)
    hold on
    text(i, 1, types{best_indice(i)} )
end
xlabel('cluster number')
ylabel('R^2')
xlim([0 6])
ylim([-0.1 1])
xticks([1:size(ir_mean, 1)])
box off
set(gca,'FontSize',16);

%%
f1 = figure;
set(f1,'color', [1 1 1]);
set(f1,'position',[50 50 500 750]);


%% clot histogram together 
%  nac_colores = {'k','k', 'm', 'r', 'g', 'y'};
% nac_colores = {'c', 'm', 'r', 'g'	, 'y'};
f1 = figure;
set(f1,'color', [1 1 1]);
set(f1,'position',[50 50 500 750]);
for i = 1:size(ir_mean, 1)
    subplot(3, 2, i)
    histogram(fit{i}.(types{best_indice(i)}) , 10)
    

    ylim([0 20]);
    xlim([0 1]);
    xticks(0:0.2:1);
    box off
    set(gca,'FontSize',14);

end

%% plot IR means plot nac
f1 = figure;
set(f1,'color', [1 1 1]);

% nac_colores = {'oc', 'om', 'or', 'og'	, 'oy'};
dark_colors = {[0.3010 0.7450 0.9330] [0.4940 0.1840 0.5560] [0.6350 0.0780 0.1840]	  [0.4660 0.6740 0.1880]	[0.9290 0.6940 0.1250]	};

ir_mean2plot(2) =  ir_mean(2,1);
ir_std2plot(2) =  ir_std(2,1);

ir_mean2plot(1) =  ir_mean(1,3);
ir_std2plot(1) =  ir_std(1,3);

ir_mean2plot(3:5) =  ir_mean(3:5,2);
ir_std2plot(3:5) =  ir_std(3:5,2);

for i = 1:5
    errorbar(i, ir_mean2plot(i),ir_std2plot(i), 'o', 'Color', dark_colors{i},  'LineWidth', 4)
    hold on
end
xlabel('cluster number')
ylabel('R^2')
xlim([0 6])
ylim([-0.1 1])
xticks([1:5])
box off
set(gca,'FontSize',16);

%% plot all IR scores
f1 = figure;
set(f1,'color', [1 1 1]);

% nac_colores = {'oc', 'om', 'or', 'og'	, 'oy'};
dark_colors = {[0.3010 0.7450 0.9330] [0.4940 0.1840 0.5560] [0.6350 0.0780 0.1840]	  [0.4660 0.6740 0.1880]	[0.9290 0.6940 0.1250]	};

for j = 1:3
    f{j} = figure;
    set(f{j},'color', [1 1 1]);
    ir_mean2plot(:) =  ir_mean(:,j);
    ir_std2plot(:) = ir_std(:, j);
    for i = 1:5
        errorbar(i, ir_mean2plot(i),ir_std2plot(i), 'o', 'Color', dark_colors{i},  'LineWidth', 4)
        hold on
    end
    xlabel('cluster number')
    ylabel('R^2')
    xlim([0 6])
    ylim([-0.1 1])
    xticks([1:5])
    box off
    set(gca,'FontSize',16);
    title(types{j})
end


xlabel('cluster number')
ylabel('R^2')
xlim([0 6])
ylim([-0.1 1])
xticks([1:5])
box off
set(gca,'FontSize',16);


%% clot histogram together for on off and sustained 

%% plot IR means plot dms
f1 = figure;
set(f1,'color', [1 1 1]);
set(f1,'position',[50 50 300 300]);
nac_colores = {'oc','ok', 'om', 'or', 'og', 'oy'};

ir_mean2plot([1:3, 5]) =  ir_mean([1:3, 5],1);
ir_std2plot([1:3, 5]) =  ir_std([1:3, 5],1);

ir_mean2plot(4) =  ir_mean(4,2);
ir_std2plot(4) =  ir_std(4,2);

ir_mean2plot(6) =  ir_mean(6,3);
ir_mean2plot(6) =  ir_mean(6,3);


counts = 0;
for i = 6:-1:1
    counts = counts + 1;
    errorbar(counts, ir_mean2plot(i),ir_std2plot(i), nac_colores{i}, 'LineWidth', 3)
    hold on
end
ylabel('R^2')
xlim([0 7])
ylim([0 0.7])
set(gca,'FontSize',15);
set(gca,'FontWeight','bold')
xticks([1:6])
yticks(0.1:0.1:0.7)
box off

%%
%% plot histogram together for DMS
f1 = figure;
set(f1,'color', [1 1 1]);
set(f1,'position',[50 50 500 750]);
%%
 responses = {'unresponsive 2', 'unresponsive 1', 'ON', 'ON-OFF', 'ON transient', 'ON suppressed OFF'};

counts = 2;
for i = 4%:-1:1
    counts = counts + 1;
    subplot(3, 2, counts)
    histogram(fit{i}.(types{2}) , 0:0.1:1)
    
    text(0.1, 11, responses{i}, 'FontWeight','bold' )
    ylim([0 13]);
    xlim([0 1]);
    xticks(0:0.2:1);
    box off
    set(gca,'FontSize',15);
    set(gca,'FontWeight','bold')


end