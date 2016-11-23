#!/bin/bash
BRANCH="project"

if [ "$TRAVIS_BRANCH" == "$BRANCH" ]; then
	set -o errexit

	git config --global user.email "travis@travis-ci.org"
	git config --global user.name "Travis CI"

	cp README.md build/_site/web
	cp LICENSE build/_site/web/license.txt

	cd build/_site/web
	git init
	git add --a
	git commit -m "Deploy to Github Pages"
	git push --force --quiet "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" master:gh-pages
else
	echo "Branch is not $BRANCH. Skipping deploy!"
fi
