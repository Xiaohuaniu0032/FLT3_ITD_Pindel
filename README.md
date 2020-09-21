# FLT3\_ITD_Pindel
detect FLT3-internal tandem duplication using Pindel

## Usage
`perl /path/FLT3_ITD_Pindel/TandemDupScan.pl -bam <bam file> -n <name> -flen <fragment length> -fa <fasta> -pindel <path to binary pindel> -od <outdir>`

### paramerter specification

`-bam`: bam file

`-n`: sample name

`-flen`: DNA fragment length. default: 500

`-fa`: fasta file

`-pindel`: binary pindel

`-od`: output dir

## Testing
1. `cd /path/FLT3_ITD_Pindel/test/res`
2. `sh run.sh`
3. `sh test.pindel.sh >log 2>&1 &`

### result files
```
-rw-r--r--  1 lffu  staff    24K  9 18 14:55 log
-rw-r--r--  1 lffu  staff    85B  9 18 14:55 pinde.cfg
-rw-r--r--  1 lffu  staff    66B  9 18 14:55 run.sh
-rw-r--r--  1 lffu  staff   1.1K  9 18 14:55 test.ins.vcf
-rw-r--r--  1 lffu  staff   1.0K  9 18 14:55 test.pindel.sh
-rw-r--r--  1 lffu  staff   1.7K  9 18 14:55 test.td.final.vcf
-rw-r--r--  1 lffu  staff   1.8K  9 18 14:55 test.td.vcf
-rw-r--r--  1 lffu  staff     0B  9 18 14:55 test_BP
-rw-r--r--  1 lffu  staff     0B  9 18 14:55 test_CloseEndMapped
-rw-r--r--  1 lffu  staff     0B  9 18 14:55 test_D
-rw-r--r--  1 lffu  staff     0B  9 18 14:55 test_INT_final
-rw-r--r--  1 lffu  staff   3.8K  9 18 14:55 test_INV
-rw-r--r--  1 lffu  staff     0B  9 18 14:55 test_LI
-rw-r--r--  1 lffu  staff     0B  9 18 14:55 test_RP
-rw-r--r--  1 lffu  staff     0B  9 18 14:55 test_SI
-rw-r--r--  1 lffu  staff    76K  9 18 14:55 test_TD
```

### Note

* short tandem dup will be stored in _SI file

* long tandem dup will be stored in _TD file


`*.ins.vcf`: short tandem dup vcf file

`*.td.vcf`: long tandem dup vcf file

`*.td.final.vcf`: final tandem dup vcf file


## filter process

### for _SI file
1. HOMLEN > 0
2. ref POS column need to be included by the positions of alt seq
3. alt num >= 2
4. SVLEN >= 2

>*step2 details*

 #1. get **ins seq** from ALT column in `*.ins.vcf`
 
 #2. find all positions of **ins seq** in ref (allow one mismatch)
 
 #3. check if POS column in `*.ins.vcf` is included by the finded postions in #2
 
 #4. if the POS column is included, then this variant will output in the final result file `*.td.final.vcf`

### for _TD file
1. no filter


## about Pindel

#### *install*
`conda install -c bioconda pindel`


#### *origin paper*
`Pindel: a pattern growth approach to detect break points of large deletions and medium sized insertions from paired-end short reads, Bioinfomatics, 2009`


#### *source code*
`https://www.sanger.ac.uk/tool/pindel/`

`https://github.com/genome/pindel`




