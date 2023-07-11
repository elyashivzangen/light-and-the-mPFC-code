import os
import gc
import pathlib
import scipy.io
import pandas as pd
import numpy as np
import datetime as dt
from ctypes import *
from .pypl2 import pypl2api, pypl2lib


def get_files_list(dir_path, files_type):
    files_list = []

    for f in os.listdir(dir_path):
        if f.endswith(files_type):
            files_list.append((os.path.join(dir_path, f)))
    return files_list


def create_matlab_with_nd_df(matlab_files):
    df = pd.DataFrame([{'matlab_filename': f, 
                        'ND': scipy.io.loadmat(f)['ND'][0][0], 
                        'matlab_time': scipy.io.loadmat(f)['startTime'][0]} for f in matlab_files])
    df['matlab_time'] = pd.to_datetime(df['matlab_time'].astype('str'), format='%b.%d,%Y %H:%M:%S')
    return df.sort_values(by=['matlab_time']).reset_index(drop=True)


def create_plexon_df(plexon_files):
    df = pd.DataFrame(plexon_files, columns=['plexon_filename'])
    
    for i, filename in enumerate(plexon_files):
        p = pypl2lib.PyPL2FileReader() # Create an instance of PyPL2FileReader.    
        handle = p.pl2_open_file(filename) # Verify that the file passed exists first, if it does open the file
        file_info = pypl2lib.PL2FileInfo() # Create instance of PL2FileInfo 
        res = p.pl2_get_file_info(handle, file_info)

        df.loc[df['plexon_filename'] == filename, 'plexon_time'] = (dt.time(file_info.m_CreatorDateTime.tm_hour, 
                                                                            file_info.m_CreatorDateTime.tm_min, 
                                                                            file_info.m_CreatorDateTime.tm_sec))
        
    return df.sort_values(by=['plexon_time']).reset_index(drop=True)


def create_intensity_df(filename):
    intensity_values_df = pd.read_csv(filename, header=0, index_col=0)
    return intensity_values_df


def extract_channels_data(filename, channels_num, channel_type): # TODO:: rename function
    flag = True
    print('extract_channels_data ---------------')
    for i in range(channels_num):
        channel_name = '{}{:02d}'.format(channel_type, i+1)
        print(filename)
        adfrequency, n, timestamps, fragmentcounts, ad = pypl2api.pl2_ad(filename, channel_name)
        if flag:
            channels_ad = np.empty([channels_num, n])
            flag = False
        channels_ad[i] = ad
    channels_ad = np.multiply(channels_ad, 1000000) #convert volts to microvolts
    channels_ad = np.int16(channels_ad)
    return n, channels_ad, adfrequency


def extract_pl2_data_into_bin(plexon_files, files_df, output_file_path, channel_type, prefix=''):
    for f, i in zip(plexon_files, range(len(plexon_files))):
        n, channels_ad, adfrequency = extract_channels_data(f, 32, channel_type)
        files_df.loc[files_df.plexon_filename == f, 'plexon_samples_num'] = n
        files_df.loc[files_df.plexon_filename == f, 'ad_frequency'] = adfrequency
        channels_ad.ravel(order='F').tofile('{}/{}sequence_{}.bin'.format(output_file_path, prefix, i + 1))
        del channels_ad
    return files_df


def get_ts(filename, channel):
    n, timestamps, values = pypl2api.pl2_events(filename, channel) 
    return pd.Series(timestamps)


def create_ts_df(df, channel):
    ts_df = pd.DataFrame()
    ts_dict = {}
    for nd in df['ND']:
        files = df.loc[df['ND'] == nd, 'plexon_filename']
        # reformat duplicated nds
        for i, f in enumerate(files):
            ts_dict['{}_{}'.format(nd, i)] = get_ts(f, channel)
    return ts_df.from_dict(ts_dict)


def merge_bins_to_one_bin(files_path, num_of_files, prefix=''):
    output_file = '{}/sequence.bin'.format(files_path)
    for i in range(1, num_of_files):
        with open(output_file, 'ab') as out_file, open('{}/{}sequence_{}.bin'.format(files_path, prefix, i), 'rb') as in_file:
            out_file.write(in_file.read())
    return


def pl2kilosort(trial_type, intensities_number):
    # get files list
    parent_dir_path = pathlib.Path(__file__).parent.absolute()
    files_path = 'files/{}'.format(trial_type)
    full_files_path = os.path.join(parent_dir_path, files_path)
    matlab_files = get_files_list(full_files_path, '.mat')
    plexon_files = get_files_list(full_files_path, '.pl2')
    
    # create df with all the relevant data per file
    files_df = create_matlab_with_nd_df(matlab_files)
    plexon_files_df = create_plexon_df(plexon_files)
    files_df = pd.merge(files_df, plexon_files_df, left_index=True, right_index=True) # merge matlab and plexon dfs
    intensity_file_path = os.path.join(parent_dir_path, '{}_intensities.csv'.format(intensities_number))
    intensity_values_df = create_intensity_df(intensity_file_path)
    files_df = pd.merge(files_df, intensity_values_df, on='ND', how='left') # add intensities data to files_df
    
    # extract pl2 data into bin files and add number of samples per file to files_df
    files_df = extract_pl2_data_into_bin(files_df['plexon_filename'], files_df, full_files_path, 'WB')
    
    files_df = files_df.sort_values(by=['plexon_time']) # sort df according to time of trial
    # write the data to csv files
    files_df.to_csv('{}/files_extracted_data.csv'.format(full_files_path), sep=',', encoding='utf-8')
    # create dfs for on, off ts per event
    on_df = create_ts_df(files_df, 10)
    off_df = create_ts_df(files_df, 11)
    # combine the on, off ts per event to 1 df 
    combined_ts_df = pd.concat([on_df.add_suffix('_on'), off_df.add_suffix('_off')], axis=1, sort=False)
    # write the data to a csv file
    combined_ts_df.to_csv('{}/events_ts.csv'.format(full_files_path), sep=',', encoding='utf-8')
    
    # garbage collection
    gc.collect()
    
    # merge all bin files to 1 binary file (according to kilosort's requirements)
    merge_bins_to_one_bin(full_files_path, len(files_df) + 1)
    
    return