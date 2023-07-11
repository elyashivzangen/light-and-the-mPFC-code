from django import forms
from django.forms import ModelForm
from django.core.exceptions import ValidationError

from .models import Trial


class Pl2KilosortForm(ModelForm):
    trial_type = forms.CharField(
        max_length=15,
        widget=forms.Select(choices=Trial.TYPES),
        required=True,
    )
    intensities_number = forms.CharField(
        max_length=10,
        widget=forms.Select(choices=Trial.INTENSITIES_NUMBER),
        required=True,
    )
    matlab_files = forms.FileField(widget=forms.ClearableFileInput(attrs={'multiple': True}), required=True)
    plexon_files = forms.FileField(widget=forms.ClearableFileInput(attrs={'multiple': True}), required=True)
    
    class Meta:
        model = Trial
        fields = '__all__'

    def clean_matlab_files(self):
        data = self.cleaned_data['matlab_files']

        if not data.name.endswith('.mat'):
            raise ValidationError('Invalid file type - needs to be a .mat file')

        return data
    
    def clean_plexon_files(self):
        data = self.cleaned_data['plexon_files']
    
        if not data.name.endswith('.pl2'):
            raise ValidationError('Invalid file type - needs to be a .pl2 file')

        return data