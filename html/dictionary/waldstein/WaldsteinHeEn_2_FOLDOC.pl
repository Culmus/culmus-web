#!/usr/bin/perl -C63

# This program has been created by Maxim Iorsh (iorsh@users.sourceforge.net).
# It is a PUBLIC DOMAIN - you may do with it anything you wish.

# 22-Aug-08 | iorsh@users.sourceforge.net | Created

use strict;
use integer;
use XML::LibXML;
use FileHandle;
binmode(STDOUT, ":utf8");

sub VerbKeysFromImperative;

my $diacritics = "\x{05b0}\x{05b1}\x{05b2}\x{05b3}\x{05b4}\x{05b5}\x{05b6}\x{05b7}\x{05b8}\x{05b9}\x{05ba}\x{05bb}\x{05bc}\x{05c1}\x{05c2}";
my $re_hebword = "[\x{05b0}-\x{05ea}]+";

my $file = shift;
my @dict_lines;
my $line;

die "Can't find file \"$file\""
  unless -f $file;

{
   open (DICT, $file)  || die "can't open $file for reading: $!";
   @dict_lines = <DICT>;
   close DICT;
}

# A hash of the form {definition}=>{key1, key2, ...}
my %reverse_lookup;

foreach $line (@dict_lines)
{
   # Skip comments
   next if $line =~ /^\#/;

   my (@keys, $key, $stripped_line, $poetic, $past, $future, @sublines);

   # Strip trailing spaces, newline, dot
   $line =~ s/[\.\s]*$//s;

   # Extract poetic variations
   if ( $line =~ /\(poet\.(.*?)\)/ )
   {
      $poetic = $1;
   }

   #Extract verb conjugations
   if ( $line =~ /\(($re_hebword),\s*($re_hebword)\)/ )
   {
      $past = $1;
      $future = $2;
   }

   # Strip grammar information located in parentheses
   ($stripped_line = $line) =~ s/\(.*?$re_hebword.*?\)//;

   # The first word is always a key
   ($key) = split (/\s/, $line);
   push @keys, $key;

   # Replace hyphens with the main key - this is a known convention
   # in printed dictionaries.
   $stripped_line =~ s/-/$key/g;

   # Split line into sublines
   @sublines = split (/;\s*/, $stripped_line);

   # Add the main entry into the reverse hash.
   if (!$reverse_lookup{$sublines[0]})
   {
      $reverse_lookup{$sublines[0]} = (); # empty list
   }

   push @{$reverse_lookup{$sublines[0]}}, @keys;

   for (my $i = 1; $i < @sublines; $i++)
   {
      my ($subline, @words, $word, @subkeys);

      $subline = $sublines[$i];

      # Pick all Hebrew words in the subline as subkeys
      @words = split (/\s+/, $subline);

      foreach $word (@words)
      {
         if ($word =~ /^$re_hebword$/)
         {
            push @subkeys, $word;
         }
      }

      # Main keys should point at subentries too.
      push @subkeys, @keys;

      # Add the subentry into the reverse hash.
      if (!$reverse_lookup{$subline})
      {
         $reverse_lookup{$subline} = (); # init with empty list
      }

      push @{$reverse_lookup{$subline}}, @subkeys;
   } 
}

# Clean keys
foreach my $entry (keys %reverse_lookup)
{
   my $keys = \@{$reverse_lookup{$entry}};

   # Remove nikud.
   for (my $i = 0; $i < @{$keys}; $i++)
   {
      $keys->[$i] =~ s/[\x{05b0}-\x{05cf}]//g;
   }

   # Remove duplicate keys
   my %keyhash = map { $_, 1 } @{$keys};
   @{$keys} = keys %keyhash;
}

my %lookup;
# A hash of the form {key}=>{definition1, definition2, ...}
foreach my $entry (keys %reverse_lookup)
{
   my $keys = \@{$reverse_lookup{$entry}};

   for (my $i = 0; $i < @{$keys}; $i++)
   {
      # Add entry into the lookup hash.
      if (!$lookup{$keys->[$i]})
      {
         $lookup{$keys->[$i]} = (); # init with empty list
      }

      push @{$lookup{$keys->[$i]}}, $entry;
   }
}

foreach my $key (sort keys %lookup)
{
#   print $key.":".join("|",@{$lookup{$key}})."\n";

   my @entry = @{$lookup{$key}};

   if ($#entry >= 0)
   {
      print $key . "\n";

      for (my $i = 0; $i <= $#entry; $i++)
      {
         print " " . $entry[$i] . "\n";
      }
   }
}
exit;

sub VerbKeysFromImperative
{
   my ($imper, $subline) = @_;
   my ($male, $haser);

   # strip diacritics
   $imper =~ s/[$diacritics]//g;

   if ($subline =~ /tr\./ || $subline =~ /intr\./)
   {
      # Binyan PA'AL - undotted past is equal to imperative

      $haser = $imper;
   }
   elsif ($subline =~ /nif\./)
   {
      # Binyan NIF'AL - replace He wit Nun to get past, add Yod to get
      # ktiv male.

      ($haser = $imper) =~ s/^\x{05d4}/\x{05e0}/;
      ($male = $imper) =~ s/^\x{05d4}/\x{05e0}\x{05d9}/;
   }
   elsif ($subline =~ /pi\./)
   {
      # Binyan PI'EL - undotted past is equal to imperative.
      # For ktiv male add Yod after the first radical.

      $haser = $imper;
      ($male = $imper) =~ s/^.\K/\x{05d9}/;
   }
   elsif ($subline =~ /pu\./)
   {
      # Binyan PU'AL - undotted past is equal to imperative.
      # For ktiv male add Vav after the first radical.

      $haser = $imper;
      ($male = $imper) =~ s/^.\K/\x{05d5}/;
   }
   elsif ($subline =~ /hif\./)
   {
      # Binyan HIF'IL - insert Yod before lamed-ha-poal for past.
      # Ktiv male is equal to ktiv haser.

      ($haser = $imper) =~ s/(?=.$)/\x{05d9}/;
   }
   elsif ($subline =~ /hof\./)
   {
      # Binyan HUF'AL - undotted past is equal to imperative.
      # For ktiv male insert Vav after starting He.

      $haser = $imper;
      ($male = $imper) =~ s/^\x{05d4}/\x{05d4}\x{05d5}/;
   }
   elsif ($subline =~ /hith\./)
   {
      # Binyan HITPA'EL - undotted past is equal to imperative.
      # Ktiv male is equal to ktiv haser.

      $haser = $imper;
   }

   return ($haser, $male);
}
