clear
clc
%% ir
x = [15.4000000000000;14.9000000000000;14.4000000000000;13.9000000000000;12.9000000000000;11.4000000000000;9.40000000000000];

cd('C:\Users\elyashivz\OneDrive - huji.ac.il\מחקר\current_analysis\DREEDS_VS_control\plot_control_vs_drreedds_per_cluster(figure5g)')
load('dreedds_IR_mean_sem.mat', 'ir_mean_sem');
dreedds_IR_mean_sem = ir_mean_sem;

load('control_IR_mean_sem.mat', 'ir_mean_sem');
control_IR_mean_sem = ir_mean_sem;
%%  plot
f1= figure;
f1.Position = [582 130 1242 848];

for i = 1:size(control_IR_mean_sem,1)
    subplot(2,2,i)
    plot(x,control_IR_mean_sem.before_ir(i,:), '-o')
    hold on
    plot(x,control_IR_mean_sem.after_ir(i,:), '-o')
    plot(x,dreedds_IR_mean_sem.before_ir(i,:), '-o')
    plot(x,dreedds_IR_mean_sem.after_ir(i,:), '-o')
    title(['cluster = ' num2str(i)])
    legend(["control before", "control after", "DREEDDS before", "DREEDDS after"])
end
savefig(f1, "IR_control_vs_DREEDDS")

%% psth
cd('C:\Users\elyashivz\OneDrive - huji.ac.il\מחקר\current_analysis\DREEDS_VS_control\plot_control_vs_drreedds_per_cluster(figure5g)')
load('dreedds_all_int_psth_mean_sem.mat');
dreedds_mean_psth = all_int_psth;

load('control_all_int_psth_mean_sem.mat');
control_mean_psth = all_int_psth;
%%  plot
f1= figure;
f1.Position = [582 130 1242 848];

for i = 1:size(control_mean_psth,1)
    subplot(2,2,i)
    plot(bin_psth(control_mean_psth.before_all_ints{i}(1,:), 5))
    hold on
    plot(bin_psth(control_mean_psth.after_all_ints{i}(1,:),5))
    plot(bin_psth(dreedds_mean_psth.before_all_ints{i}(1,:),5))
    plot(bin_psth(dreedds_mean_psth.after_all_ints{i}(1,:),5))
    title(['cluster = ' num2str(i)])
    legend(["control before", "control after", "DREEDDS before", "DREEDDS after"])
end
savefig(f1, "PSTH_ND1_control_vs_DREEDDS")