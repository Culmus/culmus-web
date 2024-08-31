#!/usr/bin/perl -C63

# This program has been created by Maxim Iorsh (iorsh@users.sourceforge.net).
# It is a PUBLIC DOMAIN - you may do with it anything you wish.

# 27-Sep-08 | iorsh@users.sourceforge.net | Created

my $file = shift;
my ($index_html, $before, $after);

die "Can't find file \"$file\""
  unless -f $file;

{
   local(*INDEX, $/);
   open (INDEX, $file) 	|| die "can't open $file for reading: $!";
   $index_html = <INDEX>;
   close INDEX;
}

$index_html =~ /(^.*<!--_BEGIN_-->).*(<!--_END_-->.*?$)/s;
$before = $1;
$after = $2;

open (IDX_OUT, '>', $file) || die "can't open $file for writing: $!";

$ls_png = `ls *.png`;

my @png_files = split /\.png\n/, $ls_png;

print IDX_OUT $before;
print IDX_OUT "<ul>";

for (my $i = 0; $i < @png_files; $i++)
{
   print IDX_OUT "<li><a href='" . $png_files[$i] . ".png" . "'>" . $png_files[$i] . "</a>";

   if (-f $png_files[$i] . ".txt")
   {
      print IDX_OUT " - <a href='" . $png_files[$i] . ".txt" . "'>" . "\x{05d4}\x{05d5}\x{05e7}\x{05dc}\x{05d3}" . "</a>";

      open (TXT, $png_files[$i] . ".txt");
      my $first_line = <TXT>;
      if ($first_line =~ /^#\x{05e7}(.*)$/)
      {
         print IDX_OUT " \x{05e2}\"\x{05d9} " . $1;
      }
      close TXT;
   }

   print IDX_OUT "</li>\n";
}

print IDX_OUT "</ul>\n";
print IDX_OUT $after;

exit;
