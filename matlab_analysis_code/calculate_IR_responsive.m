clear
clc
%%
% Needs to be in D:\Data\IR data Shira_May_14_2022

windows = {40:50, 40:60, 40:45, 40:55, 65:125, 75:125, 85:125, 95:125, 100:130, 140:150, 140:160, 140:155};
relevant_windows = [1, 5, 10];
win = ["early"; "steady"; "off"];

[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
%%

datafile = fullfile(path, file); %save path
IR_cell = zeros(1,3);
total_cell = 0;
reponsive_cells = zeros(1,3);
IR_sugnificant_cells =zeros(1,3);

if ~iscell(datafile)
    datafile = {datafile};
    file = {file};
end

res_names = cell(length(datafile), 3);
ir_res_names = cell(length(datafile), 3);
ir_names = cell(length(datafile), 3);

z = 3; %number of intensities used in calculating sugnificans
for i = 1:length(datafile)
    load(datafile{1,i});
    if iscell(all_data)
        all_data = all_data{1,1};
    end
    total_cell_exp(i,1) = 0;
    reponsive_cells_exps(i,:) = zeros(1,3);
    IR_sugnificant_cells_exps(i, :) = zeros(1,3);
    %     all_data = all_data.all_data;
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        current_cell = all_data.(cells{j});
        total_cell = total_cell + 1;
        total_cell_exp(i,1) = total_cell_exp(i,1) + 1;
        all_data.(cells{j}).Is_reponsive = zeros(1,3);
        all_data.(cells{j}).Is_reponsive_and_IR  = zeros(1,3);
        for w = 1:3 %run over the 3 time windows
            if ~isfield(current_cell, 'ttest_pval')
                if isfield(current_cell, 'pval_table2')
                    current_cell.ttest_pval = current_cell.pval_table2(:,z);
                else
                    current_cell.ttest_pval = current_cell.pval_table(:,z);
                end
            end
            if current_cell.ttest_pval(w) < 0.05   %%pval_table(w,z) < 0.05
                all_data.(cells{j}).Is_reponsive(w) = 1;
                reponsive_cells(w) = reponsive_cells(w) + 1;
                reponsive_cells_exps(i, w) = reponsive_cells_exps(i, w) + 1;
                res_names{i, w} = [res_names{i, w}; string(cells{j})];
            end
            if current_cell.new_fit3(w).isIntEncoding
                IR_cell(w) = IR_cell(w) + 1;
                ir_names{i, w} = [ir_names{i, w}; string(cells{j})];

                if all_data.(cells{j}).Is_reponsive(w)
                    all_data.(cells{j}).Is_reponsive_and_IR(w) = 1;
                    IR_sugnificant_cells(w) = IR_sugnificant_cells(w) + 1;
                    IR_sugnificant_cells_exps(i,w) = IR_sugnificant_cells_exps(i, w) + 1;
                    ir_res_names{i, w} = [ir_res_names{i, w}; string(cells{j})];

                end
            end
        end
    end
    save(datafile{1,i}, 'all_data')

end
save('calculate_ir_responsive_parameters')
file = [file' ; "total"];
total_cell_exp(end+1,:) =total_cell;
reponsive_cells_exps(end+1,:) =reponsive_cells;
reponsive_cells_expsT = array2table(reponsive_cells_exps,"VariableNames",win);
IR_sugnificant_cells_exps(end+1,:) =IR_sugnificant_cells;
IR_sugnificant_cells_expsT = array2table(IR_sugnificant_cells_exps,"VariableNames",win);

responsvie_and_ie_table = table(file, total_cell_exp, reponsive_cells_exps, IR_sugnificant_cells_exps);
writetable(responsvie_and_ie_table, "responsive cells per exp.csv");
responsvie_and_ie_table2 = table(file, total_cell_exp, reponsive_cells_expsT, IR_sugnificant_cells_expsT);
percentage_responsvie_and_ie_table = array2table(responsvie_and_ie_table{:,3:end}./responsvie_and_ie_table.total_cell_exp);
percentage_responsvie_and_ie_table = [responsvie_and_ie_table(:,1:2) percentage_responsvie_and_ie_table];
save("responsive cells per exp", "responsvie_and_ie_table2");
save("percentage_responsvie_and_ie_table", "percentage_responsvie_and_ie_table")


