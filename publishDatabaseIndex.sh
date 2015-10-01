#!/bin/bash

on_error () {
    local message=$1;echo >&2 "${message}";exit 1;
}

on_usage () {

    echo -e "Usage:\n\tpublishDatabaseIndex.sh Dbindex.json [Token]"
    exit 0

}

if [[ "$1" == "--help" ]];
then
    on_usage
fi

DEFAULT_FILENAME="Dbindex.json"
INDEXFILE=${1:-$DEFAULT_FILENAME}

DEFAULT_TOKEN=
TOKEN=${2:-$DEFAULT_TOKEN}

PREF_TENANT="araport.org"

# Make sure the needed components of the Agave CLI are installed
echo "Verifying dependencies..."
DEPS="jq metadata-addupdate auth-tokens-refresh auth-tokens-create metadata-delete tenants-init"
for D in $DEPS
do
    hash $D 2>/dev/null || { echo >&2 "Script required '$D' but it's not installed.";exit 1; }
done

# Check tenant
echo "Verifying tenant config..."
CHECK_TENANT=$(auth-check -v | jq -r .tenantid)
if [[ ! "$CHECK_TENANT" == "${PREF_TENANT}" ]];
then
    on_error "The Agave CLI is not configured to access the $PREF_TENANT tenant. Please run 'tenants-init' to remedy this."
fi

# Allow user to specify a token instead of running the refresh flow
echo "Testing authentication workflow..."
if [[ -z "$TOKEN" ]];
    then
    TOKEN=$(auth-tokens-refresh -S)
    if [[ "$TOKEN" =~ "invalid" ]]
    then
        on_error "There was an error refreshing your access token. Please run 'auth-tokens-create -S' or manually acquire a token."
    fi
else
    echo "Using provided token $TOKEN"
fi

IMAGE=$(jq -r .value.docker_this.image "${INDEXFILE}")
TAG=$(jq -r .value.docker_this.tag "${INDEXFILE}")

# Query to see if the record exists
EXISTS=0
query_orig="{\"name\":\"araport.blastdb.index\",\"value.docker_this.tag\":\"${TAG}\"}"
query_enc=`echo -ne "${query_orig}" | hexdump -v -e '/1 "%02x"' | sed 's/\(..\)/%\1/g'`
QUUID=$(metadata-list -z $TOKEN -i -Q $query_enc)
# All agave structured data records have a UUID ending in -012
# Should actually replace this with a call to a UUID typing function
# in order to be future proof
if [[ "$QUUID" =~ -012$ ]];
then
    echo "Index exists ($QUUID). Will update it."
    EXISTS=1
else
    echo "Index doesn't exist. Will create it."
    QUUID=""
fi

# Publish or update, depending on of QUUID is empty or not
NUUID=$(metadata-addupdate -v -z $TOKEN -F $INDEXFILE $QUUID | jq -r .uuid)
echo "Metadata document: $NUUID"
# Add a notification for the next time it is updated
NOTIFICATION="{ \"associatedUuid\": \"$NUUID\", \"event\": \"*\", \"url\": \"https://maker.ifttt.com/trigger/araport.agave-ncbi-blastdb.index.UPDATED/with/key/jkt8aS-u6LrEEDqoeEm_eCgD76Pc5DZhcuCxxOBt9YH\" }"
echo $NOTIFICATION > "notify.json"
EUUID=$(notifications-addupdate -z $TOKEN -F notify.json)
echo -e "Notification:\n$EUUID"
rm -rf "notify.json"
# Share the doc with the world
PEMS=$(metadata-pems-addupdate -z $TOKEN -u public -p READ "$NUUID")
