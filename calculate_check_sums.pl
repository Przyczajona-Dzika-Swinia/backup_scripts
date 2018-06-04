#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use File::Slurp;
use Digest::SHA qw(sha1_hex);
use Cwd 'abs_path';

# Skrypt do obliczania sum kontrlonych archiwizowanych plików

my $czas_start = time;

######  Argumenty skryptu  ######

my $ilosc_argumentow = $#ARGV + 1;
if ($ilosc_argumentow != 2) {
    print "\nUżycie: oblicz_sumy_kontrolne.pl ścieżka_do_katalogu plik_wynikowy\n";
    exit;
}

my $sciezka = $ARGV[0];
my $plik_wynikowy = $ARGV[1];

print "\nWprowadzona ścieżka: $sciezka\n";
print "Wprowadzony plik:    $plik_wynikowy\n\n";

######  Przygotowanie  ######

open(my $PLIK, '>', $plik_wynikowy) or die "Nie można otworzyć pliku $plik_wynikowy: $!";

my $ilosc_plikow = 0;
my @nazwy_plikow = ();
my $powtarzajace_sie_pliki = "";

print $PLIK "    Suma SHA1                                   Nazwa pliku\n";
print $PLIK "    =======================================================\n";

######  Wykonanie  ######

sub sortowanie {
    return sort @_;
}

sub akcja {
    if (-d) {                   # gdy katalog
        print $PLIK "\nkatalog: $_\n";
        print abs_path($_), "\n";
    } else {                    # gdy plik
        my $nazwa_pliku = $_;
        $ilosc_plikow++;

        my $zawartosc = read_file($nazwa_pliku);
        my $suma_sha = sha1_hex($zawartosc);

        print $PLIK "    $suma_sha    $nazwa_pliku\n";

        if (grep(/$nazwa_pliku/, @nazwy_plikow)) { # jeśli nazwa pliku się powtarza
           $powtarzajace_sie_pliki = $powtarzajace_sie_pliki . $nazwa_pliku . "\n";
        } else {
           push(@nazwy_plikow, $nazwa_pliku);
        }
    }
}

find({ preprocess => \&sortowanie,
       wanted     => \&akcja},
     $sciezka);

######  Zakończenie  ######

if ($powtarzajace_sie_pliki ne "") {
   print "\nPowtarzające się nazwy plików:\n", $powtarzajace_sie_pliki;
} else {
   print "\nWszystkie nazwy plików są unikatowe.\n";
}

my $dlugosc = time - $czas_start;

print $PLIK "\nIlość plików: $ilosc_plikow\n";
print $PLIK "Obliczenie sum kontrolnych zajęło: $dlugosc s\n";

my ($dzien, $miesiac, $rok) = (localtime)[3,4,5];
print $PLIK "Data: ", $dzien, ".", sprintf("%02d", $miesiac+1) , ".", $rok+1900;

close $PLIK;

print "\nIlość plików: $ilosc_plikow\n";
print "Obliczenie sum kontrolnych zajęło: $dlugosc s\n";

