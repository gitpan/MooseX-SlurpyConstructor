package MooseX::SlurpyConstructor::Role::Object;
BEGIN {
  $MooseX::SlurpyConstructor::Role::Object::VERSION = '1.2';
}

# applied as base_class_roles => [ __PACKAGE__ ], for all Moose versions.
use Moose::Role;

use namespace::autoclean;

after BUILDALL => sub {
    my $self   = shift;
    my $params = shift;

    my %attrs = (
        __INSTANCE__ => 1,
        map  { $_ => 1 }
        grep { defined }
        map  { $_->init_arg } $self->meta->get_all_attributes
    );

    my @extra = sort grep { !$attrs{$_} } keys %{$params};
    return if not @extra;

    # XXX TODO: stuff all these into the slurpy attr.

    # find the slurpy attr
    # TODO: use the metaclass slurpy_attr to find this:
    # if $self->meta->slurpy_attr
    # and then the check for multiple slurpy attrs can be done at
    # composition time.

    my $slurpy_attr = $self->meta->slurpy_attr;

    Moose->throw_error('Found extra construction arguments, but there is no \'slurpy\' attribute present!') if not $slurpy_attr;

    my %slurpy_values;
    @slurpy_values{@extra} = @{$params}{@extra};

    $slurpy_attr->set_value( $self, \%slurpy_values );
};

1;

# ABSTRACT: A role which implements a slurpy constructor for Moose::Object



=pod

=head1 NAME

MooseX::SlurpyConstructor::Role::Object - A role which implements a slurpy constructor for Moose::Object

=head1 VERSION

version 1.2

=head1 SYNOPSIS

  Moose::Util::MetaRole::apply_base_class_roles(
      for_class => $caller,
      roles =>
          ['MooseX::SlurpyConstructor::Role::Object'],
  );

=head1 DESCRIPTION

When you use C<MooseX::SlurpyConstructor>, your objects will have this
role applied to them. It provides a method modifier for C<BUILDALL()>
from C<Moose::Object> that saves all unrecognized attributes.

=head1 AUTHORS

=over 4

=item *

Mark Morgan <makk384@gmail.com>

=item *

Karen Etheridge <ether@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Karen Etheridge.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

