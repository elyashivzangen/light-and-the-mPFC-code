from django.contrib import admin

from .models import Analysis


class AnalysisAdmin(admin.ModelAdmin):
    pass

admin.site.register(Analysis, AnalysisAdmin)