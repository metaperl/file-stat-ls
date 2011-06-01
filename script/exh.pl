use lib '../lib';

use File::Stat::Ls;

my $folder = '..';

my $o = File::Stat::Ls->new(folder => $folder);
for my $file ($o->files) {
    
    # get plain-text ls format
    print $file->render_as_html, $/;

}
