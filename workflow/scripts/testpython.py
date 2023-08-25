import os
import glob

fastq_paths = {
    'WT_1': "test_dir/WT_1",
    'WT_2': "test_dir/WT_2"
}

is_gz = False

os.chdir("C:\\Users\\isaac\\Documents\\")

for p in fastq_paths.values():

    fastqs = sorted(glob.glob(f"{p}/*.fastq*"))
    test_gz = any(path.endswith('.fastq.gz') for path in fastqs)
    is_gz = any([is_gz, test_gz])

