#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
WARN=$(tput setaf 3)
NC=$(tput sgr0)
BOLD=$(tput bold)
REV=$(tput smso)

WORKING_DIR=$(dirname $(realpath $0))/repos

#read -r -d '' REPOS << EOL
#
#web-platform-tests|w3c|master|jeremypoulter|w3c_mirror
#web-platform-tests|w3c|master|jeremypoulter|w3c_tracking
#web-platform-tests|jeremypoulter|master|jeremypoulter|w3c_tracking
#
#wpt-tools|w3c|master|jeremypoulter|w3c_mirror
#wpt-tools|w3c|master|jeremypoulter|w3c_tracking
#wpt-tools|jeremypoulter|master|jeremypoulter|w3c_tracking
#
#EOL

echo "Using woring directory '${WORKING_DIR}'"
mkdir -p ${WORKING_DIR}

# Some support functions
function error()
{
    echo "${RED}$*${NC}" >&2
    cleanup
    exit 1
}

function abort()
{
    error "Abort."
}

function cleanup()
{
    echo -n
}

function msg()
{
    echo "${GREEN}$*${NC}"
}

function warn()
{
    echo "${WARN}$*${NC}"
}

REPO=$1
TO_USER=$2
TO_BRANCH=$3

msg "### Updating $REPO on $TO_USER/$TO_BRANCH"

DIR=$WORKING_DIR/$REPO

# Update to the 'to' repo/branch
if [ -e $DIR ]; then
    msg "### Pulling ${REPO} from ${TO_USER}/${TO_BRANCH}"
    cd $DIR
    # Add the new remote if needed 
    git remote show | grep ${TO_USER} > /dev/null || git remote add ${TO_USER} "git@github.com:${TO_USER}/${REPO}.git" || abort
    git fetch ${TO_USER} || abort
    git checkout ${TO_BRANCH} || abort
else
    msg "### Cloning ${REPO} from ${TO_USER}/${TO_BRANCH}"
    GIT_DIR=${DIR}
    # Assumes we are using the system Git on windows rather than Cygwin's Git
    if [ $(uname -o) = Cygwin ] ; then
        GIT_DIR=$(cygpath -w ${GIT_DIR})
    fi
    git clone --origin ${TO_USER} --branch ${TO_BRANCH} "git@github.com:${TO_USER}/${REPO}.git" $GIT_DIR || abort
fi

shift 3
cd $DIR
while [[ $# -ge 2 ]]
do
    FROM_USER=$1
    FROM_BRANCH=$2

    msg "### Fetching ${REPO} from ${FROM_USER}/${FROM_BRANCH}"
    git remote show | grep ${FROM_USER}  > /dev/null || git remote add ${FROM_USER} "git@github.com:${FROM_USER}/${REPO}.git" || abort
    git fetch ${FROM_USER} || abort

    msg "### Merging ${REPO} from ${FROM_USER}/${FROM_BRANCH}"
    git config user.name "WPT Auto Merger" || abort
    git config user.email "wpt.am@dlna.org" || abort
    git merge ${FROM_USER}/${FROM_BRANCH} --no-edit || abort

    shift 2
done

msg "### Pushing ${REPO} to ${TO_USER}/${TO_BRANCH}"
git push ${TO_USER} ${TO_BRANCH} || about
