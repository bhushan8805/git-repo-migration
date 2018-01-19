#!/bin/bash

echo -ne "Enter the URL of source GIT Repo: "
read SOURCE_GIT_REPO
echo -ne "Enter the URL of target GIT Repo (MUST NOT BE INITIALISED): "
read DESTINATION_GIT_REPO

url_regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
if [[ $SOURCE_GIT_REPO =~ $url_regex ]] || [[ $DESTINATION_GIT_REPO =~ $url_regex ]]
then 
    # Checkout the repositories 
    WORKPLACE_DIR=`date +%s`
    mkdir $WORKPLACE_DIR
    cd $WORKPLACE_DIR
    git clone $SOURCE_GIT_REPO .

    # Fetch all remote branches for local copy
    git fetch --all
    for BRANCH in `git branch -a | \
                    grep remotes/origin/* | \
                    sed 's/\( ->\).*//' | \
                    sed 's/remotes\/origin\///'`; do 
      if [[ $BRANCH != 'HEAD' ]]; then
        git checkout $BRANCH;
      fi; 
    done

    # Add new destination repo
    git remote add new-origin $DESTINATION_GIT_REPO

    # Push whole repo to destination repo
    git push --all new-origin
    git push --tags new-origin

    # List current config of source git repo
    git remote -v

    # Change remote of old repo to point to new repo
    git remote rm origin
    git remote rename new-origin origin
    exit 0
else
    echo "ERROR: INVALID URL"
    exit 1
fi

