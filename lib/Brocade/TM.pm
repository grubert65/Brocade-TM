package Brocade::TM;

use Moose;
use strict;
use warnings;
use RestAPI         ();
use Log::Log4perl   ();

=head1 NAME

#=============================================================
Brocade::TM - An API to interact with the Brocade vTM Virtual Traffic Manager.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Brocade::TM ();

    my $client = Brocade::TM->new(
        server      => ...,
        username    => ...,
        password    => ...,
        version     => ..., # defaults to 3.8
    );

    # set working environment...
    $client->setEnvironment( Configuration );

    # read all objects
    my $objs = $client->GetAll( $obj_type );

    # read an object
    foreach $ref ( @$objs ) {
        my $obj_by_name = $client->get_obj_by_name($ref->{name});
        my $obj_by_url = $client->get_obj_by_url($ref->{url});
    }

    # create a new object
    my $profile = {
    };
    unless ( $client->create($obj_type, $profile) ) {
        $log->Error("Error creating an object");
    }
    
    #updating an object
    unless ( $client->update($obj_type, $profile) ) {
        $log->Error("Error updating an object");
    }

    # deleting an object
    unless ( $client->delete($obj_type, $profile) ) {
        $log->Error("Error updating an object");
    }

=head1 EXPORT

None

=head1 SUBROUTINES/METHODS

=cut

#=============================================================


has 'username'      => ( is => 'rw', isa => 'Str', required => 1 );
has 'password'      => ( is => 'rw', isa => 'Str', required => 1 );
has 'server'        => ( is => 'rw', isa => 'Str', required => 1 );
has 'api_version'   => ( is => 'rw', isa => 'Str' );

has 'client'        => ( is => 'ro', isa => 'RestAPI' );
has 'api_prefix'    => ( is => 'ro', isa => 'Str', default => "api/tm" );
has 'configuration' => ( is => 'ro', isa => 'Str', default => "config/active" );
has 'tm'            => ( is => 'rw', isa => 'Str'); # the specific traffic manager addressed

has 'counters'              => ( is => 'ro', isa => 'Str', writer => '_set_counters_uri' );
has 'information'           => ( is => 'ro', isa => 'Str', writer => '_set_information_uri' );
has 'supported_versions'    => ( is => 'ro', isa => 'ArrayRef', writer => '_set_versions' );
has 'base_request_path'     => ( is => 'ro', isa => 'Str', writer => '_set_base_request_path' );
has 'log'   => ( is => 'ro', isa => 'Log::Log4perl::Logger', default => sub {
        return Log::Log4perl->get_logger( __PACKAGE__);
    });

has 'configuration_flag'    => ( is => 'rw', isa => 'Bool' );

sub _get_counters_uri {
    my $self=shift; 
    return "status/$self->{tm}/statistics" if (exists( $self->{tm} ));
}

sub _get_information_uri {
    my $self=shift; 
    return "status/$self->{tm}/information" if (exists( $self->{tm} ));
}

#=============================================================

=head2 BUILD

=head3 INPUT

=head3 OUTPUT

An hashref

=head3 DESCRIPTION

Called at each creation time, just to check connection
parameters are valid.

=cut

#=============================================================
sub BUILD {
    my $self = shift;

    $self->{client} = RestAPI->new(
        basicAuth   => 1,
        realm       => "Brocade Virtual Traffic Manager REST API",
        ssl_opts    => { verify_hostname => 0 },
        username    => $self->username,
        password    => $self->password,
        server      => $self->server,
        scheme      => 'https',
        query       => $self->api_prefix,
        http_verb   => 'GET',
        encoding    => 'application/json',
    ) or die "Error getting a Rest API client";
    
    $DB::single=1;
    my $resp = $self->client->do();
    $self->_set_versions( $resp->{children} );
    if (! $self->api_version ) {
        # a little Swartzian...
        my @versions_sorted = reverse sort map{ $_->{name} } @{$self->supported_versions};
        $self->api_version($versions_sorted[0]);
        $self->log->debug("Using version $self->{api_version}");
    }
    $self->client->{query} .= "/$self->{api_version}";
    $self->_set_base_request_path( $self->client->query );
}


#=============================================================

=head2 getConfigurationResources

=head3 INPUT

=head3 OUTPUT

An ArrayRef

=head3 DESCRIPTION

Returns the list of configuration resources.

=cut

#=============================================================
sub getConfigurationResources {
    my $self = shift;

    die "Set first configuration environment"
        unless $self->configuration_flag;

    my $resp = $self->client->do();
    return $resp->{children};
}

#=============================================================

=head2 workWithConfiguration

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

Set path to work with configuration resources

=cut

#=============================================================
sub workWithConfiguration {
    my $self = shift;
    $self->client->query( $self->base_request_path.'/'.$self->configuration );
    $self->configuration_flag( 1 );
}

#=============================================================

=head2 readAll

=head3 INPUT

=head3 OUTPUT

An arrayref

=head3 DESCRIPTION

Read all resource references of the specified type

=cut

#=============================================================
sub readAll {
    my ($self, $resType) = @_;

    die "Set first configuration environment"
        unless $self->configuration_flag;

    $self->client->path( $resType );
    my $resp = $self->client->do();
    return $resp->{children};
}

#=============================================================

=head2 readFromName

=head3 INPUT

    res_type    : the resource type
    name        : the resource name

=head3 OUTPUT

An hashref

=head3 DESCRIPTION

Returns the resource

=cut

#=============================================================
sub readFromName {
    my ( $self, $type, $name ) = @_;

    die "Set first configuration environment"
        unless $self->configuration_flag;

    $self->client->path( $type.'/'.$name );
    my $resp = $self->client->do();
    return $resp->{properties};
}

#=============================================================

=head2 readFromUrl

=head3 INPUT

    url : the resource url

=head3 OUTPUT

=head3 DESCRIPTION

Returns the resource

=cut

#=============================================================
sub readFromUrl {
    my ( $self, $url ) = @_;
}

=head1 AUTHOR

Marco Masetti, C<< <marco.masetti at sky.uk> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-brocade-tm at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Brocade-TM>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Brocade::TM


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Brocade-TM>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Brocade-TM>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Brocade-TM>

=item * Search CPAN

L<http://search.cpan.org/dist/Brocade-TM/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2017 Marco Masetti.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Brocade::TM
