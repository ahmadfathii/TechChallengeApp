# 1. Record architecture decisions

Date: 2022-09-20

## Status

submitted

## Context

based on the documentation, Environment variables has precedence over configuration from the conf.toml but in this version of code , the configuration file precedence is higher
## Decision

as a workaround , i added a placeholder on conf.toml which will be replaced at build time.

## Consequences
not secure approach.