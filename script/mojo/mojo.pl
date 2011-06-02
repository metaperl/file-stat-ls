#!/usr/bin/perl

use Mojolicious::Lite;

get '/dirls' => sub {
    my $self = shift;

    use File::Stat::Ls;
    my $physical_folder = $self->param('folder') ? $self->param('folder') : 'public/dl';
    my $physical_folder_as_url = do {
	my @part = split '/', $physical_folder;
	"/" . join '/', @part[1..$#part];
    };
    my $o = File::Stat::Ls->new(folder => $physical_folder);
    $self->render('baz', ls => $o, controller_url => '/dirls', physical_folder_as_url => $physical_folder_as_url);
};

app->secret('soap');
app->start;

__DATA__
