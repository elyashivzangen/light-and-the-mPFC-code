from django.shortcuts import render
from django.contrib import messages
from django.views.generic.edit import FormView
from django.core.exceptions import ValidationError

from .forms import PsthAnalysisForm
from .models import Analysis
from .psth_analysis import psth


class IndexView(FormView):
    model = Analysis
    form_class = PsthAnalysisForm
    template_name = 'psth/index.html'
    success_url = 'psth/index.html'
    
    def post(self, request, *args, **kwargs):
        form_class = self.get_form_class()
        form = self.get_form(form_class)
        
        if form.is_valid():
            standardize = True if form.cleaned_data['standardize'] else False
            remove_low_baseline_clusters = True if form.cleaned_data['remove_low_baseline_clusters'] else False
            remove_high_movement_correlation = True if form.cleaned_data['remove_high_movement_correlation'] else False
            trial_type = request.POST['trial_type']
            unit_type = form.cleaned_data['unit_type']
            length_of_trial = int(request.POST['length_of_trial'])
            bin_length = int(request.POST['bin_length'])
            split_chunks = request.POST['split_chunks']
            message = psth(standardize, remove_low_baseline_clusters, trial_type, unit_type, length_of_trial, bin_length, split_chunks, remove_high_movement_correlation)
            messages.add_message(request, messages.SUCCESS, 'Completed successfully')
            messages.add_message(request, messages.INFO, message)
        else:
            form.add_error(None, 'Something went wrong')
            return super().form_invalid(form)
            
        return render(request, self.success_url, {'form': form})