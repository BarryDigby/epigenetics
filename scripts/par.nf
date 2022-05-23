#!/usr/bin/env nextflow

params.pval = "/data2/bdigby/epigenetics_rdats/pvaltab_all_des.txt"
Channel.fromPath(params.pval)
       .set{ ch_pval }

params.tab = "/data2/bdigby/epigenetics_rdats/tab_all_des.txt"
Channel.fromPath(params.tab)
       .set{ ch_tab }

process SPLIT_PVAL{
    publishDir "/data2/bdigby/epigenetics_rdats/splits", mode: 'copy'

    input:
    file(pval) from ch_pval

    output:
    file("*.txt") into ch_pval_splits

    script:
    """
    Rscript /data2/bdigby/epigenetics_rdats/split_pval.R
    """
}

a = ch_pval_splits.flatten().map{ it -> [it.simpleName, it]}.view()

process SPLIT_TAB{
    publishDir "/data2/bdigby/epigenetics_rdats/splits", mode: 'copy'

    input:
    file(tab) from ch_tab

    output:
    file("*.txt") into ch_tab_splits

    script:
    """
    Rscript /data2/bdigby/epigenetics_rdats/split_tab.R
    """
}

b = ch_tab_splits.flatten().map{ it -> [it.simpleName, it]}

// join by common key
c = a.join(b)

process SIG_TAB{
    publishDir "/data2/bdigby/epigenetics_rdats/results", mode:'copy'

    input:
    tuple val(base), file(pval), file(tab) from c

    output:
    file("*.txt") into finished

    script:
    """
    Rscript /data2/bdigby/epigenetics_rdats/bonferroni.R $pval $tab
    """
}
