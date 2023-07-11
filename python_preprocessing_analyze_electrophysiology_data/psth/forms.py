from django import forms
from django.forms import ModelForm

from .models import Analysis


class PsthAnalysisForm(ModelForm):
    trial_type = forms.CharField(
        max_length=15,
        widget=forms.Select(choices=Analysis.TRIAL_TYPES),
        required=True,
    )
    unit_type = forms.CharField(
        max_length=15,
        widget=forms.Select(choices=Analysis.UNIT_TYPES),
        required=True,
    )
    standardize = forms.BooleanField(initial=True, required=False)
    length_of_trial = forms.IntegerField(initial=20000, min_value=1, label='Trial length in ms', required=True)
    bin_length = forms.IntegerField(initial=100, min_value=1, label='Bin length in ms', required=True)
    remove_low_baseline_clusters = forms.BooleanField(initial=True, required=False)
    remove_high_movement_correlation = forms.BooleanField(initial=True, required=False)
    
    class Meta:
        model = Analysis
        fields = '__all__'