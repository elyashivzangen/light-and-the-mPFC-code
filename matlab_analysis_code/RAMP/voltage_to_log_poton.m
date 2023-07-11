%% voltage to log/photons
trial_time = 120;
[file, path] = uigetfile('.xlsx',"MultiSelect","off");
datafile = fullfile(path, file); %save path
cd(path)
T = readtable(datafile);
load("interpulated_ramp_range.mat")
v = T.V; %voltage
l = T.QuantumCatch_logPhotonsCm_2S_1_; %log photons
int_index = 6001;
ramp = round(linspace(1, int_index, trial_time/2));
ramp = [ramp flip(ramp)];
ramp_voltage = vq(ramp);
ramp_int = interp1(v,l,ramp_voltage); %ramp intensity
save("ramp_intensties_120_sec", 'ramp_int')