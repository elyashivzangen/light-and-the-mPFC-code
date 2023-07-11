clear
clc
[file, path] = uigetfile('*.mat','MultiSelect','off');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
load(datafile)
close all
w = 2; %window to use (on, sustaneid, off)
%%
n = fieldnames(clusters.cluster_cells);
ints = clusters.cluster_cells.cluster_2{1,1}.x;

for i = 1:length(n)
    count = 0;
    for j = 1:length(clusters.cluster_cells.(n{i}))
        current_cell = clusters.cluster_cells.(n{i}){1, j};
        if ~isempty(current_cell)
            count = count + 1;
            IR{i}(count, :) = current_cell.new_fit3(w).y - current_cell.new_fit3(w).shift;
        end
    end
    mean_IR(i, :) = mean(IR{i} , 1);
    sem_IR(i, :) = std(IR{i}, [], 1)/sqrt(count);
end
save("clusters_ir.mat", "IR")
save("sem_IR", "sem_IR")
save("mean_IR", "mean_IR")

%% plot and calculate fit
f4 = figure;
set(f4,'color', [1 1 1]);
set(f4,'position',[50 50 1500 300]);

for i = 1:size(mean_IR, 1)
    subplot(1, 5, i)
    errorbar(ints, mean_IR(i,:), sem_IR(i,:),'o')
    title(["cluater " i])
end

%% Fit IR data
f4 = figure;
set(f4,'color', [1 1 1]);
set(f4,'position',[50 50 size(mean_IR, 1)*300 300]);
for i = 1:size(mean_IR, 1)
    x = ints;
    y = mean_IR(i, :)';
    shift(i) = abs(min(y)); %shift so Y will be max
    y = y + shift(i);

    fo = fitoptions('Method','NonlinearLeastSquares',...
        'Algorithm','Trust-Region',...
        'Display','final',...
        'TolFun',1.0E-20,...
        'TolX',1.0E-20,...
        'Lower',[-1,min(x),-10],...
        'Upper',[2*max(y),max(x),10],...
        'StartPoint',[max(y),mean(x),0]);

    ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
    [curve1,gof1]=fit(x,y,ft);


    %plot
    subplot(1, size(mean_IR, 1), i)

    original_curve=curve1;
    original_gof=gof1;
    original_rmse=gof1.rmse;
    original_n=curve1.n;
    hold on;
    errorbar(ints, mean_IR(i,:), sem_IR(i,:),'o');
    z = (x(end)-1):0.0001:(x(1)+1);
    curve2 = feval(curve1, z)- shift(i);
    plot(z, curve2,'m');
    legend off
    title(['rmse = ',num2str(gof1.rmse),'   n = ',num2str(curve1.n)]);
    savefig('ir_fit')
end
AIC_calculate