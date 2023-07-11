# Generated by Django 3.1.4 on 2021-04-04 10:24

from django.db import migrations, models
import mapping.models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Map',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('probe_type', models.CharField(choices=[('neuronexus_a1_32_poly2', 'Neuronexus_A1_32_Poly2'), ('cambridge_h7b', 'Cambridge_H7b')], max_length=50)),
                ('probe_number', models.IntegerField(null=True)),
                ('probe_points_file', models.FileField(null=True, upload_to=mapping.models.get_upload_path)),
                ('channel_positions_file', models.FileField(null=True, upload_to=mapping.models.get_upload_path)),
                ('channel_map_file', models.FileField(null=True, upload_to=mapping.models.get_upload_path)),
                ('cluster_info_file', models.FileField(blank=True, null=True, upload_to=mapping.models.get_upload_path)),
                ('borders_table_file', models.FileField(blank=True, null=True, upload_to=mapping.models.get_upload_path)),
                ('probe_data_file', models.FileField(blank=True, null=True, upload_to=mapping.models.get_upload_path)),
            ],
        ),
    ]