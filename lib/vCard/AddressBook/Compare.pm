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

has _lc => ( is => 'lazy' );

sub _build__lc {
    my $self = shift;
    return List::Compare->new('--unsorted', '--accelerated',
			      $self->primary->vcards(),
			      $self->secondary->vcards());
}

sub unique {
    my $self = shift;
    return $self->_lc->get_unique_ref();
}

sub complement {
    my $self = shift;
    return $self->_lc->get_complement_ref();
}

sub intersection {
    my $self = shift;
    return $self->_lc->get_intersection_ref();
}

1;
