package App::Math::Trainer::Role::VulFrac;

use warnings;
use strict;

=head1 NAME

App::Math::Trainer::Role::VulFrac - role for vulgar fraction numbers

=cut

use Moo::Role;
use MooX::Options;

our $VERSION = '0.003';

{
    package    #
      VulFrac;

    use Moo;
    use overload
      '""'   => \&_stringify,
      '0+'   => \&_numify,
      'bool' => sub { 1 },
      '<=>'  => \&_num_compare;

    use Carp qw/croak/;
    use Scalar::Util qw/blessed/;

    has num => (
                 is       => "ro",
                 required => 1
               );

    has denum => (
                   is       => "ro",
                   required => 1
                 );

    sub _stringify { "\\frac{" . $_[0]->num . "}{" . $_[0]->denum . "}" }

    sub _numify
    {
        my $rc = eval sprintf( "(%s)/(%s)", $_[0]->num, $_[0]->denum );
        $@ and croak $@;
        return $rc;
    }

    sub _num_compare
    {
        my ( $self, $other, $swapped ) = @_;
        $swapped and return $other <=> $self->_numify;

        blessed $other or return $self->_numify <=> $other;
        return $self->_numify <=> $other->_numify;
    }

    sub _euklid
    {
        my ( $a, $b ) = @_;
        my $h;
        while ( $b != 0 ) { $h = $a % $b; $a = $b; $b = $h; }
        return $a;
    }

    sub _gcd
    {
        my ( $a, $b ) = ( $_[0]->num, $_[0]->denum );
        my $gcd = $a > $b ? _euklid( $a, $b ) : _euklid( $b, $a );
        return $gcd;
    }

    sub _reduce
    {
        my ( $a, $b ) = ( $_[0]->num, $_[0]->denum );
        my $gcd = $a > $b ? _euklid( $a, $b ) : _euklid( $b, $a );
        return
          VulFrac->new( num   => $_[0]->num / $gcd,
                        denum => $_[0]->denum / $gcd );
    }

}

sub _check_vulgar_fraction { my $vf = shift; $vf->num >= 2 and $vf->denum >= 2 }

requires "format";

sub get_vulgar_fractions
{
    my ( $self, $amount ) = @_;

    my @result;
    my ( $max_num, $max_denum ) = @{ $self->format };

    while ( $amount-- )
    {
        my $vf;
        do
        {
            my ( $num, $denum ) = ( int( rand($max_num) ), int( rand($max_denum) ) );
            $vf = VulFrac->new( num   => $num,
                                denum => $denum );
        } while ( !_check_vulgar_fraction($vf) );

        push @result, $vf;
    }

    return @result;
}

1;
