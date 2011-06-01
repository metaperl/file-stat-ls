package File::Stat::Ls::Data;

use Moose;

has	 name => (is => 'rw');
has	 isdir =>  (is => 'rw');
has	 formatted_mode =>  (is => 'rw');
has	 number_of_links =>  (is => 'rw'); 
has	 uid =>  (is => 'rw'); 
has	 gid =>  (is => 'rw');
has	 size =>  (is => 'rw');
has	 datetime =>  (is => 'rw');

sub render_as_text {
    my ($self)=@_;


  my @attr = qw(	formatted_mode
			number_of_links
			uid
			gid
			size
			datetime
			name 
	      );


  my $format = "%10s %3d %7s %4s %12d %12s %-26s";  
  return sprintf $format, @$self{@attr};

}

sub render_as_html {
    my ($self)=@_;


  my @attr = qw(	formatted_mode
			number_of_links
			uid
			gid
			size
			datetime
			name 
	      );


    my $format =<<EOFORMAT;
<tr>
<td>%10s</td> 
<td align="right">%3d</td> 
<td>%7s</td> <td>%4s</td>
<td align="right">%12d</td> <td>%12s</td>
<td>%-26s</td>
</tr>
EOFORMAT

  return sprintf $format, @$self{@attr};

}

1;
