# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

package Bugzilla::KMS::KeyProvider;
use 5.10.1;
use Moo;

has 'master_keys' => (
    is => 'ro',
    required => 1,
);

has 'real_key_provider' => (
    is => 'lazy',
);

sub _build_real_key_provider {
    my ($self) = @_;

    return _make_key_provider( $self->master_keys );
}

sub encrypt {
    my ($self, $source) = @_;

    return _encrypt($source, $self->real_key_provider);
}

sub decrypt {
    my ($self, $source) = @_;

    return _decrypt($source, $self->real_key_provider);
}

use Inline Python => <<'PYTHON';
import aws_encryption_sdk

def _encrypt(source, key_provider):

    return aws_encryption_sdk.encrypt(source = source, key_provider = key_provider)

def _decrypt(source, key_provider):
    return aws_encryption_sdk.decrypt(source = source, key_provider = key_provider)

def _make_key_provider(keys):
    kms_master_key_provider = aws_encryption_sdk.KMSMasterKeyProvider()

    for key in keys:
        kms_master_key_provider.add_master_key(key)

    return kms_master_key_provider
PYTHON



1;