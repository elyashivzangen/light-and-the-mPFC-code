function plot_and_save_before_and_after_psth(all_psth, all_cells, name)
% plot and save psth of before after input all psth - 7 ints
% plot and save ir of before and after
%calculate and plot pvalue of mean response for each intensitiey
%all_psth(7*2 cell with all psth for all intensiteis
% 
mkdir(name)
cd(name)
save('all_psth', 'all_psth')
save('all_cells', "all_cells")
n_is = ['n = ' num2str(size(all_cells{1,1} ,1))];
save(n_is, "n_is")

mkdir('before_and_after_psth')
cd("before_and_after_psth")

nds = [10,8,6,4,3,2,1];
times = ["before", "after"];
ploting = 1;
window_times = {40:50, 65:125, 140:150};
win_names = ["early", "steady" , "off"];
intensities = [15.400000000000000;14.900000000000000;14.400000000000000;13.900000000000000;12.900000000000000;11.400000000000000;9.400000000000000];

all_psth{1,1}(isnan(all_psth{1,1}(:,1)), :) = [];
all_psth{1,2}(isnan(all_psth{1,2}(:,1)), :) = [];

mean_psth = cellfun(@(x) mean(x, 1),all_psth ,'UniformOutput',false);
sem_psth = cellfun(@(x) sem(x, 1),all_psth ,'UniformOutput',false);



f1 = figure;
f1.Position = [415,125,390,853];
if ploting
    for i = 1:7
        subplot(7, 1, i)
        plot(smooth(mean_psth{i, 1}))
        hold on
        plot(smooth(mean_psth{i, 2}))
        nd_name{i} =  ['nd' num2str(nds(i))];
        title(['nd = ' num2str(nds(i))])
        legend(times)
    end
end
sem_psth = cellfun(@(x) {x}, sem_psth, 'UniformOutput',false);
mean_psth= cellfun(@(x) {x}, mean_psth, 'UniformOutput',false);

sem_psth = cell2table(sem_psth);
sem_psth.Properties.VariableNames = times;
sem_psth.Properties.RowNames = nd_name;

mean_psth = cell2table(mean_psth);
mean_psth.Properties.VariableNames = times;
mean_psth.Properties.RowNames = nd_name;


savefig(f1, 'before_after_psth')
save("mean_psth", "mean_psth")
save("sem_psth", "sem_psth")
cd ..

%% calculate and plot and save ir and mean response before and after and cacualte pval

mean_response = [];
mkdir("meanIR")
cd("meanIR")
win_res = [];

for w = 1:length(window_times)
    response{w} = cellfun(@(x) abs(mean(x(:, window_times{w}),2)), all_psth,'UniformOutput', false);
    win_res{w} = cell2table(response{w}, 'VariableNames',times, 'RowNames',nd_name);
    for i = 1:7 %go over the nds
        response_dif{i, w} = response{w}{i, 1} -  response{w}{i, 2};
        mean_response_dif(i,w) = mean(response_dif{i, w});
        %figure
        %histogram( response_dif{i, w},200)
        %hold on
        %xline(mean_response_dif(i,w),'r')
        [~, response_pval(i,w)] = ttest(response{w}{i, 1}, response{w}{i, 2}, "Tail","right");
    end
    mean_response{w} = cellfun(@mean, response{w});
    sem_response{w} = cellfun(@(x) sem(x, 1), response{w});

    if ploting
        figure
        plot(flip(intensities), mean_response{w}, '-o')
        title(win_names{w})
        legend(times)
        savefig([win_names{w} '_mean_ir'])
    end
    mean_response{w} = array2table(mean_response{w}, 'VariableNames',times, 'RowNames',nd_name);
    sem_response{w} = array2table(sem_response{w}, 'VariableNames',times, 'RowNames',nd_name);
    
end

win_res = cell2table(win_res, "VariableNames",win_names);
save("all_responses_all_windows", "win_res")

response_pval = array2table(response_pval, "RowNames",nd_name, "VariableNames",win_names);
save("response_pval", "response_pval")
writetable(response_pval, "response_pval.csv","WriteRowNames",true )

mean_response = cell2table(mean_response, "VariableNames",win_names);
save("mean_response_all_windows", "mean_response")

sem_response = cell2table(sem_response, "VariableNames",win_names);
save("sem_response_all_windows", "sem_response")


cd ..


%% plot baseline change
mkdir("baseline")
cd("baseline")
baseline = [];
figure
for i = 1:size(all_cells,2)
    data = all_cells{i}.baseline_vector;
    baseline.(times{i}) = cellfun(@(x) x.mean, data, 'UniformOutput',false);
    %exclude eaperiment without 7 intensiteis
    long_basline = cellfun(@length,  baseline.(times{i})) == 7;
    baseline.(times{i}) = baseline.(times{i})(long_basline);
    baseline.(times{i}) = cell2mat(baseline.(times{i}));
    mean_baseline.(times{i}) = mean(baseline.(times{i}),1)';
    sem_baseline.(times{i}) = sem(baseline.(times{i}), 1)';
   
    errorbar(flip(intensities), mean_baseline.(times{i}), sem_baseline.(times{i}), '-o')
    hold on
end
title('basline before and after')
baselineT = struct2table(baseline);
mean_baselineT = struct2table(mean_baseline);
sem_baselineT = struct2table(sem_baseline);
[~, basline_pval] = ttest(baselineT.before, baselineT.after);
basline_pval =basline_pval';
mean_sem_basline = table(mean_baselineT, sem_baselineT, basline_pval,'RowNames',nd_name);

savefig('baseline')
save("baseline_diffrences", "mean_sem_basline")



save basline
cd ..
%% magnitude index (response/baseline)
% shorten PSTH to include only ones with all ints
nonabs_response = [];
magnitude = [];
for i = 1:2
    count = zeros(7,1);
    for j = 1:size(all_cells{i}, 1)
        ints = all_cells{i}{j, "intensities"}{1};
        c_baseline{i, j} = all_cells{i}{j, "baseline_vector"}{1}.mean;
        intnums = length(c_baseline{i, j});
        for z = (7-intnums+1):7
            count(z) = count(z) + 1;
           
            psth = ints(nds(z)).psth.mean;
            for w  = 1:length(window_times)
                nonabs_response.(win_names(w)){z,i}(count(z),1) = mean(psth(window_times{w}));
                magnitude.(win_names(w)){z,i}(count(z),1) = nonabs_response.(win_names(w)){z,i}(count(z),1)/c_baseline{i, j}(z- (7-intnums));
                if c_baseline{i, j}(z- (7-intnums)) == 0;
                    magnitude.(win_names(w)){z,i}(count(z),1)  = NaN;
                end
            end
        end
    end
end
%%
%save and plot
nonabs_response = struct2table(nonabs_response);
save('non_abs_IR','nonabs_response')

mkdir('magnitude')
cd('magnitude')
if isfile('magnitude all box plots.pdf')
    delete 'magnitude all box plots.pdf'
end
mean_magnitude= [];
sem_magnitude= [];
for w = 1: 1:length(window_times)
    for j = 1:7
        f1 = figure;
        boxplot([magnitude.(win_names(w)){j,1}, magnitude.(win_names(w)){j,2}], 'Notch','on','Labels',times)
        title({['window = ' win_names{w}],nd_name{j}})
        exportgraphics(f1,'magnitude all box plots.pdf', 'Append', true)
        mean_magnitude.(win_names(w)).before(j,1) = mean(magnitude.(win_names(w)){j,1}, 'omitnan');
        mean_magnitude.(win_names(w)).after(j,1) = mean(magnitude.(win_names(w)){j,2}, 'omitnan');
        sem_magnitude.(win_names(w)).before(j,1) = std(magnitude.(win_names(w)){j,1}, [], 1, "omitnan")/sqrt(length((magnitude.(win_names(w)){j,1})));
        sem_magnitude.(win_names(w)).after(j,1) = std(magnitude.(win_names(w)){j,2}, [], 1, "omitnan")/sqrt(length((magnitude.(win_names(w)){j,1})));
    end
    f1 = figure;
    errorbar(flip(intensities), mean_magnitude.(win_names(w)).before, sem_magnitude.(win_names(w)).before, '-o')
    hold on
    errorbar(flip(intensities), mean_magnitude.(win_names(w)).after, sem_magnitude.(win_names(w)).after, '-o')
    title(win_names(w))
    legend(times)
    savefig(f1, ['mean_magnitude_' win_names{w}])
    mean_magnitude.(win_names(w)) = struct2table(mean_magnitude.(win_names(w)));
    sem_magnitude.(win_names(w)) = struct2table(sem_magnitude.(win_names(w)));
end
mean_magnitude = struct2table(mean_magnitude);
sem_magnitude = struct2table(sem_magnitude);
close all
save("all_cells_magnitude", "magnitude")
save("mean_magnitude", "mean_magnitude")
save("sem_magnitude", "sem_magnitude")
cd ..
cd ..



