[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%%
mean_response = 1;
n=1;
plotting = 0;
%%
sugnificnt_cells = 0;
cell_num = 0;

for i = 1:length(datafile)
    load(datafile{1,i});
    %   all_data = all_data.all_data;
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        current_cell = all_data.(cells{j}).intensities;
        p_val = 0;
        for k = 1:n%length(current_cell)
            if isempty( current_cell(k).intensty_data )
                continue
            end
            cell_num = cell_num + 1;
            raster = current_cell(k).intensty_data;
            basline_vector = reshape(raster(1:30,:),[],1);


            on = reshape(raster(40:50,:),[],1);
            on_long = reshape(raster(40:60,:),[],1);
            on_delay = reshape(raster(50:70,:),[],1);
            sustanied = reshape(raster(90:120,:),[],1);
            off = reshape(raster(140:150,:),[],1);
            if mean_response
                basline_vector = reshape(mean(raster(1:30,:), 1),[],1);
                on = reshape(mean(raster(40:50,:), 1),[],1);
                sustanied = reshape(mean(raster(90:120,:), 1),[],1);
                on_long = reshape(mean(raster(40:60,:), 1),[],1);
                off = reshape(mean(raster(140:150,:), 1),[],1);
                on_delay = reshape(mean(raster(50:70,:), 1),[],1);
            end
            if mean(basline_vector) < 0.5
                continue
            end
            
            [p_on(cell_num), ~, ~] = permutationTest(basline_vector, on, 100);
            [p_on_long(cell_num), ~, ~] = permutationTest(basline_vector, on_long, 100);
            [p_sustanied(cell_num), ~, ~] = permutationTest(basline_vector, sustanied, 100);
            [p_off(cell_num), ~, ~] = permutationTest(basline_vector, off, 100);
            [p_on_delay(cell_num), ~, ~] = permutationTest(basline_vector, on_delay, 100);

            %[p, observeddifference, effectsize] = permutationTest(basline_vector, on, 100)
                         if on < 1%0.05
                             figure
                             plot(mean(raster, 2))
                             subtitle(mean(basline_vector))
                             title([' p on: ' num2str(p_on(cell_num)),  ' p on long: ' num2str(p_on_long(cell_num)), ...
                                 ' p sustanied: ' num2str(p_sustanied(cell_num)), ' p off: ' num2str(p_off(cell_num)), ...
                                 ' p on delay: ' num2str(p_on_delay(cell_num))])
                         end
            if p < 0.05/n
                p_val = p_val + 1;
            end

        end
        
        if p_val > 0
            sugnificnt_cells = sugnificnt_cells+1;
            if plotting
            figure
                        for k = 1:4
                            raster = current_cell(k).intensty_data;
                            plot(mean(raster, 2))
                            hold on
                        end
            end
        end

    end
end
sugnificnt_cells



