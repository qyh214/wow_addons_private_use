#!/bin/bash -eu

# This script generates a commit that updates the handler submodule. It
# assumes that it'll be run from within the repo while it's checked out as a
# submodule.
# ./handler/bin/updateHandler.sh        updates to master
# ./handler/bin/updateHandler.sh hash   updates to specified hash

# go to the script's directory
cd $(dirname $0)
# go to the handler directory
cd ..
# store what it's called
HANDLER=$(basename "$PWD")
echo "The handler is in: $HANDLER"

# Check that both working directories are clean
if git status -uno --ignore-submodules | grep -i changes > /dev/null
then
	echo >&2 "Handler working directory must be clean"
	exit 1
fi
cd ..
if git status -uno --ignore-submodules | grep -i changes > /dev/null
then
	echo >&2 "Working directory must be clean"
	exit 1
fi
BRANCH=$(git branch --show-current)

git fetch origin

# Current commit for the submodule
SUBMODULE=$(git rev-parse @:$HANDLER)

cd $HANDLER
git fetch origin

# Figure out what to set the submodule to
if [ -n "${1:-}" ]
then
	TARGET="$1"
	TARGETDESC="$1"
else
	TARGET=main
	TARGETDESC="main ($(git rev-parse --short origin/main))"
	# If we're falling back to main, it has to be up to date
	if [ $(git rev-parse $TARGET) != $(git rev-parse origin/$TARGET) ]; then
		echo >&2 "Local and remote $TARGET need to be in sync"
		echo >&2 "$(git rev-parse $TARGET) != $(git rev-parse origin/$TARGET)"
		exit 1
	fi
fi

# Generate commit summary
# TODO recurse
NEWCHANGES=$(git log $SUBMODULE..$TARGET --oneline --no-merges --topo-order --reverse --color=never)
NEWCHANGESDISPLAY=$(git log $SUBMODULE..$TARGET --oneline --no-merges --reverse --color=always)
COMMITMSG=$(cat <<END
Update handler submodule to $TARGETDESC

New changes:
$NEWCHANGES
END
)
# Check out main (or hash) of handler
git checkout $TARGET

# Commit
cd ..
git commit $HANDLER -m "$COMMITMSG" > /dev/null
if [ "$?" == "1" ]
then
	echo >&2 "No changes"
else
	cat >&2 <<END


Created commit with changes:
$NEWCHANGESDISPLAY
END
fi
