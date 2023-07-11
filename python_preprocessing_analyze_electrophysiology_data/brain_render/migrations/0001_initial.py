# Generated by Django 3.1.4 on 2021-03-07 11:04

import brain_render.models
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Scene',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('probes_number', models.IntegerField(null=True)),
                ('clusters_sets_number', models.IntegerField(null=True)),
                ('probes_files', models.FileField(null=True, upload_to=brain_render.models.get_upload_path)),
                ('clusters_sets_files', models.FileField(null=True, upload_to=brain_render.models.get_upload_path)),
                ('scene_title', models.CharField(max_length=1000, null=True)),
                ('brain_regions', models.ManyToManyField(related_name='_scene_brain_regions_+', to='brain_render.Scene')),
            ],
        ),
    ]