# mimQTL Analysis

miRNA expression and DNA methylation data from `TCGA-PRAD` were integrated via correlation analysis termed miRNA-methylation Quantitative Trait Loci (`mimQTL`) analysis. mRNA expression data was downloaded to assess the relationship between significant `mimQTLs` and gene expression in `PRAD`.
<details>
<summary>Dataset staging</summary>
<br>

<details open>
<summary>miRNA expression</summary>
<br>

`TCGA-PRAD` miRNA counts were downloaded from the GDC portal:

```bash
gdc-client download -m mirna_meta/mirna_manifest -d mirna/
```

A brief explanation of the workflow used to generate the count matrix is given below:

###### [GDC miRNA workflow](https://github.com/bcgsc/mirna)

smRNA sequencing reads are mapped to the `GRCh38` build using `BWA-aln`. Next, the sequencing reads are annotated using `miRBase v21` and `UCSC` - sequencing reads are required to have at least a 3bp overlap with an annotated genomic region to be considered for annotation. It is important to note that due to the workflows reliance on `miRBase` annotations, it is not suitable for novel miRNA discovery. Customized perl scripts (`tcga.pl`) are used to generate the final expression files for GDC. 

Subsequent to the download of individual miRNA expression data, the data was merged into a single dataframe using customized functions in `R` ([`scripts/1.format_assays.Rmd`](scripts/1.format_assays.Rmd): # 1. miRNA Staging).

The `Metastatic` sample was removed, resulting in 52 `Normals` and 498 `Tumor` samples.
***
</details>

<details open>
<summary>DNA methylation</summary>
<br>

Raw DNA methylation data from `TCGA-PRAD` was downloaded from the GDC portal:

```bash
gdc-client download -m methylation_meta/methylation_manifest -d methylation/
```

A brief description of the generation of raw methylation data is given below:

###### [GDC Methylation workflow](https://github.com/zwdzwd/sesame)

`SeSAMe` offers correction to detection failures that occur in other DNA methylation array software commonly due to germline and somatic deletions by utilizing a novel way to calculate the significance of detected signals in methylation arrays. By correcting for these artifacts as well as other improvements to DNA methylation data processing, `SeSAMe` improves upon detection calling and quality control of processed DNA methylation data. `SeSAMe` output files include: two Masked Methylation Array IDAT files, one for each color channel, that contains channel data from a raw methylation array after masking potential genotyping information; and a subsequent Methylation Beta Value TXT file derived from the two Masked Methylation Array IDAT files, that displays the calculated methylation beta value for CpG sites.

The two Masked Methylation Array IDAT files were used in the analysis and processed using the `minfi` package in `R` ([`scripts/1.format_assays.Rmd`](scripts/1.format_assays.Rmd): # 3. Methylation staging)

Briefly, sample detection p-values were assessed as per recommended in the `minfi` tutorial:

> The method used by minfi to calculate detection p-values compares the total signal $(M+U)$ for each probe to the background signal level, which is estimated from the negative control probes. Very small p-values are indicative of a reliable signal whilst large p-values, for example >0.01, generally indicate a poor quality signal.

![Alt text](methylation_meta/pval_det.png?raw=true)

3 samples have p-values higher than 0.01 and are discarded from downstream analysis. 

As with the miRNA and mRNA assays, the `Metastatic` sample was removed, resulting in 50 `Normal` samples and 499 `Tumor` samples.

Quantile processing, removal of probes overlapping SNPs and [cross-reactive probes](methylation_meta/cross_reactive_probes.csv) was performed as per the minfi documentation.

***
</details>

<details open>
<summary>mRNA expression</summary>
<br>

`TCGA-PRAD` mRNA expression data was downloaded from the GDC portal [link to full workflow available here](https://www.biostars.org/p/9500223/).

```bash
gdc-client download -m rna_meta/mrna_manifest -d mrna/
```

###### [GDC mRNA workflow](https://github.com/akahles/icgc_rnaseq_align)

The mRNA Analysis pipeline begins with the Alignment Workflow, which is performed using a two-pass method with `STAR`. `STAR` aligns each read group separately and then merges the resulting alignments into one. As of release `v32`, which uses `STAR` to directly output `FPKM`, `RPKM`, and `TPM` values (`--quantMode TranscriptomeSAM GeneCounts`) `HTSeq` has been made redundant and is no longer used to generate gene level counts.

When staging the gene level counts, the `unstranded` column was selected to create the gene expression matrix for `TCGA-PRAD` ([`scripts/1.format_assays.Rmd`](scripts/1.format_assays.Rmd): # 2. mRNA staging).

Upon removal of the `Metastatic` sample, the number of samples was 50 `Normals` and 500 `Tumor` samples.

***
</details>
</details>

<details>
<summary> Exploratory Data Analysis</summary>
<br>

<details open>
<summary>miRNA EDA</summary>
<br>

Pearsons R2 correlation was computed between Principal Components 1:10 of variance stabilized miRNA expression data. Based on the results of the exploratory data analysis, the covariates 'age', 'ajcc tumor stage' and 'race' will not be included in the `DESeq2` generalized linear model.

![Alt text](mirna_meta/PCA_corr.png?raw=true "R2 correlation PC:Metadata")

![Alt text](mirna_meta/PCA_biplot.png?raw=true "PCA miRNA biplot")

</details>

<details open>
<summary>mRNA EDA</summary>
<br>

Pearsons R2 correlation was computed between Principal Components 1:10 of variance stabilized mRNA expression data. The covariate 'ajcc tumor stage' was correlated with PC3, however as PC3 only accounts for 5.36% variation in the dataset, this covariate was excluded from the analysis.

![Alt text](mrna_meta/PCA_corr.png?raw=true "R2 correlation PC:Metadata")

![Alt text](mrna_meta/PCA_biplot.png?raw=true "PCA mRNA biplot")

</details>

<details open>
<summary>DNA methylation EDA</summary>
<br>

MDS plot displaying the top 10,000 CpG sites in the TCGA-PRAD cohort given below.

![Alt text](methylation_meta/PCA_biplot.png?raw=true "MDS methyation biplot")

</details>
</details>

<details open>
<summary> Differential Expression Analysis</summary>
<br>

DEA scripts are available in [`2.DEA.Rmd`](scripts/DEA.Rmd)

<details open>
<summary>DE miRNA</summary>
<br>

Differential expression analsis was conducted using `DESeq2` contrasting `Tumor` vs `Normal` samples in the TCGA-PRAD cohort. Robust results were generated using the `IHW` filter function for multiple correction testing, followed by `apeglm` shrinkage correction to penalize differentially expressed miRNAs with high variance.

miRNAs passing strict filtering (`Log2FoldChange > 0.5 || < -0.5 && adjusted p-value < 0.05`) were selected for downstream analysis (`upregulated: 121, downregulated: 135`).

Results were annotated using `biomaRt_v2.52.0` ([`mirna_res/de_mirs.txt`](mirna_res/de_mirs.txt))
</details>

<details open>
<summary>DE mRNA</summary>
<br>

Differential expression analsis was conducted using `DESeq2` contrasting `Tumor` vs `Normal` samples in the TCGA-PRAD cohort. Robust results were generated using the `IHW` filter function for multiple correction testing, followed by `apeglm` shrinkage correction to penalize differentially expressed miRNAs with high variance.

mRNAs passing strict filtering (`Log2FoldChange > 0.5 || < -0.5 && adjusted p-value < 0.05`) were selected for downstream analysis (`upregulated: 3201, downregulated: 3274`).

Results were annotated using `biomaRt_v2.52.0` ([`mrna_res/de_genes.txt`](mrna_res/de_genes.txt))

</details>

<details open>
<summary>DE Methylation</summary>
<br>

Diffferential expression analysis of CpG probes was conducted using `Limma`. As per the recommendations of [S. Lin et al](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-587), M values were used for DE analysis instead of Beta values due to their homoscedastic properties, meeting the assumptions of canonical linear models/ANOVA tests.

Prior to filtering, there were 121062 up regulated probes and 169255 down regulated probes ([`methylation_res/DMPs.txt.gz`](methylation_res/DMPs.txt)). Subsequent to filtering (`Log2FoldChange > 0.5 || < -0.5 && adjusted p-value < 0.05`) there were 60785 up regulated probes and 46911 down regulated probes retained for downstream analysis ([`methylation_res/dmp_filt.txt.gz`](methylation_res/dmp_filt.txt)).

</details>
</details>

<details open>
<summary>mimQTL analysis</summary>
<br>

A two-fold approach was taken to analysing mimQTLs:

<details open>
<summary>Approach 1</summary>
<br>

> Identify differentially expressed miRNAs in TCGA-PRAD and their overlapping differentially expressed CpG sites, yielding differentially methylated & differentially expressed (DMDE) mimQTLs. Compute pearsons correlation coefficient at mimQTL sites, filter for statistically significant associations.

##### Calculating Overlaps

miRNA promoter regions were calculated in accordance to common literature, spanning 2kb from the miRNA transcription start site ([`scripts/3.miR_TSS.Rmd`](scripts/3.miR_TSS.Rmd)).

Prior to overlapping miRNA promoter regions with differentially expressed CpG sites using bedtools, the order of negative strand miRNAs was corrected:

```console
head mirna_TSS.bed 
chromosome	upstream	downstream	mirbase_id	strand
20	62552306	62554377	hsa-mir-1-1	+
18	21831088	21829003	hsa-mir-1-2	-
11	122154308	122152228	hsa-mir-100	-
```

```bash
awk '{OFS="\t"; if ($5=="+") {print} else {print $1,$3,$2,$4,$5,$6}}' mirna_TSS.bed | sed 's/[[:space:]]*$//' > mirs.bed
```

```console
head mirs.bed
chromosome	downstream	upstream	mirbase_id	strand
20	62552306	62554377	hsa-mir-1-1	+
18	21829003	21831088	hsa-mir-1-2	-
11	122152228	122154308	hsa-mir-100	-
```

Differentially expressed CpG sites were overlapped with differentially expressed miRNAs using bedtools:

```bash
bedtools intersect -a dmp_filt.bed -b mirs.bed -wa -wb > de-probes_olap_de-mirs.bed
```

***

##### Calculating Correlations

Using the results of [`de-probes_olap_de-mirs.bed`](bedtools/de-probes_olap_de-mirs.bed) as the subset key for the original methylation M Values and normalized miRNA counts (variance stabilizing transformation (`DESeq2`) see below), the **spearman** correlation between differentially methylated probes and differentially expressed miRNAs was computed.

###### VST normalization (miRNAs)

> This function calculates a variance stabilizing transformation (VST) from the fitted dispersion-mean relation(s) and then transforms the count data (normalized by division by the size factors or normalization factors), **yielding a matrix of values which are now approximately homoskedastic (having constant variance along the range of mean values). The transformation also normalizes with respect to library size.** 

![Alt text](mimQTL/spearman_heatmap.png?raw=true "Spearman correlation heatmap")



</details>