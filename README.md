# epigenetics

a stream of waffle...

analysis in R locally for miRNA, mRNA is straight forward. 

Had to conduct methylation signal proc on HPC - installing "minfi" via containers did not work, 
module load R/R.4.0.2 shared libs not writable (expected):

```console
Warning in install.packages("BiocManager") :
  'lib = "/opt/ohpc/pub/apps/R/R-4.0.2/lib64/R/library"' is not writable
Would you like to use a personal library instead? (yes/No/cancel) yes
Would you like to create a personal library
‘~/R/x86_64-pc-linux-gnu-library/4.0’
to install packages into? (yes/No/cancel) yes
```


