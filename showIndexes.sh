#!/bin/bash

PREF_TENANT=araport.org
FLAG=$1

on_error () {
    local message=$1;echo >&2 "${message}";exit 1;
}

if [[ "$FLAG" =~ -h ]];
then
    echo "Usage: showIndexes.sh [-v]"
    exit 0
fi

if [[ ! "$FLAG" =~ -v ]];
then
    FLAG=''
fi

CHECK_TENANT=$(auth-check -v | jq -r .tenantid)
if [[ ! "$CHECK_TENANT" == "${PREF_TENANT}" ]];
then
    on_error "The Agave CLI is not configured to access the $PREF_TENANT tenant. Please run 'tenants-init' to remedy this."
fi

metadata-list $FLAG -i -Q '{"name":"araport.blastdb.index"}'
