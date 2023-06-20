%% all magnitude index
%% load all data files
clear
clc
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%% calulate
count = 0;
window_names = {'ON', 'Sustanied', 'OFF'};
x = [15.400000000000000;14.900000000000000;14.400000000000000;13.900000000000000;12.900000000000000;11.400000000000000;9.400000000000000];

magnitude_vector = [];
for i = 1:length(datafile)
    %     for w = 1:length(window_names)
    load(datafile{1,i});
    if iscell(all_data)
        all_data = all_data{1,1};
    end
    cells = fieldnames(all_data);
    for j = 1:length(cells)

        count = count + 1;
        current_cell = all_data.(cells{j});

        exp_name{count,1} = file{i}(1:end-4);
        cell_name{count,1} = cells{j};
        is_responsive(count,:) = current_cell.Is_reponsive;
        is_responsive_and_ir(count,:) = current_cell.Is_reponsive_and_IR;

        for w = 1:length(window_names)
            if length(current_cell.baseline_vector.mean) > 7
                current_cell.baseline_vector.mean = current_cell.baseline_vector.mean([1,3,5,7:10]);
            end

            magnitude_vector(count, w, :) = flip(current_cell.new_fit3(w).y-current_cell.new_fit3(w).shift)./current_cell.baseline_vector.mean';

        end
%         all_data.(cells{j}).magnitude_vector = squeeze(magnitude_vector(count, :, :));
    end
%     save(datafile{1,i}, 'all_data')
end
%%
mkdir('magnitude_vector')
cd('magnitude_vector')
all_magnitude_vector = table(exp_name, cell_name,is_responsive, is_responsive_and_ir, magnitude_vector);
magnitude_vector(find(isinf(magnitude_vector))) = NaN;
magnitude_vector_abs = abs(magnitude_vector);
abs_magnitude_vector.mean = squeeze(mean(magnitude_vector_abs(:,2,:),1,"omitnan"));
abs_magnitude_vector.std = squeeze(std(magnitude_vector_abs(:,2,:),1,"omitnan"));
abs_magnitude_vector.sem = abs_magnitude_vector.std/sqrt(size(magnitude_vector_abs,1));

save('abs_magnitude_vector', 'abs_magnitude_vector')
save('all_magnitude_vector', "all_magnitude_vector")
errorbar(flip(current_cell.x), abs_magnitude_vector.mean,abs_magnitude_vector.sem)
title('magnitude vector sustaiend')
xlabel('log photons')
ylabel('magnitude of FR change')
savefig('magnitude_vector_with_sem')

cd ..