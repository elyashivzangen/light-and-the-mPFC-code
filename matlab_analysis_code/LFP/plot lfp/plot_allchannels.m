%% plot_LFP from all channels LFPs
clc
clear
load("E:\PFC\LFP\all_locations\all_chennels_each_eria.mat")

plot_example_lfp = 0;
%% 
fields = fieldnames(all_channels_LFPs);
for i = 1:length(fields)
    figure
    T = all_channels_LFPs.(fields{i});
    for w = 1:size(T,1)
        for j = 1:size(T,2)
            T2(w, j,:) =  T{w, j};
        end
        T3(w,:) = squeeze(mean(T2(w, j,:),1));
        subplot(7,1,w)
        plot(T3(w,:))
    end
    plot(T3)

    

  
    if plot_example_lfp
    for j = 80:100

        figure
        subplot(4,1,1)
        plot(-3:0.001:16, T{:, j}(1, :))
        hold on
        xline(0)
        xline(10)
        title(channels{j})

        subplot(4,1,2)
        plot(-3:0.001:16, T{:, j}(2, :))
        hold on
        xline(0)
        xline(10)
        title(channels{j})

        subplot(4,1,3)
        plot(-3:0.001:16, T{:, j}(3, :))
        hold on
        xline(0)
        xline(10)
        title(channels{j})

        subplot(4,1,4)
        plot(-3:0.001:16, T{:, j}(4, :))
        hold on
        xline(0)
        xline(10)
        title(channels{j})
    end


    end
end

