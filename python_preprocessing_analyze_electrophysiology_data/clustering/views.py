from django.shortcuts import render
from django.contrib import messages
from django.views.generic.edit import FormView
from django.core.exceptions import ValidationError

from .forms import ClusteringForm
from .models import Cluster
from .clustering_code import cluster_data


class IndexView(FormView):
    model = Cluster
    form_class = ClusteringForm
    template_name = 'clustering/index.html'
    success_url = 'clustering/index.html'

    def post(self, request, *args, **kwargs):
        form_class = self.get_form_class()
        form = self.get_form(form_class) 
        histogram_data_files = request.FILES.getlist('histogram_data_files')
        clusters_coordinates_files = request.FILES.getlist('clusters_coordinates_files')
        clustering_data_file = request.FILES['clustering_data_file'] if 'clustering_data_file' in request.FILES else request.POST['clustering_data_file']
        
        if form.is_valid():
            data_type = request.POST['data_type']
            algorithm_type = request.POST['algorithm_type']
            nd = request.POST['nd']
            [Cluster(histogram_data_files=f).save() for f in histogram_data_files]
            histogram_data_files_names = [f.name for f in histogram_data_files]
            [Cluster(clusters_coordinates_files=f).save() for f in clusters_coordinates_files]
            clusters_coordinates_files_names = [f.name for f in clusters_coordinates_files]
            if not '' == clustering_data_file:
                Cluster(clustering_data_file=clustering_data_file).save()
                cluster_data(data_type, algorithm_type, nd, histogram_data_files_names, clusters_coordinates_files_names, clustering_data_file.name)
            else:
                cluster_data(data_type, algorithm_type, nd, histogram_data_files_names, clusters_coordinates_files_names, None)
            messages.add_message(request, messages.SUCCESS, 'Completed successfully')
        else:
            form.add_error(None, 'Something went wrong')
            return super().form_invalid(form)
            
        return render(request, self.success_url, {'form': form})
    