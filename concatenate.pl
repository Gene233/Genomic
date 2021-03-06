#!usr/bin/perl
use warnings;
use strict;
use autodie;
use Getopt::Long;

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#

=head1 NAME

concatenate.pl - Concatenate fasta/fastaq/ files according to the strains and insert 'N' as missing value.(In proteins data could replace 'N' with 'X' or other character)

=head1 SYNOPSIS

    perl concatenate.pl -i input_file -o output_file [options]
      Options:
        --help      -?          brief help message
        --input     -i  STR     input filename. Default is [stdin] for screen
        --outfile   -o  STR     output filename. Default is [stdout] for screen
        
=head1 EXAMPLE
        
    perl concatenate.pl -i test.fasta -o out.fasta
    
=cut

GetOptions(
    'help|?' => sub { Getopt::Long::HelpMessage(0) },
    'input|i=s' => \( my $infile = 'stdin' ),
    'outfile|o=s' => \( my $outfile = 'stdout' ),
) or Getopt::Long::HelpMessage(1);

my $in_fh;
if (lc($outfile) eq "stdin"){
    $in_fh = *STDIN;
}
else{
    open $in_fh, "<", $infile || die "$!: The file $infile can't be opened.\n";
}

my $strain = '';
my $bp = {};
my $seq = {};
while(<$in_fh>){
    chomp;
    if(/^>(.*)\:(\d+)-(\d+)/){
        $strain = $1;
        if($bp->{$strain}){
            my $n = $2 - $bp->{$strain}->[1] - 1;
            $seq->{$strain} .= "N" x $n;
        }
        $bp->{$strain} = [$2, $3];
        next;
    }
    $seq->{$strain} .= $_;
}
close $in_fh;

my $out_fh;
if (lc($outfile) eq "stdout"){
    $out_fh = *STDOUT;
}
else{
    open $out_fh, ">", $outfile || die "$!: Can't write output into $outfile.\n";
}
foreach my $s (keys %{$seq}){
    print {$out_fh} ">$s:1-$bp->{$s}->[1]\n";
    print {$out_fh} "$seq->{$s}\n\n";
}
close $out_fh;

