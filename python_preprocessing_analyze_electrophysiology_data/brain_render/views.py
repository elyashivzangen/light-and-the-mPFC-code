from django.shortcuts import render
from django.contrib import messages
from django.views.generic.edit import FormView
from django.core.exceptions import ValidationError

from .forms import SceneForm
from .models import Scene
from .brain_render_scenes import build_scene


class IndexView(FormView):
    model = Scene
    form_class = SceneForm
    template_name = 'brain_render/index.html'
    success_url = 'brain_render/index.html'      

    def post(self, request, *args, **kwargs):
        form_class = self.get_form_class()
        form = self.get_form(form_class)         
        probes_files = request.FILES.getlist('probes_files') if 'probes_files' in request.FILES else request.POST['probes_files']
        clusters_sets_files = request.FILES.getlist('clusters_sets_files')
        probes_number = int(request.POST['probes_number'])
        clusters_sets_number = int(request.POST['clusters_sets_number'])
        
        form = validate_num_of_files(form, probes_number, probes_files, 'probes_files')
        form = validate_num_of_files(form, clusters_sets_number, clusters_sets_files, 'clusters_sets_files')
            
        if form.is_valid():
            scene_title = request.POST['scene_title']
            brain_regions = request.POST.getlist('brain_regions')
            
            [Scene(clusters_sets_files=f).save() for f in clusters_sets_files]
            
            clusters_sets_files_names = [f.name for f in clusters_sets_files]
            if not '' == probes_files:
                [Scene(probes_files=f).save() for f in probes_files]
                probes_files_names = [f.name for f in probes_files]
                message = build_scene(probes_number, clusters_sets_number, probes_files_names, clusters_sets_files_names, scene_title, brain_regions)
            else:
                message = build_scene(probes_number, clusters_sets_number, None, clusters_sets_files_names, scene_title, brain_regions)
            messages.add_message(request, messages.SUCCESS, 'Completed successfully')
            messages.add_message(request, messages.INFO, message)
        else:
            form.add_error(None, 'Something went wrong')
            return super().form_invalid(form)
            
        return render(request, self.success_url, {'form': form})
    

def validate_num_of_files(form, num, files_list, field):
    if not len(files_list) == num:
        form.add_error(field, 'Invalid files number - needs to to equal {} number: {}'.format(field, num))
        return form
    return form  
