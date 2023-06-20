%% before and after lfp cimogenctics
clc
clear
%load all files to one big file
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
mkdir('statistics')

datafile = fullfile(path, file); %save path
%%
NDnames = ["ND10", "ND8", "ND6", "ND4", "ND3", "ND2", "ND1"];
all_exps.Properties.VariableNames = NDnames;
for i = 1:length(datafile)
    load(datafile{1,i});
    exp_mean(i,:) = LFP.all_channel_mean';
end

all_exps = array2table(exp_mean, "VariableNames",NDnames, "RowNames",file);
before_cells =  contains(file, 'before');
after_cells  =  contains(file, 'after');
% before_names = cellfun(@(x) upper(x(8:end-4)), file(1, before_cells), 'UniformOutput', false);
%after_names = cellfun(@(x) upper(x(7:end-4)), file(1, after_cells), 'UniformOutput', false);
% setdiff(before_names,   after_names)
 %setdiff(  after_names, before_names)
before_after(before_cells) = "before";
before_after(after_cells) = "after";
before_after = categorical(before_after)';
all_exps.time = before_after;

cd('statistics')
save('all_exps_lfp', 'all_exps')
%% plot mean
mean_nd = @(x) mean(cell2mat(x),1);
sem_nd = @(x) sem(cell2mat(x),1);
mean_lfp = groupsummary(all_exps, "time", mean_nd);
sem_lfp = groupsummary(all_exps, "time", sem_nd);
time =(( -3:0.001:16) - 0.116)';
save('time_with_shift', 'time')
save('mean_lfp', 'mean_lfp')
save('sem_lfp', "sem_lfp")

%% plot
f1 = figure;
f1.Position = [100,100,1500,800];

for i = 1:7
    subplot(7,1,i)
    plot(time,mean_lfp{:, i+2})
    xline(0,'r')
    xline(10,'r')
    ylabel(NDnames(i))
end
legend(mean_lfp.time)


f2 = figure;
f2.Position = [100,100,800,800];
for i = 1:7
    subplot(7,1,i)
    errorbar(repmat(time,[1,2]),mean_lfp{:, i+2}',sem_lfp{:, i+2}')
    hold on
    plot(mean_lfp{:, i+2}', LineWidth=1)
    xline(0,'r')
    xline(10,'r')
    ylabel(NDnames(i))
    xlim([-0.3 0.5])
end
legend(mean_lfp.time)

f3 = figure;
f3.Position = [100,100,800,800];
for i = 1:7
    subplot(7,1,i)
    plot(repmat(time,[1,2]),mean_lfp{:, i+2}')
    hold on
    plot(mean_lfp{:, i+2}', LineWidth=1)
    xline(0,'r')
    xline(10,'r')
    ylabel(NDnames(i))
    xlim([-0.3 0.5])
end
legend(mean_lfp.time)

savefig(f1, 'mean_lfp')
savefig(f2, 'mean_sem_lfp_on_window')
savefig(f2, 'mean_lfp_on_window')


