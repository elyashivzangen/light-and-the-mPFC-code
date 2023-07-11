import os
import math
import glob
import pathlib
import librosa
import pandas as pd
import numpy as np
import matplotlib as mpl
from scipy import signal
from scipy import stats
from matplotlib import pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages


def get_clusters_type(filename):
    types_dict = {
        'noise': 0,
        'mua': 1,
        'good': 2,
        'unsorted': 3
    }
    clusters_df = pd.read_csv(filename, sep='\t', header=0)
    clusters_df['type'] = clusters_df['KSLabel'].apply(lambda x: types_dict[x])
    clusters_df['type'] = clusters_df.apply(lambda x: types_dict[x['group']] if not pd.isna(x['group']) else x['type'], axis=1)
    return clusters_df


def reforamt_nds(df):
    df['ND'] = ['{}_{}'.format(element, i) for i, element in enumerate(df['ND'])]
    return df


def get_relevant_clusters_spikes_data(relevant_clusters, spike_clusters, spikes_times):
    cluster_indexes = relevant_clusters.map(lambda x: np.where(np.in1d(spike_clusters, x))[0])
    spikes_times = cluster_indexes.map(lambda x: spikes_times[x].flatten())
    spikes_data_index = [['cluster_indexes', 'spikes_times'], relevant_clusters]
    spikes_data_df = pd.DataFrame(cluster_indexes.append(spikes_times).to_list())
    spikes_data_df.set_index(pd.MultiIndex.from_product(spikes_data_index), inplace=True)
    spikes_data_df = spikes_data_df.transpose()
    empty_clusters = spikes_data_df.columns[spikes_data_df.isna().all()].get_level_values(1).unique()
    spikes_data_df = spikes_data_df.dropna(axis=1, how='all')
    relevant_clusters = relevant_clusters.drop(empty_clusters)
    return relevant_clusters, spikes_data_df


def get_spike_times_by_nd(spikes_df, pl_data, result_df, Hz): # TODO:: improve function, now runs 16.5 sec
    idx = pd.IndexSlice
    left = 0
    for nd in pl_data['ND']:   
        right = pl_data.loc[pl_data['ND'] == nd, 'cumulative_plexon_samples_num'].item()
        result_df.loc[:, idx[:, nd]] = result_df.apply( 
            lambda x: spikes_df[spikes_df[x.name[0]].between(left, right)][x.name[0]].reset_index(drop=True) / Hz)
        left = right
    return result_df[: result_df.last_valid_index()]


def align_df_times(df, pl_data, Hz, index): #TODO:: rename index variable
    idx = pd.IndexSlice
    nds_to_align = pl_data['ND'][1:]
    for nd in nds_to_align:
        df.loc[:, idx[:, nd]] = df.loc[:, idx[:, nd]].apply(lambda x: x - pl_data.loc[pl_data.loc[pl_data['ND'] == nd].index - index, 'cumulative_plexon_samples_num'].item() / Hz)
    return df


def get_spikes_times_in_seconds(relevant_clusters, pl_data, spikes_df, Hz):
    cluster_nd_index = pd.MultiIndex.from_product([relevant_clusters, pl_data['ND']], names=['id', 'nd'])
    spikes_times_df = pd.DataFrame(np.nan, index=np.arange(0, len(spikes_df)), columns=cluster_nd_index)
    spikes_times_df = get_spike_times_by_nd(spikes_df, pl_data, spikes_times_df, Hz)
    spikes_times_df = align_df_times(spikes_times_df, pl_data, Hz, 1)
    return spikes_times_df


def get_spikes_between_times(spikes_df, start, end):
    return spikes_df[(spikes_df >= start) & (spikes_df <= end)].reset_index(drop=True)


