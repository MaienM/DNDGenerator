#!/usr/bin/perl -wT
###############################################################################
#
package TestBondGenerator;

use strict;
use warnings;

use Data::Dumper;
use Exporter;
use GenericGenerator qw( set_seed );
use BondGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create' => sub {
    my $bond;
    $bond = BondGenerator::create();
    foreach my $value (qw( seed other template) ){
        isnt($bond->{$value}, undef, "ensure $value is set");
    }

    like ($bond->{'template'}, "/you/i", "make sure you is interpolated.");
    
    $bond = BondGenerator::create(
        {
            'seed'        => 12,
            'other'       => 'Zeus',
            'template'    => 'Dog and [% other %] show.',
            'when_chance'   => 1,
            'reason_chance' => 1,
            'when'        => 'Silly',
            'reason'      => 'Because.'
        }
    );
    is( $bond->{'seed'},        12,                                   'ensure seed is set to 12' );
    is( $bond->{'other'},       'Zeus',                               'ensure other is set' );
    is( $bond->{'when_chance'},   1,                                    'ensure when_chance is set' );
    is( $bond->{'reason_chance'}, 1,                                    'ensure reason_chance is set' );
    is( $bond->{'when'},        'Silly',                              'ensure when is set' );
    is( $bond->{'reason'},      'Because.',                           'ensure reason is set' );
    is( $bond->{'template'},     'Silly, Dog and Zeus show. Because.', 'ensure template is sane' );

    done_testing();
};

subtest 'test when' => sub {
    my $bond;
    $bond = BondGenerator::create( {'seed' => 12, 'when_chance' => 1, 'when' => 'Silly',}  );

    is( $bond->{'when_chance'},   1,                                  'ensure when_chance is set' );
    is( $bond->{'when'},        'Silly',                              'ensure when is set' );
    like($bond->{'template'}, '/^Silly,/');

    done_testing();
};


subtest 'test select_reason' => sub {
    my $bond;
    $bond = BondGenerator::create({'seed'=>1, 'reasontype'=>'what',});
    is( $bond->{'reasontype'}, 'what', 'ensure reasontype is set' );

    $bond = BondGenerator::create({'seed'=>1, 'reasontype'=>'what', 'reason_chance'=>100});
    is( $bond->{'reasontype'}, 'what', 'ensure reasontype is set' );
    is( $bond->{'reason_chance'}, '100', 'ensure reason_chance is set' );
    is( $bond->{'reason'}, undef, 'ensure reason is not set' );


    $bond = BondGenerator::create({'seed'=>1, 'reasontype'=>'what', 'reason_chance'=>1});

    is( $bond->{'reasontype'}, 'what', 'ensure reasontype is set' );
    is( $bond->{'reason_chance'}, '1', 'ensure reason_chance is set' );
    isnt( $bond->{'reason'}, undef, 'ensure reason is set' );

    $bond = BondGenerator::create({'seed'=>1, 'reasontype'=>'what','reason_chance'=>1, 'reason'=>'because'});
    is( $bond->{'reasontype'}, 'what', 'ensure reasontype is set' );

    done_testing();
};
done_testing();
1;
