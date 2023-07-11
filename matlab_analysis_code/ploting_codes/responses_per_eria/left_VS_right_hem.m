%% plot right vs left form brain render table
clear
clc
[file, path] = uigetfile('clusters.csv','MultiSelect','off');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
T  = readtable(datafile);
%%
%left_side
L_IR = sum(T.cluster == 10 & T.side == "Left");
L_responsive = sum(T.cluster == 11 & T.side == "Left") + L_IR;
L_total = sum(T.side == "Left");

%right side
R_IR = sum(T.cluster == 10 & T.side == "Right");
R_responsive = sum(T.cluster == 11 & T.side == "Right") + R_IR;
R_total = sum(T.side == "Right");


Left = [L_total; L_responsive; L_IR; L_responsive/L_total;L_IR/ L_total];
Rigth = [R_total; R_responsive; R_IR; R_responsive/R_total; R_IR/R_total ];
T2 = table(Left, Rigth, 'RowNames',{'total', 'responsive', 'ir', '%_responsive', '%_IR'});
writetable(T2, ['left_VS_right_' file(17:end)],'WriteRowNames', true)
%%
x = table2array(T2);
bar(flip(categorical(T2.Row(1:3))), flip(x(1:3, :)))
legend({'left', 'right'}, 'Location','northeast')

