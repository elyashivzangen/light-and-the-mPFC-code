from django.urls import path

from . import views

app_name = 'pl2kilosort'
urlpatterns = [
    path('', views.IndexView.as_view(), name='index'),
]