%%devide_cells_by_aria
clear
clc
%%
%save only Intensity encoding + IR
row_names = {'total'; 'responsive'; 'IR'; '%_reponsive'; '%_IR' };
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
%%
datafile = fullfile(path, file); %save path
window_names = {'ON', 'Sustanied', 'OFF'};
for w = 1:length(window_names)
    T = table(row_names);

    for i = 1:length(datafile)
        load(datafile{1,i});
        temp_all_data = all_data;
        cells = fieldnames(all_data);
        position = cell(length(cells), 1);
        for j = 1:length(cells)
            position{j} = all_data.(cells{j}).position{1};
             if contains(position{j}, '6')
                position{j} = position{j}(1:end-1);
            end
            if contains(position{j}, 'Anterior')
                layer_num  = find(ismember(position{j}, '12356'));
                position{j} = position{j}([1:23 layer_num]);
            end
           

            slash = ismember(position{j}, '/');
            if sum(slash)
                position{j}(slash) = '_';
            end

        end
        [uniqe_positions,~ , indices]= unique(position);
        for j = 1:length(uniqe_positions)
            if ~ismember(uniqe_positions{j},T.Properties.VariableNames)
                T.(uniqe_positions{j}) = zeros(5,1);
            end
            all_data = rmfield(temp_all_data, cells(indices ~= j));
            T.(uniqe_positions{j})(3) = T.(uniqe_positions{j})(3) + sum(structfun(@(x) (x.Is_reponsive_and_IR(w)), all_data,'UniformOutput',true));
            T.(uniqe_positions{j})(2) = T.(uniqe_positions{j})(2) + sum(structfun(@(x) (x.Is_reponsive(w)), all_data,'UniformOutput',true));
            T.(uniqe_positions{j})(1) = T.(uniqe_positions{j})(1) + sum(indices == j);

        end
    end
    Variables = cellfun(@(x) (x(1:4)), T.Properties.VariableNames, 'UniformOutput',false);
    [uniqe_positions,~, indices]= unique(Variables);
    T.SUM = sum(T{:, 2:end}, 2);

    for i = 1:max(indices)
        if sum(i == indices) > 1
            name = Variables(indices == i);
            T.(name{1}) = sum(table2array(T(1:5, indices == i)), 2);
            figure
            subplot(1,2,1)
            bar(categorical(T.Properties.VariableNames(indices == i)), T{2, indices == i}./T{1, indices == i}*100)
            title([name '% responsive' window_names(w)])

            subplot(1,2,2)

            bar(categorical(T.Properties.VariableNames(indices == i)), T{3, indices == i}./T{1, indices == i}*100)
            title([name '% IR ' window_names(w)])

        end
    end

    T{4, 2:end} = T{2, 2:end}./T{1, 2:end}*100;
    T{5, 2:end} = T{3, 2:end}./T{1, 2:end}*100;
    f1 = figure;
    subplot(1,2,1)

    bar(categorical(T.Properties.VariableNames(2:end)), T{4, 2:end})
    subplot(1,2,1)
    title(['%_responsive_' window_names(w)])

    subplot(1,2,2)

    bar(categorical(T.Properties.VariableNames(2:end)), T{5, 2:end})
    title(['%_IR_' window_names(w)])

    exportgraphics(f1, 'positions_all_layeres.pdf', 'Append',true)
    writetable(T, [ window_names{w} '_IR_responsive.csv'], 'Delimiter', ',')
end
