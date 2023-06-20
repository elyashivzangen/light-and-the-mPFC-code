clc
clear
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path

%in case of selcting only one file
if ~iscell(datafile)
    datafile = {datafile};
end

%%
%change if you need
relvant_window = 2; % 2 = sus
relevant_int_nums = 3; % 3 intensites together is the highest intensiety

windows = {40:50,65:125,140:150};
all_sugnificnt_cells = [];
all_p_val = [];
for z = 1:length(windows)
    response_window = windows{z};
    for n=1:4 %number of intensties used
        %     plotting = 0;
        %
        sugnificnt_cells = 0;
        cell_num = 0;
        low_basline = 0;
        p_val = [];

        for i = 1:length(datafile)
            load(datafile{1,i});
            if isfield(all_data, 'all_data')
                all_data = all_data.all_data;
            end
            if iscell(all_data)
                all_data = all_data{1};
            end
            %   all_data = all_data.all_data;
            cells = fieldnames(all_data);
            for j = 1:length(cells)
                current_cell = all_data.(cells{j}).intensities;
                cell_num = cell_num + 1;
                raster = []; 
                %         p_val = 0;
                for k = 1:n%length(current_cell)
                    if isempty( current_cell(k).intensty_data )
                        continue
                    end
                    raster = [raster current_cell(k).intensty_data];
                end
                basline_vector = reshape(mean(raster(1:30,:), 1),[],1);
                response_vector = reshape(mean(raster(response_window,:), 1),[],1);

                if mean(basline_vector) < 0.5
                    low_basline = low_basline + 1;
                    all_p_val(z, n, cell_num) =NaN;

                    all_data.(cells{j}).pval_table(z, n) = NaN;
                    continue
                end

                [p_val(cell_num), ~, ~] = permutationTest(basline_vector, response_vector, 10000);
                %         [p_on_long(cell_num), ~, ~] = permutationTest(basline_vector, on_long, 100);
                %           [p_sustanied(cell_num), ~, ~] = permutationTest(basline_vector, sustanied, 100);
                %         [p_off(cell_num), ~, ~] = permutationTest(basline_vector, off, 100);
                %         [p_on_delay(cell_num), ~, ~] = permutationTest(basline_vector, on_delay, 100);
                %
                %         %[p, observeddifference, effectsize] = permutationTest(basline_vector, on, 100)
                %         if p_on(cell_num)< 1%0.05
                %             figure
                %             plot(mean(raster, 2))
                %             hold on
                %             subtitle(mean(basline_vector))
                %             title([' p on: ' num2str(p_on(cell_num)),  ' p on long: ' num2str(p_on_long(cell_num)), ...
                %                 ' p sustanied: ' num2str(p_sustanied(cell_num)), ' p off: ' num2str(p_off(cell_num)), ...
                %                 ' p on delay: ' num2str(p_on_delay(cell_num))])
                %         end

                if p_val(cell_num) < 0.05
                    %             p_val = 1;

                    sugnificnt_cells = sugnificnt_cells+1;
                end
                %save parameters
                all_p_val(z, n, cell_num) = p_val(cell_num);

                all_data.(cells{j}).pval_table(z, n) = p_val(cell_num);

            end

            save(datafile{1,i}, "all_data")
            %save([datafile{1,i}(1:end-4) '_with_p_val.mat'], 'all_data')
            if z == relvant_window && n == relevant_int_nums
                relevant_cells = cells(all_p_val(relvant_window, relevant_int_nums, 1:length(cells)) < 0.05);
                newdatafile = [datafile{1, i}(1:end-4) '_sugnificant_cells'];
                save(newdatafile, "relevant_cells")
            end
            
        end
        %         z
        %         n
        %         sugnificnt_cells
        all_sugnificnt_cells(z, n) = sugnificnt_cells;

    end

end
cell_num
all_sugnificnt_cells = array2table(all_sugnificnt_cells);
all_sugnificnt_cells.Properties.VariableNames = ["1", "2", "3", "4"];
all_sugnificnt_cells.Properties.RowNames = ["early", "steady", "off"];


save("premutation_parameters")

%     if p_val
%         if plotting
%             figure
%             for k = 1:4
%                 raster = current_cell(k).intensty_data;
%                 plot(mean(raster, 2))
%                 hold on
%             end
%         end
%     end


