#!/usr/bin/perl

use Mojolicious::Lite;

get '/dirls' => sub {
    my $self = shift;

    use File::Stat::Ls;
    my $physical_folder = $self->param('folder') ? $self->param('folder') : 'public/dl';
    my $o = File::Stat::Ls->new(folder => $physical_folder);
    $self->render('baz', ls => $o, controller_url => '/dirls', physical_folder_as_url => '/dl');
};

app->secret('soap');
app->start;

__DATA__
