
total_cells = zeros(1,3);
IR_cell = zeros(1,3);
responsive = zeros(1,3);
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
for i = 1:length(datafile)
    load(datafile{1,i});
    %     all_data = all_data.all_data;
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        current_cell = all_data.(cells{j});
        for w = 1:length(all_data.(cells{j}).Is_reponsive)
            total_cells(w) = total_cells(w) + 1;
            if all_data.(cells{j}).Is_reponsive(w) %&& (current_cell.new_fit(2).isIntEncoding
                responsive(w) = responsive(w)  + 1;
                if all_data.(cells{j}).Is_reponsive_and_IR(w)
                    IR_cell(w) = IR_cell(w) + 1;
                end
            end
        end
    end
end
responses = {'ON'; 'Sustained'; 'OFF'};
IR_cell = IR_cell'
responsive = responsive'
total_cells = total_cells'
IR_percent = IR_cell/total_cells(1);
responsive_percent = responsive/total_cells(1);
T = table(responses, total_cells, responsive , IR_cell,responsive_percent,IR_percent );
writetable(T, 'IR_Responsive_percent.csv', 'Delimiter', ',')
for w = 1:3
    subplot(1,3,w)
    bar([IR_percent(w), responsive_percent(w)])
    title(responses{w})
end
savefig('responsivce_bar')