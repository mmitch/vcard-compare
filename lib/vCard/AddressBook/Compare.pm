use strict;
use warnings;
package vCard::AddressBook::Compare;
# ABSTRACT: compare two vCard::AddressBooks via full_name

use Moo;

use MooX::Types::MooseLike::Base 'InstanceOf';

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

has unique       => ( is => 'lazy' );

sub _build_unique {
    my $self = shift;
    return [];
}

has complement   => ( is => 'lazy' );

sub _build_complement {
    my $self = shift;
    return [];
}

has intersection => ( is => 'lazy' );

sub _build_intersection {
    my $self = shift;
    return [];
}

1;
