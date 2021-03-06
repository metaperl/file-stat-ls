#!/usr/bin/perl

use Mojolicious::Lite;

get '/dirls'           => \&bo_action;
get '/dirls/(*folder)' => \&bo_action;

my $default = 'public';

sub bo_action {
  my $self = shift;

  use File::Stat::Ls;
  my $physical_folder = $self->param('folder') ? $self->param('folder') : 'public';
 
  $self->redirect_to("/dirls/$default") if $physical_folder =~ /\.\.?/;

  my $o = File::Stat::Ls->new(folder => $physical_folder);
  my @o = $o->files;

  $self->render('webpage', ls => $o, controller_url => "/dirls", physical_folder => $physical_folder);
};

app->secret('HOHOHAHAHA')->start;

__DATA__

@@ webpage.html.ep
<!doctype html>
<html>
  <head><title>LS</title></head>
  <body>
    <table>
      <% for my $file ($ls->files) { %>
      <%== $file->render_as_html($physical_folder, $controller_url) %>				     
      <% } %>
    </table>
  </body>
</html>
