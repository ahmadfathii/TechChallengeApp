# 1. Record architecture decisions

Date: 2022-09-20

## Status

submitted

## Context

 using azure postgres server , the application successfully login to db with username convention "username@hostname" but raise an issue with @ symbol when reach drop and create db step. 
 
 ## Decision

more troubleshooting is required . 
as a workaround , i created postgres role with name convention "username@hostname" 

## Consequences
not needed manual step is required to bypass the issue .