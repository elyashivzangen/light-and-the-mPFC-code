%% AP AND ML Quntification
clc
clear
[filename, path] = uigetfile("MultiSelect","off", "load_brein_render_Table.csv");
cd(path)
datafile = fullfile(path, filename); %save path
T = readtable(datafile);
%% 
% aline to midline (5700) 
midline = 5700;
T.x = abs(T.x - 5700)/1000; %convert CCF(x) to ML
T.z = (5400 - T.z)/1000;



steady_cells = ismember(T.cluster, [13,15]); 
sT = T(steady_cells, :); 

early_cells = ismember(T.cluster, [13,14]); 
eT = T(early_cells, :); 

early_and_steady_cells= ismember(T.cluster, 13); 
easT = T(early_and_steady_cells, :);

%% AP
[steady, edges] = histcounts(sT.z, 10);
steady = steady';
early = histcounts(eT.z, edges)';
early_and_steady = histcounts(easT.z, edges)';
total = histcounts(T.z, edges)';
cordinates = edges(2:end)';

AP = table(cordinates ,steady,early, early_and_steady, total);
AP.('steady%') = steady./total;
AP.('early%') = early./total;
AP.('early_and_steady%') = early_and_steady./total;
%% plot
APfig = figure;
APfig.Position = [100 100 1000 300];
subplot(1,3,1)
bar(AP.cordinates, AP.('steady%'))
title('steady %')

subplot(1,3,2)
bar(AP.cordinates, AP.('early%'))
title('early %')

subplot(1,3,3)
bar(AP.cordinates, AP.('early_and_steady%'))
title('early and steady %')

mkdir('AP_ML_Quntification')
cd('AP_ML_Quntification')
save('AP_table', 'AP')
writetable(AP, 'AP_table.csv')
savefig(APfig, "APfig")
export_fig(APfig, 'APfig.tif')
%% ML
[steady, edges] = histcounts(sT.x, 10);
steady = steady';
early = histcounts(eT.x, edges)';
early_and_steady = histcounts(easT.x, edges)';
total = histcounts(T.x, edges)';
cordinates = edges(2:end)';

ML = table(cordinates ,steady,early, early_and_steady, total);
ML.('steady%') = steady./total;
ML.('early%') = early./total;
ML.('early_and_steady%') = early_and_steady./total;
%% plot
MLfig = figure;
MLfig.Position = [100 100 1000 300];
subplot(1,3,1)
bar(ML.cordinates, ML.('steady%'))
title('steady %')

subplot(1,3,2)
bar(ML.cordinates, ML.('early%'))
title('early %')

subplot(1,3,3)
bar(ML.cordinates, ML.('early_and_steady%'))
title('early and steady %')

save('ML_table', 'ML')
writetable(ML, 'ML_table.csv')
savefig(MLfig, "MLfig")
export_fig(MLfig, 'MLfig.tif')
%%