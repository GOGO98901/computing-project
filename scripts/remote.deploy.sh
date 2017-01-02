#!/bin/bash

# Copyright 2016 Rory Claasen
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and

BRANCH="project"

if [ "$TRAVIS_BRANCH" == "$BRANCH" ]; then
	set -o errexit

	git config --global user.email "travis@travis-ci.org"
	git config --global user.name "Travis CI"

	cp README.md build/_site
	cp LICENSE build/_site/license.txt
	cp pubspec.yaml build/_site
	cp deploy.ignore build/_site/.gitignore

	cd build/_site/site

	echo "" >> pubspec.yaml
	echo "build: $TRAVIS_BUILD_NUMBER" >> pubspec.yaml

	git init
	git add --a
	git commit -m "Deploy to Github Pages"
	git push --force --quiet "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" master:gh-pages
else
	echo "Branch is not $BRANCH. Skipping deploy!"
fi