def get_aligned_reps_times(events_df, result_df, pre=0, post=0):
    result_df = result_df.apply(lambda x: get_spikes_between_times(x, 
                                                                   (events_df['{}_on'.format(x.name[1])][x.name[2]] - pre), 
                                                                   (events_df['{}_off'.format(x.name[1])][x.name[2]] + post)))
    result_df = result_df.apply(lambda x: x - (events_df['{}_on'.format(x.name[1])][x.name[2]] - pre))
    return result_df


def split_by_chunks(df_to_split, split_chunks):
    splitted_df_list = []
    for chunk in split_chunks.split(';'):
        indices = chunk.split(',')
        indices_array = np.array(indices, dtype=np.int64)
        splitted_df_list.append(df_to_split.loc[indices_array])
    return splitted_df_list


def split_df_by_splitted_data(splitted_data, df_to_split, level=0):
    splitted_df_list = []
    for df in splitted_data:
        relevant_columns = df_to_split.columns[df_to_split.columns.get_level_values(level).str.startswith(tuple(df['ND']))]
        splitted_df_list.append(df_to_split[relevant_columns].dropna(how='all', axis=0))
    return splitted_df_list


def get_events_duration(events_ts_df, nds):
    for nd in nds:
        events_ts_df['{}_duration'.format(nd)] = events_ts_df['{}_off'.format(nd)] - events_ts_df['{}_on'.format(nd)]
    return events_ts_df


def get_mean_duration_per_nd(events_ts_df, nds):
    return {nd: events_ts_df['{}_duration'.format(nd)].mean() for nd in nds}


def get_histogram_parameters(histogram, histogram_df):
    histogram_df['values'] = histogram_df['values'].apply(lambda x: histogram.T[0][x.name[0]][x.name[1]][x.name[2]])
    histogram_df['edges'] = histogram_df['edges'].apply(lambda x: histogram.T[1][x.name[0]][x.name[1]][x.name[2]])
    histogram_df['histogram'] = histogram_df['histogram'].apply(lambda x: histogram.T[2][x.name[0]][x.name[1]][x.name[2]])
    histogram_df['values'] = histogram_df['values'].apply(lambda x: x.shift(1, fill_value=x[0])) # TODO:: why shift?
    histogram_df = histogram_df.dropna(how='all')
    return histogram_df


def interpolate_histogram_values(histogram_df, result_df, last_data_point, data_points_num):
    data_points = np.linspace(0, last_data_point, data_points_num)
    result_df = result_df.apply(lambda x: np.interp(data_points, 
                                                    histogram_df['edges'][x.name[0]][x.name[1]][x.name[2]], 
                                                    histogram_df['values'][x.name[0]][x.name[1]][x.name[2]]))
    # remove first and last second which doesn't interpolate well, now pre = 3 and post = 6
    relevant_indices = np.where((data_points > 1) & (data_points < last_data_point - 2))
    result_df = result_df.iloc[relevant_indices[0], :].reset_index(drop=True)
    data_points = data_points[relevant_indices]
    return result_df, data_points


def get_downsampled_histogram_df(events_ts_df, pl_data, spikes_reps_ms_df, relevant_clusters, length_of_trial, MS, 
                                 bin_length=1000):
    # create histogram for all repetitions 
    bins_vector = np.arange(0, length_of_trial + bin_length, step=bin_length)

    histogram = spikes_reps_ms_df.apply(plt.hist, bins=bins_vector, histtype='stepfilled') # create histograms
    # save histograms parameters
    hist_index = pd.MultiIndex.from_product([['values', 'edges', 'histogram'], relevant_clusters, pl_data['ND'], 
                                             np.arange(0, len(events_ts_df))], names=['hist', 'id', 'nd', 'rep'])
    histogram_df = pd.DataFrame(np.nan, index=np.arange(0, len(spikes_reps_ms_df + 1)), columns=hist_index)
    histogram_df = get_histogram_parameters(histogram, histogram_df)
    bins_per_sec = MS / bin_length
    histogram_values_df = histogram_df['values'] * bins_per_sec
    return histogram_values_df


