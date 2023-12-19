# bash/justfile

# advent-of-spin-2023-c1/justfile

# https://just.systems/man/en/chapter_1.html

# ------------------------------------------------------------------------------
# CONFIG

set shell := ["bash", "-uc"]

# ------------------------------------------------------------------------------
# VARIABLES

# NODE_VERSION := "v16.13.2"

################################################################################
# RECIPES
################################################################################

# DEFAULT RECIPE WHEN USER DOES NOT GIVE A SPECIFIC RECIPE

@_default:
    echo "View file 'justfile' to see internals of any recipe."
    just --list --unsorted

# ------------------------------------------------------------------------------
# BASIC RECIPES

# ------------------------------------------------------------------------------
# RUN LOCAL SERVERS

# Run the app on localhost with hot-reloading.
@dev:
    spin watch

# ------------------------------------------------------------------------------
# BUILD & DEPLOY

# Build the app for production.
@build:
    spin build

# Deploy the app to the cloud.
@deploy: build
    spin deploy

# ------------------------------------------------------------------------------
# LINTING

# Lint all code.
@lint: lint-go lint-go-extras

# TODO: figure out a workaround for the following error when running lint-go & lint-go-extras:
# main.go:8:11: could not import github.com/fermyon/spin/sdk/go/v2/http (-: # github.com/fermyon/spin/sdk/go/v2/http
# ../../../go/pkg/mod/github.com/fermyon/spin/sdk/go/v2@v2.0.1/http/internals.go:16:1: export comment has wrong name "spin_http_handle_http_request", want "handle_http_request") (typecheck)
#   spinhttp "github.com/fermyon/spin/sdk/go/v2/http"

# TODO: after fixing the above error, then go enable a bunch of linters in .golangci.yml

# Only lint the Go code via golangci-lint.
@lint-go:
    find . -name "go.mod" -execdir golangci-lint run \;

# Run extra 'linters' on the Go code.
@lint-go-extras:
    find . -name "go.mod" -execdir govulncheck ./... \;

# ------------------------------------------------------------------------------
# TESTING

# Run all tests.
test: test-go test-hurl

# Run Go tests.
@test-go:
    find . -name "go.mod" -execdir tinygo test ./... \;

# Run Hurl tests.
@test-hurl:
    hurl --test test.hurl

# ------------------------------------------------------------------------------
# FINAL SUBMISSION

# TODO: update serviceUrl

# Submit the final version of the app to the Advent of Code website.
submit:
    hurl \
    --error-format long \
    --variable serviceUrl="https://aos3.fermyon.app/rust-api" \
    submit.hurl

# ------------------------------------------------------------------------------
# MISC

# Gather stats about the app's code size & todos.
@stats:
    ( \
        echo ""; \
        echo "Tokei"; \
        echo ""; \
        tokei; \
        echo ""; \
        echo "TCount"; \
        echo ""; \
        tcount; \
        NUM=$(rg TODO -g "!justfile" -g "!stats.txt" | wc -l | tr -s ' '); \
        echo ""; \
        echo "################################################################################"; \
        echo ""; \
        echo "Todo: $NUM"; \
        echo ""; \
        rg TODO -g "!justfile" -g "!stats.txt" || echo "none"; \
    ) > stats.txt && bat stats.txt