clear
clc
[file, path] = uigetfile('all_magnitude_vetor.mat','MultiSelect','off');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
load(file)
%% exclude inf  
mv = all_magnitude_vector.magnitude_vector;
[x, y, z] = findND(mv == inf);
all_magnitude_vector.magnitude_vector(x, y ,z) = NaN;
all_magnitude_vector.magnitude_vector = abs(all_magnitude_vector.magnitude_vector);
%calculate light responsive magnitude vector from all magnitude vector
x = [15.400000000000000;14.900000000000000;14.400000000000000;13.900000000000000;12.900000000000000;11.400000000000000;9.400000000000000];
x = flip(x);
%remove the OFF colom form magnitude vector
windows = ["early", "steady", "off"];
is_responsive = array2table(all_magnitude_vector.is_responsive,"VariableNames",windows);
is_ir = array2table(all_magnitude_vector.is_responsive_and_ir,"VariableNames",windows);
T = table;
T.is_responsive_early = is_responsive.early;
T.is_responsive_steady = is_responsive.steady;
T.magnitude_vector = squeeze(all_magnitude_vector.magnitude_vector);
GS.both_early_and_steady = groupsummary(T,["is_responsive_early", "is_responsive_steady"] ,["mean", "std"]);
GS.both_early_and_steady.sem_magnitude_vector = GS.both_early_and_steady.std_magnitude_vector./sqrt(GS.both_early_and_steady.GroupCount);
GS.only_early = groupsummary(T,["is_responsive_early"] ,["mean", "std"]);
GS.only_early.sem_magnitude_vector = GS.only_early.std_magnitude_vector./sqrt(GS.only_early.GroupCount);
GS.only_steady = groupsummary(T, "is_responsive_steady",["mean", "std"]);
GS.only_steady.sem_magnitude_vector = GS.only_steady.std_magnitude_vector./sqrt(GS.only_steady.GroupCount);

TB(1,:) = GS.only_early(2, ["mean_magnitude_vector", "sem_magnitude_vector"]);%table for ploting
TB(2,:) = GS.only_steady(2, ["mean_magnitude_vector", "sem_magnitude_vector"]);%table for ploting
TB(3,:) = GS.both_early_and_steady(1, ["mean_magnitude_vector", "sem_magnitude_vector"]);%table for ploting
TB.Properties.RowNames = {'early', 'steady', 'non_responsive'};

G{1} = both_early_and_steady;
G{2} = only_early;
G{3} = only_steady;
%%
path = uigetdir();
cd(path)
save("both_early_and_steady", "both_early_and_steady")
save("only_early", "only_early")
save("only_steady","only_steady")
save("responsvie_vs_non_Responsvie_table", "TB")
%%
for n = 1:2
    for j = 1:3
        f{n, j} = figure;
        errorbar(x, squeeze(TB.mean_magnitude_vector(j,n,:)),squeeze(TB.std_magnitude_vector(j,n,:)))
        title(['window = ' windows{n}], [' group = ' TB.Properties.RowNames{j}] )
        exportgraphics(f{n, j}, [ windows{n} '.pdf'], "Append",true)
    end
    f2 =  figure;
    errorbar([x'; x'; x']', squeeze(TB.mean_magnitude_vector(:,n,:))',squeeze(TB.std_magnitude_vector(:,n,:))')
    legend(TB.Properties.RowNames)
    title(['window = ' windows{n}])
    exportgraphics(f2, [ windows{n} '.pdf'], "Append",true)
    savefig(f2,['window = ' windows{n}])
end

% names = fieldnames(GS);
% for i = 1:3
%     name = names{i};
%     for n = 1:2
%         for j = 1:size(GS.(name), 1) 
%             f.(name)(j) = figure;
%             data = GS.(name)(j,:);
%             errorbar(x, squeeze(data.mean_magnitude_vector(1,n,:)),squeeze(data.std_magnitude_vector(1,n,:)))
%             title(['window = ' windows{n} 'group = ' name  ' num = ' num2str(data{1,1})] )
%         end
%     end
% end
% 
