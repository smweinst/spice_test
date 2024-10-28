import numpy as np
from scipy.stats import pearsonr
from multiprocessing import Pool

def psi(X_mat, Y_mat, rtoz=False):
    n = X_mat.shape[0]
    if not rtoz:
        # Compute Pearson correlation for each row and average
        psi_i = np.mean([pearsonr(X_mat[i, :], Y_mat[i, :])[0] for i in range(n)])
    else:
        # Apply Fisher's r-to-z transformation if rtoz is True
        psi_i = np.mean([0.5 * (np.log(1 + pearsonr(X_mat[i, :], Y_mat[i, :])[0]) - np.log(1 - pearsonr(X_mat[i, :], Y_mat[i, :])[0])) 
                         for i in range(n)])
    return psi_i

# Helper function to perform the permutation test in parallel
def permute_and_psi(X_mat, Y_mat, n, rtoz):
    rows = np.random.permutation(n)
    Y_perm = Y_mat[rows, :]
    return psi(X_mat, Y_perm, rtoz=rtoz)

def map_test(K, X_mat, Y_mat, use_cores=1, rtoz=False):
    n = X_mat.shape[0]
    
    # Calculate A.0 (original correlation)
    A_0 = psi(X_mat, Y_mat, rtoz=rtoz)
    
    # Use parallel processing for permutations
    # with Pool(processes=use_cores) as pool:
    #     A_k = pool.starmap(permute_and_psi, [(X_mat, Y_mat, n, rtoz) for _ in range(K)])

    A_k = []
    for _ in range(K):
        # Permute the rows of Y_mat
        rows = np.random.permutation(n)
        Y_perm = Y_mat[rows, :]
        A_k.append(psi(X_mat, Y_perm, rtoz=rtoz))
    
    I_k = [1 if abs(A_0) < abs(A_k[k]) else 0 for k in range(K)]
    p_value = (sum(I_k) + 1) / (K + 1)
    
    return {
        "A_0": A_0,
        "A_k": A_k,
        "p_value": p_value
    }


