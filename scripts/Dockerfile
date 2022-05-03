FROM r-base:4.2.0

RUN apt-get update
RUN install2.r --error BiocManager
RUN R -e 'BiocManager::install(c("minfi"), ask=F)'

COPY verify.R ./
RUN Rscript verify.R
