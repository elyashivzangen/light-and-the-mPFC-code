import os
import pandas as pd

from django.db import models
from django.conf import settings


def get_brain_regions_from_atlas(atlas_filename='brain_render/allen_mouse_25um_v1_2_structures.csv'):
    brain_regions = pd.read_csv(atlas_filename, header=0, index_col=1)
    brain_regions = brain_regions[['acronym', 'name']]
    brain_regions_list = list(brain_regions.itertuples(index=False, name=None))
    return brain_regions_list

def get_upload_path(instance, filename):
    return '/'.join(filter(None, ('brain_render/files', filename)))

class Scene(models.Model):
    BRAIN_REGIONS = get_brain_regions_from_atlas()
    
    probes_number = models.IntegerField(blank=False, null=True)
    clusters_sets_number = models.IntegerField(blank=False, null=True)
    probes_files = models.FileField(upload_to=get_upload_path, blank=False, null=True)
    clusters_sets_files = models.FileField(upload_to=get_upload_path, blank=False, null=True)
    scene_title = models.CharField(max_length=1000, blank=False, null=True)
    brain_regions = models.ManyToManyField('self')
 