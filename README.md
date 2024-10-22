# R and python code for SPICE
- [Preprint on bioRxiv](https://www.biorxiv.org/content/10.1101/2020.09.10.285049v2)
- [Published in Human Brain Mapping](https://onlinelibrary.wiley.com/doi/full/10.1002/hbm.25577)

### What's included in this repository:

### R code:
#### `maptest_script.R`
- includes the basic script for implementing a test of intermodal correspondence
- function can be implemented either as `map.test()` or `spice.test()`
- Input arguments:
    - `K`: number of permutations (in the paper, we use 999)
    - `X.mat`: each row is made up of the vector of intensities across all image locations in the "X" modality for each subject (number of rows of `X.mat` should equal the number of subjects; number of columns of `X.mat` should equal the number of locations in each image)
    - `Y.mat`: same as `X.mat` but for the "Y" modality. Dimension of this matrix should be the same as for `X.mat`
    - `use_cores`: optionally specify the number of cores to use for parallelizing parts of the code. The default is 1.
    
#### `brain_simulations_batch.R`
- Code for conducting simulations from paper. We use average cortical thickness, sulcal depth, and n-back from the Philadelphia Neurodevelopmental Cohort (PNC) as population-level image patterns. Then we add/multiply noise/signal to these images to generate multi-modal image data.
- See description and results of these simulations in the paper (section 2.2.2 and Figures 3 and 4).

### python code:
