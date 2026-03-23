#!/bin/bash

set -e

cd /workspaces/mono-repo && bazelisk \
	--output_base=/home/vscode/.cache/bazel/_bazel_vscode/x86_64 \
	build \
	--config=clippy \
	--show_result=0 \
	--noshow_progress \
	--keep_going \
	--@rules_rust//rust/settings:error_format=json \
	$(bazel query 'kind("rust_library|rust_binary", //apps/...:all) + kind("rust_library|rust_binary", //libs/...:all)')
