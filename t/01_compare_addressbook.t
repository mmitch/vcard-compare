use strict;
use warnings;

use Test::More tests => 8;
use Test::Exception;

use vCard::AddressBook;
use vCard::AddressBook::Compare;

my $VCARD1 = get_vcard('one');
my $VCARD2 = get_vcard('two');
my $VCARD3 = get_vcard('three');

subtest 'constructor typecheck' => sub {
    # given
    my $abL = { foo => 'bar' };
    my $abR = { foo => 'bar' };

    # when + then
    throws_ok { vCard::AddressBook::Compare->new( primary => $abL, secondary => $abR ) } qr/isa check.*failed/, 'new(HASH, HASH)';
};

subtest 'compare empty addressbooks' => sub {
    # given
    my $abL = vCard::AddressBook->new;
    my $abR = vCard::AddressBook->new;
    my $cmp = new_ok( 'vCard::AddressBook::Compare', [ $abL, $abR ] );

    # when
    my $onlyL = $cmp->unique;
    my $onlyR = $cmp->complement;
    my $both  = $cmp->intersection;

    # then
    is_deeply( $onlyL, [], 'unique list');
    is_deeply( $onlyR, [], 'complement list');
    is_deeply( $both , [], 'intersection list');
};

subtest 'compare addressbooks (1, 0)' => sub {
    # given
    my $abL = vCard::AddressBook->new;
    my $abR = vCard::AddressBook->new;

    add_vcard( $abL, $VCARD1 );

    my $cmp = new_ok( 'vCard::AddressBook::Compare', [ $abL, $abR ] );

    # when
    my $onlyL = $cmp->unique;
    my $onlyR = $cmp->complement;
    my $both  = $cmp->intersection;

    # then
    is_deeply( $onlyL, [ $VCARD1 ], 'unique list');
    is_deeply( $onlyR, [], 'complement list');
    is_deeply( $both , [], 'intersection list');
};

subtest 'compare addressbooks (0, 1)' => sub {
    # given
    my $abL = vCard::AddressBook->new;
    my $abR = vCard::AddressBook->new;

    add_vcard( $abR, $VCARD1 );

    my $cmp = new_ok( 'vCard::AddressBook::Compare', [ $abL, $abR ] );

    # when
    my $onlyL = $cmp->unique;
    my $onlyR = $cmp->complement;
    my $both  = $cmp->intersection;

    # then
    is_deeply( $onlyL, [], 'unique list');
    is_deeply( $onlyR, [ $VCARD1 ], 'complement list');
    is_deeply( $both , [], 'intersection list');
};

subtest 'compare addressbooks (1 != 1)' => sub {
    # given
    my $abL = vCard::AddressBook->new;
    my $abR = vCard::AddressBook->new;

    add_vcard( $abL, $VCARD1 );
    add_vcard( $abR, $VCARD2 );

    my $cmp = new_ok( 'vCard::AddressBook::Compare', [ $abL, $abR ] );

    # when
    my $onlyL = $cmp->unique;
    my $onlyR = $cmp->complement;
    my $both  = $cmp->intersection;

    # then
    is_deeply( $onlyL, [ $VCARD1 ], 'unique list');
    is_deeply( $onlyR, [ $VCARD2 ], 'complement list');
    is_deeply( $both , [], 'intersection list');
};

subtest 'compare addressbooks (1 == 1)' => sub {
    # given
    my $abL = vCard::AddressBook->new;
    my $abR = vCard::AddressBook->new;

    add_vcard( $abL, $VCARD1 );
    add_vcard( $abR, $VCARD1 );

    my $cmp = new_ok( 'vCard::AddressBook::Compare', [ $abL, $abR ] );

    # when
    my $onlyL = $cmp->unique;
    my $onlyR = $cmp->complement;
    my $both  = $cmp->intersection;

    # then
    is_deeply( $onlyL, [], 'unique list');
    is_deeply( $onlyR, [], 'complement list');
    is_deeply( $both , [ $VCARD1 ], 'intersection list');
};

subtest 'compare addressbooks (2 /= 2)' => sub {
    # given
    my $abL = vCard::AddressBook->new;
    my $abR = vCard::AddressBook->new;

    add_vcard( $abL, $VCARD1 );
    add_vcard( $abL, $VCARD2 );
    add_vcard( $abR, $VCARD2 );
    add_vcard( $abR, $VCARD3 );

    my $cmp = new_ok( 'vCard::AddressBook::Compare', [ $abL, $abR ] );

    # when
    my $onlyL = $cmp->unique;
    my $onlyR = $cmp->complement;
    my $both  = $cmp->intersection;

    # then
    is_deeply( $onlyL, [ $VCARD1 ], 'unique list');
    is_deeply( $onlyR, [ $VCARD3 ], 'complement list');
    is_deeply( $both , [ $VCARD2 ], 'intersection list');
};

subtest 'unique primary' => sub {
    # given
    my $abL = vCard::AddressBook->new;
    my $abR = vCard::AddressBook->new;

    add_vcard( $abL, $VCARD1 );
    add_vcard( $abL, $VCARD1 );

    my $cmp = new_ok( 'vCard::AddressBook::Compare', [ $abL, $abR ] );

    # when + then
    throws_ok { $cmp->complement } qr/duplicate.*primary/, 'new(duplicate, ok)';
};
    
### helper methods

sub get_vcard {
    my ($name) = (@_);

    my $vcard = vCard->new;
    $vcard->full_name( $name );
    return $vcard;
}

sub add_vcard {
    my ($ab, $vcard) = (@_);

    push @{ $ab->vcards }, $vcard;
}
