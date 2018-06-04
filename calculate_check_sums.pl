#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use File::Slurp;
use Digest::SHA qw(sha1_hex);
use Cwd 'abs_path';

# Script for calculation of check sums of archived files

my $start_time = time;

######  Arguments  ######

my $num_of_args = $#ARGV + 1;
if ($num_of_args != 2) {
    print "\nUsage: calculate_check_sums.pl directory_path result_file\n";
    exit;
}

my $dir_path = $ARGV[0];
my $output_file = $ARGV[1];

print "\nDirectory path to process: $dir_path\n";
print   "Output file:               $output_file\n\n";

######  Preparation  ######

open(my $FILE, '>', $output_file) or die "Can not open file $output_file: $!";

my $number_of_files = 0;
my @filenames = ();
my $repeating_filenames = "";

print $FILE "    SHA1 sum                                    File name\n";
print $FILE "    =====================================================\n";

######  Execution  ######

sub sorting {
    return sort @_;
}

sub action {
    if (-d) {                            # when a directory
        print $FILE "\ndirectory: $_\n";
        print abs_path($_), "\n";
    } else {                             # when a file
        my $file_name = $_;
        $number_of_files++;

        my $contents = read_file($file_name);
        my $suma_sha = sha1_hex($contents);

        print $FILE "    $suma_sha    $file_name\n";

        if (grep(/$file_name/, @filenames)) { # when the file name is repeating
           $repeating_filenames = $repeating_filenames . $file_name . "\n";
        } else {
           push(@filenames, $file_name);
        }
    }
}

find({ preprocess => \&sorting,
       wanted     => \&action},
     $dir_path);

######  Finish  ######

if ($repeating_filenames ne "") {
   print "\nRepeating file names:\n", $repeating_filenames;
} else {
   print "\nAll File names are unique.\n";
}

my $duration = time - $start_time;

print $FILE "\nNumber of files: $number_of_files\n";
print $FILE "Calculation of check sums took: $duration s\n";

my ($day, $month, $year) = (localtime)[3,4,5];
print $FILE "Calculation date: ", $day, ".", sprintf("%02d", $month+1) , ".", $year+1900;

close $FILE;

print "\nNumber of files: $number_of_files\n";
print "Calculation of check sums took: $duration s\n";

