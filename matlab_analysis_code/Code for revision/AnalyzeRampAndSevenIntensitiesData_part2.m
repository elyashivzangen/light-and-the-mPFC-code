
% plot ramp data

clear all;
close all;
cd 'D:\Papers and future research plans\paper_Light-sensitive brain networks\Data\Ramp_Nov_23_2022\Ramp revision';
load('ramp and seven intensities data per cluster.mat');

%% Process data

ramp_int(91:120)=[];
ramp_int(1:30)=[];

% reorder data according to the order of clusters presented in the paper
% cluster #1 ON-OFF, cluster #2 ON suppressed, cluster #3 ON enhanced.
ramp_mean=flipud(ramp_mean);
ramp_sem=flipud(ramp_sem);

% remove the first and last 30 sec, when the light stimulus flickers. This leaves 60 sec (only intensities higher than 13.47)
ramp_mean(:,91:120)=[];
ramp_mean(:,1:30)=[];
ramp_sem(:,91:120)=[];
ramp_sem(:,1:30)=[];

ramp_mean(:,end)=[];
ramp_sem(:,end)=[];

for j=1:4
    ramp_meanS(j,:)=smooth(ramp_mean(j,:),5);     % smooth mean data
    ramp_meanS(j,:)=ramp_meanS(j,:)-repmat(min(ramp_mean(j,:)),1,length(ramp_meanS(j,:)));     % normalize ramp_meanS
    ramp_mean(j,:)=ramp_mean(j,:)-repmat(min(ramp_mean(j,:)),1,length(ramp_mean(j,:)));     % normalize ramp_meanS
end


%% Plot original and smoothed data per cluster
f1=figure;
set(f1, 'color', [1 1 1]);
set(f1,'position',[50 0 1300 300]);

c=[1 0 0;0.3010 0.7450 0.9330;1 0 1;0 1 0];   % create colors
for i=1:4
    subplot(1,4,i);
    hold on;

    p1=shadedErrorBarColor(1:length(ramp_mean),ramp_mean(i,:),ramp_sem(i,:),'lineprops',{'-','Color',[c(i,1),c(i,2),c(i,3)]},'patchSaturation',0.3,'transparent',1);
    p2=plot(1:length(ramp_mean),ramp_mean(i,:),'LineWidth',0.5,'Color',[c(i,1),c(i,2),c(i,3)]);
    p3=plot(1:length(ramp_meanS),ramp_meanS(i,:),'LineWidth',2,'Color',[c(i,1),c(i,2),c(i,3)]);

    %ylim([-12 5]);
    xlim([0 61]);
    xticks([0,30,60,90,120]);
    set(gca,'fontsize', 16);
    xlabel('Time (sec)','FontSize',16);
    ylabel('Firing rate (spikes/sec)','FontSize',16);
    box off
    ax = gca;
    ax.FontSize=16;
end


%% find max or min point for data and data2

f2=figure;
set(f2,'position',[200 200 1000 240])
set(f2, 'color', [1 1 1]);

for i=1:4
    
if mean(ramp_meanS(i,1:10))<mean(ramp_meanS(i,20:40))
    [M(i),I(i)]=max(ramp_meanS(i,20:40));
    I(i)=I(i)+19;
else
    [M(i),I(i)]=min(ramp_meanS(i,20:40));
    I(i)=I(i)+19;
end

I1(i)=30;    % in the middle

y1plot{i}=ramp_meanS(i,1:I(i));
y2plot{i}=ramp_meanS(i,I(i):end);
miny1plot{i}=min(y1plot{i});
miny2plot{i}=min(y2plot{i});
y1plot{i}=y1plot{i}-repmat(miny1plot{i},1,length(y1plot{i}));
y2plot{i}=y2plot{i}-repmat(miny2plot{i},1,length(y2plot{i}));
x1plot{i}=ramp_int(1:I(i));

ygap{i}=ramp_meanS(i,I1(i)+1:I(i)-1);
minygap{i}=min(ygap{i});
%ygap{i}=ygap{i}-repmat(miny1plot{i},1,length(ygap{i}));
xgap{i}=ramp_int(1,I1(i)+1:I(i)-1);

