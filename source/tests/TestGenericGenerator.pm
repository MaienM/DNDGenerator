#!/usr/bin/perl -wT
###############################################################################
#
package TestGenericGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use FlagGenerator;
use GenericGenerator;
use Test::Exception;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test rand_from_array' => sub {
    my $result;
    srand(1);
    GenericGenerator::set_seed(1);
    my $testarray = [ 'foo', 'bar', 'baz' ];
    my $loop = 10;
    while ( $loop-- > 0 ) {
        GenericGenerator::set_seed(1);
        $result = GenericGenerator::rand_from_array($testarray);
        is( $result, 'foo', 'test array results' );
    }
    GenericGenerator::set_seed(2);
    $loop = 10;
    while ( $loop-- > 0 ) {
        GenericGenerator::set_seed(2);
        $result = GenericGenerator::rand_from_array($testarray);
        is( $result, 'baz', 'test array results' );
    }

    dies_ok( sub { GenericGenerator::rand_from_array(undef) }, "undef is not a valid array" );



    done_testing();
};

subtest 'test set_seed' => sub {
    my $result;
    srand(1);

    $result = GenericGenerator::set_seed();
    is( $result,                 '41630', 'a random number' );
    is( $GenericGenerator::seed, 41630,   'the resulting seed' );
    $result = GenericGenerator::set_seed(3);
    is( $result,                 3, 'the given number' );
    is( $GenericGenerator::seed, 3, 'the resulting seed' );
    $result = GenericGenerator::set_seed('broken');
    is( $result,                 783234, 'a random number' );
    is( $GenericGenerator::seed, 783234, 'the resulting seed' );


    done_testing();
};

subtest 'test set_seed and get_seed' => sub {
    my $result;

    foreach my $value (qw( 0 1 2 4 10000 ) ){
        GenericGenerator::set_seed($value);
        is (GenericGenerator::get_seed(), $value, "ensure value is $value");
    }
    done_testing();
};


subtest 'test single d() ' => sub {
    my $result;
    srand(1);
    is( GenericGenerator::d(3), 1 );
    is( GenericGenerator::d(3), 2 );
    is( GenericGenerator::d(3), 3 );
    is( GenericGenerator::d(3), 2 );
    dies_ok( sub { GenericGenerator::d('pie') }, "pie is not a valid dice format." );
    done_testing();
};

subtest 'test multi d() ' => sub {
    my $result;
    srand(1);
    $result = GenericGenerator::d('1d6');
    is( $result, 1 );
    $result = GenericGenerator::d('4d6');
    is( $result, 16 );
    $result = GenericGenerator::d('4d6');
    is( $result, 14 );
    $result = GenericGenerator::d('0d6');
    is( $result, 0 );
    $result = GenericGenerator::d('1d0');
    is( $result, 1 );
    $result = GenericGenerator::d('0d0');
    is( $result, 0 );

    done_testing();
};


######################################33
subtest 'test parse_object parts' => sub {
    my $testObject = {
        'title'   => [ { 'content' => 'titlefoo' },   { 'content' => 'titlebar' }, ],
        'pre'     => [ { 'content' => 'prefoo' },     { 'content' => 'prebar' }, ],
        'root'    => [ { 'content' => 'rootfoo' },    { 'content' => 'rootbar' }, ],
        'post'    => [ { 'content' => 'postfoo' },    { 'content' => 'postbar' }, ],
        'trailer' => [ { 'content' => 'trailerfoo' }, { 'content' => 'trailerbar' }, ],
    };
    srand(1);
    my $result = GenericGenerator::parse_object($testObject);
    is( $result->{'content'}, 'titlefoo prefoorootbarpostfoo trailerbar' );
    is( $result->{'title'},   'titlefoo' );
    is( $result->{'pre'},     'prefoo' );
    is( $result->{'root'},    'rootbar' );
    is( $result->{'post'},    'postfoo' );
    is( $result->{'trailer'}, 'trailerbar' );
    srand(2);
    $result = GenericGenerator::parse_object($testObject);
    is( $result->{'content'}, 'titlebar prefoorootbarpostbar trailerbar' );
    done_testing();

};

