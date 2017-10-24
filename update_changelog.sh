#!/bin/bash -
# Usage: ./update_changelog <version>

Colorize() {
	echo "$(tput setaf $2)$1$(tput sgr0)"
}

# Updates CHANGELOG.md.
# Usage: UpdateChangeLog <version>
UpdateChangelog() {
	echo -e $(Colorize ">> Interactive CHANGELOG Updater <<\n" 14)

	local version=$1

	local entries_added=''
	local entries_changed=''
	local entries_fixed=''

	local keep_going=1
	local index_from_head=0
	while [ $keep_going -eq 1 ]; do
		# Gets the commit message.
		local commit_message=$(git log --format=%B -n 1 HEAD~$index_from_head | head -n 1)
		index_from_head=$[index_from_head+1]

		echo -e "COMMIT: $(Colorize "$commit_message" 10) \n"
		local use_commit

		# Asks the user whether or not to use the commit or to finish.
		while true; do
			read -r -p "Use commit? $(Colorize [yes/no/done] 1) " use_commit

			( [ "done" == "$use_commit" ] || [ "no" == "$use_commit" ] || [ "yes" == "$use_commit" ] ) \
				&& break
		done

		if [ "done" == "$use_commit" ]; then break; fi
		if [ "no" == "$use_commit" ]; then continue; fi

		# Asks the user what type of change this is.
		local entry_type
		while true; do
			read -r -p "What type of change is this? $(Colorize [add/change/fix] 1) " entry_type
			( [ "add" == "$entry_type" ] || [ "change" == "$entry_type" ] || [ "fix" == "$entry_type" ] ) \
				&& break
		done

		# Removes the PR number from the commit message.
		local entry_message=$(echo $commit_message | sed -e 's/ (\(.*\))//')

		# Capitalizes first character.
		entry_message=$(echo "$(tr '[:lower:]' '[:upper:]' <<< ${entry_message:0:1})${entry_message:1}")

		# Allows the user to edit the entry message.
		entry_message_file=$(mktemp)
		echo -e "# Edit the entry text below:\n$entry_message" > entry_message_file
		vi entry_message_file
		entry_message=$(cat entry_message_file | head -n 2 | tail -n 1)
		rm entry_message_file

		# Asks the user the link to include with the entry.
		local entry_link

		# Extracts the PR number.
		local pr_number=$(echo $commit_message | sed -e 's/.*(#\(.*\))/\1/')
		local pr_url="https://github.com/GoogleCloudPlatform/app-maven-plugin/pull/$pr_number"

		echo -e "\nFound PR link: $(Colorize $pr_url 14)"
		read -r -p "Use as link for entry? $(Colorize [Y/n] 1)"

		if [ "n" == "$use_pr_url" ]; then
			echo "Find the issue number to use. $(Colorize https://github.com/GoogleCloudPlatform/app-maven-plugin/issues/ 14)"

			local issue_number
			read -r -p 'Use issue number: ' issue_number

			entry_link="[#$issue_number](https://github.com/GoogleCloudPlatform/app-gradle-plugin/issues/$issue_number)"
		else
			entry_link="[#$pr_number]($pr_url)"
		fi

		local entry_text=$(echo "* $entry_message ($entry_link)")

		if [ "add" == "$entry_type" ]; then
			entries_added="$entries_added\n$entry_text"
		elif [ "change" == "$entry_type" ]; then
			entries_changed="$entries_changed\n$entry_text"
		elif [ "fix" == "$entry_type" ]; then
			entries_fixed="$entries_fixed\n$entry_text"
		fi

		echo -e "Entry added: $(Colorize "$entry_text" 8)\n"
	done

	local entries_file=$(mktemp)

	if ! ( [[ $entries_added ]] || [[ $entries_changed ]] || [[ $entries_fixed ]] ); then
		return
	fi

	echo -e "\n## $version" >> $entries_file
	if [[ $entries_added ]]; then
		echo -e "\n### Added\n$entries_added" >> $entries_file
	fi
	if [[ $entries_changed ]]; then
		echo -e "\n### Changed\n$entries_changed" >> $entries_file
	fi
	if [[ $entries_fixed ]]; then
		echo -e "\n### Fixed\n$entries_fixed" >> $entries_file
	fi

	# Gets line number to start inserting at.
	local insert_line=$(sed -n '/### Fixed/=' CHANGELOG.md | head -n 1)

	# Inserts the new entries into the changelog.
	echo "INSERT_LINE: $insert_line"
	sed -e "${insert_line}r $entries_file" CHANGELOG.md > CHANGELOG.md
	rm $entries_file

	echo -e $(Colorize ">> CHANGELOG Updated <<\n" 14)
}

UpdateChangelog $1
