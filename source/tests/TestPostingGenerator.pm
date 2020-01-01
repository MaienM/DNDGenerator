#!/usr/bin/perl -wT
###############################################################################
#
package TestPostingGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use PostingGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create' => sub {
    my $posting;
    $posting = PostingGenerator::create( );
    isnt( $posting->{'seed'}, undef, 'ensure seed is set.' );

    $posting = PostingGenerator::create( { 'seed' => 12 } );
    is( $posting->{'seed'}, 12, 'ensure seed is set.' );

    done_testing();
};

subtest 'test contact, person,class' => sub {
    my $posting;
    $posting = PostingGenerator::create( { 'seed' => 12, 'contact'=>'Bob', 'person'=>'billy', 'class'=>'Ranger' } );
    is( $posting->{'seed'}, 12, 'ensure seed is set.' );

    done_testing();
};
subtest 'test location' => sub {
    my $posting;
    $posting = PostingGenerator::create( {'seed' => 12, 'request_roll'=>0, 'hook_roll'=>0, 'requirement_roll'=>0, 'disclaimer_roll'=>0, 'detail_roll'=>0, 'location'=>"fall" });
    like($posting->{'template'},"/fall/"  );
    done_testing();
};

subtest 'test select_feature' => sub {
    my $posting;
    $posting = PostingGenerator::create( {'seed' => 12, 'request_roll'=>0, 'hook_roll'=>0, 'requirement_roll'=>0, 'disclaimer_roll'=>0, 'detail_roll'=>0 });
    foreach my $featurename (qw( template request hook payment duration requirement disclaimer detail critter skill item testitem supplies subject ) ){
        isnt( $posting->{$featurename}, undef, "ensure $featurename is set." );
    }
    my $presets={
      'seed'         => 12,
      'template'     => 'template',
      'request'      => 'request',
      'hook'         => 'hook',
      'payment'      => 'payment',
      'duration'     => 'duration',
      'requirement'  => 'requirement',
      'disclaimer'   => 'disclaimer',
      'detail'       => 'detail',
      'critter'      => 'critter',
      'skill'        => 'skill',
      'item'         => 'item',
      'testitem'     => 'testitem',
      'supplies'     => 'supplies',
      'subject'      => 'subject',
    };

    $posting = PostingGenerator::create( $presets );
    foreach my $featurename (qw( request hook payment duration requirement disclaimer detail critter skill item testitem supplies subject ) ){
        is( $posting->{$featurename}, $featurename, "ensure $featurename is set." );
    }
    #FIXME template is weird....


    done_testing();
};

done_testing();
1;
