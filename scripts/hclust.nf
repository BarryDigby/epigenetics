#!/usr/bin/env nextflow

params.sig = "/data2/bdigby/epigenetics_rdats/results/sig.tab.txt"
Channel.fromPath(params.sig)
       .set{ch_sig}

params.tab = "/data2/bdigby/epigenetics_rdats/tab_all_des.txt"
Channel.fromPath(params.tab)
       .set{ch_tab}

process DIST{
    publishDir "/data2/bdigby/epigenetics_rdats/hclust", mode:'copy'
    memory '123 GB'

    input:
    file(sig) from ch_sig
    file(tab) from ch_tab

    output:
    file("*RData") into ch_dist

    script:
    """
    Rscript /data2/bdigby/epigenetics_rdats/dist.R $sig $tab
    """
}

process HCLST{
   publishDir "/data2/bdigby/epigenetics_rdats/hclust", mode:'copy'
   memory '123 GB'

   input:
   file(dist) from ch_dist

   output:
   file("*RData") into out

   script:
   """
   Rscript /data2/epigenetics_rdats/hclust.R
   """
}
