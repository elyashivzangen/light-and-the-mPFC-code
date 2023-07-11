import scipy.io
import numpy as np
import pandas as pd
from skspatial.objects import Line
from skspatial.objects import Points


def get_probe(probe_number, probe_coordinates):
    probe_df = pd.DataFrame(probe_coordinates['pointList'][0][0][0][probe_number - 1][0], columns=['ML', 'DV', 'AP'])
    probe_df = probe_df * 10 # convert pixels to micorns
    return probe_df


def get_probe_best_fit_line(probe_df):
    points = Points(probe_df.to_numpy())
    line_fit = Line.best_fit(points)
    return line_fit


def get_good_clusters_coordinates(clusters_df, channel_positions, channel_map):
    good_clusters_df = clusters_df.loc[(clusters_df['KSLabel'] == 'good') | (clusters_df['group'] == 'good'), ['ch', 'n_spikes']]
    probe_mapping_df = pd.DataFrame({'coordinates': list(map(tuple, channel_positions))}, index = channel_map.flatten())
    return good_clusters_df.join(probe_mapping_df, on='ch', how='left')


def get_point_coordinates_on_probe(probe_points, cluster, shrinkage_factor):
    point = probe_points.to_point(cluster['coordinates'][1] * shrinkage_factor) # get the relevant point on the probe
    point[0] = point[0] + cluster['coordinates'][0] # shift the point on the ML axis (according to the columns on the probe)
    return point


def is_value_in_range(range_df, value):
    return range_df['upperBorder'] <= value < range_df['lowerBorder']


def add_acronym(df, borders_table):
    for i, row in df.iterrows():
        region = borders_table[borders_table[['lowerBorder', 'upperBorder']].apply(is_value_in_range, value=row['DV'], axis=1)]
        df.at[i, 'region_name'] = region['name'].item() if not region.empty else ''
        df.at[i, 'region_acronym'] = region['acronym'].item() if not region.empty else ''
    return df


def analyze_coordinates(probe_type, probe_number, probe_points_file, channel_positions_file, channel_map_file, cluster_info_file, borders_table_file, probe_data_file):
    working_directory = pathlib.Path(__file__).parent.absolute()
    directory = r'{}\files'.format(working_directory)

    # load probes, channels, and clusters files
    probe_coordinates = scipy.io.loadmat(os.path.join(directory, probe_points_file))
    channel_positions = np.load(os.path.join(directory, channel_positions_file))
    channel_map = np.load(os.path.join(directory, channel_map_file))
    clusters_data_df = pd.read_csv(os.path.join(directory, cluster_info_file), sep="\t", header=0, index_col=0)
    
    # load SHARP-TRACK saved data
    borders_table = pd.read_csv(os.path.join(directory, borders_table_file), header=0, index_col=None)
    probe_data = pd.read_csv(os.path.join(directory, probe_data_file), header=0, index_col=None)
    
    # load configuration file matching the probe type
    config = yaml.safe_load(open(r'{}\configuration\{}_config.yml'.format(working_directory, probe_type)))

    # get the relevant probes data
    probe_df = get_probe(probe_number, probe_coordinates)
    probe_best_fit_line = get_probe_best_fit_line(probe_df[['ML', 'DV', 'AP']])

    # get only good clusters
    clusters_df = get_good_clusters_coordinates(clusters_data_df, channel_positions, channel_map)

    # calculate clusters DV (dorso-ventral), ML (medial-lateral), AP (anterior-posterior) loactions according to the probe paramteres
    clusters_points = clusters_df.apply(lambda x: get_point_coordinates_on_probe(probe_best_fit_line, x, probe_data['shrinkage_factor'].item()), axis=1)
    clusters_points_df = pd.DataFrame(clusters_points.values.tolist(), index=clusters_points.index, columns=['ML', 'DV', 'AP'])
    clusters_df = clusters_df.join(clusters_points_df, how='left')
    
    # add region to probe and clusters data
    probe_df = add_acronym(probe_df, borders_table)
    clusters_df = add_acronym(clusters_df, borders_table)

    # calculate probes registration points locations (from SHARP-TRACK) )in microns and rename columns to match brain_render demands
    probe_df.columns = ['x', 'y', 'z', 'region_name', 'region_acronym']
    fitted_probe_df = pd.DataFrame({'point': probe_best_fit_line.point, 'direction': probe_best_fit_line.direction})

    # calculate clusters locations in microns and rename columns to match brain_render demands
    clusters_coordinates_df = clusters_df[['ML', 'DV', 'AP', 'region_name', 'region_acronym']].copy()
    clusters_coordinates_df.columns = ['x', 'y', 'z', 'region_name', 'region_acronym']

    # save probe and clusters data to csv files (for brain-render use)
    fitted_probe_df.to_csv(r'{}\files\probe_fitted_line_{}.csv'.format(working_directory, probe_number), sep=',', encoding='utf-8')
    probe_df.to_csv(r'{}\files\sharp_track_probe_coordinates_{}.csv'.format(working_directory, probe_number), sep=',', encoding='utf-8', index_label='id')
    return
