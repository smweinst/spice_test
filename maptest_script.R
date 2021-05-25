# MAP TEST SCRIPT (aka SPICE test)

# pearson correlation version of psi
psi <- function(X.mat, Y.mat,n=n, rtoz = FALSE){
  if (rtoz==F){
    psi.i <- mean(sapply(1:n, FUN = function(i){cor(X.mat[i,],Y.mat[i,])}))
  }else{ # if fisher r-to-z transformation should be used
    psi.i <- mean(sapply(1:n, FUN = function(i){
      
      r = cor(X.mat[i,],Y.mat[i,]) # pearson correlation (default in cor() function)
      z = 0.5*(log(1+r) - log(1-r)) # fisher r to z transformation
      
      return(z) # psi.i will be the average over the r-to-z transformed statistics
      
      }))
  }
  return(psi.i)
}

map.test <- function(K, X.mat, Y.mat, use_cores=1, rtoz = FALSE){
  
  n = nrow(X.mat)
  
  A.0 <- psi(X.mat, Y.mat,n=n, rtoz = rtoz) # average within-subject correlation between X and Y
  
  A.k <- parallel::mclapply(1:K, FUN = function(k){
    rows <- sample(nrow(Y.mat),replace = F)
    Y.mat <- Y.mat[rows,]
    A.k.temp <- psi(X.mat,Y.mat,n=n,rtoz = rtoz)
    return(A.k.temp)
  },mc.cores = use_cores)
  A.k = unlist(A.k)
  
  I.k <- sapply(1:K, FUN = function(k){
    as.numeric(I(abs(A.0)<abs(A.k[k])))
  })
  
  pvalue <- (sum(I.k)+1)/(K+1)
  
  return(list(A.0 = A.0, 
              A.k = A.k,
              pvalue = pvalue
              ))
}

spice.test = map.test # can also call function by spice.test
