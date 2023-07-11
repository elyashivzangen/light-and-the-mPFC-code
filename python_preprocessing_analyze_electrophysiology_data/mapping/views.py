from django.shortcuts import render
from django.contrib import messages
from django.views.generic.edit import FormView
from django.core.exceptions import ValidationError

from .forms import MappingForm
from .models import Map
from .analyze_coordinates import analyze_coordinates


class IndexView(FormView):
    model = Map
    form_class = MappingForm
    template_name = 'mapping/index.html'
    success_url = 'mapping/index.html'

    def post(self, request, *args, **kwargs):
        form_class = self.get_form_class()
        form = self.get_form(form_class)         
        probe_points_file = request.FILES['probe_points_file']
        channel_positions_file = request.FILES['channel_positions_file']
        channel_map_file = request.FILES['channel_map_file']
        cluster_info_file = request.FILES['cluster_info_file']
        borders_table_file = request.FILES['borders_table_file']
        probe_data_file = request.FILES['probe_data_file']
        
        if form.is_valid():
            probe_type = request.POST['probe_type']
            probe_number = int(request.POST['probe_number'])
            Map(probe_points_file=probe_points_file).save()
            Map(channel_positions_file=channel_positions_file).save()
            Map(channel_map_file=channel_map_file).save()
            Map(cluster_info_file=cluster_info_file).save()
            Map(borders_table_file=borders_table_file).save()
            Map(probe_data_file=probe_data_file).save()
            analyze_coordinates(probe_type, probe_number, probe_points_file.name, channel_positions_file.name, channel_map_file.name, cluster_info_file.name, borders_table_file.name, probe_data_file.name)
            messages.add_message(request, messages.SUCCESS, 'Completed successfully')
        else:
            form.add_error(None, 'Something went wrong')
            return super().form_invalid(form)
            
        return render(request, self.success_url, {'form': form})