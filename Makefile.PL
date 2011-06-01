use inc::Module::Install;

# metadata
name 'File-Stat-Ls';
all_from 'lib/File/Stat/Ls.pm';

# data
author 'Terrence Brannon';
abstract 'Perl class for converting stat to ls -l format';
include 'Module::AutoInstall';

# deps
requires 'Moose';

WriteAll;
