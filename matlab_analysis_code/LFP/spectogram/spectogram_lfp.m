[file, path] = uigetfile('all_areas_per_exp.mat','MultiSelect','off');
cd(path)
load(file)
mkdir("spect")
cd("spect")
%%
fs = 100;
t = 0:1/fs:20-1/fs;

earias = fieldnames(meanLFP);
for i = 1:length(earias)
    f1 = figure;
    f1.Position = [100, 100, 800, 800]

    for j = 1:7
        subplot(4,2,j)
        x = meanLFP.(earias{i}){1,j+1};
        resample_x = mean(reshape(x(1:19000),10, []),1);
        baseline = mean(resample_x(1, 1:300));
        resample_x = resample_x - baseline;
        spectrogram(resample_x,40,20,2000,fs, "power",'yaxis')
        title(earias{i})
        subtitle(['nd = ' num2str(8-j)])

    end
    savefig([earias{i} ' LFP_spectogram'])

end

