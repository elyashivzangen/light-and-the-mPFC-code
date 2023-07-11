from django.contrib import admin

from .models import Cluster


class ClusterAdmin(admin.ModelAdmin):
    pass

admin.site.register(Cluster, ClusterAdmin)