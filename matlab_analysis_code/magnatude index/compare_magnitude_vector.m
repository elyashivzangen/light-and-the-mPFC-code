%% compare magnitude vector
clear
clc

[file1, path] = uigetfile('all_magnitude_vector.mat');
cd(path)
dataset1 = load(file1);
dataset1 = dataset1.all_magnitude_vector;

[file2, path] = uigetfile('all_magnitude_vector.mat');
cd(path)
dataset2 = load(file2);
dataset2 = dataset2.all_magnitude_vector;

win_names = ["early", "steady" , "off"];
n = 3; %number of letters of name of file
x = [15.400000000000000;14.900000000000000;14.400000000000000;13.900000000000000;12.900000000000000;11.400000000000000;9.400000000000000];
paired = 0;

expname1 = file1(1:n);
expname2 = file2(1:n);

%%
mkdir([expname1 '_vs_' expname2])
cd([expname1 '_vs_' expname2])
abs_magnitude_vector1 = abs(dataset1.magnitude_vector);
abs_magnitude_vector2 = abs(dataset2.magnitude_vector);

abs_magnitude_vector1(find(isinf(abs_magnitude_vector1))) = NaN;
abs_magnitude_vector2(find(isinf(abs_magnitude_vector2))) = NaN;
if isfile([expname1 '_vs_' expname2 '.pdf'])
    delete([expname1 '_vs_' expname2 '.pdf'])
end
for i = 1:length(win_names)
    window_mag1 = squeeze(abs_magnitude_vector1(:,i,:));

    window_mag2 = squeeze(abs_magnitude_vector2(:,i,:));
        nun_mag1 = find(sum(isnan(window_mag1),2));
        nun_mag2 = find(sum(isnan(window_mag2),2));


    if paired  
       window_mag1([nun_mag1; nun_mag2],:) = [];
       window_mag2([nun_mag1; nun_mag2],:) = [];
       [pval{i,1}, t_orig{i,1}, crit_t{i,1}, est_alpha{i,1}] = mult_comp_perm_t1(window_mag1-window_mag2, 10000, -1);
    else
        window_mag1(nun_mag1,:) = [];
        window_mag2(nun_mag2,:) = [];
        [pval{i,1}, t_orig{i,1}, crit_t{i,1}, est_alpha{i,1}] = mult_comp_perm_t2(window_mag1,window_mag2, 10000, -1);
    end
    
    mean_mag1{i,1} = mean(window_mag1, 1);
    mean_mag2{i,1} = mean(window_mag2, 1);

    sem_mag1{i,1} = sem(window_mag1, 1);
    sem_mag2{i,1} = sem(window_mag2, 1);

    f1 = figure;
    
    errorbar(flip(x), mean_mag1{i,1},  sem_mag1{i,1})
    hold on
   
    errorbar(flip(x), mean_mag2{i,1},  sem_mag2{i,1})

    % add pval
    text(flip(x),mean_mag2{i,1},strsplit(num2str(pval{i,1})))

    legend({expname1, expname2})
    title("magnitude vector")
    subtitle(win_names(i))
    savefig(win_names(i))
   
    exportgraphics(f1,[expname1 '_vs_' expname2 '.pdf'],"Append",true)
end
T = table(mean_mag1,mean_mag2,sem_mag1, sem_mag2,pval, t_orig,  'RowNames',win_names, 'VariableNames', {['mean_' expname1 ],['mean_' expname2], ['sem_' expname1],['sem_' expname2], 'pval', 't_orig'})
save([expname1 '_vs_' expname2 '_table'], "T")


cd ..



