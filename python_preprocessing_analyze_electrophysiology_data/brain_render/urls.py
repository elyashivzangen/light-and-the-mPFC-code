from django.urls import path

from . import views

app_name = 'brain_render'
urlpatterns = [
    path('', views.IndexView.as_view(), name='index'),
]