from django import forms
from django.forms import ModelForm
from django.core.exceptions import ValidationError

from .models import Scene


class SceneForm(ModelForm):
    probes_number = forms.IntegerField(min_value=0, required=True)
    clusters_sets_number = forms.IntegerField(min_value=1, label = 'Cluster sets number (- How many sets of clusters)', required=True)
    probes_files = forms.FileField(widget=forms.ClearableFileInput(attrs={'multiple': True}), required=False)
    clusters_sets_files = forms.FileField(widget=forms.ClearableFileInput(attrs={'multiple': True}), required=True)
    scene_title = forms.CharField(required=True)
    brain_regions = forms.MultipleChoiceField( #TODO:: fix brain regions
        choices=Scene.BRAIN_REGIONS,
        required=True,
    )
    
    class Meta:
        model = Scene
        fields = '__all__'

    def clean_probes_files(self):
        data = self.cleaned_data['probes_files']
        
        if data is None:
            return data

        if not data.name.endswith('.csv'):
            raise ValidationError('Invalid file type - needs to be a .csv file')

        return data
    
    def clean_clusters_sets_files(self):
        data = self.cleaned_data['clusters_sets_files']

        if not data.name.endswith('.csv'):
            raise ValidationError('Invalid file type - needs to be a .csv file')

        return data
            