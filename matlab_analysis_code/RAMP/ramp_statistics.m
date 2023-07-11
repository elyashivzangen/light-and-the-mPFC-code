%% ramp statistics
clear
clc
ploting = 1 ;
norm  = 1;
ploting2 =1;
%%
[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%%
%laod ramp intensites
load('C:\Users\elyashivz\Dropbox\מחקר\Data for final project\RAMP\ramp_intensties_120_sec.mat') %loadramp intensity

all_ramp_data = [];
for i = 1:length(datafile)
    load(datafile{1,i});
    if iscell(all_data)
        all_data = all_data{1,1};
    end
    ramps = struct2cell(structfun(@(x) x.ramp.mean,all_data, "UniformOutput",false));
    %ramps.total = num2cell(ramps.total,2);
    cells = fieldnames(all_data);
    expname = repmat(file(i), length(cells),1);
    cluster = structfun(@(x) x.cluster,all_data, "UniformOutput",true);
    is_responsive = struct2cell(structfun(@(x) x.Is_reponsive,all_data, "UniformOutput",false));
    is_responsive_and_ir = struct2cell(structfun(@(x) x.Is_reponsive_and_IR,all_data, "UniformOutput",false));
    cells_data = table(expname, cells, cluster, is_responsive, is_responsive_and_ir, ramps);
    
    all_ramp_data = [cells_data;all_ramp_data];
end
%%

% norm_Ramps FRnorm = [FR − min(FR)]/[max(FR) − min(FR)].
FRnorm = @(FR) FR - mean(FR(1:10));

binned_both_ramp = [];
res_type = [];
norm_ramp = [];
log10_fr_ratio =[];
r2 = [];
for i = 1:length(all_ramp_data.expname)
    norm_ramp(i, :) = FRnorm(all_ramp_data.ramps{i});
    up_ramp(i,:) = norm_ramp(i, 1:60);
    down_ramp(i,:) = norm_ramp(i, 120:-1:61);
    both_ramp(i,:) = mean([up_ramp(i,:); down_ramp(i,:)], 1);
    binned_both_ramp(i,:) = mean(reshape(both_ramp(i,1:60), [],10), 1);
    %log10_fr_ratio(i,1) = log10(binned_both_ramp(i, end)/binned_both_ramp(i, 1));
    if binned_both_ramp(i,end) < 0
        res_type(i,1) = 0; %supprressed
    else
        res_type(i,1) = 1; %excite
    end
    [fitobject,gof] = fit(ramp_int(1:60)',both_ramp(i,:)','poly1');
    r2(i,:) = gof.rsquare;
    linfit{i} = fitobject;
end
ramp_only =   table(norm_ramp, up_ramp, down_ramp, both_ramp, binned_both_ramp, res_type, r2);
G1 = groupsummary(ramp_only,"res_type","mean")
    figure
    plot(G1.mean_both_ramp')
    figure
    plot(G1.mean_norm_ramp')
    figure
    bar(G1.mean_r2)
    %%
 [R2hist, edges]  = histcounts(r2, 20, Normalization="probability" );
 figure
 plot(edges(1:end-1),R2hist)
    

    % [N,edges] = histcounts(log10_fr_ratio, 20, 'Normalization', 'probability');
% plot(edges(1:eGnd-1),smooth(N))
