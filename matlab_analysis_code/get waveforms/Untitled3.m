from npyx import *

dp = 'C:\Users\elyashivz\Documents\code\electrophysiology\electrophysiology\analyze_electrophysiology_data\pl2kilosort\files\sequence\';

% load contents of .lf.meta and .ap.meta or .oebin files as python dictionnary.
% The metadata of the high and lowpass filtered files are in meta['highpass'] and meta['lowpass']
% Quite handy to get probe version, sampling frequency, recording length etc
meta = read_metadata(dp);

%% Load synchronization channel

from npyx.io import get_npix_sync % star import is sufficient, but I like explicit imports!

% If SpikeGLX: slow the first time, then super fast
onsets, offsets = get_npix_sync(dp);
% onsets/offsets are dictionnaries
% keys: ids of sync channel where a TTL was detected,
% values: times of up (onsets) or down (offsets) threshold crosses, in seconds.
%% Get good units from dataset
from npyx.gl import get_units
units = get_units(dp, quality='good');

%% Load spike times from unit u
from npyx.spk_t import trn
u=234;
t = trn(dp, u); % gets all spikes from unit 234, in samples

