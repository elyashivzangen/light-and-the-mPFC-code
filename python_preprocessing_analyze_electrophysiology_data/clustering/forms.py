from django import forms
from django.forms import ModelForm
from django.core.exceptions import ValidationError

from .models import Cluster


class ClusteringForm(ModelForm):
    data_type = forms.CharField(
        max_length=15,
        widget=forms.Select(choices=Cluster.DATA_TYPES),
        required=True,
    )
    
    algorithm_type = forms.CharField(
        max_length=50,
        widget=forms.Select(choices=Cluster.ALGORITHM_TYPES),
        required=True,
    )
    nd = forms.IntegerField(initial=1, required=True)
    histogram_data_files = forms.FileField(widget=forms.ClearableFileInput(attrs={'multiple': True}), required=True)
    clusters_coordinates_files = forms.FileField(widget=forms.ClearableFileInput(attrs={'multiple': True}), required=True)
    clustering_data_file = forms.FileField(widget=forms.ClearableFileInput(attrs={'multiple': False}), required=False)
    
    class Meta:
        model = Cluster
        fields = '__all__'
        
    def clean_histogram_data_files(self):
        data = self.cleaned_data['histogram_data_files']

        if not data.name.endswith('.csv'):
            raise ValidationError('Invalid file type - needs to be a .csv file')

        return data
    
    def clean_clusters_coordinates_files(self):
        data = self.cleaned_data['clusters_coordinates_files']

        if not data.name.endswith('.csv'):
            raise ValidationError('Invalid file type - needs to be a .csv file')

        return data
    
    def clean_clustering_data_file(self):
        data = self.cleaned_data['clustering_data_file']

        if data is None:
            return data
        
        if not data.name.endswith('.csv'):
            raise ValidationError('Invalid file type - needs to be a .csv file')

        return data