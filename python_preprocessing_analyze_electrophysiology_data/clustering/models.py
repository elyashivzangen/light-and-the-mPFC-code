import os

from django.db import models
from django.conf import settings


def get_upload_path(instance, filename):
    return '/'.join(filter(None, ('clustering/files', filename)))

class Cluster(models.Model):
    DATA_TYPES = [ 
        ('pca', 'PCA'),
    ]
    
    ALGORITHM_TYPES = [ 
        ('gmm', 'Gaussian Mixture'),
    ]
    
    data_type = models.CharField(max_length=15, choices=DATA_TYPES)        
    algorithm_type = models.CharField(max_length=50, choices=ALGORITHM_TYPES) 
    nd = models.IntegerField(blank=False, null=True)
    histogram_data_files = models.FileField(upload_to=get_upload_path, blank=False, null=True)
    clusters_coordinates_files = models.FileField(upload_to=get_upload_path, blank=False, null=True)
    clustering_data_file = models.FileField(upload_to=get_upload_path, blank=False, null=True)