# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

package Bugzilla::KMS::Signature;
use 5.10.1;
use Moo;
use Paws;

has 'signing_key_alias' => (
    is       => 'ro',
    required => 1,
);

has 'account_id' => (
    is => 'lazy',
);

has 'regions' => (
    is      => 'ro',
    default => sub { ['us-east-1'] },
);

has 'sts_client' => (
    is => 'lazy',
);

has 'multiregion_kms_master_key_provider' => (
    is => 'lazy',
);

sub _build_sts_client { Paws->service('STS') }

sub _build_account_id {
    my ($self) = @_;

    return $self->sts_client->GetCallerIdentity->Account;
}

sub _build_multiregion_kms_master_key_provider {
    my ($self) = @_;
    my @regions    = @{ $self->regions };
    my $account_id = $self->account_id;
    my $alias      = $self->signing_key_alias;

    return Bugzilla::KMS::KeyProvider->new(
        master_keys => [
            map { "arn:aws:kms:$_:$account_id:$alias" } @regions
        ]
    )
}

1;