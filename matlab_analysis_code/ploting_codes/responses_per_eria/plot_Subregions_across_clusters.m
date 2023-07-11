%plot clusters across leyers and leyeres acroos clusters
clc
clear
[filename, path] = uigetfile("MultiSelect","off", ".csv");
datafile = fullfile(path, filename); %save path
T = readtable(datafile);
cluster_names = {'On Sustained', 'ON Suppressed 1', 'ON-OFF', 'ON Suppressed 2'};

%%
%plot clusters across erias
figure
bar(categorical(T.Properties.VariableNames), T{1:4, :})
title("clusters across arias")
legend(cluster_names,   'Location','northeast', 'Box','off');


%plot clusters across erias probabilty
a = T{1:4, :}./T{5, :};
figure
bar(categorical(T.Properties.VariableNames), a)
title("clusters across arias")
legend(cluster_names,   'Location','northwest', 'Box','off');
ylim([0 1])


%% plot arias across clusters
cluster_num = sum(T{1:4,:}, 2);
b = T{1:4,:}'./cluster_num';
bar(categorical(cluster_names), b)
title("arias across clusters")
legend(T.Properties.VariableNames,   'Location','northwest', 'Box','off');
ylim([0 1])
