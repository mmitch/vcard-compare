use strict;
use warnings;
package vCard::AddressBook::Compare;
# ABSTRACT: compare two vCard::AddressBooks via full_name

use Moo;

use List::Compare;
use MooX::Types::MooseLike::Base 'InstanceOf'; # TODO: check out Type::Tiny::Class
use Scalar::Util 'blessed';

has primary   => ( is => 'ro', required => 1, isa => InstanceOf['vCard::AddressBook'] );
has secondary => ( is => 'ro', required => 1, isa => InstanceOf['vCard::AddressBook'] );

sub BUILDARGS {
    my ( $class, @args ) = @_;

    if ( @args == 2
	 and blessed $args[0] and $args[0]->isa('vCard::AddressBook')
	 and blessed $args[1] and $args[1]->isa('vCard::AddressBook') ) {
	my $tmp = shift @args;
	unshift @args, 'secondary';
	unshift @args, $tmp;
	unshift @args, 'primary';
    }

    return { @args };
}

has _primary => ( is => 'lazy' );

sub _build__primary {
    my $self = shift;
    return $self->_map_from_ab( $self->primary );
}

has _secondary => ( is => 'lazy' );

sub _build__secondary {
    my $self = shift;
    return $self->_map_from_ab( $self->secondary );
}

has _lc => ( is => 'lazy' );

sub _build__lc {
    my $self = shift;
    return List::Compare->new('--unsorted', '--accelerated',
			      [ keys %{ $self->_primary } ],
			      [ keys %{ $self->_secondary } ] );
}

sub unique {
    my $self = shift;
    return $self->_get_from_map( $self->_primary, $self->_lc->get_unique() );
}

sub complement {
    my $self = shift;
    return $self->_get_from_map( $self->_secondary, $self->_lc->get_complement() );
}

sub intersection {
    my $self = shift;
    return $self->_get_from_map( $self->_primary, $self->_lc->get_intersection() );
}

sub _id_from_vcard {
    my $self = shift;
    my $vcard = shift;
    return $vcard->full_name;
}

sub _get_from_map {
    my $self = shift;
    my ($map, @keys) = (@_);
    return [ map { exists $map->{$_} ? $map->{$_} : () } @keys ];
}

sub _map_from_ab {
    my $self = shift;
    my $ab = shift;
    my $map = {};
    foreach my $vcard ( @{ $ab->vcards } ) {
	my $key = $self->_id_from_vcard( $vcard );
	die "duplicate id in primary list: `$key'" if exists $map->{$key};
	$map->{$key} = $vcard;
    }
    return $map;
}

1;
