# SPICE test simulations to be run in batch
# simulations using mean cortical thickness vs. sulcal depth and cortical thickness vs. n-back as M1 and M2

# number of cores to use for parallelizing
use_cores = as.numeric(Sys.getenv('LSB_DJOB_NUMPROC')) 

# jobid for different simulation parameters
jobid = as.numeric(Sys.getenv("LSB_JOBINDEX"))

# load in mean cortical thickness, sulcal depth, and n-back daata (may need to change directory)
load("mean_ct_depth_nback.RData")

# script for map test (may need to change directory)
source("maptest_script.R")

# parameter values specif
par.vals = expand.grid(seq(0,3,length.out = 21), # variance of a.i (signal)
                       c(0.5,1.5,3,6), # variance of e.ij (noise)
                       c(25,50,100), # sample size
                       c("CT_NB","CT_SD")) # M2 = mean n-back or mean sulcal depth from PNC data
names(par.vals) = c("var.a.i","var.e.ij","n","maps")

M1 = mean_ct_depth_nback$CT # M1 is always mean cortical thickness

# M2 is either n-back or sulcal depth (all parameters will be considered for each version of M2)
if (par.vals$maps[jobid]=="CT_NB"){
  M2 = mean_ct_depth_nback$nback
}

if (par.vals$maps[jobid]=="CT_SD"){
  M2 = mean_ct_depth_nback$sulcal_depth
}


sim.brain.fun <- function(n, M1,M2, sd.a.i, sd.e.ij){
  p = length(M1)
  X.mat <- matrix(nrow=n,ncol=p) # to store simulated image 1
  Y.mat <- matrix(nrow=n,ncol=p) # to store simulated image 2
  for (i in 1:n){
    a.i <- rnorm(n = 1, mean = 1, sd = sd.a.i) # subject level (signal)
    e.ij1 <- rnorm(p, mean = 0, sd = sd.e.ij) # voxel/channel level randomness (noise)
    e.ij2 <- rnorm(p, mean = 0, sd = sd.e.ij) # voxel/channel level randomness (noise)
    
    M1.i = a.i*M1
    M2.i = a.i*M2
    
    X.mat[i,] <- as.vector(M1.i + e.ij1) # simulated image 1 for subject i
    Y.mat[i,] <- as.vector(M2.i + e.ij2) # simulated image 2 for subject i
  }
  return(list(X.mat=X.mat,Y.mat=Y.mat))
}

nsim = 5000 # number of simulations (for each parameter set)
K = 999 # number of permutations (within each simulation)

set.seed(917)
pval.s = vector(mode = "numeric", length = nsim) # where pvalue from each simulation will be saved

for (s in 1:nsim){
  if (s%%100==0){
    print(paste("simulation ", s, "of ", nsim),quote = F)
  }
  sim.dat.s <- sim.brain.fun(n=par.vals$n[jobid],M1 = M1,M2=M2,sd.a.i=sqrt(par.vals$var.a.i[jobid]),sd.e.ij = sqrt(par.vals$var.e.ij[jobid]))
  pval.s[s] <- map.test(K=K,X.mat = sim.dat.s$X.mat,Y.mat = sim.dat.s$Y.mat, use_cores = use_cores, rtoz = FALSE)$pvalue
}

p.reject = length(which(pval.s<0.05))/nsim # proportion of simulations in which H_0 was rejected

# setwd("/folder/for/results")
save(p.reject, file = paste0("n",par.vals$n[jobid],"sd.a.i",par.vals$var.a.i[jobid], "sd.e.ij",par.vals$var.e.ij[jobid],"maps",par.vals$maps[jobid],".RData"))

