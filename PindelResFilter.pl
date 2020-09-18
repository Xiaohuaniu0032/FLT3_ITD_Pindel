use strict;
use warnings;
use File::Basename;
use Getopt::Long;

my ($si_vcf,$td_vcf,$name,$outdir);

GetOptions(
    "si:s" => \$si_vcf,         # Need
    "td:s" => \$td_vcf,         # Need
    "n:s" => \$name,            # Need
    "od:s" => \$outdir,         # Need
    ) or die "unknown args\n";



# filer policy

# for _SI file:
# 1. HOMLEN > 0;
# 2. alt seq is included by HOMSEQ (not used)
# 3. hom seq len >= alt seq len
# 4. alt num >= 2
# 5. SVLEN >= 2

# for _TD file:
# 1. no filter


my $outfile_vcf = "$outdir/$name\.td.final.vcf";

open O, ">$outfile_vcf" or die;

# get header from ins vcf
open INS, "$si_vcf" or die;
while (<INS>){
    chomp;
    if (/^\#/){
        print O "$_\n";
    }else{
        my @arr = split /\t/, $_;
        next if ($arr[0] !~ /13/); # only skep chr13
        next if ($arr[1] < 28600000 || $arr[1] > 28610000);
        next if /HOMLEN=0/;
        if (/HOMSEQ/){
            my $alt_seq_raw = $arr[4];
            my $alt_seq_new = substr($alt_seq_raw,1);
            my $alt_len = length($alt_seq_new);
            my $info = $arr[-3];
            my @info = split /;/, $info;
            for my $item (@info){
                if ($item =~ /HOMSEQ/){
                    my $hom_seq = (split /=/, $item)[1];
                    my $hom_len = length($hom_seq);
                    my $alt_num = (split /\,/, $arr[-1])[1];
                    next if ($alt_num <= 1);
                    
                    if (/SVLEN=1/){
                        next;
                    }
                    
                    if ($hom_len >= $alt_len){
                        print O "$_\n";
                    }
                }
            }
        }
    }
}
close INS;

open DUP, "$td_vcf" or die;
while (<DUP>){
    chomp;
    next if /^\#/;
    my @arr = split /\t/, $_;
    next if ($arr[0] !~ /13/); # only skep chr13
    next if ($arr[1] < 28600000 || $arr[1] > 28610000);
    print O "$_\n";
}
close DUP;

close O;

