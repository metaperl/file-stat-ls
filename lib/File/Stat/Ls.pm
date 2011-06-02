package File::Stat::Ls;

use Moose;

use Carp;
use IO::Dir;

use POSIX qw(strftime);

use File::Stat::Ls::Data;

our $VERSION = 0.12;
my %file;

has 'folder' => (is => 'rw', required => 1);
has 'skipdotfiles' => (is => 'rw', default => 1);
has 'onwindows' => (is => 'rw');

sub BUILD {
    my ($self)=@_;
    tie %file, 'IO::Dir', $self->folder;

    if ($^O =~ /Win32/) {
	$self->onwindows(1);
	require Win32;
    }
}

sub files {
    my($self)=@_;

    my @object;
    for my $file (sort keys %file) {
	next if $self->skipdotfiles and $file =~ /^[.][.]?$/ ;
	my $object = $self->attr($file, $file{$file}, $self->folder);
	push @object, $object;
    }
    @object;
}

sub attr {
    my ($self, $filename,$filestat, $folder) = @_;

    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks) = @$filestat;

    my $dateformat = "%b %d  %Y";
    my $ud = $self->onwindows ? Win32::LoginName() : getpwuid($uid);
    my $gd = $self->onwindows ? 'unknown' : getpwuid($uid);
    my $fm = format_mode($mode); 
    my $mt = strftime $dateformat,localtime $mtime; 
    my $isdir = $fm =~ /^d/ ? 1 : 0 ;
    my %attr = 
	(
	 s => $filestat,
	 folder => $folder,
	 name => $filename,
	 isdir => $isdir,
	 formatted_mode => $fm,
	 number_of_links => $nlink,
	 uid => $ud,
	 gid => $gd,
	 size => $size,
	 datetime => $mt,
	 filename => $filename
	);

    use Data::Dumper;
    warn Dumper(\%attr);

    File::Stat::Ls::Data->new(%attr);

}


# ------ partial inline of Stat::lsMode v0.50 code
# (see http://www.plover.com/~mjd/perl/lsMode/
# for the complete module)
#
#
# Stat::lsMode
#
# Copyright 1998 M-J. Dominus
# (mjd-perl-lsmode@plover.com)
#
# You may distribute this module under the same terms as Perl itself.
#
# $Revision: 1.2 $ $Date: 2004/08/05 14:17:43 $

sub format_mode {

    my $mode = shift;
    my %opts = @_;

    my @perms = qw(--- --x -w- -wx r-- r-x rw- rwx);
    my @ftype = qw(. p c ? d ? b ? - ? l ? s ? ? ?);
    $ftype[0] = '';
    my $setids = ($mode & 07000)>>9;
    my @permstrs = @perms[($mode&0700)>>6, ($mode&0070)>>3, $mode&0007];
    my $ftype = $ftype[($mode & 0170000)>>12];
    
    if ($setids) {
	if ($setids & 01) {         # Sticky bit
	    $permstrs[2] =~ s/([-x])$/$1 eq 'x' ? 't' : 'T'/e;
	}
	if ($setids & 04) {         # Setuid bit
	    $permstrs[0] =~ s/([-x])$/$1 eq 'x' ? 's' : 'S'/e;
	}
	if ($setids & 02) {         # Setgid bit
	    $permstrs[1] =~ s/([-x])$/$1 eq 'x' ? 's' : 'S'/e;
	}
    }
    
    join '', $ftype, @permstrs;
}

sub ls_stat {
    my $s = ref($_[0]) ? shift : (File::Stat::Ls->new);
    my $fn = shift; 

    -e $fn or die "Error opening $fn: $!";

    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
        $atime,$mtime,$ctime,$blksize,$blocks) = lstat $fn;
    my @a = lstat $fn; 
    my $dft = "%b %d  %Y";
    my $ud = getpwuid($uid);
    my $gd = getgrgid($gid); 
    my $fm = format_mode($mode); 
    my $mt = strftime $dft,localtime $mtime; 
    my $fmt = "%10s %3d %7s %4s %12d %12s %-26s\n";  
    return sprintf $fmt, $fm,$nlink,$ud,$gd,$size,$mt,$fn;
}



sub stat_attr {
    my $s = ref($_[0]) ? shift : (File::Stat::Ls->new);
    my ($fn,$typ) = @_; 
    croak "ERR: no file name for stat_attr.\n" if ! $fn;
    return undef if ! $fn;
    my $vs  = 'dev,ino,mode,nlink,uid,gid,rdev,size,atime,mtime,';
    $vs .= 'ctime,blksize,blocks';
    my $v1  = 'flags,perm,uid,gid,size,atime,mtime';
    my $ls = ls_stat $fn;  chomp $ls;
    my @a = (); my @v = (); 
    my $attr = {};
    if ($typ && $typ =~ /SFTP/i) {
        @v = split /,/, $v1; 
        @a = (stat($fn))[1,2,4,5,7,8,9];
        %$attr = map { $v[$_] => $a[$_] } 0..$#a ;
        # 'SSH2_FILEXFER_ATTR_SIZE' => 0x01,
        # 'SSH2_FILEXFER_ATTR_UIDGID' => 0x02,
        # 'SSH2_FILEXFER_ATTR_PERMISSIONS' => 0x04,
        # 'SSH2_FILEXFER_ATTR_ACMODTIME' => 0x08,
        $attr->{flags} = 0; 
        $attr->{flags} |= 0x01; 
        $attr->{flags} |= 0x02; 
        $attr->{flags} |= 0x04; 
        $attr->{flags} |= 0x08; 
        return wantarray ? %{$attr} : $attr;
    } else { 
        @v = split /,/, $vs; 
        @a = stat($fn);
        %$attr = map { $v[$_] => $a[$_] } 0..$#a ;
    }
    my %r = (filename=>$fn, longname=>$ls, a=>$attr);
    # foreach my $k (keys %r) { print "$k=$r{$k}\n"; }
    # foreach my $k (keys %a) { print "$k=$a{$k}\n"; }
    # print "X: " . (wantarray ? %r : \%r) . "\n";
    return wantarray ? %r : \%r;
}

1;

