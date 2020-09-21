use strict;
use warnings;
use File::Basename;
use Getopt::Long;

my ($si_vcf,$td_vcf,$query_seq,$name,$outdir);

GetOptions(
    "si:s" => \$si_vcf,         # Need
    "td:s" => \$td_vcf,         # Need
    "qseq:s" => \$query_seq,    # Need
    "n:s" => \$name,            # Need
    "od:s" => \$outdir,         # Need
    ) or die "unknown args\n";



# filer policy

# for _SI file:
# 1. HOMLEN > 0;
# 2. POS column need to be included by the positions of alt seq 
# 3. alt num >= 2
# 4. SVLEN >= 2

# for _TD file:
# 1. no filter

# seq's region is 13:28600000-28610000
my $seq;
open IN, "$query_seq" or die;
$seq = <IN>;
close IN;
chomp $seq;


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

                    # get all pos of this alt seq
                    my $alt_pos_aref = &find_pos($seq,$alt_seq_raw);
                    my $pos_n = scalar @{$alt_pos_aref};
                    next if ($pos_n == 0); # this alt seq can not find any pos is seq

                    my %alt_pos;
                    for my $p (@{$alt_pos_aref}){

                        $alt_pos{$p} = 1;
                    }

                    if (exists $alt_pos{$arr[1]}){
                        print O "$_\n";
                    }else{
                        next;
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



sub find_pos{
    my ($full_seq,$alt_seq) = @_;
    # start pos of full seq is 28600000 (1-based)
    my @pos; # 1-based
    my $full_len = length($full_seq);
    my $alt_len = length($alt_seq);
    my $right_pos_limit = $full_len - $alt_len; # 0-based
    

    for (my $i=0;$i<=$right_pos_limit;$i++){
        my $sub_seq = substr($full_seq,$i,$alt_len);
        my $mis_n = &mismatch_num(uc($sub_seq),uc($alt_seq));
        if ($mis_n <= 1){ # allow 1 mismatch between ref and alt seq
            my $abs_pos = 28600000 + $i;
            push @pos, $abs_pos;
        }
    }

    return(\@pos);
}


sub mismatch_num{
    my ($seq1,$seq2) = @_;
    my $len_seq = length($seq1);
    my @seq1 = split //, $seq1;
    my @seq2 = split //, $seq2;
    my $mis_n = 0;
    for (my $i=0;$i<=$#seq1;$i++){
        my $a = $seq1[$i];
        my $b = $seq2[$i];
        if ($a ne $b){
            $mis_n += 1;
        }
    }

    return($mis_n);
}