#!/usr/bin/perl
use strict;
use warnings;
# use Data::Dumper qw(Dumper);

######  Arguments  ######

my $num_of_args = $#ARGV + 1;
if ($num_of_args != 2) {
    print "\nUsage: compare_check_sums.pl old_checksums_file new_checksums_file\n";
    exit;
}

my $old_checksums_path = $ARGV[0];
my $new_checksums_path = $ARGV[1];

######  Preparation  ######

open(my $OLD_FILE, '<', $old_checksums_path) or die "Can not open file $old_checksums_path: $!";
open(my $NEW_FILE, '<', $new_checksums_path) or die "Can not open file $new_checksums_path: $!";

######  Reading of log files  ######

# array format:
# [i][0] - sha1 sum
# [i][1] - file name
# [i][2] - found
my @matrix_old = ();
my @matrix_new = ();

read_list_of_checksums($OLD_FILE, $old_checksums_path, \@matrix_old);
read_list_of_checksums($NEW_FILE, $new_checksums_path, \@matrix_new);

######  Execution  ######

my $matching_files = "";
my $not_matching_files = "";
my $number_of_matching_files = 0;
my $number_of_not_matching_files = 0;

foreach my $newer_file (@matrix_new) {
   foreach my $older_file (@matrix_old) {
      if (@$newer_file[1] eq @$older_file[1]) {
         if (@$newer_file[0] eq @$older_file[0]) {     # SHA1 sums are matching
            @$newer_file[2] = 'matching';
            @$older_file[2] = 'matching';
            $number_of_matching_files++;
            $matching_files .= "@$newer_file[1]\n";
         } else {                                      # SHA1 sums are not matching
            @$newer_file[2] = 'different_checksum';
            @$older_file[2] = 'different_checksum';
            $number_of_not_matching_files++;
            $not_matching_files .= "@$newer_file[1]\n";
         }
         last;                     # TODO improve this to handle files with non-unique names
      }
   }
}

print "Files with matching checksums:\n$matching_files";
print "Number: $number_of_matching_files\n\n";

print "Files with not matching checksums:\n$not_matching_files";
print "Number: $number_of_not_matching_files\n\n";

print_deleted_and_new_files(\@matrix_old, \@matrix_new);

######  Finish  ######

close $OLD_FILE;
close $NEW_FILE;

######  Functions  ######

sub read_list_of_checksums {

   my ($FILE, $path, $matrix_ref) = @_;

   print "Reading list of checksums: $path\n";

   my $i = 0;
   my $not_fitting_lines = "";

   while(my $row = <$FILE>) {

      if ($row =~ m/^\s{4}([0-9a-f]{40})\s{4}(.+)/) {
         ${$matrix_ref}[$i][0] = $1;
         ${$matrix_ref}[$i][1] = $2;
         ${$matrix_ref}[$i][2] = '-';
         $i++;
      } else {
         if (($row ne "\n") && ($row ne ".\n") &&               # TODO improve this
             ($row ne "    SHA1 sum                                      File name\n") &&
             ($row ne "    =======================================================\n")) {
#         if ($row =~ m/^\s{4}/) {
            $not_fitting_lines .= $row;
         }
      }
   }

   print "Number of files: $i\n\n";

   if ($not_fitting_lines ne "") {
      print "Not fitting lines:\n";
      print $not_fitting_lines, "\n\n";
   }
}

sub print_deleted_and_new_files {

   my ($old_ref, $new_ref) = @_;

   print "Removed files:\n";
   my $number_of_removed_files = 0;

   foreach my $file (@{$old_ref}) {
      if (@$file[2] eq '-') {
         print @$file[1], "\n";
         $number_of_removed_files++;
      }
   }

   if ($number_of_removed_files == 0) {
      print "-\n";
   } else {
      print ">>> Number of removed files: $number_of_removed_files\n";
   }

   print "\nNew files:\n";
   my $number_of_new_files = 0;

   foreach my $file (@{$new_ref}) {
      if (@$file[2] eq '-') {
         print @$file[1], "\n";
         $number_of_new_files++;
      }
   }

   if ($number_of_new_files == 0) {
      print "-\n";
   } else {
      print ">>> Number of new files: $number_of_new_files\n";
   }
}

