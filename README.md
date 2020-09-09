# R code for the Simple Permutation-based Intermodal CorrEspondence (SPICE) test

### What's included:

### (1) `maptest_script.R`
- includes the basic script for implementing a test of intermodal correspondence
- function can be implemented either as `map.test()` or `spice.test()`
- Input arguments:
    - `K`: number of permutations (in the paper, we use 999)
    - `X.mat`: each row is made up of the vector of intensities across all image locations in the "X" modality for each subject (number of rows of `X.mat` should equal the number of subjects; number of columns of `X.mat` should equal the number of locations in each image)
    - `Y.mat`: same as `X.mat` but for the "Y" modality. Dimension of this matrix should be the same as for `X.mat`
    - `use_cores`: optionally specify the number of cores to use for parallelizing parts of the code. The deafult is 1.
    
### (2) `bird_script_batch.R`
- Code for conducting simulations from paper. We first take a colorful image of a bird (array stored in `M.RData`) and extract the intensity values from the red and green color channels. Then we add/multiply random noise at each location in each color channel to obtain a population of bi-modal image data.
- See description and results of these simulations in the paper (sections 2.3 and 3.1 and Figure 4).
