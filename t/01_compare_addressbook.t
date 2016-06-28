use strict;
use warnings;

use Test::More tests => 7;
use Test::Exception;

use vCard::AddressBook;
use vCard::AddressBook::Compare;

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

    my $vcard = $abL->add_vcard();

    my $cmp = new_ok( 'vCard::AddressBook::Compare', [ $abL, $abR ] );

    # when
    my $onlyL = $cmp->unique;
    my $onlyR = $cmp->complement;
    my $both  = $cmp->intersection;

    # then
    is_deeply( $onlyL, [ "$vcard" ], 'unique list');
    is_deeply( $onlyR, [], 'complement list');
    is_deeply( $both , [], 'intersection list');
};

subtest 'compare addressbooks (0, 1)' => sub {
    # given
    my $abL = vCard::AddressBook->new;
    my $abR = vCard::AddressBook->new;

    my $vcard = $abR->add_vcard();

    my $cmp = new_ok( 'vCard::AddressBook::Compare', [ $abL, $abR ] );

    # when
    my $onlyL = $cmp->unique;
    my $onlyR = $cmp->complement;
    my $both  = $cmp->intersection;

    # then
    is_deeply( $onlyL, [], 'unique list');
    is_deeply( $onlyR, [ "$vcard" ], 'complement list');
    is_deeply( $both , [], 'intersection list');
};

subtest 'compare addressbooks (1 != 1)' => sub {
    # given
    my $abL = vCard::AddressBook->new;
    my $abR = vCard::AddressBook->new;

    my $vcardL = $abL->add_vcard();
    my $vcardR = $abR->add_vcard();

    my $cmp = new_ok( 'vCard::AddressBook::Compare', [ $abL, $abR ] );

    # when
    my $onlyL = $cmp->unique;
    my $onlyR = $cmp->complement;
    my $both  = $cmp->intersection;

    # then
    is_deeply( $onlyL, [ "$vcardL" ], 'unique list');
    is_deeply( $onlyR, [ "$vcardR" ], 'complement list');
    is_deeply( $both , [], 'intersection list');
};

subtest 'compare addressbooks (1 == 1)' => sub {
    # given
    my $abL = vCard::AddressBook->new;
    my $abR = vCard::AddressBook->new;

    my $vcard = $abL->add_vcard();
    push @{ $abR->vcards() }, $vcard;

    my $cmp = new_ok( 'vCard::AddressBook::Compare', [ $abL, $abR ] );

    # when
    my $onlyL = $cmp->unique;
    my $onlyR = $cmp->complement;
    my $both  = $cmp->intersection;

    # then
    is_deeply( $onlyL, [], 'unique list');
    is_deeply( $onlyR, [], 'complement list');
    is_deeply( $both , [ "$vcard" ], 'intersection list');
};

subtest 'compare addressbooks (2 /= 2)' => sub {
    # given
    my $abL = vCard::AddressBook->new;
    my $abR = vCard::AddressBook->new;

    my $vcard = $abL->add_vcard();
    push @{ $abR->vcards() }, $vcard;
    my $vcardL = $abL->add_vcard();
    my $vcardR = $abR->add_vcard();

    my $cmp = new_ok( 'vCard::AddressBook::Compare', [ $abL, $abR ] );

    # when
    my $onlyL = $cmp->unique;
    my $onlyR = $cmp->complement;
    my $both  = $cmp->intersection;

    # then
    is_deeply( $onlyL, [ "$vcardL" ], 'unique list');
    is_deeply( $onlyR, [ "$vcardR" ], 'complement list');
    is_deeply( $both , [ "$vcard" ], 'intersection list');
};
