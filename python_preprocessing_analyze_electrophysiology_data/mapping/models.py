import os

from django.db import models


def get_upload_path(instance, filename):
    return '/'.join(filter(None, ('mapping/files', filename)))

class Map(models.Model):
    PROBE_TYPES = [ 
        ('neuronexus_a1_32_poly2', 'Neuronexus_A1_32_Poly2'),
        ('cambridge_h7b', 'Cambridge_H7b'),
    ]
    
    probe_type = models.CharField(max_length=50, choices=PROBE_TYPES)
    probe_number = models.IntegerField(blank=False, null=True)
    probe_points_file = models.FileField(upload_to=get_upload_path, blank=False, null=True)
    channel_positions_file = models.FileField(upload_to=get_upload_path, blank=False, null=True)
    channel_map_file = models.FileField(upload_to=get_upload_path, blank=False, null=True)
    cluster_info_file = models.FileField(upload_to=get_upload_path, blank=True, null=True)
    borders_table_file = models.FileField(upload_to=get_upload_path, blank=True, null=True)
    probe_data_file = models.FileField(upload_to=get_upload_path, blank=True, null=True)