subtest 'test parse_object chance' => sub {
    my $result;
    my $testObject = {
        'title_chance' => '50',
        'title'        => [ { 'content' => 'titlefoo' }, ],
        'pre_chance'   => '50',
        'pre'          => [ { 'content' => 'prefoo' }, ],
        'root'         => 'rootfoo'
    };
    srand(1);
    $result = GenericGenerator::parse_object($testObject);
    is( $result->{'content'}, 'titlefoo prefoo' );
    is( $result->{'title'},   'titlefoo' );
    is( $result->{'pre'},     'prefoo' );
    srand(2);
    $result = GenericGenerator::parse_object($testObject);
    is( $result->{'content'}, 'prefoo' );
    isnt( defined $result->{'title'}, 'test title not defined, as expected' );
    is( $result->{'pre'}, 'prefoo' );

    $testObject = {
        'title_chance' => '50',
        'title'        => [],
        'pre_chance'   => '50',
        'pre'          => [ { 'content' => 'prefoo' }, ],
    };
    srand(1);
    $result = GenericGenerator::parse_object($testObject);
    is( $result->{'content'}, 'prefoo' );
    is( $result->{'title'},   undef );
    is( $result->{'pre'},     'prefoo' );


    $testObject = {
        'title_chance' => '50',
        'title'        => {},
    };
    srand(1);
    $result = GenericGenerator::parse_object($testObject);
    is( $result->{'content'}, '' );
    is( $result->{'title'},   undef );
    is( $result->{'pre'},     undef );

    $testObject = {
        'title_chance' => '50',
        'title'        => { 'content' => 'test' },
    };
    srand(1);
    $result = GenericGenerator::parse_object($testObject);
    is( $result->{'content'}, 'test ' );
    is( $result->{'title'},   'test' );
    is( $result->{'pre'},     undef );


    done_testing();
};


subtest 'test roll_from_array' => sub {
    my $result;
    srand(1);
    my $testdata = {
        'option' => [
            { 'min' => '1',  'max' => '10',  'content' => 'unheard of' },
            { 'min' => '11', 'max' => '30',  'content' => 'rare' },
            { 'min' => '29', 'max' => '100', 'content' => 'unusual' },
            ]

    };
    $result = GenericGenerator::roll_from_array( -1, $testdata->{'option'} )->{'content'};
    is( $result, 'unheard of' );
    $result = GenericGenerator::roll_from_array( 3, $testdata->{'option'} )->{'content'};
    is( $result, 'unheard of' );
    $result = GenericGenerator::roll_from_array( 10, $testdata->{'option'} )->{'content'};
    is( $result, 'unheard of' );
    $result = GenericGenerator::roll_from_array( 11, $testdata->{'option'} )->{'content'};
    is( $result, 'rare' );
    $result = GenericGenerator::roll_from_array( 110, $testdata->{'option'} )->{'content'};
    is( $result, 'unheard of', 'if it is beyond the max' );
    $testdata = {
        'option' => [
            { 'max' => '20', 'content' => 'unheard of' },
            { 'min' => '21', 'max'     => '30', 'content' => 'rare' },
            { 'min' => '31', 'content' => 'unusual' },
            ]

    };
    $result = GenericGenerator::roll_from_array( 1, $testdata->{'option'} )->{'content'};
    is( $result, 'unheard of' );
    $result = GenericGenerator::roll_from_array( 20, $testdata->{'option'} )->{'content'};
    is( $result, 'unheard of' );
    $result = GenericGenerator::roll_from_array( 21, $testdata->{'option'} )->{'content'};
    is( $result, 'rare' );
    $result = GenericGenerator::roll_from_array( 30, $testdata->{'option'} )->{'content'};
    is( $result, 'rare' );
    $result = GenericGenerator::roll_from_array( 31, $testdata->{'option'} )->{'content'};
    is( $result, 'unusual' );
    $result = GenericGenerator::roll_from_array( 101, $testdata->{'option'} )->{'content'};
    is( $result, 'unusual' );
    $testdata = { 'option' => [ { 'content' => 'unheard of' }, ] };
    $result = GenericGenerator::roll_from_array( 101, $testdata->{'option'} )->{'content'};
    is( $result, 'unheard of' );
    $result = GenericGenerator::roll_from_array( 11, $testdata->{'option'} )->{'content'};
    is( $result, 'unheard of' );
    $testdata = { 'option' => [ { 'min' => '10', 'content' => 'unheard of' }, ] };
    $result = GenericGenerator::roll_from_array( 1, $testdata->{'option'} )->{'content'};
    is( $result, 'unheard of' );


    $testdata = { 'option' => [ { 'min' => '9', 'content' => 'unheard of' }, { 'content' => 'no idea' }, ] };
    $result = GenericGenerator::roll_from_array( 1, $testdata->{'option'} )->{'content'};
    is( $result, 'no idea' );
    $result = GenericGenerator::roll_from_array( 40, $testdata->{'option'} )->{'content'};
    is( $result, 'unheard of' );


    done_testing();
};


