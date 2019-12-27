#!/bin/bash

set -euxo pipefail
dub build --vverbose --compiler=${DC}
# pushd example
# dub build --compiler=${DC} --vverbose
# && dub test --build=unittest-cov --compiler=${DC}
