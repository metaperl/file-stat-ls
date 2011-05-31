use File::Stat::Ls;

my $obj = File::Stat::Ls->new;
my $ls = $obj->ls_stat('t');

warn $ls;
