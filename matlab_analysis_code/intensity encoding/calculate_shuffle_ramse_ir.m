function all_data = calculate_shuffle_ramse_ir(all_data)
%calculate new correct fit

windows = {40:50, 65:125, 140:150}; %windows for calculating the response time - on, sustaneid and off
%%
% Needs to be in D:\Data\IR data Shira_May_14_2022
%     all_data = all_data.all_data;
cells = fieldnames(all_data);
for j = 1:length(cells)
    current_cell = all_data.(cells{j});
    for n = 1:length(windows)%:length(windows) %%run the code for each window
        y = [];

        for k = 1:length(current_cell.intensities)

            if isempty( current_cell.intensities(k).intensty_data )
                continue
            end
            raster = current_cell.intensities(k).intensty_data;
            intensity_baseline = mean(raster(1:30, :), "all");
            y = [y ; mean(raster(windows{n}, :), "all") - intensity_baseline];
        end
        shift = abs(min(y)); %shift so Y will be max
        y = y + shift;
        x = [15.400000000000000;14.900000000000000;14.400000000000000;13.900000000000000;12.900000000000000;11.400000000000000;9.400000000000000];
        x = x(1:length(y));
        %% Fit original data

        fo = fitoptions('Method','NonlinearLeastSquares',...
            'Algorithm','Trust-Region',...
            'Display','final',...
            'TolFun',1.0E-20,...
            'TolX',1.0E-20,...
            'Lower',[-1,min(x),-5],...
            'Upper',[2*max(y),max(x),5],...
            'StartPoint',[max(y),mean(x),0]);

        ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
        [curve1,gof1]=fit(x,y,ft);

        original_curve=curve1;
        original_gof=gof1;
        original_rmse=gof1.rmse;
        original_n=curve1.n;



        if ploting1
            f1=figure;
            set(f1,'position',[200 200 400 400])
            set(f1, 'color', [1 1 1]);
            hold on;
            plot(x,y,'o');
            plot(curve1,'m');
            legend off
            title(['rmse = ',num2str(gof1.rmse),'   n = ',num2str(curve1.n)]);
            exportgraphics(f1,'reponsive_new_ir.pdf','Append',true)

            %                         subtitle(num2str(current_cell.pval_table(5, 3)))
        end

        %% Fit resampled data

        for s=1:100
            ys=y(randperm(length(y)));
            fo = fitoptions('Method','NonlinearLeastSquares',...
                'Algorithm','Trust-Region',...
                'Display','off',...
                'TolFun',1.0E-20,...
                'TolX',1.0E-20,...
                'Lower',[-1,min(x),-5],...
                'Upper',[2*max(y),max(x),5],...
                'StartPoint',[max(y),mean(x),0]);

            ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
            [curve1,gof1]=fit(x,ys,ft);

            shuffle_curves{s}=curve1;
            shuffle_gof{s}=gof1;
            shuffle_rmse(s)=gof1.rmse;
            shuffle_n(s)=curve1.n;

        end
        %% Determine if the cell is intensity encoding
        shuffle_rmse(find(shuffle_n>4.999))=max(shuffle_rmse);   % Set the rmse of all fits that reached the slope upper bound (2) to max(rmse).
        shuffle_rmse(find(shuffle_n<-4.999))=max(shuffle_rmse);   % Set the rmse of all fits that reached the slope lower bound (-2) to max(rmse).
        if  original_n>4.999 || original_n<-4.999
            original_rmse = max(shuffle_rmse);
        end

        P10=prctile(shuffle_rmse,10);    % calculate the 10 percentile of the distribution of shuffled rmse. Because half of the functions
        % fitted to the shuffled data are positive
        % and the other half are negative. The
        % 10th percentile actually corresponds to
        % the 5 percentile.

        if original_rmse<P10             % determine if the cell is intensity encoding (1) or not (0)
            isIntEncoding=1;
        else
            isIntEncoding=0;
        end

        %             all_data.(cells{j}).fit_windowns = windows;
        all_data.(cells{j}).new_fit3(n).y = y;
        all_data.(cells{j}).x = x;
        all_data.(cells{j}).new_fit3(n).original_curve = original_curve;
        all_data.(cells{j}).new_fit3(n).original_gof = original_gof;
        all_data.(cells{j}).new_fit3(n).shift = shift;
        all_data.(cells{j}).new_fit3(n).isIntEncoding = isIntEncoding;
        all_data.(cells{j}).new_fit3(n).original_rmse = original_rmse;
        all_data.(cells{j}).new_fit3(n).P10_mean = P10;
        all_data.(cells{j}).new_fit3(n).shuffle_rmse = shuffle_rmse;
    end
end



