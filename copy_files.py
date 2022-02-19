import glob
import os
import shutil
from tqdm import tqdm
files = glob.glob('./tempdir/**/17*.xml', recursive=True)
target_dir = './data/editions/'
for x in tqdm(files, total=len(files)):
    head, tail = os.path.split(x)
    shutil.copyfile(x, f"{target_dir}ed__{tail}")