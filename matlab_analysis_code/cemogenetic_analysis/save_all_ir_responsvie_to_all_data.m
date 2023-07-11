%save relevant_all_data

%load the both files

clear
clc
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
if ~iscell(file)
    file = {file};
end
cd(path)
%%
responsive = cell(3,2);
responsive_counts = zeros(3,1);
responsive_IR = cell(3,2);
responsive_IR_counts = zeros(3,1);

for i = 1:length(file)
    load(file{i})
    if iscell(all_data{1,2})
        all_data{1,2} = all_data{1,2}{1,1};
    end
    fields = fieldnames(all_data{1,2});
    for w = 1:3
        for j = 1:length(fields)
            S = all_data{1,1}.(fields{j});
            if S.Is_reponsive(w)
                responsive_counts(w)= responsive_counts(w) + 1 ;
                name = ['cell_' num2str(responsive_counts(w))];
                S.exp_name = file{i};
                S.cell_name = fields{j};
                responsive{w, 1}.(name) = S;
                responsive{w, 2}.(name) = all_data{1,2}.(fields{j});

            end
            if S.Is_reponsive_and_IR(w)
                responsive_IR_counts(w)= responsive_IR_counts(w) + 1 ;
                name = ['cell_' num2str(responsive_IR_counts(w))];
                S.exp_name = file{i};
                S.cell_name = fields{j};
                responsive_IR{w, 1}.(name) = S;
                responsive_IR{w, 2}.(name) = all_data{1,2}.(fields{j});

            end
        end
    end
end
%%
mkdir('all_Cells_from_each_group')
cd('all_Cells_from_each_group')
window_names = {'ON', 'Sustanied', 'OFF'};
    for w = 1:3
        all_data = [];

        all_data{1,1} = responsive_IR{w,1};
        all_data{1,2} = responsive_IR{w,2};
        save(['IR_reponsive' window_names{w}], "all_data")
    end

      for w = 1:3
          all_data = [];

        all_data{1,1} = responsive{w,1};
        all_data{1,2} = responsive{w,2};
        save(['reponsive' window_names{w}], "all_data")
    end
%% plot all ints
