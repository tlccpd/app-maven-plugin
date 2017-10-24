set -x
set -e

Die() {
	echo $1
	exit 1
}

# if [[ $(git status -uno --porcelain) ]]; then
# 	Die 'There are uncommitted changes.'
# fi

# git checkout master
# git pull

read -r -p 'Release version: ' VERSION

git checkout -b release-$VERSION

mvn versions:set versions:commit -DnewVersion=$VERSION
git commit -am "Releases v$VERSION."
# git tag v$VERSION
# git push --tags

mvn versions:set versions:commit -DnewVersion=$VERSION-SNAPSHOT
git commit -am "Updates version to v$VERSION-SNAPSHOT."

# Updates README.md version - Maven.
sed -e "s/\(<version>\).*\(<\/version>\)/\1$VERSION\2/g" README.md > README.md

# # Updates README.md version - Gradle.
# sed -i -e "s/(com.google.cloud.tools:appengine-gradle-plugin:).*(')/\1$REPLACE_TEXT\2/g" README.md

# Updates CHANGELOG.md.
./update_changelog $VERSION

read -n 1 -r -s -p "Double-check CHANGELOG edits [Press any key to continue]"

git commit -am "Updates CHANGELOG and README for v$VERSION."

# git push -u origin release-$VERSION
