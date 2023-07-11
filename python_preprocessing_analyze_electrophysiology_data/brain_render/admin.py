from django.contrib import admin

from .models import Scene


class SceneAdmin(admin.ModelAdmin):
    pass

admin.site.register(Scene, SceneAdmin)