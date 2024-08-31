#!/usr/bin/perl

# This program has been created by Maxim Iorsh (iorsh@math.technion.ac.il).
# It is a PUBLIC DOMAIN - you may do with it anything you wish.

# The purpose of this program is to create a paragraph of meaningless
# combinations of Hebrew letters with one very special property: each couple
# of letters appears inside this paragraph at least once in each order. This
# property would help you to kern Hebrew fonts: you simply typeset it in a
# font of your choice, and than observe carefully the printed text in order
# to reveal character pairs which are too close or too far from each other.

# Enjoy!

# Created at December 03, 2003; tested with Perl 5.004_03 on Solaris 9.

use strict;
binmode(STDOUT, ":utf8");

my @lettergrid;
my ($i, $last, $mixline);

# Initialize array of pairs of letters:
# 0x05D0 is for aleph .. 0x05EA is for tav
foreach $i (0x05D0 .. 0x05EA)
{
	push @lettergrid, ($i*65536+0x05D0 .. $i*65536+0x05EA) ;
}

$last = $#lettergrid;

# Mix the array randomally
for $i (0 .. $last)
{
	my $r = int(rand($last - $i + 1));
	my $tmp = $lettergrid[$last - $i];
	$lettergrid[$last - $i] = $lettergrid[$r];
	$lettergrid[$r] = $tmp;
}

# Convert each element to a pair of letters and append to a string
$mixline = "";
for $i (0 .. $last)
{
	$mixline = $mixline.chr($lettergrid[$i]%65536).chr($lettergrid[$i]/65536);
}

# From now on - pretty printing attempts

# Put a space after each "sofit" letter
$mixline =~ s/\x05DA/\x05DA /g;	# final kaf
$mixline =~ s/\x05DD/\x05DD /g;	# final mem
$mixline =~ s/\x05DF/\x05DF /g;	# final nun
$mixline =~ s/\x05E3/\x05E3 /g;	# final pe
$mixline =~ s/\x05E5/\x05E5 /g;	# final tsadi

# Remove standalone sofiyot letters
$mixline =~ s/ [\x05DA\x05DD\x05DF\x05E3\x05E5]//g;

# Split character sequences longer than 6 letters. Hopefully this will not
# destroy any unique couple of letters
# $mixline =~ s/(\S{6})/$1 /g;

print $mixline;
print "\n"

