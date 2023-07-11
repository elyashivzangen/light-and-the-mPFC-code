%% save all_data files to breain render table with out spliting
clc
clear
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
flip_ml = 1; %if to flip the ML axes (x);
midline = 5700; %the value of midline in the x axes
%%
response_times = {'on';'sustained'; 'off'};

for w =  1:3
    x = [];
    y= [];
    z= [];
    id= [];
    cluster = [];
    %     experiment_name = [];
    count = 0;
    for i = 1:length(datafile)
        load(datafile{1,i});
        cells = fieldnames(all_data);
        for j = 1:length(cells)
            count = count + 1;
            
            current_cell = all_data.(cells{j});
            %  total_cells = total_cells + 1;
            exp_name{count, 1} = file{i}(1:8);
            if contains(exp_name{count, 1},'R')
                side{count, 1} = "Right";
            else
                side{count, 1} = "Left";
            end
            region_acronym{count, 1} = current_cell.region_acronym;
            position{count, 1} = current_cell.position;
            x =  [x; all_data.(cells{j}).cordinates.x{1}];
            y = [y; all_data.(cells{j}).cordinates.y{1}];
            z = [z; all_data.(cells{j}).cordinates.z{1}];
            id = [id; str2double(cells{j}(6:end))];

            if flip_ml %flip the ml axes if it is wronge
               if contains(exp_name{count, 1},'R') && x(end) > midline
                   x(end) = midline - (x(end)-midline);
               elseif contains(exp_name{count, 1},'L') && x(end) < midline
                    x(end) = midline - (x(end)-midline);
               end
            end


            cluster = [cluster; 10];
            
            %             experiment_name = [experiment_name repmat(file{i}, j, 1)];
        end
        %         cd(new_path)
        %         save('total_cells', 'total_cells')
        %         labels = {'sugnificant cells', 'deleted cells'};
        %         save('sugnificant_cells', 'sugnificant_cells')
        %         explode = [1 1];
        %         piefig = pie([sugnificant_cells deleted_cells],explode);
        %         legend(labels);
        %         savefig('piefig.fig')

    end
    brain_render_table = table(id, cluster, x,y,z, position, region_acronym, exp_name, side);
    writetable(brain_render_table, ['clustering_data ' response_times{w} '.csv'], 'Delimiter', ',')

end


%%