y1{i}=ramp_meanS(i,1:I1(i));
miny1{i}=min(y1{i});
%y1{i}=y1{i}-repmat(miny1{i},1,length(y1{i}));
x1{i}=ramp_int(1:I1(i));
y2{i}=ramp_meanS(i,I(i):end);
miny2{i}=min(y2{i});
%y2{i}=y2{i}-repmat(miny2{i},1,length(y2{i}));
x2{i}=ramp_int(I(i):end);

subplot(1,4,i);
hold on;
plot(x1{i},y1{i},'color','g','LineWidth',2);
plot(x2{i},y2{i},'color',[0 0.4470 0.7410],'LineWidth',2);
%plot(xgap{i},ygap{i},'color',[1.00,0.41,0.16],'LineWidth',2);
legend off
%xlabel({'Light intensity';'(log photons cm^-^2 s^-^1)'}','FontSize',16);
set(gca,'FontSize',20);
xlim([13.3 15.7]);
xticks([13.5,14.5,15.5]);
xticklabels({'13.5','14.5','15.5'});


% if i==1
%     ylabel('Firing rate (spikes/sec)','FontSize',18);
%     legend({'ascending','descending'});
%     legend box off
% end


% Find response threshold
% try
% resp=1;
% tmp1=x1{i}(find(y1{i}>resp));
% thres1(i)=tmp1(1)
% 
% tmp2=x2{i}(find(y2{i}>resp));
% thres2(i)=tmp2(1)
% end

end

%tightfig

% figure
% lengthX2=length(x2{i});
% x1{i}=x1{i}(1:lengthX2);
% y1{i}=y1{i}(1:lengthX2);
% plot([y1{i};y2{i}],x1{i},'-o');

%% Fit original data
for c=1:4   % clusters
for i=1:2
    
    if i==1
        x=x1{c};
        y=y1{c};
    elseif i==2
        x=x2{c};
        y=y2{c};
    end


fo = fitoptions('Method','NonlinearLeastSquares',...
    'Algorithm','Trust-Region',...
    'Display','final',...
    'TolFun',1.0E-20,...
    'TolX',1.0E-20,...
    'Lower',[-1,min(x),-10],...
    'Upper',[2*max(y),max(x),10],...
    'StartPoint',[max(y),mean(x),0]);

ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
[curve1{c},gof1{c}]=fit(x',y',ft);

original_curve{i,c}=curve1{c};
original_gof{i,c}=gof1{c};
original_rmse(i,c)=gof1{c}.rmse;
original_n(i,c)=curve1{c}.n;

f3=figure;
set(f3,'position',[200 200 800 400])
set(f3, 'color', [1 1 1]);
subplot(1,2,1);
hold on;
plot(x,y,'ok','LineWidth',2);
plot(original_curve{i,c},'m');
legend off
title(['rmse = ',num2str(gof1{c}.rmse),'   n = ',num2str(curve1{c}.n)]);
xlabel({'Light intensity';'(log photons cm^-^2 s^-^1)'}','FontSize',16);
ylabel('Firing rate (spikes/sec)','FontSize',16);
set(gca,'FontSize',16);


%% Fit resampled data

for s=1:100
    ys=y(randperm(length(y)));
    fo = fitoptions('Method','NonlinearLeastSquares',...
        'Algorithm','Trust-Region',...
        'Display','off',...
        'TolFun',1.0E-20,...
        'TolX',1.0E-20,...
        'Lower',[-1,min(x),-10],...
        'Upper',[2*max(y),max(x),10],...
        'StartPoint',[max(y),mean(x),0]);
    
    ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
    [curve2,gof2]=fit(x',ys',ft);
    
    shuffle_curves{i,s}=curve2;
    shuffle_gof{i,s}=gof2;
    shuffle_rmse(i,s)=gof2.rmse;
    shuffle_n(i,s)=curve2.n;
  
end


% temp only for example %%%%%%%%%%%%
%P10(i)=prctile(shuffle_rmse(i,:),5);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P10=prctile(shuffle_rmse(i,:),10);    % calculate the 10 percentile of the distribution of shuffled rmse. Because half of the functions
                                  % fitted to the shuffled data are positive
                                  % and the other half are negative. The
                                  % 10th percentile actually corresponds to
                                  % the 5 percentile.
                                 
if original_rmse(i,c)<P10             % determine if the cell is intensity encoding (1) or not (0)
    isIntEncoding(i,c)=1;
else
    isIntEncoding(i,c)=0;
end

%% plot

subplot(1,2,2);
hold on;
histogram(shuffle_rmse(i,:),10);
plot([P10 P10],[0 50],'-k','LineWidth',2);
plot([original_rmse(i,c) original_rmse(i,c)],[0 50],'-m','LineWidth',2);
legend off
title(['rmse 5th percentile = ',num2str(P10),'   original rmse = ',num2str(original_rmse(i,c))]);
xlabel('RMSE','FontSize',16);
ylabel('Number of iterations','FontSize',16);
set(gca,'FontSize',16);

end

%% Plot both up and down phases long (data)


x1p{c}=padarray(x1{c},[0 length(ramp_int)-length(x1{c})],nan,'post');
x2p{c}=padarray(x2{c},[0 length(ramp_int)-length(x2{c})],nan,'pre');
y1p{c}=padarray(y1{c},[0 length(ramp_int)-length(y1{c})],nan,'post');
y2p{c}=padarray(y2{c},[0 length(ramp_int)-length(y2{c})],nan,'pre');

x1pPlot{c}=padarray(x1plot{c},[0 length(ramp_int)-length(x1plot{c})],nan,'post');
y1pPlot{c}=padarray(y1plot{c},[0 length(ramp_int)-length(y1plot{c})],nan,'post');

xpgap{c}=padarray(xgap{c},[0 length(ramp_int)/2],nan,'both');
xpgap{c}(61:end)=[];
ypgap{c}=padarray(ygap{c},[0 length(ramp_int)/2],nan,'both');
ypgap{c}(61:end)=[];

for j=1:2
    
     if j==1
        x=x1p{c};
        y=y1p{c};
    elseif j==2
        x=x2p{c};
        y=y2p{c};
     end
    
Rmax=original_curve{j,c}.Rmax;
n=original_n(j,c);
logK=original_curve{j,c}.logK;
R{j,c}=min(ramp_meanS(c,:))+(Rmax*10.^(n.*x)./(10.^(n.*x)+10^(n*logK)));
end

f4=figure;
set(f4,'position',[200 200 400 400])
set(f4, 'color', [1 1 1]);
hold on;
plot([30 30],[0 6],'--k','LineWidth',0.5);
if c==2
    plot(1:60,R{1,c}+repmat(miny1plot{c},1,length(y1p{c})),'g','LineWidth',2);
    plot(1:60,R{2,c},'color',[0 0.4470 0.7410],'LineWidth',2);
elseif c==4
    plot(1:60,R{1,c}-0.15+repmat(miny1plot{c},1,length(y1p{c})),'g','LineWidth',2);
    plot(1:60,R{2,c},'color',[0 0.4470 0.7410],'LineWidth',2);
else
    plot(1:60,R{1,c}+repmat(miny1{c},1,length(y1p{c})),'g','LineWidth',2);
    plot(1:60,R{2,c}+repmat(miny2{c},1,length(y2p{c})),'color',[0 0.4470 0.7410],'LineWidth',2);
end
plot(1:60,y1pPlot{c}+repmat(miny1plot{c},1,length(y1pPlot{c})),'og','LineWidth',2);
plot(1:60,y2p{c}+repmat(miny2{c},1,length(y2p{c})),'o','color',[0 0.4470 0.7410],'LineWidth',2);

plot(1:60,ypgap{c}+repmat(miny1plot{c},1,length(ypgap{c})),'o','color',[1.00,0.41,0.16],'LineWidth',2);

%plot(1:60,ypgap{c}-repmat(miny2{c},1,length(ypgap{c})),'o','color',[1.00,0.41,0.16],'LineWidth',2);
xlim([1 60]);

legend off
xlabel('Time (sec)','FontSize',20);
ylabel('Firing rate (spikes/sec)','FontSize',20);
set(gca,'FontSize',16);


end

