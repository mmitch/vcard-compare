use strict;
use warnings;
package vCard::AddressBook::Compare;
# ABSTRACT: compare two vCard::AddressBooks for unique or duplicate entries

use List::Compare;
use MooX::Types::MooseLike::Base 'InstanceOf'; # TODO: check out Type::Tiny::Class
use Scalar::Util 'blessed';

use Moo;

=head1 SYNOPSIS

    my $ab1 = vCard::AddressBook->new()->load_file('some_file.vcf');
    my $ab2 = vCard::AddressBook->new()->load_file('other_file.vcf');
    
    my $cmp = vCard::AddressBook::Compare->new( $ab1, $ab2 );
    
    for my $vcard ( @{ $cmp->unique }) {
        # do something with the entries unique to $ab1
    }

    for my $vcard ( @{ $cmp->complement }) {
        # do something with the entries unique to $ab2
    }

    for my $vcard ( @{ $cmp->intersection }) {
        # do something with the entries contained in both $ab1 and $ab2
    }

=head1 DESCRIPTION

This class takes two L<vCard::AddressBook> instances and compares the
L<vCard>s contained within those address books to determine unique
and/or duplicate entries.

The key used for comparison is L<vCard/full_name>.

=attr primary

The primary L<vCard::AddressBook> to compare.

Read-only.  Must be set in the constructor via C<< new( primary => $ab
) >> where C<$ab> is an instance of L<vCard::AddressBook>.

=cut

has primary   => ( is => 'ro', required => 1, isa => InstanceOf['vCard::AddressBook'] );

=attr secondary

The secondary L<vCard::AddressBook> to compare.

Read-only.  Must be set in the constructor via C<< new( secondary =>
$ab ) >> where C<$ab> is an instance of L<vCard::AddressBook>.

=cut

has secondary => ( is => 'ro', required => 1, isa => InstanceOf['vCard::AddressBook'] );

=method new( $primary, $secondary )

Convenience constructor: When C<new()> is called with two scalars,
they are used as L</primary> and L</secondary> address book.  It's a
short form of C<< new( primary => $primary, secondary => $secondary )
>>

=cut

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

=method unique()

Returns a reflist of all L<vCard>s that are contained in the
L<#primary> address book, but not in the L<#secondary> address book.

=cut

sub unique {
    my $self = shift;
    return $self->_get_from_map( $self->_primary, $self->_lc->get_unique() );
}

=method complement()

Returns a reflist of all L<vCard>s that are contained in the
L<#secondary> address book, but not in the L<#primary> address book.

=cut

sub complement {
    my $self = shift;
    return $self->_get_from_map( $self->_secondary, $self->_lc->get_complement() );
}

=method intersection()

Returns a reflist of all L<vCard>s that are contained in both the
L<#primary> and L<#secondary> address books.

=cut

sub intersection {
    my $self = shift;
    return $self->_get_from_map( $self->_primary, $self->_lc->get_intersection() );
}

# mapped L<#primary>: key = vCard-ids, value = vCards

has _primary => ( is => 'lazy' );

sub _build__primary {
    my $self = shift;
    return $self->_map_from_ab( $self->primary );
}

# mapped L<#secondary>: key = vCard-ids, value = vCards

has _secondary => ( is => 'lazy' );

sub _build__secondary {
    my $self = shift;
    return $self->_map_from_ab( $self->secondary );
}

# List::Compare instance

has _lc => ( is => 'lazy' );

sub _build__lc {
    my $self = shift;
    return List::Compare->new('--unsorted', '--accelerated',
			      [ keys %{ $self->_primary } ],
			      [ keys %{ $self->_secondary } ] );
}

# generates the id for a L<vCard>
#  in:  vCard instance
#  out: id scalar

sub _id_from_vcard {
    my $self = shift;
    my $vcard = shift;
    return $vcard->full_name;
}

# get multiple values from a map
#  in:  hashref of map, list of keys
#  out: listref of values

sub _get_from_map {
    my $self = shift;
    my ($map, @keys) = (@_);
    return [ map { exists $map->{$_} ? $map->{$_} : () } @keys ];
}

# create a map of vcards from an AddressBook
# the id is generated via L<#_id_from_vcard>
#  in:  vCard::AddressBook instance
#  out: hashref of map ( id scalar => vCard instance )

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