subtest 'test select_features' => sub {

    GenericGenerator::set_seed(1);
    my $ds={};
    my $xml={
             'feature'=>{
                            'pre'=>{
                                    'option'=>[{'content'=>'a'},{'content'=>'b'},{'content'=>'c'}],
                                    },
                            'root'=>{
                                    'chance'=>100,
                                    'option'=>[{'content'=>'a'},{'content'=>'b'},{'content'=>'c'}],
                                    },
                            'post'=>{
                                    'chance'=>1,
                                    'option'=>[{'content'=>'a'},{'content'=>'b'},{'content'=>'c'}],
                                    },
                            'trailer'=>{
                                    'chance'=>99,
                                    'option'=>[{'type'=>'foo','content'=>'a'},{'type'=>'foo','content'=>'b'},{'type'=>'foo','content'=>'c'}],
                                    },
                        }
            };

    GenericGenerator::select_features($ds,$xml);

    isnt( $ds->{'pre'},     undef,  'pre exists' );
    isnt( $ds->{'root'},    undef,  'root exists' );
    is( $ds->{'post'},      undef,  'post doesnt' );
    is( $ds->{'trailer_type'},      'foo',  'foo is set' );
    GenericGenerator::set_seed(1);

    $ds={'post_roll'=>99, 'root'=>'foo', 'trailer_type'=>'bar'};

    GenericGenerator::select_features($ds,$xml);
    isnt( $ds->{'pre'},     undef,  'pre exists' );
    is( $ds->{'root'},      'foo',  'root exists' );
    is( $ds->{'post'},      undef,  'post doesnt' );
    is( $ds->{'trailer_type'},      'bar',  'bar is preset' );

    done_testing();
};


subtest 'test parse_template' => sub {

    my $ds={ 'template'=>'wait what [%adverb%]', 'dogtoy'=>'some [%adverb%] test', 'adverb'=>'quick' };

    GenericGenerator::parse_template($ds,'dogtoy');
    is( $ds->{'dogtoy'},    'some quick test', 'ensure variables are parsing' );

    GenericGenerator::parse_template($ds);
    is( $ds->{'template'},    'wait what quick', 'ensure variables are parsing' );

    $ds={ 'template'=>'Broken template [%adverb[1]%] ', 'adverb'=>'quick' };

    dies_ok( sub { GenericGenerator::parse_template($ds) }, "bad template dies" );


    done_testing();
};

subtest 'test generate_stats' => sub {
    my $ds={    };
    my $xml={
             'stats'=>{ 
                        'age'=>{ 'option'=>[
                                          {           'max'=>30, 'content'=>'foo'},
                                          {'min'=>31, 'max'=>60, 'content'=>'fbar'},
                                          {'min'=>61,            'content'=>'baz'},
                                        ]
                             },
                        'str'=>{ 'option'=>[
                                          {           'max'=>30, 'content'=>'foo'},
                                          {'min'=>31, 'max'=>60, 'content'=>'fbar'},
                                          {'min'=>61,            'content'=>'baz'},
                                        ]
                             }
                }
            };
    GenericGenerator::generate_stats($ds,$xml);
    foreach my $stat ( keys %{$xml->{'stats'}} ) {
        ok($ds->{'stats'}->{$stat} >=1 &&$ds->{'stats'}->{$stat} <=100, "$ds->{'stats'}->{$stat} between 1-100 for $stat");
        isnt($ds->{$stat."_description"}, undef,  $ds->{$stat."_description"}." between is text for $stat description");
    }
    $ds={'stats'=>{'age'=>99}, 'age_description'=>'qwe'};
    GenericGenerator::generate_stats($ds,$xml);
    is($ds->{'stats'}->{'age'},99, 'set a stat');
    is($ds->{'age_description'},'qwe', 'set a stat description');
    done_testing();
};

subtest 'test bound' => sub {
    my $results;
    $results=GenericGenerator::bound(5,1,100);
    is($results,5, "acceptable value");
    $results=GenericGenerator::bound(-5,1,100);
    is($results,1, "too low");
    $results=GenericGenerator::bound(500,1,100);
    is($results,100, "too high");
};

subtest 'test rand_between' => sub {
    GenericGenerator::set_seed(1);
    my $results;
    $results=GenericGenerator::rand_between(400,500);
    ok($results>=400 && $results<=500, "acceptable value $results");
    $results=GenericGenerator::rand_between(-5,5);
    ok($results>=-5 && $results<=5, "acceptable value $results");
};





done_testing();
1;

