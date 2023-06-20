function calculate_premutation_t1_for_3_ints_win(file, path)
%%
datafile = fullfile(path, file); %save path

if ~iscell(datafile)
    datafile = {datafile};
    file = {file};
end
windows = {40:50,65:125,140:150};
all_sugnificnt_cells = [];
all_p_val = [];
sugnificnt_cells = zeros(3,1);
cell_num = 0;
low_basline = 0;
p_val = [];
times = ["before"; "after"];
win = ["early"; "steady"; "off"];
all_cells = cell(1,1);
for i = 1:length(datafile)
    load(datafile{1,i});
    if ~iscell(all_data)
        all_data = {all_data};
    end

    for j = 1:length(all_data)
        t = struct2table_open(all_data{1,j});
        cname = t.Properties.RowNames;
        new_cname = cellfun(@(x) [file{i}(1:end-4) '_' x], cname, 'UniformOutput', false); %cange cells names to includ exp
        t.Properties.RowNames = new_cname;
        if ~isempty(all_cells{1,j})
            [~, diff_varnames] = setdiff( all_cells{1,j}.Properties.VariableNames, t.Properties.VariableNames);
            all_cells{1,j}(:, diff_varnames) = [];
            t = t(:, all_cells{1,j}.Properties.VariableNames);
        end
        all_cells{1,j} = [all_cells{1,j} ; t];



        data = all_data{1, j};
        cells = fieldnames(data);
        for c = 1:length(cells)
            cell_num = cell_num + 1;
            exp{cell_num} = file{i};
            timing{cell_num} = times{j};
            cname{cell_num} = cells{c};
            current_cell = data.(cells{c}).intensities;
            n = 3; %number of first intensities to use for calculation
            raster = [];
            for k = 1:n%length(current_cell)
                if isempty( current_cell(k).intensty_data )
                    continue
                end
                raster = [raster current_cell(k).intensty_data];
            end
            basline_vector = mean(raster(1:30,:), 1)';
            % go over windows
            for z = 1:length(windows)
                response_window = windows{z};
                response_vector = mean(raster(response_window,:), 1)';
                if mean(basline_vector) < 0.25
                    low_basline = low_basline + 1;
                    p_val(cell_num, z) = NaN;
                    all_data{1, j}.(cells{c}).ttest_pval(z) = NaN;
                    continue
                end
                p_val(cell_num, z) = mult_comp_perm_t1(basline_vector-response_vector, 10000, 0, 0.05, 0, 0);
                all_data{1, j}.(cells{c}).ttest_pval(z) = p_val(cell_num, z);
                if p_val(cell_num, z) < 0.05
                    sugnificnt_cells(z) = sugnificnt_cells(z)+1;
                    all_data{1, j}.(cells{c}).Is_reponsive(z) = 1;
                    Is_reponsive(cell_num, z) = 1;
                    if all_data{1, j}.(cells{c}).new_fit3(z).isIntEncoding
                        all_data{1, j}.(cells{c}).Is_reponsive_and_IR(z) = 1;
                        Is_reponsive_and_IR(cell_num, z) = 1;
                    else
                        all_data{1, j}.(cells{c}).Is_reponsive_and_IR(z) = 0;
                        Is_reponsive_and_IR(cell_num, z) = 0;
                    end
                else
                    Is_reponsive(cell_num, z) = 0;
                    all_data{1, j}.(cells{c}).Is_reponsive(z) = 0;
                    all_data{1, j}.(cells{c}).Is_reponsive_and_IR(z) = 0;
                    Is_reponsive_and_IR(cell_num, z) = 0;
                end
            end
        end
    end
    save(datafile{1,i}, 'all_data')
end

%%
T = table;
T.exp = exp';
T.time = timing';
T.cname = cname;
%T.cluster = all_cells{1,1}.cluster;
X = [];
for i = 1:3
    X.([convertStringsToChars(win(i)) '_Is_responsive']) = Is_reponsive(:, i);
    X.([convertStringsToChars(win(i)) '_Is_reponsive_and_IR']) = Is_reponsive_and_IR(:, i);
    X.([convertStringsToChars(win(i)) '_pval']) = p_val(:, i);
end
if isnan(X.early_pval(end))
    X.early_pval(end) = [];
    X.steady_pval(end) = [];
    X.off_pval(end) = [];
end
X = struct2table(X);
T = [T X];
save('all_ir_responsive_parameters', "T")
%%
G = groupsummary(T(:, [2 4:end]),"time",["sum", "mean"]);
writetable(G, 'is_responsive_and_ir_summary.csv')
save("all_cells", "all_cells")
end