def downsample_data(data_df, columns, new_samples_num):
    downsampled_data_df = data_df.apply(lambda x: signal.resample(np.array(x.dropna()), new_samples_num, np.array(x.dropna().index)))
    downsampled_index = downsampled_data_df.loc[1]
    downsampled_data = np.array(downsampled_data_df.loc[0])
    downsampled_data_df = pd.DataFrame(np.nan, index=downsampled_index, columns=np.arange(0, len(downsampled_data)))
    downsampled_data_df = downsampled_data_df.apply(lambda x: downsampled_data[x.name])
    downsampled_data_df.columns = columns
    return downsampled_data_df


def get_correlation(histogram_values_df, movement_reps_df):
    histogram_signal_len = len(histogram_values_df)
    movement_signal_len = len(movement_reps_df)
    
    correlation = correlation = histogram_values_df.apply(lambda x: stats.pearsonr(x.values, librosa.core.resample(
        movement_reps_df[x.name[1]][str(x.name[2])].values, orig_sr=movement_signal_len, target_sr=histogram_signal_len))) 
    correlation.index = ['corr_coef', 'p_value']

    return correlation.T


def apply_func_on_sub_df(df, result_df, result_col_name, indices, func):
    idx = pd.IndexSlice
    result_df = result_df.loc[:, idx[:, :, result_col_name]].apply(
        lambda x: getattr(df[x.name[0]][x.name[1]].iloc[indices].mean(axis=0), func.__name__)())
    return result_df


def calculate_statistics(hist_df, result_df, indices, mean_col, std_col, sem_col): # TODO:: rename function
    idx = pd.IndexSlice
    result_df.loc[0, idx[:, :, mean_col]] = apply_func_on_sub_df(hist_df, result_df, mean_col, indices, pd.DataFrame.mean)
    result_df.loc[0, idx[:, :, std_col]] = apply_func_on_sub_df(hist_df, result_df, std_col, indices, pd.DataFrame.std)
    result_df.loc[0, idx[:, :, sem_col]] = apply_func_on_sub_df(hist_df, result_df, sem_col, indices, pd.DataFrame.sem)
    return result_df


def calculate_psth_statistics(statistics_df, hist_df):
    idx = pd.IndexSlice
    statistics_df.loc[:, idx[:, :, 'mean_psth']] = statistics_df.loc[:, idx[:, :, 'mean_psth']].apply(
        lambda x: hist_df[x.name[0]][x.name[1]].mean(axis=1))
    statistics_df.loc[:, idx[:, :, 'std_psth']] = statistics_df.loc[:, idx[:, :, 'std_psth']].apply(
        lambda x: hist_df[x.name[0]][x.name[1]].std(axis=1))
    statistics_df.loc[:, idx[:, :, 'sem_psth']] = statistics_df.loc[:, idx[:, :, 'sem_psth']].apply(
        lambda x: hist_df[x.name[0]][x.name[1]].sem(axis=1))
    return statistics_df


def get_clusters_groups_from_multiindex_df(multiindex_df, curr_pl_data):
    stacked_df = multiindex_df.stack(['id', 'nd']).reset_index()
    stacked_df['int_nd'] = stacked_df['nd'].apply(lambda x: pd.to_numeric(x[: x.find('_')]))
    stacked_df = stacked_df.sort_values(['id', 'int_nd']).reset_index(drop=True)
    stacked_df = stacked_df.merge(curr_pl_data[['ND', 'intensity']], left_on = 'nd', right_on = 'ND', how = 'left')
    cluster_groups = stacked_df.groupby(['id'])
    return cluster_groups


def get_clusters_to_remove_according_to_baseline(clusters_groups, base_column):
    clusters_to_remove = []
    for (index, group) in clusters_groups:
        if group[base_column].max() <= 0.5:
            clusters_to_remove.append(index)
    return clusters_to_remove


