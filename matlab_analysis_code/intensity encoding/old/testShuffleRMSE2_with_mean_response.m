clear
clc
windows = {40:50, 65:125, 140:150}; %windows for calculating the response time - on, sustaneid and off
ploting = 0;
%%
% Needs to be in D:\Data\IR data Shira_May_14_2022

[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
for i = 1:length(datafile)
    load(datafile{1,i});
    %     all_data = all_data.all_data;
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        current_cell = all_data.(cells{j});
        for n = 1:length(windows) %%run the code for each window
            y = [];
            for k = 1:length(current_cell.intensities)
                if isempty( current_cell.intensities(k).intensty_data )
                    continue
                end
                raster = current_cell.intensities(k).intensty_data;
                intensity_baseline = mean(raster(1:30, :), "all");
                y = [y ; mean(raster(windows{n}, :), "all") - intensity_baseline];
            end
            x = [15.400000000000000;14.900000000000000;14.400000000000000;13.900000000000000;12.900000000000000;11.400000000000000;9.400000000000000];
            %         x = x';
            shift = abs(min(y)); %shift so Y will be max
            y = y + shift;
            %x = flip(x);
            %% Fit original data

            fo = fitoptions('Method','NonlinearLeastSquares',...
                'Algorithm','Trust-Region',...
                'Display','final',...
                'TolFun',1.0E-20,...
                'TolX',1.0E-20,...
                'Lower',[-1,min(x),-2],...
                'Upper',[2*max(y),max(x),2],...
                'StartPoint',[max(y),mean(x),0]);

            ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
            [curve1,gof1]=fit(x,y,ft);

            original_curve=curve1;
            original_gof=gof1;
            original_rmse=gof1.rmse;
            original_n=curve1.n;
            
                

            if ploting
                        f1=figure;
                        set(f1,'position',[200 200 800 300])
                        set(f1, 'color', [1 1 1]);
                        subplot(1,2,1);
                        hold on;
                        plot(x,y,'o');
                        plot(curve1,'m');
                        legend off
                        title(['rmse = ',num2str(gof1.rmse),'   n = ',num2str(curve1.n)]);
            end

            %% Fit resampled data

            for s=1:100
                ys=y(randperm(length(y)));
                fo = fitoptions('Method','NonlinearLeastSquares',...
                    'Algorithm','Trust-Region',...
                    'Display','off',...
                    'TolFun',1.0E-20,...
                    'TolX',1.0E-20,...
                    'Lower',[-1,min(x),-2],...
                    'Upper',[2*max(y),max(x),2],...
                    'StartPoint',[max(y),mean(x),0]);

                ft = fittype('Rmax*10^(n*x)/(10^(n*x)+10^(n*logK))','options',fo);
                [curve1,gof1]=fit(x,ys,ft);

                shuffle_curves{s}=curve1;
                shuffle_gof{s}=gof1;
                shuffle_rmse(s)=gof1.rmse;
                shuffle_n(s)=curve1.n;

            end

            %% Determine if the cell is intensity encoding
            shuffle_rmse(find(shuffle_n>1.999))=max(shuffle_rmse);   % Set the rmse of all fits that reached the slope upper bound (2) to max(rmse).
            shuffle_rmse(find(shuffle_n<-1.999))=max(shuffle_rmse);   % Set the rmse of all fits that reached the slope lower bound (-2) to max(rmse).
            if  original_n>1.999 || original_n<-1.999
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
            
            all_data.(cells{j}).fit_windowns = windows;
            all_data.(cells{j}).new_fit(n).y = y;
            all_data.(cells{j}).x = x;
            all_data.(cells{j}).new_fit(n).original_curve = original_curve;
            all_data.(cells{j}).new_fit(n).original_gof = original_gof;     
            all_data.(cells{j}).new_fit(n).shift = shift;
            all_data.(cells{j}).new_fit(n).isIntEncoding = isIntEncoding;
            all_data.(cells{j}).new_fit(n).original_rmse = original_rmse;
            all_data.(cells{j}).new_fit(n).P10_mean = P10;
            all_data.(cells{j}).new_fit(n).shuffle_rmse = shuffle_rmse;
        end
    end
    save(datafile{1,i}, 'all_data')
end

% %% plot
%
% subplot(1,2,2);
% hold on;
% hold on;
% histogram(shuffle_rmse,10);
% plot([P10 P10],[0 50],'-k');
% plot([original_rmse original_rmse],[0 50],'-m','LineWidth',2);
% legend off
% title(['rmse 5th percentile = ',num2str(P10),'   original rmse = ',num2str(original_rmse)]);
%
