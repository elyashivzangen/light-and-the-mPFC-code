
%load IRdata.mat
load IRdata_example.mat
d=intensity;    % intensity

for k=1:3
    
    switch k
        case 1
            dataset=earlyres;
        case 2
            dataset=steadyres;
        case 3
            dataset=OFFres;
    end
    
    
    for i=1:size(dataset,1)
        a=dataset(i,:);   % response
        shift=min(a);
        a=a-repmat(shift,1,size(a,2));         % normalize response to be non-negative
        
        y=a';
        x=d;
        
        fo = fitoptions('Method','NonlinearLeastSquares',...
            'Algorithm','Levenberg-Marquardt',...
            'Display','iter',...
            'TolFun',1.0E-20,...
            'TolX',1.0E-20,...
            'Lower',[-1,min(x),-5],...
            'Upper',[2*max(y),max(x),5],...
            'StartPoint',[max(y),mean(x),0]);
        
        ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
        [curve1,gof1]=fit(x,y,ft)
        
        switch k
            case 1
                earlyres_curves{i}=curve1;
                earlyres_gof{i}=gof1;
                earlyres_rsquare(i)=gof1.rsquare;
                earlyres_n(i)=curve1.n;
            case 2
                steadyres_curves{i}=curve1;
                steadyres_gof{i}=gof1;
                steadyres_rsquare(i)=gof1.rsquare;
                steadyres_n(i)=curve1.n;
            case 3
                OFFres_curves{i}=curve1;
                OFFres_gof{i}=gof1;
                OFFres_rsquare(i)=gof1.rsquare;
                OFFres_n(i)=curve1.n;
        end
        
        figure;
        hold on;
        plot(x,y,'o');
        plot(curve1,'m');
        title(['R^2 = ',num2str(gof1.rsquare),'n = ',num2str(curve1.n)]);
    end
end

%% extract relevant R^2 and place it r_clust %%% FOR PHb %%%
% cluster4==ON sustained, cluster2=OFF transient, cluster3=OFF sustained, clusters0,1,5=not defined
% for i=1:size(dataset,1)
%     if clust(i)==4
%         r_clust(i)=steadyres_rsquare(i);
%         n_clust(i)=steadyres_n(i);
%     elseif clust(i)==2
%         r_clust(i)=OFFres_rsquare(i);
%         n_clust(i)=OFFres_n(i);
%     elseif clust(i)==3
%         r_clust(i)=OFFres_rsquare(i);
%         n_clust(i)=OFFres_n(i);
%     elseif clust(i)==0
%         r_clust(i)=steadyres_rsquare(i);
%         n_clust(i)=steadyres_n(i);
%     elseif clust(i)==1
%         r_clust(i)=steadyres_rsquare(i);
%         n_clust(i)=steadyres_n(i);
%     elseif clust(i)==5        r_clust(i)=steadyres_rsquare(i);
%         n_clust(i)=steadyres_n(i);
%     end
% end


%% extract relevant R^2 and place it r_clust %%% FOR NAc %%%
% cluster0==steady, cluster1=early, cluster2=OFF, cluster3=OFF, cluster4=early,
%  cluster5=early
for i=1:size(dataset,1)
    if clust(i)==4
        r_clust(i)=steadyres_rsquare(i);
        n_clust(i)=steadyres_n(i);
    elseif clust(i)==2
        r_clust(i)=OFFres_rsquare(i);
        n_clust(i)=OFFres_n(i);
    elseif clust(i)==3
        r_clust(i)=OFFres_rsquare(i);
        n_clust(i)=OFFres_n(i);
    elseif clust(i)==0
        r_clust(i)=steadyres_rsquare(i);
        n_clust(i)=steadyres_n(i);
    elseif clust(i)==1
        r_clust(i)=steadyres_rsquare(i);
        n_clust(i)=steadyres_n(i);
    elseif clust(i)==5        
        r_clust(i)=steadyres_rsquare(i);
        n_clust(i)=steadyres_n(i);
    end
end

%% put in r_clust NaN where n-clust is 5 or -5 (reached the bounds)
for i=1:size(dataset,1)
    if abs(n_clust(i))>4.9
        r_clust(i)=nan;
    end
end

%% put in r_clust NaN where abs(n_clust) is smaller than 0.05 (represents fits with an unrealistic trend) 
%r_clust(abs(n_clust)<0.05)=nan;

%%  plot histograms of R^2 for each cluster

f1=figure;
set(f1,'color', [1 1 1]);
set(f1,'position',[50 50 500 500]);
hold on;

for i=1:max(clust)+1
    subplot(3,2,i)
    ind_clust{i}=find(clust==(i-1));
    r_clust_sep{i}=r_clust(ind_clust{i});
    n_clust_sep{i}=n_clust(ind_clust{i});
    histogram(r_clust_sep{i},10);
    title(['cluster ',num2str(i-1)]);
    ylim([0 15]);
    xlim([0 1]);
    xticks(0:0.2:1);
    box off;
end

%% plot mean +- SE R^2 per across clusters

f2=figure;
set(f2,'color', [1 1 1]);
set(f2,'position',[50 50 300 400]);
hold on;
for i=1:max(clust)+1
    errorbar(i,mean(r_clust_sep{i},'omitnan'),std(r_clust_sep{i},'omitnan')./sqrt(length(r_clust_sep{i}(~isnan(r_clust_sep{i})))),'or','LineWidth',3,'MarkerSize',10);
    xlim([0.5 6.5]);
    ylim([0 0.7]);
    set(gca,'FontSize',14);
    ylabel({'\itR^2'},'FontSize',16);
    xticks(1:1:6);
    yticks(0:0.1:0.7);
    xticklabels({'ON sustained','ON suppressed','OFF','ON-OFF','OFF transient','ON'}); % for NAc
    %xticklabels({'unresponsive','ON','OFF transient','OFF sustained','ON sustained','unresponsive'}); % for PHb
    xtickangle(45)
    box off
end



% f2=figure;
% set(f2,'color', [1 1 1]);
% set(f2,'position',[50 50 500 500]);
% hold on;
% for i=1:max(clust)+1
%     subplot(3,2,i)
%     ind_clust{i}=find(clust==(i-1));
%     scatter(n_clust_sep{i},r_clust_sep{i});
% end

