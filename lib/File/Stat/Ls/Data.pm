package File::Stat::Ls::Data;

use Moose;

has	 folder => (is => 'rw', required => 1);
has	 name => (is => 'rw');
has	 isdir =>  (is => 'rw');
has	 formatted_mode =>  (is => 'rw');
has	 number_of_links =>  (is => 'rw'); 
has	 uid =>  (is => 'rw'); 
has	 gid =>  (is => 'rw');
has	 size =>  (is => 'rw');
has	 datetime =>  (is => 'rw');

use File::Spec;


my @attr = qw(	formatted_mode
		number_of_links
		uid
		gid
		size
		datetime
		name 
	    );


sub render_as_text {
  my ($self)=@_;

  my $format = "%10s %3d %7s %4s %12d %12s %-26s";
  return sprintf $format, @$self{@attr};

}

sub render_as_html {
  my ($self, $physical_folder, $controller_url)=@_;

  my $filelink;
  if ($self->isdir) {
    $filelink = sprintf '<a href="%s">%s</a>',
      make_folder_url($controller_url, $self->folder , $self->name), $self->name;
  } else {
    $filelink = sprintf '<a href="%s">%s</a>',
      make_file_url($self->folder, $self->name), $self->name;
  }

  my $format =<<EOFORMAT;
    <tr>
	<td>%10s</td> 
	<td align="right">%3d</td> 
	<td>%7s</td> <td>%4s</td>
	<td align="right">%12d</td> 
	<td align="right">%12s</td>
	<td>$filelink</td>
	</tr>
EOFORMAT

  return sprintf $format, @$self{@attr};
}

sub folder_deconstruct {
  my($folder)=@_;
  my @part = split qr![/\\]!, $folder;
}
sub make_file_url {
  my($physical_folder, $filename)=@_;

  my $url = do {
    my @part = folder_deconstruct($physical_folder);
    join '/', @part[1..$#part];
  };

  "/$url/$filename";
}

sub make_folder_url {
  my($controller_url, $physical_folder, $filename)=@_;

  my $url = do {
    my @part = folder_deconstruct($physical_folder);
    join '/', @part;
  };

  "$controller_url/$url/$filename";
}

1;

