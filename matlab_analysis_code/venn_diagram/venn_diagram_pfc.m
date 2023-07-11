%% venn diagram
% create the relevant table
clear
clc
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%%
total = [];
early = [];
late = [];
late_ir = [];
early_ir = [];
for i = 1:length(datafile)
    load(datafile{1,i});
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        c = all_data.(cells{j}); %current cell
        cell_num = i*1000 + j; %1000 is the number of experiment in the set
        total = [total cell_num];
        if c.Is_reponsive(1)
            early = [early cell_num];
        end
        if c.Is_reponsive(2)
            late = [late cell_num];
        end
        if c.Is_reponsive_and_IR(1)
            early_ir = [early_ir cell_num];
        end
        if c.Is_reponsive_and_IR(2)
            late_ir = [late_ir cell_num];
        end
    end
end
%% plot
setLabels = ["total", "early", "late", "early ir", "late ir"];
setListData = {total, early, late, early_ir, late_ir};
h = vennEulerDiagram(setListData, setLabels, 'drawProportional', true);
mkdir('venn_diagram')
cd('venn_diagram')
savefig('venn_diagram.fig')
save('list_of_cell_numbers_from_each_group', "setListData")
save('group_names', "setLabels")


