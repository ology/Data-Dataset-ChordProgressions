package Data::Dataset::ChordProgressions;

# ABSTRACT: Provide access to hundreds of possible chord progressions

our $VERSION = '0.0109';

use strict;
use warnings;

use Text::CSV_XS ();
use File::ShareDir qw(dist_dir);
use Music::Scales qw(get_scale_notes);

=head1 SYNOPSIS

  use Data::Dataset::ChordProgressions;

  my $filename = Data::Dataset::ChordProgressions::as_file();

  my @data = Data::Dataset::ChordProgressions::as_list();

  my %data = Data::Dataset::ChordProgressions::as_hash();

=head1 DESCRIPTION

C<Data::Dataset::ChordProgressions> provides access to hundreds of
possible musical chord progressions in five genres: C<blues>,
C<country>, C<jazz>, C<pop> and C<rock>.  Each has progressions in
keys of C<C major> and C<C minor>.

Each of these is divided into a C<type> of progression, depending on
song position.  Take these types with a grain of salt.  They may or
may not be meaningful...

The named chords are meant to match the known chords of
L<Music::Chord::Note> (listed in the source of that module).

There are a few odd chord "progressions" like
C<"Eb7-Eb7-Eb7-Eb7","III-III-III-III">.  Strange...

I stumbled across this list, saved it on my hard-drive for a long
time, and then forgot where it came from!  Also the documentation in
the original list said nothing about who made it or how.

=cut

=head1 FUNCTIONS

=head2 as_file

  $filename = Data::Dataset::ChordProgressions::as_file();

Return the data filename location.

=cut

sub as_file {
    my $file = eval { dist_dir('Data-Dataset-ChordProgressions') . '/Chord-Progressions.csv' };

    $file = 'share/Chord-Progressions.csv'
        unless $file && -e $file;

    return $file;
}

=head2 as_list

  @data = Data::Dataset::ChordProgressions::as_list();

Return the data as an array.

=cut

sub as_list {
    my $file = as_file();

    my @data;

    my $csv = Text::CSV_XS->new({ binary => 1 });

    open my $fh, '<', $file
        or die "Can't read $file: $!";

    while (my $row = $csv->getline($fh)) {
        push @data, $row;
    }

    close $fh;

    return @data;
}

=head2 as_hash

  %data = Data::Dataset::ChordProgressions::as_hash();

Return the data as a hash.

=cut

sub as_hash {
    my $file = as_file();

    my %data;

    my $csv = Text::CSV_XS->new({ binary => 1 });

    open my $fh, '<', $file
        or die "Can't read $file: $!";

    while (my $row = $csv->getline($fh)) {
        # Row = Genre, Key, Type, Chords, Roman
        push @{ $data{ $row->[0] }{ $row->[1] }{ $row->[2] } }, [ $row->[3], $row->[4] ];
    }

    close $fh;

    return %data;
}

=head2 transpose

  $named = transpose($note, $scale, $progression);

Transpose a B<progression> to the given B<note> and B<scale>.

The progression must be the value of
C<$data{$style}{$scale}{$section}>, as given by the C<as_hash()>
function, and having the form of, for example:

  C-F-Am-F

=cut

sub transpose {
    my ($note, $scale, $progression) = @_;

    my %note_map;
    @note_map{ get_scale_notes('C', $scale) } = get_scale_notes($note, $scale);

    # transpose the progression chords from C
    (my $named = $progression->[0]) =~ s/([A-G][#b]?)/$note_map{$1}/g;

    return $named;
}

1;
