#!/bin/bash

# ./download_jar.sh example-app 2.1.9"

# Artifact name
if [[ "${1}" ]]; then
    ARTIFACT="${1}"
else
    echo "No artifact provided. Exit....."
    exit 1
fi

# Artifact version
if [[ "${2}" ]]; then
    VERSION="${2}"
else
    echo "No version provided. Exit....."
    exit 1
fi

# Artifactory location
if [[ "${3}" ]]; then
    REPO="${3}"
else
    REPO="repo/example"
fi

# Artifactory server
if [[ "${4}" ]]; then
    SERVER="${4}"
else
    SERVER="https://artifactory.example.com/artifactory"
fi

FULL_PATH="${SERVER}/${REPO}/${ARTIFACT}/${VERSION}"

echo "SERVER: ${SERVER}"
echo "REPO: ${REPO}"
echo "ARTIFACT: ${ARTIFACT}"
echo "VERSION: ${VERSION}"
echo "FULL_PATH: ${FULL_PATH}"

ARTIFACTORY_CREDENIALS="user-ro:ThisIsAPassword"

# get lastest version
FULL_VERSION=$(curl -u "${ARTIFACTORY_CREDENIALS}" -s "${FULL_PATH}/maven-metadata.xml" | grep -E "(<value>*.*<\/value>)"  | head -1 | sed "s/.*<value>\([^<]*\)<\/value>.*/\1/")
echo "FULL_VERSION: ${FULL_VERSION}"

# Artifact full path
ARTIFACT_PATH="${FULL_PATH}/${ARTIFACT}-${FULL_VERSION}.jar"
echo "ARTIFACT_PATH: ${ARTIFACT_PATH}"

# md5 full path
MD5_PATH="${ARTIFACT_PATH}.md5"
echo "MD5_PATH: ${MD5_PATH}"

# download jar
curl -u "${ARTIFACTORY_CREDENIALS}" -o "${ARTIFACT}.jar" "${ARTIFACT_PATH}" -L

# Get md5
MD5_REMOTE=$(curl -u ${ARTIFACTORY_CREDENIALS} "${MD5_PATH}")
MD5_LOCAL=$(md5sum "${ARTIFACT}.jar" | awk '{ print $1 }')

echo "MD5_REMOTE: ${MD5_REMOTE}"
echo "MD5_LOCAL: ${MD5_LOCAL}"

# Check if md5 is the the same
if ! [[ "${MD5_REMOTE}" == "${MD5_LOCAL}" ]]; then 
    echo "MD5 is different. Exit....."
    exit 1
fi