# mimQTL Analysis

miRNA expression and DNA methylation data from `TCGA-PRAD` were integrated via correlation analysis termed miRNA-methylation Quantitative Trait Loci (`mimQTL`) analysis. mRNA expression data was downloaded to assess the relationship between significant `mimQTLs` and gene expression in `PRAD`.
<details>
<summary>## Dataset staging</summary>
<br>

### miRNA expression

`TCGA-PRAD` miRNA counts were downloaded from the GDC portal:

```bash
gdc-client download -m mirna_meta/mirna_manifest -d mirna/
```

A brief explanation of the workflow used to generate the count matrix is given below:

###### [GDC miRNA workflow](https://github.com/bcgsc/mirna)

smRNA sequencing reads are mapped to the `GRCh38` build using `BWA-aln`. Next, the sequencing reads are annotated using `miRBase v21` and `UCSC` - sequencing reads are required to have at least a 3bp overlap with an annotated genomic region to be considered for annotation. It is important to note that due to the workflows reliance on `miRBase` annotations, it is not suitable for novel miRNA discovery. Customized perl scripts (`tcga.pl`) are used to generate the final expression files for GDC. 

Subsequent to the download of individual miRNA expression data, the data was merged into a single dataframe using customized functions in `R` (`scripts/1.format_assays.Rmd`: # 1. miRNA Staging).

The `Metastatic` sample was removed, resulting in 52 `Normals` and 498 `Tumor` samples.
***

### DNA methylation

Raw DNA methylation data from `TCGA-PRAD` was downloaded from the GDC portal:

```bash
gdc-client download -m methylation_meta/methylation_manifest -d methylation/
```

A brief description of the generation of raw methylation data is given below:

###### [GDC Methylation workflow](https://github.com/zwdzwd/sesame)

`SeSAMe` offers correction to detection failures that occur in other DNA methylation array software commonly due to germline and somatic deletions by utilizing a novel way to calculate the significance of detected signals in methylation arrays. By correcting for these artifacts as well as other improvements to DNA methylation data processing, `SeSAMe` improves upon detection calling and quality control of processed DNA methylation data. `SeSAMe` output files include: two Masked Methylation Array IDAT files, one for each color channel, that contains channel data from a raw methylation array after masking potential genotyping information; and a subsequent Methylation Beta Value TXT file derived from the two Masked Methylation Array IDAT files, that displays the calculated methylation beta value for CpG sites.

The two Masked Methylation Array IDAT files were used in the analysis and processed using the `minfi` package in `R` (`scripts/1.format_assays.Rmd`: # 3. Methylation staging)

The `Metastatic` sample was removed, resulting in 50 `Normal` samples and 502 `Tumor` samples.

## mRNA expression

`TCGA-PRAD` mRNA expression data was downloaded from the GDC portal [link to full workflow available here](https://www.biostars.org/p/9500223/).

```bash
gdc-client download -m rna_meta/mrna_manifest -d mrna/
```

###### [GDC mRNA workflow](https://github.com/akahles/icgc_rnaseq_align)

The mRNA Analysis pipeline begins with the Alignment Workflow, which is performed using a two-pass method with `STAR`. `STAR` aligns each read group separately and then merges the resulting alignments into one. As of release `v32`, which uses `STAR` to directly output `FPKM`, `RPKM`, and `TPM` values (`--quantMode TranscriptomeSAM GeneCounts`) `HTSeq` has been made redundant and is no longer used to generate gene level counts.

When staging the gene level counts, the `unstranded` column was selected to create the gene expression matrix for `TCGA-PRAD` (`scripts/1.format_assays.Rmd`: # 2. mRNA staging).

Upon removal of the `Metastatic` sample, the number of samples was 50 `Normals` and 500 `Tumor` samples.

***
</details>