import os

from django.db import models
from django.conf import settings


def get_upload_path(instance, filename):
    return '/'.join(filter(None, ('pl2kilosort/files', instance.trial_type, filename)))

class Trial(models.Model):
    TYPES = [
        #('individual', 'Individual'), 
        ('sequence', 'Sequence'),
    ]
    
    INTENSITIES_NUMBER = [ 
        ('7', '7'),
        ('10', '10'),
    ]
    
    trial_type = models.CharField(max_length=15, choices=TYPES)
    intensities_number = models.CharField(max_length=10, choices=INTENSITIES_NUMBER)
    matlab_files = models.FileField(upload_to=get_upload_path, blank=False, null=True)
    plexon_files = models.FileField(upload_to=get_upload_path, blank=False, null=True)
    
    def __str__(self):
        return self.trial_type
        
 