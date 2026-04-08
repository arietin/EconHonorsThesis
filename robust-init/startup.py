import sys
import os, stat
import shutil
import pandas as pd
import time

def mkdirs(dirs, year):
    for d in dirs:
        dy = f"{year}_{d}"
        try:
            os.mkdir(dy)
        except:
            shutil.rmtree(dy)
            os.mkdir(dy)

def prep_data(truepath, simdir, year):
    data = pd.read_csv(truepath)
    if year != 2005:
        data = data[data['year0'] == year]
    print(data.shape)
    
    print(f'Using {len(data)} observations')
    data.to_csv(f"{year}_{simdir}/used_data.csv")
    
def write_mat(params, simdir, year, seed = '"default"'):
    i = 1
    params = list(params)
    print(params)
    with open(f"srun{year}_{seed}.m","w") as m:
        m.write(f"""part = {i}
Theta={params}
outdir = "{year}_{simdir}"
y = "{year}"
seed = {seed}
run('master.m')
""")

def write_srun(year, seed):
    
    options = f"""#!/bin/bash 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=80
#SBATCH --time=3:00:00 
#SBATCH --mem=140g
"""
    #prefix = 'srun --ntasks=1 --nodes=1 --cpus-per-task=$SLURM_CPUS_PER_TASK '
    #suffix = ' & \n'
   
    with open(f"slurm{year}_{seed}.sl", "w") as outfile: 
        outfile.write(options)

        outfile.write(f"matlab -nodisplay -batch 'srun{year}_{seed}'")

def write_bat(year, seeds):
    with open(f"batch_{year}.sh", "w") as bfile:
        bfile.write("#!/bin/bash \n")
        for seed in range(seeds):
            bfile.write(f"sbatch slurm{year}_{seed}.sl\n")
    os.chmod(f"batch_{year}.sh",stat.S_IRWXU)
    
def main():
    simdir = time.strftime("%Y%m%d")
    year = int(sys.argv[1])
    if len(sys.argv) == 3:
        n_seeds = int(sys.argv[2])
    else: 
        n_seeds = 1
    mkdirs([simdir], year)
    if year == 2005:
        truepath = "2005samplePosM.csv"
    else:
        truepath = "Post2017Sample.csv"
    init_O = [0.322773392263051,-0.281851152140988,-2.39059597031676,-2.044644989741,-0.897883745312797,0,0,0,-0.922580122977585,0,0,-1.43235200557379,0,-1.35905026847786]
    prep_data(truepath, simdir, year)
    for seed in range(n_seeds):
        write_mat(init_O, simdir, year, seed)
        write_srun(year, seed)
    write_bat(year, n_seeds)

if __name__ == "__main__":
    main()
