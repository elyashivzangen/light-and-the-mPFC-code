import os
import shutil
import pathlib


def move_files(source_directory, target_directory):
    files_list = os.listdir(source_directory)
    
    for filename in files_list:
        shutil.move(os.path.join(source_directory, filename), target_directory)
    return


if '__main__' == __name__:
    working_directory = pathlib.Path(__file__).parent.absolute()
    pl2kilosort_source_directory = r'{}\pl2kilosort\files'.format(working_directory)
    psth_source_directory = r'{}\psth\files'.format(working_directory)
    trial_types = ['sequence', 'individual']

    target_directory = input('Enter full path to experiment directory (path must not include any spaces!): ')

    move_files(psth_source_directory, target_directory)
    [move_files(os.path.join(pl2kilosort_source_directory, x), target_directory) for x in trial_types]
    