from django.contrib import admin

from .models import Trial


class TrialAdmin(admin.ModelAdmin):
    pass

admin.site.register(Trial, TrialAdmin)