package Music::Dataset::ChordProgressions;

# ABSTRACT: Provide access to hundreds of chord progressions

our $VERSION = '0.0400';

use strict;
use warnings;

use Text::CSV_XS ();
use File::ShareDir qw(dist_dir);
use Music::Scales qw(get_scale_notes);
use Exporter 'import';

our @EXPORT = qw(
    as_file
    as_list
    as_hash
    transpose
);

=head1 SYNOPSIS

  use Music::Dataset::ChordProgressions qw(as_file as_list as_hash transpose);

  my $filename = as_file();
  my @data = as_list();
  my %data = as_hash();

  my $transposed = transpose('A', 'major', 'C-F-Am-F');

=head1 DESCRIPTION

C<Music::Dataset::ChordProgressions> provides access to hundreds of
musical chord progressions in five genres: C<blues>, C<country>,
C<jazz>, C<pop> and C<rock>.  Each has progressions in keys of
C<C major> and C<C minor>.

Each of these is divided into a named C<type> of progression. Take
these types with a grain of salt. They may or may not be meaningful...

The named chords are meant to match the known chords of
L<Music::Chord::Note> (listed in the source of that module).

There are a few odd chord "progressions" like
C<"Eb7-Eb7-Eb7-Eb7","III-III-III-III">. Strange...

I stumbled across this list, saved it on my hard-drive for a long
time, and then forgot where it came from!  Also the documentation in
the original list said nothing about who made it or how. :\

=cut

=head1 FUNCTIONS

=head2 as_file

  $filename = as_file();

Return the chord progression data filename location.

=cut

sub as_file {
    my $file = eval { dist_dir('Music-Dataset-ChordProgressions') . '/Chord-Progressions.csv' };

    $file = 'share/Chord-Progressions.csv'
        unless $file && -e $file;

    return $file;
}

=head2 as_list

  @data = as_list();

Return the chord progression data as an array.

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

  %data = as_hash();

Return the chord progression data as a hash.

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

  $transposed = transpose($note, $scale, $progression);

Transpose a B<progression> in the key of C<C> to the given B<note> and
B<scale>.

The progression must be a string of hyphen-separated chord names. For
example: C<'C-F-Am-F'>

=cut

sub transpose {
    my ($note, $scale, $progression) = @_;

    my %note_map;
    @note_map{ get_scale_notes('C', $scale) } = get_scale_notes($note, $scale);

    # transpose the progression chords from C
    $progression =~ s/([A-G][#b]?)/$note_map{$1}/g;

    return $progression;
}

1;

=head1 SEE ALSO

The F<t/01-functions.t> and F<eg/*> files

L<Exporter>

L<File::ShareDir>

L<Music::Scales>

L<Text::CSV_XS>
