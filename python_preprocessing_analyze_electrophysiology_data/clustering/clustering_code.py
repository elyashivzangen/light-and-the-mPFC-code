import os
import sys
import pathlib
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from sklearn.mixture import GaussianMixture
from sklearn.preprocessing import StandardScaler
from matplotlib.backends.backend_pdf import PdfPages

module_path = os.path.abspath(os.path.join('..'))
if module_path not in sys.path:
    sys.path.append(module_path)
    
from psth.psth_analysis import set_plot_format, plot_vertical_lines


def load_mean_data(directory, filename):
    if filename is not None:
        return pd.read_csv(os.path.join(directory, filename), header=0, index_col=0)
    return pd.DataFrame()


def get_intensity_data(data_df, nd):
    idx = pd.IndexSlice
    intensity_data = data_df.loc[:, idx[:, nd, :]]
    intensity_data.columns = intensity_data.columns.droplevel('nd')
    return intensity_data


def get_mean_data(data_df):
    clusters_ids = data_df.columns.get_level_values(0).unique()
    mean_df = pd.DataFrame(np.nan, index=np.arange(0, len(data_df)), columns=clusters_ids)
    mean_df = mean_df.apply(lambda x: data_df[x.name].mean(axis=1).reset_index(drop=True))
    mean_df.index = mean_df.index.map(str)
    return mean_df


def remove_suffix(string, suffix):
    if suffix and string.endswith(suffix):
        return string[: -len(suffix)]
    return string


def get_channels(histogram_file, clusters_coordinates_files, directory, histogram_file_suffix='aligned_interpolated_histogram_data.csv'):
    prefix = remove_suffix(histogram_file, histogram_file_suffix)
    clusters_coordinates_file = [x for x in clusters_coordinates_files if x.startswith(prefix)][0]
    clusters_channel_df = pd.read_csv(os.path.join(directory, clusters_coordinates_file), header=0, index_col=0)
    clusters_channel_df.index = clusters_channel_df.index.map(str)
    return clusters_channel_df[['x', 'y', 'z']]


def normalize(data_df):
    sc = StandardScaler()
    normalized_data = sc.fit_transform(data_df)
    return normalized_data


def get_components_and_score_by_percent(data, percent):
    pca = PCA()
    pca_data = pca.fit_transform(data)
    cumsum_explained_variance = pca.explained_variance_ratio_.cumsum()
    components_number = (np.abs(cumsum_explained_variance - percent)).argmin() + 1 # components that cover percent of the data
    return components_number, pca.components_[: components_number]


def get_weighted_data(data, components_number):
    pca = PCA(n_components=components_number)
    pca_data = pca.fit_transform(data)
    std_pca = np.std(pca_data)
    weighted_data = data * std_pca
    return weighted_data


def select_best(arr:list, X:int)->list:
    '''
    returns the set of X configurations with shorter distance
    '''
    dx=np.argsort(arr)[:X]
    return arr[dx]


def num_of_clusters_iteration(data, clusters_range, iterations = 50):
    bics = []
    bics_err = []

    for n in clusters_range:
        tmp_bic = []
        for _ in range(iterations):
            gmm = GaussianMixture(n, 
                                  n_init=3, 
                                  covariance_type='diag', 
                                  tol=1e-15,
                                  max_iter=1000,
                                  reg_covar=0.001,
                                  random_state=0
                                 ).fit(data) 
            tmp_bic.append(gmm.bic(data))

        val = np.mean(select_best(np.array(tmp_bic), int(iterations / 5)))
        err = np.std(tmp_bic)
        bics.append(val)
        bics_err.append(err)
    return bics, bics_err


def plot(x, y, y_err, err_label, title, x_label, y_label):
    plt.clf()
    plt.errorbar(x, y, yerr=y_err, label=err_label)
    plt.title(title, fontsize=20)
    plt.xticks(x)
    plt.xlabel(x_label)
    plt.ylabel(y_label)
    plt.legend()
    return 


def get_clusters_groups(data_df, clusters):
    clusters_df = data_df.copy()
    clusters_df['cluster'] = clusters
    cluster_groups = clusters_df.groupby(['cluster'])
    return cluster_groups


def get_data_points(rep_duration = 10, pre = 3, post = 6):
    bins_num = rep_duration + (pre + 1) + (post + 1) + 1
    data_points_num = bins_num * 5 - 1
    data_points = np.linspace(0, bins_num, data_points_num)
    data_points = data_points[np.where((data_points > 1) & (data_points < bins_num - 2))]
    aligned_data_points = np.subtract(data_points, 1)
    return aligned_data_points


