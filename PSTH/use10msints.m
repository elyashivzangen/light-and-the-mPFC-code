[file, path] = uigetfile('*.mat','MultiSelect','on');%When the user clicks the load psetion button, a window should open to enable the user to select a file.
cd(path)
datafile = fullfile(path, file); %save path
%%

for i = 1:length(datafile)
    load(datafile{i})
    cells = fieldnames(all_data);
    for j = 1:length(cells)
        c = all_data.(cells{j});
        ints = c.intensities;
        if length(c.bin10ms) > 7
            c.intensities = c.bin10ms(1:7);
        else
            c.intensities = c.bin10ms;
        end
        c.intensities_100ms = ints;
        all_data.(cells{j}) = c;
    end
    save(datafile{i}, 'all_data')
end