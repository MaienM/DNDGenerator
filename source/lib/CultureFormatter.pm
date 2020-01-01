#!/usr/bin/perl -wT
###############################################################################

package CultureFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);

###############################################################################

=head1 NAME

    CultureFormatter - used to format the summary.

=head1 DESCRIPTION

 This take a city, strips the important info, and generates a Summary.

=cut

###############################################################################

use Carp;
use CGI;
use Lingua::Conjunction;
use Data::Dumper;
use Exporter;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;

###############################################################################

=head2 printReligions()

printPostings displays a list of current job religions

=cut

###############################################################################

sub printReligions {
    my ($city) = @_;
    my $content = "In, $city->{'name'}, you can find worsipers of the following deities:";
    $content .= "<ul class='twocolumn'> \n";
    foreach my $deity (@{ $city->{'religions'} } ){
        $content.= "<li><a href='deitygenerator?seed=$deity->{'seed'}'>$deity->{'firstname'} (".conjunction(@{$deity->{'portfolio'}}).")</a></li>\n";
    }    

    $content .= "</ul>\n";

    return $content;
}

###############################################################################

=head2 printLegends()

printPostings displays a list of current job legends

=cut

###############################################################################

sub printLegends {
    my ($city) = @_;
    my $content = "Around town you'll hear the following legends:";
    $content .= "<ul class='twocolumn'> \n";
    foreach my $legend (@{ $city->{'legends'} } ){
        $content.= "<li>".$legend->{'template'}."</li>\n";
    
    }    

    $content .= "</ul>\n";

    return $content;
}


1;

__END__


=head1 AUTHOR

Jesse Morgan (morgajel)  C<< <morgajel@gmail.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013, Jesse Morgan (morgajel) C<< <morgajel@gmail.com> >>. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation version 2
of the License.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=head1 DISCLAIMER OF WARRANTY

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=cut
