import os
import numpy as np
from scipy.stats import norm
from multiprocessing import cpu_count
from maptest_script import map_test
import rdata

parsed = rdata.parser.parse_file('mean_ct_depth_nback.RData')
converted = rdata.conversion.convert(parsed)
mean_ct_depth_nback = converted['mean_ct_depth_nback']

# Number of cores for parallel processing
#use_cores = int(os.getenv('LSB_DJOB_NUMPROC', cpu_count()))  # Default to all available cores

use_cores = 1

# Job ID for simulation parameters
jobid = int(os.getenv("LSB_JOBINDEX", 1))  # Default job ID to 1 if not provided
print('jobid',jobid)

# Load data (this would normally come from a file like "mean_ct_depth_nback.RData")


# Parameter values
par_vals = np.array(np.meshgrid(np.linspace(0, 3, 21), [0.5, 1.5, 3, 6], [25, 50, 100], ["CT_NB", "CT_SD"])).T.reshape(-1, 4)
var_a_i = float(par_vals[jobid, 0])
var_e_ij = float(par_vals[jobid, 1])
n_samples = int(par_vals[jobid, 2])
map_type = par_vals[jobid, 3]

# M1 is always mean cortical thickness
M1 = mean_ct_depth_nback["CT"]

# M2 is either n-back or sulcal depth
if map_type == "CT_NB":
    M2 = mean_ct_depth_nback["nback"]
else:
    M2 = mean_ct_depth_nback["sulcal_depth"]

# Simulation function in Python
def sim_brain_fun(n, M1, M2, sd_a_i, sd_e_ij):
    p = len(M1)
    X_mat = np.zeros((n, p))
    Y_mat = np.zeros((n, p))
    
    for i in range(n):
        a_i = np.random.normal(1, sd_a_i)
        e_ij1 = np.random.normal(0, sd_e_ij, p)
        e_ij2 = np.random.normal(0, sd_e_ij, p)
        
        M1_i = a_i * M1
        M2_i = a_i * M2
        
        X_mat[i, :] = M1_i + e_ij1
        Y_mat[i, :] = M2_i + e_ij2
        
    return {"X_mat": X_mat, "Y_mat": Y_mat}

# Simulation parameters
nsim = 100  # Number of simulations
K = 999  # Number of permutations

np.random.seed(917)
pval_s = np.zeros(nsim)

# Running simulations
for s in range(nsim):
    # if s % 100 == 0:
    print(f"Simulation {s + 1} of {nsim}")
    
    sim_data_s = sim_brain_fun(n=n_samples, M1=M1, M2=M2, sd_a_i=np.sqrt(var_a_i), sd_e_ij=np.sqrt(var_e_ij))
    
    # Perform map test
    pval_s[s] = map_test(K=K, X_mat=sim_data_s["X_mat"], Y_mat=sim_data_s["Y_mat"], use_cores=use_cores, rtoz=False)["p_value"]

# Calculate proportion of rejections
p_reject = np.sum(pval_s < 0.05) / nsim

print('p_reject:',p_reject)

output_filename = f"n{n_samples}_sd.a.i{var_a_i}_sd.e.ij{var_e_ij}_maps{map_type}.npy"
np.save(output_filename, p_reject)