def get_early_response_and_steady_state_and_off_indices(length, pre, post, early_response = 1.5, steady_state = 3, off = 2):
    early_response_indices = np.arange(pre * 5, (pre + early_response) * 5 - 1)
    steady_state_indices = np.arange(length - (post + steady_state) * 5 + 1, length - post * 5 + 1)
    off_indices = np.arange(length - post * 5 + 1, length - post * 5 + off * 5 + 1) # verify
    return early_response_indices, steady_state_indices, off_indices


def plot_shaded_error_bar(ax, x, y, error):
    if len(y) < len(x):
        x = x[: len(y)]
    ax.plot(x, y, '-')
    ax.fill_between(x, y - error, y + error, alpha=0.35)
    return


def set_plot_format(ax, key, xlabel, ylabel, legend_labels=None):
    ax.set_title('cluster id: {}'.format(key), fontsize=16)
    ax.set_xlabel(xlabel, fontsize=14)
    ax.set_ylabel(ylabel, fontsize=14)
    if legend_labels is not None:
        ax.legend(legend_labels, fontsize='large', loc='upper left', framealpha=0.3)
    return


def plot_vertical_lines(ax):
    xlim = ax.get_xlim()
    ylim = ax.get_ylim()
    ax.vlines(3, ylim[0], ylim[1], color='black', linestyles='dashed')
    ax.vlines(13, ylim[0], ylim[1], color='black', linestyles='dashed')
    return

def get_intensity(entity, field='intensity'):
    if isinstance(entity, pd.Series):
        return entity[field].unique()
    elif isinstance(entity, pd.DataFrame):
        return entity[field].unique()[0]
    else:
        return entity[field].T.drop_duplicates()


def plot(data_points, cluster_groups, base_cluster_groups, early_state_cluster_groups, steady_state_cluster_groups, off_cluster_groups, plots_filename, cols_num=5, rows_num=12):
    keys = list(cluster_groups.groups.keys())
    
    divided_list = [keys[x : x + rows_num] for x in range(0, len(keys), rows_num)]

    with PdfPages(plots_filename) as pdf:
        for l in divided_list:
            fig, axes = plt.subplots(figsize=((rows_num + 1) * 2, cols_num * 18), nrows=rows_num, ncols=cols_num, gridspec_kw=dict(hspace=0.4, wspace=0.3))
            for key, ax in zip(l, axes):
                group = cluster_groups.get_group(key)
                base_group = base_cluster_groups.get_group(key)
                early_state_group = early_state_cluster_groups.get_group(key)
                steady_state_group = steady_state_cluster_groups.get_group(key)
                off_group = off_cluster_groups.get_group(key)
                nd_groups = group.groupby(['nd'], sort=False)
                nd_groups.apply(lambda x: plot_shaded_error_bar(ax[0], data_points, x['mean_psth'], x['sem_psth']))
                intensities = nd_groups.apply(get_intensity)
                plot_vertical_lines(ax[0])
                set_plot_format(ax[0], key, 'Time(sec)', '$Firing\ rate(spikes\ sec^{-1})$', np.round(intensities, 1))
                ax[1].errorbar(intensities, early_state_group['mean'], early_state_group['sem'])
                set_plot_format(ax[1], key, 'Light intensity\n($log\ photons\ cm^{-2}\ s^{-1}$)', '$Light\ evoked\ early\ firing\ rate(spikes\ sec^{-1})$')
                ax[2].errorbar(intensities, steady_state_group['mean'], steady_state_group['sem'])
                set_plot_format(ax[2], key, 'Light intensity\n($log\ photons\ cm^{-2}\ s^{-1}$)', 'Light evoked steadystate \n$firing\ rate(spikes\ sec^{-1})$')
                ax[3].errorbar(intensities, off_group['mean'], off_group['sem'])
                set_plot_format(ax[3], key, 'Light intensity\n($log\ photons\ cm^{-2}\ s^{-1}$)', '$Light\ evoked\ off\ firing\ rate(spikes\ sec^{-1})$')
                ax[4].errorbar(intensities, base_group['mean_base'], base_group['sem_base'])
                set_plot_format(ax[4], key, 'Light intensity\n($log\ photons\ cm^{-2}\ s^{-1}$)', '$Baseline\ firing\ rate(spikes\ sec^{-1})$')
            pdf.savefig(fig, bbox_inches='tight')
    return

