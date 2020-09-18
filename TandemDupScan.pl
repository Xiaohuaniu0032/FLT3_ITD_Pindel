use strict;
use warnings;
use File::Basename;
use FindBin qw/$Bin/;
use Getopt::Long;
use Cwd 'abs_path';

my ($bam,$name,$frag_len,$fa,$fa_version,$pindel_bin,$outdir);

GetOptions(
    "bam:s" => \$bam,                 # Need
    "n:s" => \$name,                  # Optional (default:<name>.bam)
    "flen:i" => \$frag_len,           # Optional (default: 500)
    "fa:s" => \$fa,                   # Optional (default: /data1/database/b37/human_g1k_v37.fasta)
    "fa_v:s" => \$fa_version,         # Optional (default: hg19)
    "pindel:s" => \$pindel_bin,       # Optional (default: /home/fulongfei/miniconda3/bin/pindel)
    "od:s" => \$outdir,               # Need
    ) or die "unknown args\n";



# check args

# default value
if (not defined $name){
    $name = (split /\./, basename $bam)[0];   
}

if (not defined $frag_len){
    $frag_len = 500; # this value is suggest by pindel author when you do not know your NGS lib fragment length
}

if (not defined $fa){
    $fa = "/data1/database/b37/human_g1k_v37.fasta";
}

if (not defined $fa_version){
    $fa_version = "hg19";
}

if (not defined $pindel_bin){
    $pindel_bin = "/home/fulongfei/miniconda3/bin/pindel";
}

if (!-d $outdir){
    `mkdir -p $outdir`;
}

# detect chr naming
my $chr_naming;
open FA, "$fa" or die;
my $first_line = <FA>;
close FA;

if ($first_line =~ /^\>\d/){
    $chr_naming = "no_chr_prefix"
}else{
    $chr_naming = "with_chr_prefix";
}


# FLT3 exon13-15 region
my $region;
if ($chr_naming eq "no_chr_prefix"){
    $region = "13:28608000-28609000";
}else{
    $region = "chr13:28608000-28609000";
}


# make pindel cfg file
my $abs_bam = abs_path($bam);
my $pindel_cfg = "$outdir/pinde.cfg";
open O, ">$pindel_cfg" or die;
print O "$abs_bam\t$frag_len\t$name\n";
close O;

my $runsh = "$outdir/$name\.pindel.sh";
open O, ">$runsh" or die;
print O "$pindel_bin -f $fa -i $pindel_cfg -o $outdir/$name -c $region\n";
my $short_ins = "$outdir/$name\_SI"; # short dup will be in _SI file
my $td = "$outdir/$name\_TD"; # long dup will be in _TD file
my $pindel_dir = dirname($pindel_bin);
my $pindel2vcf = "$pindel_dir/pindel2vcf";
my $fa_name = (split /\./, basename $fa)[0];
print O "$pindel2vcf -p $short_ins -r $fa -R $fa_name -d 2009 -v $outdir/$name\.ins.vcf\n";
print O "$pindel2vcf -p $td -r $fa -R $fa_name -d 2009 -v $outdir/$name\.td.vcf\n";


# filter result
print O "perl $Bin/PindelResFilter.pl \n";
close O;





