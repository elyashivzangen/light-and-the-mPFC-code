from django.db import models


class Analysis(models.Model):
    TRIAL_TYPES = [
        #('individual', 'Individual'), 
        ('sequence', 'Sequence'),
    ]
    UNIT_TYPES = [
        #('1', 'Multi Units'), 
        ('2', 'Single Units'),
    ]
    
    trial_type = models.CharField(max_length=15, choices=TRIAL_TYPES)
    unit_type = models.CharField(max_length=15, choices=UNIT_TYPES)
    standardize = models.BooleanField(default=True, null=True, blank=True)
    length_of_trial = models.IntegerField(blank=False, null=True)
    bin_length = models.IntegerField(blank=False, null=True)
    split_chunks = models.CharField(max_length=5000, blank=True, null=True)
    remove_low_baseline_clusters = models.BooleanField(default=True, null=True, blank=True)
    remove_high_movement_correlation = models.BooleanField(default=True, null=True, blank=True)