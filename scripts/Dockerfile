FROM r-base:4.1.3

RUN apt-get update
RUN install2.r --error BiocManager
RUN R -e 'BiocManager::install(ask = F)' && R -e 'BiocManager::install(c("minfi"))'
