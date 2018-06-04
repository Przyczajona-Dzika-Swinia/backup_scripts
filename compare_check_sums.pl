#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper qw(Dumper);

######  Argumenty skryptu  ######

my $ilosc_argumentow = $#ARGV + 1;
if ($ilosc_argumentow != 2) {
    print "\nUżycie: porownaj_sumy_kontrolne.pl stare_sumy nowe_sumy\n";
    exit;
}

my $sciezka_stare = $ARGV[0];
my $sciezka_nowe  = $ARGV[1];

######  Przygotowanie  ######

open(my $STARE, '<', $sciezka_stare) or die "Nie można otworzyć pliku $sciezka_stare: $!";
open(my $NOWE, '<', $sciezka_nowe) or die "Nie można otworzyć pliku $sciezka_nowe: $!";

######  Wczytanie plików  ######

# format tablic:
# [i][0] - sha1
# [i][1] - nazwa pliku
# [i][2] - znaleziony
my @matrix_stare = ();
my @matrix_nowe = ();

wczytaj_liste_z_haszami($STARE, $sciezka_stare, \@matrix_stare);
wczytaj_liste_z_haszami($NOWE, $sciezka_nowe, \@matrix_nowe);

######  Wykonanie porównania  ######

my $pasujace_pliki = "";
my $niepasujace_pliki = "";
my $ilosc_pasujacych_plikow = 0;
my $ilosc_niepasujacych_plikow = 0;

foreach my $plik (@matrix_nowe) {
   foreach my $drugi_plik (@matrix_stare) {
      if (@$plik[1] eq @$drugi_plik[1]) {
         if (@$plik[0] eq @$drugi_plik[0]) {
            @$plik[2] = 'pasuje';
            @$drugi_plik[2] = 'pasuje';
            $ilosc_pasujacych_plikow++;
            $pasujace_pliki .= "@$plik[1]\n";
         } else {
            @$plik[2] = 'inny_hash';
            @$drugi_plik[2] = 'inny_hash';
            $ilosc_niepasujacych_plikow++;
            $niepasujace_pliki .= "@$plik[1]\n";
         }
         last;
      }
   }
}

print "Pliki z pasującymi hashami:\n$pasujace_pliki";
print "Ilość: $ilosc_pasujacych_plikow\n\n";

print "Pliki z niepasującymi hashami:\n$niepasujace_pliki";
print "Ilość: $ilosc_niepasujacych_plikow\n\n";

wyswietl_usuniete_i_nowe(\@matrix_stare, \@matrix_nowe);

######  Zakończenie  ######

close $STARE;
close $NOWE;

######  Funkcje  ######

sub wczytaj_liste_z_haszami {

   my ($FILE, $sciezka, $matrix_ref) = @_;

   print "Wczytywanie listy z haszami: $sciezka\n";

   my $i = 0;
   my $linie_niepasujace = "";

   while(my $linia = <$FILE>) {

      if ($linia =~ m/^\s{4}([0-9a-f]{40})\s{4}(.+)/) {
         ${$matrix_ref}[$i][0] = $1;
         ${$matrix_ref}[$i][1] = $2;
         ${$matrix_ref}[$i][2] = 'nie';
         $i++;
      } else {
         if (($linia ne "\n") && ($linia ne ".\n") &&
             ($linia ne "    Suma SHA1                                   Nazwa pliku\n") &&
             ($linia ne "    =======================================================\n")) {
#         if ($linia =~ m/^\s{4}/) {
            $linie_niepasujace .= $linia;
         }
      }
   }

   print "Ilość plików: $i\n\n";

   if ($linie_niepasujace ne "") {
      print "Linie niepasujące:\n";
      print $linie_niepasujace, "\n";
   }
}

sub wyswietl_usuniete_i_nowe {

   my ($stare_ref, $nowe_ref) = @_;

   print "Pliki usunięte:\n";
   my $ilosc_usunietych = 0;

   foreach my $plik (@{$stare_ref}) {
      if (@$plik[2] eq 'nie') {
         print @$plik[1], "\n";
         $ilosc_usunietych++;
      }
   }

   if ($ilosc_usunietych == 0) {
      print "-\n";
   } else {
      print ">>> Ilość usuniętych plików: $ilosc_usunietych\n";
   }

   print "\nPliki nowe:\n";
   my $ilosc_nowych = 0;

   foreach my $plik (@{$nowe_ref}) {
      if (@$plik[2] eq 'nie') {
         print @$plik[1], "\n";
         $ilosc_nowych++;
      }
   }

   if ($ilosc_nowych == 0) {
      print "-\n";
   } else {
      print ">>> Ilość nowych plików: $ilosc_nowych\n";
   }
}

