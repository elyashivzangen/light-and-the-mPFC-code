from django import forms
from django.forms import ModelForm
from django.core.exceptions import ValidationError

from .models import Map


class MappingForm(ModelForm):
    probe_type = forms.CharField(
        max_length=30,
        widget=forms.Select(choices=Map.PROBE_TYPES),
        required=True,
    )
    probe_number = forms.IntegerField(min_value=1, required=True)
    probe_points_file = forms.FileField(widget=forms.ClearableFileInput(attrs={'multiple': False}), required=True)
    channel_positions_file = forms.FileField(widget=forms.ClearableFileInput(attrs={'multiple': False}), required=True)
    channel_map_file = forms.FileField(widget=forms.ClearableFileInput(attrs={'multiple': False}), required=True)
    cluster_info_file = forms.FileField(widget=forms.ClearableFileInput(attrs={'multiple': False}), required=True)
    borders_table_file = forms.FileField(widget=forms.ClearableFileInput(attrs={'multiple': False}), required=True)
    probe_data_file = forms.FileField(widget=forms.ClearableFileInput(attrs={'multiple': False}), required=True)
    
    class Meta:
        model = Map
        fields = '__all__'

    def clean_probe_points_file(self):
        data = self.cleaned_data['probe_points_file']

        if not data.name.endswith('.mat'):
            raise ValidationError('Invalid file type - needs to be a .mat file')

        return data
    
    def clean_channel_positions_file(self):
        data = self.cleaned_data['channel_positions_file']

        if not data.name.endswith('.npy'):
            raise ValidationError('Invalid file type - needs to be a .npy file')

        return data
        
    def clean_channel_map_file(self):
        data = self.cleaned_data['channel_map_file']

        if not data.name.endswith('.npy'):
            raise ValidationError('Invalid file type - needs to be a .npy file')

        return data
        
    def clean_cluster_info_file(self):
        data = self.cleaned_data['cluster_info_file']

        if not data.name.endswith('.tsv'):
            raise ValidationError('Invalid file type - needs to be a .tsv file')

        return data
    
    def borders_table_file(self):
        data = self.cleaned_data['borders_table_file']

        if not data.name.endswith('.csv'):
            raise ValidationError('Invalid file type - needs to be a .csv file')

        return data
    
    def probe_data_file(self):
        data = self.cleaned_data['probe_data_file']

        if not data.name.endswith('.csv'):
            raise ValidationError('Invalid file type - needs to be a .csv file')

        return data