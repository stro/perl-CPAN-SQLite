#!/usr/bin/perl

use strict;
use warnings;
use 5.010;
use Carp;
use File::Copy;
use File::Spec;

my ($old, $new) = @ARGV;

if (defined $old and defined $new) {
  say 'Changing version from ', $old, ' to ', $new;

  my @files = ('dist.ini', 'bin/cpandb', find_pm('lib'));

  foreach my $file (@files) {
    open(my $FIN, '<', $file) or fail('Cannot open file ', $file, ':', $!);
    local $/;
    my $content = <$FIN>;
    close $FIN or fail('Cannot close file ', $file, ':', $!);

    $content =~ s/$old/$new/g;
    $content =~ s/\n\r/\n/g;

    if (-e $file . '.bak') {
      unlink($file . '.bak') or fail('Cannot open file ', $file, '.bak:', $!);
    }
    File::Copy::move($file => $file . '.bak') or fail('Cannot backup file ', $file, ':', $!);
    open(my $FOUT, '>', $file) or fail('Cannot write file ', $file, ':', $!);
    binmode $FOUT;
    print $FOUT $content;
    close $FOUT or fail('Cannot close file ', $file, ':', $!);
    say $file;
  }
} else {
  say 'Usage: bump_version.pl <old_version> <new_version>';
}

sub fail {
  Carp::longcarp(@_);
}

sub find_pm {
  my ($dir) = @_;

  opendir(my $DIR => $dir);
  my @files = grep { !/^\./ } readdir($DIR);
  closedir $DIR;

  my @pm = map { File::Spec->catfile($dir, $_) } grep { /\.pm$/ } @files;

  foreach my $subdir (grep { -d File::Spec->catfile($dir, $_) } @files) {
    push @pm, find_pm(File::Spec->catfile($dir, $subdir));
  }

  return @pm;
}
