%% create all channels LFP
%LFP STATSITICS
clc
clear
%% load all files
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%%
%in case of selcting only one file
if ~iscell(datafile)
    datafile = {datafile};
end
all_LFP = table;

for i = 1:length(datafile)
    load(datafile{1,i})
    for j = 1:7
        all_LFP.(['ND_' num2str(LFP.ND(j))])(i) = LFP.all_channel_mean(j);
    end
end
all_LFP.Properties.RowNames = file;
save("all_DTA_lfp_exps", "all_LFP")
%%

mean_LFP = varfun(@(x) mean(cell2mat(x)), all_LFP);
mean_LFP.Properties.VariableNames = all_LFP.Properties.VariableNames;
save("maen_DTA_LFP_exps", "mean_LFP")
%%
t = (1:length(mean_LFP{1,1}))/1000;
f1 = figure;
f1.Position = [100, 100, 1500, 800];
for i = 1:7
    subplot(4,2,i)
    plot(t,mean_LFP{1,i})
    hold on
    xline(3.116,'r')
    xline(13,'r')
    title(mean_LFP.Properties.VariableNames{i}, Interpreter="none")
end
sgtitle('all frame')
savefig(f1, 'all frame')

f2 = figure;
f2.Position = [100, 100, 1500, 800];
for i = 1:7
    subplot(4,2,i)
    plot(t,mean_LFP{1,i})
    hold on
    xline(3.116,'r')
    xline(13,'r')
    xlim([2.8 3.5])
    title(mean_LFP.Properties.VariableNames{i}, Interpreter="none")
end
sgtitle('on window')
savefig(f1, 'on window')

f3 = figure;
f3.Position = [100, 100, 1500, 800];
for i = 1:7
    subplot(4,2,i)
    plot(t,mean_LFP{1,i})
    hold on
    xline(3.116, 'r')
    xline(13,'r')
    xlim([12.8 13.5])
    title(mean_LFP.Properties.VariableNames{i}, Interpreter="none")
end
sgtitle('off window')
savefig(f1, 'off window')




