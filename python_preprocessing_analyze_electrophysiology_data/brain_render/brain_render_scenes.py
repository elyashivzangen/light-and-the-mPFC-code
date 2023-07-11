import os
import pathlib
import numpy as np
import pandas as pd
from brainrender import Scene, Animation, settings
from brainrender.actors import Points
from brainrender._colors import get_random_colors
from vedo import embedWindow, Plotter, show
from brainrender.video import VideoMaker
from scipy.spatial.distance import pdist


def add_brain_regions_to_scene(scene, brain_regions):
    colors = get_random_colors(n_colors=len(brain_regions))
    for region, color in zip(brain_regions, colors):
        scene.add_brain_region(region, alpha=0.2, color=color)
    return scene


def add_probes_to_scene(scene, probes_number, probes_files, directory):
    if probes_files is None:
        return scene
    probes_colors = get_random_colors(n_colors=probes_number)
    for probe_file, probe_color in zip(probes_files, probes_colors):
        probe_file_full_path = os.path.join(directory, probe_file)   
        probe_coordinates = np.loadtxt(open(probe_file_full_path, 'r'), delimiter=',', skiprows=1, usecols=(3, 2, 1)) 
        brain_regions = pd.read_csv(probe_file_full_path, header=0, index_col=0, usecols=['id', 'region_acronym']).drop_duplicates() 
        scene.add(Points(probe_coordinates, name='probe', colors=probe_color)) # add to scene
        scene = add_brain_regions_to_scene(scene, brain_regions['region_acronym'].tolist()) # add relevant brain regions
    return scene


def add_clustering_sets_to_scene(scene, clusters_sets_files, directory):
    for clusters_file in clusters_sets_files:
        clusters_file_full_path = os.path.join(directory, clusters_file)
        clusters_df = pd.read_csv(clusters_file_full_path, header=0, index_col=0, usecols=['id', 'x', 'y', 'z', 'cluster'])
        cluster_groups = clusters_df.groupby(['cluster'])
        colors = get_random_colors(n_colors=len(cluster_groups))
        # Add to scene
        for (name, group), color in zip(cluster_groups, colors):
            clusters_coordinates = group[['z', 'y', 'x']].to_numpy()
            scene.add(Points(clusters_coordinates, name='cluster_{}'.format(name), colors=color))
    return scene


def add_clusters_to_scene(scene, clusters_sets_files, directory):
    for clusters_file in clusters_sets_files:
        clusters_file_full_path = os.path.join(directory, clusters_file)
        clusters_coordinates = np.loadtxt(open(clusters_file_full_path, 'r'), delimiter=',', skiprows=1, usecols=(3, 2, 1))    
        colors = get_random_colors(n_colors=len(clusters_coordinates))
        scene.add(Points(clusters_coordinates, name='clusters', colors=colors)) # add to scene
    return scene


def build_scene(probes_number, clusters_sets_number, probes_files, clusters_sets_files, scene_title, brain_regions):
    working_directory = pathlib.Path(__file__).parent.absolute()
    directory = r'{}\files'.format(working_directory)
    
    # check if we have clustering data or individual cells to plot
    clustering = list(filter(lambda x: 'clusters_coordinates' not in x, clusters_sets_files))
    cells = list(filter(lambda x: 'clusters_coordinates' in x, clusters_sets_files))

    # create scene
    scene = Scene(title=scene_title)

    # add probes, clusters, cells and brain regions to scene
    if probes_files is not None:
        scene = add_probes_to_scene(scene, probes_number, probes_files, directory)
    if not 0 == len(clustering):
        scene = add_clustering_sets_to_scene(scene, clusters_sets_files, directory)
    if not 0 == len(cells):
        scene = add_clusters_to_scene(scene, clusters_sets_files, directory)
    scene = add_brain_regions_to_scene(scene, brain_regions)
    

    # export scene
    return scene.export('{}/{}.html'.format(directory, scene_title))
