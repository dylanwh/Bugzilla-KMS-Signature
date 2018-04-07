#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use lib 'lib';
use Bugzilla::KMS::Signature;
use Bugzilla::KMS::KeyProvider;

my $kms = Bugzilla::KMS::Signature->new(
    signing_key_alias => 'alias/bugzilla',
    regions => ['us-east-1'],
);

my ($ciphertext, $header) = $kms->multiregion_kms_master_key_provider->encrypt("foo");
my ($plaintext, $header2) = $kms->multiregion_kms_master_key_provider->decrypt($ciphertext);
is($plaintext, "foo");

done_testing;