# TODO:: take under consideration the data and algorithm type
def cluster_data(data_type, algorithm_type, nd, histogram_data_files, clusters_coordinates_files, clustering_data_file): 
    working_directory = pathlib.Path(__file__).parent.absolute()
    directory = r'{}\files'.format(working_directory)

    mean_df = load_mean_data(directory, clustering_data_file) # load the mean responses from previous runs

    # get the histogram data from all the files
    for file in histogram_data_files:
        data_df = pd.read_csv(os.path.join(directory, file), header=[0, 1, 2], index_col=0)
        intensity_data = get_intensity_data(data_df, nd) # take only the relevant intensity
        clusters_channel_df = get_channels(file, clusters_coordinates_files, directory) # get cluster's channels
        mean_data_df = get_mean_data(intensity_data).T # get the mean responses data
        mean_data_df = mean_data_df.join(clusters_channel_df, how='inner') # add the channels data
        mean_df = mean_data_df if mean_df.empty else mean_df.append(mean_data_df) # add the new mean responses to the existing ones

    normalized_data = normalize(mean_df.drop(columns=['x', 'y', 'z']).T) if clustering_data_file is None else normalize(mean_df.drop(columns=['x', 'y', 'z', 'cluster']).T) # normalize the mean responses data
    partial_normalized_data = normalize(mean_df.drop(columns=['x', 'y', 'z']).T[10 : -10]) if clustering_data_file is None else normalize(mean_df.drop(columns=['x', 'y', 'z', 'cluster']).T[10 : -10]) # perform pca and clustering with out the 2 first and last seconds
    normalized_df = pd.DataFrame(normalized_data.T, index=mean_df.index)

    # PCA
    components_number, data_after_pca = get_components_and_score_by_percent(partial_normalized_data, 0.95)
    weighted_data = get_weighted_data(data_after_pca, components_number)

    # iterate over a range to find num of clusters
    n_clusters = np.arange(2, 10)
    bics, bics_err = num_of_clusters_iteration(weighted_data.T, n_clusters) 
    
    # calculate measurements to find num of clusters after iterations
    gradients = np.gradient(bics)
    aligned_bic = bics - min(bics)
    exp_aligned_bic = np.exp(-0.5 * aligned_bic)
    weighted_aligned_bic = exp_aligned_bic / sum(exp_aligned_bic)
    
    max_slope_index = np.argmax(abs(gradients[:-1] - gradients[1:]))
    min_bic_index = np.argmin(bics)
    max_weighted_aligned_bic_index = np.argmax(weighted_aligned_bic)

    pdf_filename = PdfPages(r'{}\measurements_plots.pdf'.format(directory))
    plot(n_clusters, bics, bics_err, 'BIC', 'BIC Scores', 'N. of clusters', 'Score')
    pdf_filename.savefig(plt.gcf())
    plot(n_clusters, gradients, bics_err, 'BIC', 'Gradient of BIC Scores', 'N. of clusters', 'Grad(BIC)')
    pdf_filename.savefig(plt.gcf())
    plot(np.arange(0, len(weighted_aligned_bic)), weighted_aligned_bic, bics_err, 'BIC', 'Best Evidence BIC', 'N. of clusters', 'Estimate(BIC)')
    pdf_filename.savefig(plt.gcf())  
    pdf_filename.close()

    num_of_clusters = n_clusters[max_slope_index]
    
    # Gaussian Mixture - clustering
    gmm = GaussianMixture(n_components=num_of_clusters, 
                          n_init=3,
                          covariance_type='diag', 
                          tol=1e-15,
                          max_iter=1000,
                          reg_covar=0.001,
                          random_state=0)
    fitted = gmm.fit(weighted_data.T)
    labels = fitted.predict(weighted_data.T)
    
    mean_df['cluster'] = labels
    mean_df.to_csv(r'{}\clustering_data.csv'.format(directory), sep=',', encoding='utf-8') # save updated data to file

    clusters_groups = get_clusters_groups(normalized_df, labels)
    clusters_mean_df = clusters_groups.mean()
    clusters_sem_df = clusters_groups.sem().fillna(0)
    groups_sizes = clusters_groups.size()
    data_points = get_data_points()

    # plot clusters mean response
    rows_num = num_of_clusters
    cols_num = 1
    fig, axes = plt.subplots(figsize=((rows_num + 1), cols_num * 18), nrows=rows_num, ncols=cols_num, gridspec_kw=dict(hspace=0.7, wspace=0.3))

    for (index, row), ax in zip(clusters_mean_df.iterrows(), axes):
        ax.set_ylim(row.min() - 1, row.max() + 1)
        plot_vertical_lines(ax)
        ax.errorbar(data_points, row, clusters_sem_df.T[index])
        set_plot_format(ax, index, 'Time(sec)', '$Firing\ rate(spikes\ sec^{-1})$')
        ax.set_title('cluster id: {} size: {}'.format(index, groups_sizes[index]))
    plots_filename = r'{}\clusters_mean_response_plots.pdf'.format(directory)
    plt.savefig(plots_filename, bbox_inches='tight') # save plots

    # plot all cell responses per cluster
    fig, axes = plt.subplots(figsize=((rows_num + 1), cols_num * 20), nrows=rows_num, ncols=cols_num, gridspec_kw=dict(hspace=0.4, wspace=0.3))

    for (key, group), ax in zip(clusters_groups, axes.flatten()):
        ax.set_ylim(group.min().min() - 1, group.max().max() + 1)
        plot_vertical_lines(ax)
        group = group.drop(columns=['cluster'])
        group.columns = data_points
        group.T.plot(ax=ax, title='Cluster: {} Size: {}'.format(key, groups_sizes[key]))
        ax.legend(fontsize='medium', loc='upper left', framealpha=0.3)
    plots_filename = r'{}\clusters_responses_plots.pdf'.format(directory)
    plt.savefig(plots_filename, bbox_inches='tight') # save plots
    
    return