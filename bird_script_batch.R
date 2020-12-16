# SPICE test simulations to be run in batch
# bird script simulations to run in batch format
# results from these simulations can be plotted using bird_sim_batch_plots.R script

# number of cores to use for parallelizing
use_cores = as.numeric(Sys.getenv('LSB_DJOB_NUMPROC')) 

# jobid for different simulation parameters
jobid = as.numeric(Sys.getenv("LSB_JOBINDEX"))

# simulation function:
# n=number of subjects
# M = bird image
# sd.a.i = standard deviation for the shared coefficient between X and Y
# sd.e.ij = standard deviation for the pixel-level random noise
# p=number of features per subject
sim.fun <- function(n, M, sd.a.i, sd.e.ij){
  p = dim(M)[1]*dim(M)[2]
  M.i <- list() # subject-level image
  X.mat <- matrix(nrow=n,ncol=p) # color channel 1 from image
  Y.mat <- matrix(nrow=n,ncol=p) # color channel 2 from image
  for (i in 1:n){
    a.i <- rnorm(n = 1, mean = 1, sd = sd.a.i) # subject level
    a.i1 <- rnorm(n = 1, mean = 1, sd = 1) # channel level
    a.i2 <- rnorm(n = 1, mean = 1, sd = 1)  # channel level
    e.ij1 <- rnorm(p, mean = 0, sd = sd.e.ij) # voxel/channel level randomness
    e.ij2 <- rnorm(p, mean = 0, sd = sd.e.ij) # voxel/channel level randomness
    
    M.i[[i]] <- a.i*M
    X.mat[i,] <- as.vector(a.i1*M.i[[i]][,,1] + e.ij1) # color channel 1 for subject i
    Y.mat[i,] <- as.vector(a.i2*M.i[[i]][,,2] + e.ij2) # color channel 2 for subject i
  }
  return(list(X.mat=X.mat,Y.mat=Y.mat))
}

# load in parrot image:
load("M.RData") # may need to specify directory

par.vals<-expand.grid(seq(0,3,length.out = 21),
                      c(0.5,1.5,3),
                      c(25,50,100))
names(par.vals) = c("var.a.i","var.e.ij","n")
print(paste("n = ",par.vals$n[jobid],"var.a.i=",par.vals$var.a.i[jobid],
            "var.e.ij=",par.vals$var.e.ij[jobid]),quote = F)

source("maptest_script.R") # may need to specify directory

nsim = 5000 # number of simulations (for each parameter set)
K = 999 # number of permutations (within each simulation)

set.seed(917)
pval.s = vector(mode = "numeric", length = nsim) # where pvalue from each simulation will be saved

for (s in 1:nsim){
  if (s%%100==0){
    print(paste("simulation ", s, "of ", nsim),quote = F)
  }
  sim.dat.s <- sim.fun(n=par.vals$n[jobid],M = M,sd.a.i=sqrt(par.vals$var.a.i[jobid]),sd.e.ij = sqrt(par.vals$var.e.ij[jobid]))
  pval.s[s] <- map.test(K=K,X.mat = sim.dat.s$X.mat,Y.mat = sim.dat.s$Y.mat, use_cores = use_cores, rtoz = TRUE)$pvalue # rtoz = TRUE for Fisher transformation of the Pearson correlation
}
p.reject = length(which(pval.s<0.05))/nsim # proportion of simulations in which H_0 was rejected

# setwd("/folder/for/results")
save(p.reject, file = paste0("n",par.vals$n[jobid],"sd.a.i",par.vals$var.a.i[jobid], "sd.e.ij",par.vals$var.e.ij[jobid],".RData"))