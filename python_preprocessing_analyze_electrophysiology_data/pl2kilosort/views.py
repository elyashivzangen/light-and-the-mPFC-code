from django.shortcuts import render
from django.contrib import messages
from django.views.generic.edit import FormView
from django.core.exceptions import ValidationError

from .forms import Pl2KilosortForm
from .models import Trial
from .pl2kilosort_code import pl2kilosort


class IndexView(FormView):
    model = Trial
    form_class = Pl2KilosortForm
    template_name = 'pl2kilosort/index.html'
    success_url = 'pl2kilosort/index.html'

    def post(self, request, *args, **kwargs):
        form_class = self.get_form_class()
        form = self.get_form(form_class) 
        matlab_files = request.FILES.getlist('matlab_files')
        plexon_files = request.FILES.getlist('plexon_files')
        
        if form.is_valid():
            trial_type = request.POST['trial_type']
            intensities_number = request.POST['intensities_number']
            [Trial(matlab_files=f, trial_type=trial_type).save() for f in matlab_files]
            [Trial(plexon_files=f, trial_type=trial_type).save() for f in plexon_files]
            pl2kilosort(trial_type, intensities_number)
            messages.add_message(request, messages.SUCCESS, 'Completed successfully')
        else:
            form.add_error(None, 'Something went wrong')
            return super().form_invalid(form)
            
        return render(request, self.success_url, {'form': form})