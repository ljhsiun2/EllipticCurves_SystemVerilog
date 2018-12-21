#!/bin/bash

set -x

cd "$(dirname "$0")"
export IVERILOG_DUMPER=lxt2


iverilog -Wall testbed.v sha2.v sha256.v sha512.v && ./a.out