def load_list_of_files_to_one_df(working_directory, filename):
    # find relevant files
    all_files = glob.glob(r'{}\files\{}_*'.format(working_directory, filename)) 
    dfs_list = []
    
    # load all files to one dataframe
    for f in all_files:
        df = pd.read_csv(f, index_col=0, header=[0, 1, 2])
        dfs_list.append(df)
    full_df = pd.concat(dfs_list, axis=1).fillna(0)
    full_df = full_df.loc[:, ~full_df.columns.duplicated()] # remove duplicated columns 
    return full_df


def plot_mean_firing_rate(working_directory, df, nds, reps_num=3):
    # take reps_num first repetitions 
    reps = map(str, range(reps_num))
    partial_reps_df = df[df.columns[df.columns.get_level_values('rep').isin(reps)]]

    reps_mean_firing_rate = partial_reps_df.mean() # calculate mean for each repetition over time
    mean_firing_rate_df = reps_mean_firing_rate.groupby(level=[0, 1]).mean() # calculate mean for each nd
    mean_firing_rate_df = mean_firing_rate_df.unstack().fillna(0)
    mean_firing_rate_df.index = mean_firing_rate_df.index.astype('int64')
    mean_firing_rate_df = mean_firing_rate_df.sort_index()

    # plot each nd mean over sequences
    for nd in nds:
        nd_df = mean_firing_rate_df.filter(regex='{}_'.format(nd))
        nd_df.T.plot(subplots=True, layout=(math.ceil(len(nd_df) / 4), 4), figsize=(20, 50), sharex=False)
        plt.savefig(r'{}\files\mean_firing_rate_nd_{}.pdf'.format(working_directory, nd), bbox_inches='tight') # save plots
        plt.close()
    return


