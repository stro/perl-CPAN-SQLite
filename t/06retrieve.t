# $Id: 06retrieve.t 73 2019-01-23 22:29:38Z stro $

use strict;
use warnings;
use Test::More;
use Cwd;
use File::Spec::Functions;
use File::Path;
use CPAN::DistnameInfo;
use FindBin;
use lib "$FindBin::Bin/lib";
use CPAN::SQLite::Index;
use TestShell;

$ENV{'CPAN_SQLITE_DOWNLOAD'} = $ENV{'CPAN_SQLITE_DOWNLOAD_URL'} = undef;

plan tests => 4;

my $cwd = getcwd;
my $CPAN = catdir $cwd, 't', 'cpan-t-06';

mkdir $CPAN;

ok(-d $CPAN);

my $info = CPAN::SQLite::Index->new(
  'CPAN'    => $CPAN,
  'db_dir'  => $CPAN,
  'urllist' => ['http://search.cpan.org/CPAN/'],
);

isa_ok($info, 'CPAN::SQLite::Index');

SKIP: {
  skip 'Potential connection problems', 2 unless $info->fetch_cpan_indices();

  ok(-e catfile($CPAN, 'authors', '01mailrc.txt.gz'));
  ok(-e catfile($CPAN, 'modules', '02packages.details.txt.gz'));
}
