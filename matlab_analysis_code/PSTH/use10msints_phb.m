%% PLOT PSTH BY STUFF like for phb
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%shift = 0.116;
pretime = 3;
shiras_shift = 1.1;
binsize = 0.01;
%% create a table with all cells
T = [];
for i = 1:length(datafile)
    load(datafile{i})
    tt = struct2table_open(all_data);
    tt = tt(:, ["cluster","intensities","baseline_vector","Is_reponsive","Is_reponsive_and_IR","new_fit3"]);
    tt.Properties.RowNames = cellfun(@(x) [x file{i}(1:10)], tt.Properties.RowNames,'UniformOutput', false);
   
    T = [T; tt];
end
T.cluster = cell2mat(T.cluster);

%% find psth
ints = T.intensities;

psth= [];
for i = 1:length(ints)
    for j = 1:7
        ND = ['nd_' num2str(j)];
        psth.(ND)(i, :) = ints{i}(j).psth.mean';
    end
end
psth = struct2table(psth);
%%

psth.cluster = T.cluster ;
G = grpstats(psth, "cluster", "mean");
%% split by subregion

f2 = figure;

x = (1:length(psth.nd_1))*binsize-shiras_shift-pretime;

for i = 1:size(G, 1)
    f1 = figure;
    f1.Position = [100, 100, 1400,500];
    subplot(1,2, 1)
    plot(G.mean_nd_1(i,:))
    title(['n = ' num2str(G.GroupCount(i))]);
    subplot(1,2, 2)

    for j = 1:7
        plot(G.(['mean_nd_' num2str(j)])(i,:))
        hold on
    end
    sgtitle(G.Properties.RowNames{i}, 'interpreter', 'none')
    %exportgraphics(f1, 'all_structures.pdf', "Append",true)
    set(0, 'CurrentFigure', f2)
    subplot(2,2, i)
    plot(x, G.mean_nd_1(i,:))
    [~, latancy(i)] = max(abs(G.mean_nd_1(i,round((shiras_shift+pretime)/binsize):end)));
    title(G.Properties.RowNames{i}, 'interpreter', 'none')
    subtitle(['n = ' num2str(G.GroupCount(i)) ' lat:' num2str(latancy(i))]);
end
savefig(f2, 'ND_1_each_cluster_each structure')


%%