def psth(standardize, remove_low_baseline_clusters, trial_type, unit_type, length_of_trial, bin_length, split_chunks, remove_high_movement_correlation):
    working_directory = pathlib.Path(__file__).parent.absolute()
    directory = r'{}\files\{}'.format(working_directory, trial_type.lower()).replace('psth', 'pl2kilosort')
    idx = pd.IndexSlice
    pre = 3
    post = 6
    MS = 1000

    # load pl2kilosort, kilosort and phy output files
    clusters_df = get_clusters_type(os.path.join(directory, 'cluster_info.tsv'))
    clusters_df = clusters_df.set_index('id') if 'id' in clusters_df.columns else clusters_df.set_index('cluster_id')
    pl_data = pd.read_csv(os.path.join(directory, 'files_extracted_data.csv'), header=0, index_col=0)
    events_ts_df = pd.read_csv(os.path.join(directory, 'events_ts.csv'), header=0, index_col=0)
    spikes_times = np.load(os.path.join(directory, 'spike_times.npy'))
    spike_clusters = np.load(os.path.join(directory, 'spike_clusters.npy'))

    pl_data = pl_data.sort_values(by=['matlab_time']).reset_index(drop=True)
    for nd in pl_data['ND'].unique(): # reformat duplicated nds
        pl_data.loc[pl_data['ND'] == nd] = reforamt_nds(pl_data.loc[pl_data['ND'] == nd])
    pl_data['cumulative_plexon_samples_num'] = np.cumsum(pl_data['plexon_samples_num'])

    relevant_clusters = clusters_df.index[clusters_df['type'] == int(unit_type)]

    # get spikes times for the relevant clusters
    relevant_clusters, spikes_df = get_relevant_clusters_spikes_data(relevant_clusters, spike_clusters, spikes_times)
    spikes_df = get_spikes_times_in_seconds(relevant_clusters, pl_data, spikes_df['spikes_times'], pl_data['ad_frequency'][0])

    # get spikes times per repetition ( = 20)
    cluster_nd_rep_index = pd.MultiIndex.from_product([relevant_clusters, pl_data['ND'], np.arange(0, len(events_ts_df))], 
                                                      names=['id', 'nd', 'rep'])
    spikes_reps_times_df = pd.DataFrame(np.nan, index=np.arange(0, len(spikes_df)), columns=cluster_nd_rep_index)
    spikes_reps_times_df = spikes_reps_times_df.apply(lambda x: spikes_df.loc[:, idx[x.name[0], x.name[1]]].values)
    spikes_reps_times_df = get_aligned_reps_times(events_ts_df, spikes_reps_times_df, pre + 1, post + 1)
    
    # split events_ts_df and spikes_reps_times_df according to suffix
    pl_data['original_nd'] = pl_data['ND'].apply(lambda x: x.rsplit('_', 1)[0])
    pl_data['duplicate'] = pl_data[['original_nd']].duplicated()
    splitted_pl_data = split_by_chunks(pl_data.copy(), split_chunks)
    splitted_events_ts = split_df_by_splitted_data(splitted_pl_data, events_ts_df)
    splitted_spikes_reps_times = split_df_by_splitted_data(splitted_pl_data, spikes_reps_times_df, 1)


    for i, (curr_events_ts_df, curr_spikes_reps_times_df, curr_pl_data) in enumerate(zip(splitted_events_ts, splitted_spikes_reps_times, splitted_pl_data)):
        # calculate mean duration of a repetition
        curr_events_ts_df = get_events_duration(curr_events_ts_df, curr_pl_data['ND'])
        nd_mean_duration = get_mean_duration_per_nd(curr_events_ts_df, curr_pl_data['ND'])
        general_mean_duration = np.array(list(nd_mean_duration.values())).mean()

        # create histogram for all repetitions 
        bins_vector = np.arange(0, length_of_trial + bin_length, step=bin_length)

        curr_spikes_reps_ms_df = (curr_spikes_reps_times_df * MS).fillna(-1)

        histogram = curr_spikes_reps_ms_df.apply(plt.hist, bins=bins_vector, histtype='stepfilled') # create histograms
        # save histograms parameters
        hist_index = pd.MultiIndex.from_product([['values', 'edges', 'histogram'], relevant_clusters, curr_pl_data['ND'], 
                                                 np.arange(0, len(curr_events_ts_df))], names=['hist', 'id', 'nd', 'rep'])
        histogram_df = pd.DataFrame(np.nan, index=np.arange(0, len(curr_spikes_reps_times_df + 1)), columns=hist_index)
        histogram_df = get_histogram_parameters(histogram, histogram_df)
        bins_per_sec = MS / bin_length
        histogram_values_df = histogram_df['values'] * bins_per_sec

        three_sec = int((pre * MS) / bin_length)

        # if all nds are equal use the original data (without normalization)
        if len(pd.unique(curr_pl_data['original_nd'])) == 1:
            standardize = False

        # standardize the data
        if standardize: 
            aligned_hist_df = histogram_values_df - histogram_values_df[0 : three_sec].mean(axis=0) 
        else:
            aligned_hist_df = histogram_values_df
            
        if remove_high_movement_correlation:
            movement_frequency = 1000
            downsampled_histogram_values_df = get_downsampled_histogram_df(curr_events_ts_df, curr_pl_data, 
                                                                           curr_spikes_reps_ms_df, relevant_clusters, 
                                                                           length_of_trial, MS, movement_frequency)
            full_path = r'{}\files'.format(working_directory)  
            movement_reps_df = pd.read_csv(os.path.join(full_path.replace('psth', 'movement'), 'movement_yaw_data.csv'), header=[0, 1], index_col=0)
            new_samples_num = int(len(movement_reps_df) / movement_frequency)
            downsampled_movement_df = downsample_data(movement_reps_df, movement_reps_df.columns, new_samples_num)
            correlation = get_correlation(downsampled_histogram_values_df, downsampled_movement_df)

            indices_to_remove = correlation.loc[correlation['p_value'] < 0.05].index
            high_correlation_precentage = pd.DataFrame([len(correlation.loc[correlation['corr_coef'] >= 0.5]), 
                                                        len(correlation.loc[correlation['corr_coef'] <= -0.5]),
                                                        len(correlation.loc[abs(correlation['corr_coef']) >= 0.5]),
                                                        len(indices_to_remove),
                                                        len(histogram_values_df.T.index), 
                                                        len(indices_to_remove) / len(histogram_values_df.T.index)],
                                                       ['high_positive_correlation',
                                                        'high_negative_correlation',
                                                        'total_high_correlation',
                                                        'significant_p_value',
                                                        'total',
                                                        'significant_p_value_precentage'])
            high_correlation_precentage.to_csv(r'{}\files\high_correlation_precentage.csv'.format(working_directory), sep=',', encoding='utf-8')
            correlation.to_csv(r'{}\files\correlations.csv'.format(working_directory), sep=',', encoding='utf-8')
            histogram_values_df = histogram_values_df.drop(indices_to_remove, axis=1, inplace=False)
            aligned_hist_df = aligned_hist_df.drop(indices_to_remove, axis=1, inplace=False)

        # calculate base and psth statistics
        psth_statistics_index = pd.MultiIndex.from_product([relevant_clusters, curr_pl_data['ND'], ['mean_base', 'std_base', 'sem_base', 'mean_psth', 'std_psth', 'sem_psth']], names=['id', 'nd', 'stats'])
        statistics_df = pd.DataFrame(np.nan, index=np.arange(0, len(aligned_hist_df)), columns=psth_statistics_index)
        statistics_df = calculate_statistics(histogram_values_df, statistics_df, np.arange(0, three_sec), 'mean_base', 'std_base', 'sem_base')
        statistics_df = statistics_df.fillna(method='ffill')
        statistics_df = calculate_psth_statistics(statistics_df, aligned_hist_df)

        # calculate and remove clusters with baseline max response <= 0.5
        base_cluster_groups = get_clusters_groups_from_multiindex_df(statistics_df.loc[:, idx[:, :, ['mean_base', 'sem_base']]].head(1), curr_pl_data)
        if remove_low_baseline_clusters:
            clusters_to_remove = get_clusters_to_remove_according_to_baseline(base_cluster_groups, 'mean_base')
            relevant_clusters = list(set(relevant_clusters) - set(clusters_to_remove))
            statistics_df = statistics_df.drop(columns=clusters_to_remove)
            aligned_hist_df = aligned_hist_df.drop(columns=clusters_to_remove)
            histogram_values_df = histogram_values_df.drop(columns=clusters_to_remove)

        # save aligned histogram data to csv file
        aligned_hist_df.to_csv(r'{}\files\aligned_histogram_data_{}.csv'.format(working_directory, i), sep=',', encoding='utf-8')
        histogram_values_df.to_csv(r'{}\files\histogram_data_{}.csv'.format(working_directory, i), sep=',', encoding='utf-8')

        # calculate early state, steady state and off statistics
        early_response_indices, steady_state_indices, off_indices = get_early_response_and_steady_state_and_off_indices(len(aligned_hist_df), pre, post, 1.5, 3, 2)

        statistics_index = pd.MultiIndex.from_product([relevant_clusters, curr_pl_data['ND'], ['mean', 'std', 'sem']], names=['id', 'nd', 'stats'])
        early_state_df = pd.DataFrame(np.nan, index=[0], columns=statistics_index)
        steady_state_df = pd.DataFrame(np.nan, index=[0], columns=statistics_index)
        off_df = pd.DataFrame(np.nan, index=[0], columns=statistics_index)
        early_state_df = calculate_statistics(aligned_hist_df, early_state_df, early_response_indices, 'mean', 'std', 'sem')
        steady_state_df = calculate_statistics(aligned_hist_df, steady_state_df, steady_state_indices, 'mean', 'std', 'sem')
        off_df = calculate_statistics(aligned_hist_df, off_df, off_indices, 'mean', 'std', 'sem')

        # save early state, steady state and off statistics to files
        early_state_df.to_csv(r'{}\files\early_state_response_{}.csv'.format(working_directory, i), sep=',', encoding='utf-8')
        steady_state_df.to_csv(r'{}\files\steady_state_response_{}.csv'.format(working_directory, i), sep=',', encoding='utf-8')
        off_df.to_csv(r'{}\files\off_response_{}.csv'.format(working_directory, i), sep=',', encoding='utf-8')

        # fix the data structure in order to plot it
        cluster_groups = get_clusters_groups_from_multiindex_df(statistics_df.loc[:, idx[:, :, ['mean_psth', 'sem_psth']]], curr_pl_data)
        early_state_cluster_groups = get_clusters_groups_from_multiindex_df(early_state_df.loc[:, idx[:, :, ['mean', 'sem']]], curr_pl_data)
        steady_state_cluster_groups = get_clusters_groups_from_multiindex_df(steady_state_df.loc[:, idx[:, :, ['mean', 'sem']]], curr_pl_data)
        off_cluster_groups = get_clusters_groups_from_multiindex_df(off_df.loc[:, idx[:, :, ['mean', 'sem']]], curr_pl_data)
        # plot base, psth, early state and steady state
        plots_filename = r'{}\files\plots_{}.pdf'.format(working_directory, i)
        plot(bins_vector / MS, cluster_groups, base_cluster_groups, early_state_cluster_groups, steady_state_cluster_groups, off_cluster_groups, plots_filename)
        os.startfile(plots_filename) # open plots in a new window


        # create cluster df in order to classify the clusters
        clusters_df = pd.DataFrame(0, index=relevant_clusters, columns=['cluster_response_type'])

        # create classification menu
        response_types = ['Transient ON', 'Transient ON and transient OFF', 'Sustained ON', 'Delayed ON', 'Sustained OFF', 'Transient ON not intensity encoding']
        response_type_df = pd.DataFrame(response_types, columns=['response_type'])
        response_type_df.index = response_type_df.index + 1

        # write each dataframe to a different worksheet
        xlsx_filename = r'{}\files\clusters_summary_{}.xlsx'.format(working_directory, i)
        with pd.ExcelWriter(xlsx_filename) as writer:  
            response_type_df.to_excel(writer, sheet_name='response_types')
            clusters_df.to_excel(writer, sheet_name='clusters_response_type')
            statistics_df.loc[:, idx[:, :, ['mean_psth']]].to_excel(writer, sheet_name='mean_psth')
            early_state_df.loc[:, idx[:, :, ['mean']]].to_excel(writer, sheet_name='early_state_mean')
            steady_state_df.loc[:, idx[:, :, ['mean']]].to_excel(writer, sheet_name='steady_state_mean')
            off_df.loc[:, idx[:, :, ['mean']]].to_excel(writer, sheet_name='off_mean')
            writer.save()

    # plot mean firing rate for each nd over all sequences
    interpolated_histogram_data_df = load_list_of_files_to_one_df(working_directory, 'histogram_data')
    plot_mean_firing_rate(working_directory, interpolated_histogram_data_df, pl_data['original_nd'].unique())

    # return message to be displayed on the psth webpage
    return ('Please classify the clusters in the {} file'.format(xlsx_filename))
