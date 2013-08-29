#!/bin/bash
# #########################################################################
# Program:      loadpath
# Description:  Cross-terminal path management script functions.
# Author:       Joseph Babb (jbabb1@asu.edu)
# #########################################################################
# Copyright (c) 2010-2013 <Joseph Babb (jbabb1 <at> asu <dot> edu)>
#
# For information on how to contact the authors, please visit
#	http://reasoning.eas.asu.edu/cplus2asp
#
#
# This is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# cplus2asp is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# #########################################################################

_SAVE_LOAD_PATH_FILE=$HOME/.path_db
_SAVE_LOAD_PATH_FILE_TMP=$HOME/.path_db.tmp


# Displays help output for loadpath functions.
function loadpath_help() {

	echo "# ----------------------------------------------------------------------------"
	echo "Loadpath is a series of functions that allow you to manage"
	echo "and use path aliases within terminal environment."
	echo "# ----------------------------------------------------------------------------"
	echo "Functions: "
	echo "    savepath [<alias>] [-p <path>]"
	echo "    spath [<alias>] [-p <path>]"
	echo "        Saves an alias to path mapping."
	echo "        <alias> - The alias to assign. [Default: \"\"]."
	echo "        <path>  - The path to assign to the alias. [Default: working directory]"
	echo ""
	echo "    loadpath [<alias>]"
	echo "    lpath [<alias>]"
	echo "        Loads the path corresponding to the alias."
	echo "        <alias> - The alias to load. [Default: \"\"]."
	echo ""
	echo "    listpath"
	echo "    lspath"
	echo "        Lists all stored aliases and their path mappings."
	echo ""
	echo "    removepath [<alias>]"
	echo "    rmpath [<alias>]"
	echo "        Removes an alias to path mapping."
	echo "        <alias> - The alias to remove. [Default: \"\"]."
	echo "# ----------------------------------------------------------------------------"

}



# --------------------------------------------------
# @brief: Lists all available alias -> path mappings
# @usage: listpath
# --------------------------------------------------
function listpath() {

	if [ "$1" == "-h" -o "$1" == "--help" ]
	then
		loadpath_help
		return 0
	elif [ "$1" != "" ]
	then
		echo "ERROR: Bad argument \"$1\"." 1>&2
		loadpath_help
		return 1
	fi

	# Look through our list of paths
	if [ -f $_SAVE_LOAD_PATH_FILE -a -r $_SAVE_LOAD_PATH_FILE ]
	then
		printf "%14s    %s\n" "ALIAS" "PATH"
		while IFS=';' read -a line
		do
			local _CUR_ALIAS="${line[0]}"
			local _CUR_PATH="${line[1]}"

			printf "%14s -> %s\n" "$_CUR_ALIAS" "$_CUR_PATH"
		
		done < $_SAVE_LOAD_PATH_FILE

	else
		echo "ERROR: Could not access the path database file. Have you used \"savepath\" previously?" 1>&2
		loadpath_help
		return 1
	fi
}

# Alias for listpath
function lspath() {
	listpath $@
}



# --------------------------------------------------
# @brief: Saves an alias -> path mapping.
# @usage: savepath [<alias>] [-p <path>]
#         <alias> - The alias to save the path as.
#                   Defaults to "" if not provided.
#         <path>  - The path to map the alias to.
#                   Defaults to the working directory. 
# --------------------------------------------------
function savepath() {


	local _PATH=`pwd`
	local _NAME=""
	OPTION=

	# Check for --help
	for i in "$@"
	do
		if [ "$i" == "--help" ]
		then
			loadpath_help
			return 0
		fi
	done

	# parse options
	local _REPEAT="true"
	while [ "$_REPEAT" == "true" ]
	do
		while getopts ":p:h" OPTION
		do
			case $OPTION in
				h)
					loadpath_help
					return 0
					;;
				p)
					_PATH="$OPTARG"
					;;
				?)
					echo "ERROR: Invalid argument \"-$OPTARG\"." 1>&2
					loadpath_help
						return 1
					;;
				:)
					echo "ERROR: Expected a value following \"-$OPTARG\"." 1>&2
					loadpath_help
					return 1
					;;
			esac
		done
		shift $((OPTIND-1))
		OPTIND=1

		# Get the unadorned aliase argument if it's present.
		if [ -z "$1" ]
		then
			_REPEAT="false"
		else
			if [ -z "$_NAME" ]
			then
				_NAME="$1"
				shift 1
			else
				echo "ERROR: Multiple alias arguments detected. Exiting." 1>&2
				loadpath_help
				return 1
			fi
		fi
	done

	# Go through the path file line by line and see about finding the path we need.
	if [ -e $_SAVE_LOAD_PATH_FILE_TMP ] 
	then
		echo "ERROR: Could not lock path database file." 1>&2
		echo "       Please delete \"$_SAVE_PATH_FILE_TMP\" and try again." 1>&2
		return 1
	else
		touch $_SAVE_LOAD_PATH_FILE_TMP
		local _FOUND="false"


		# Make sure default goes first
		if [ "$_NAME" == "" ]
		then
			echo "$_NAME;$_PATH" >> $_SAVE_LOAD_PATH_FILE_TMP
		fi


		if [ -f $_SAVE_LOAD_PATH_FILE -a -r $_SAVE_LOAD_PATH_FILE ]
		then
			while IFS=';' read -a line
			do
				local _CUR_ALIAS="${line[0]}"
				local _CUR_PATH="${line[1]}"
	
				if [ "$_CUR_ALIAS" == "$_NAME" ]
				then
					if [ "$_NAME" != "" ]
					then
						echo "$_NAME;$_PATH" >> $_SAVE_LOAD_PATH_FILE_TMP
					fi
					_FOUND="true"
				else
					echo "$_CUR_ALIAS;$_CUR_PATH" >> $_SAVE_LOAD_PATH_FILE_TMP
				fi

			done < $_SAVE_LOAD_PATH_FILE
		fi

		# write out the path if we didn't find it (it's new)
		if [ "$_NAME" != "" -a "$_FOUND" == "false" ]
		then
			echo "$_NAME;$_PATH" >> $_SAVE_LOAD_PATH_FILE_TMP
		fi
	fi



	# Overwrite the path file with our new file.
	mv $_SAVE_LOAD_PATH_FILE_TMP $_SAVE_LOAD_PATH_FILE

}

# Alias for savepath
function spath() { 
	savepath $@
}


# --------------------------------------------------
# @brief: Removes an alias -> path mapping from the database.
# @usage: removepath [<alias>]
#         <alias> - The alias to remove.
#                   Defaults to "" if not provided.
# --------------------------------------------------
function removepath() {
	if [ "$1" == "-h" -o "$1" == "--help" ]
	then
		loadpath_help
		return 0
	fi
	
	_NAME=""
	if [ "$1" != "" ]
	then
		_NAME="$1"
	fi

	# Go through the path file line by line and see about finding the path we need to delete.
	if [ -e $_SAVE_LOAD_PATH_FILE_TMP ] 
	then
		echo "ERROR: Could not lock path database file." 1>&2
		echo "       Please delete \"$_SAVE_PATH_FILE_TMP\" and try again." 1>&2
		return 1
	else

		touch $_SAVE_LOAD_PATH_FILE_TMP

		local _FOUND="false"
		if [ -f $_SAVE_LOAD_PATH_FILE -a -r $_SAVE_LOAD_PATH_FILE ]
		then
			while IFS=';' read -a line
			do
				local _CUR_ALIAS="${line[0]}"
				local _CUR_PATH="${line[1]}"
	
				if [ "$_CUR_ALIAS" == "$_NAME" ]
				then
					_FOUND="true"
				else
					echo "$_CUR_ALIAS;$_CUR_PATH" >> $_SAVE_LOAD_PATH_FILE_TMP
				fi

			done < $_SAVE_LOAD_PATH_FILE
		fi
		
		# write out the path if we didn't find it (it's new)
		if [ "$_FOUND" == "false" ]
		then
			echo "ERROR: \"$_NAME\" does not exist." 1>&2
			return 1
		fi
	fi
	

	# Overwrite the path file with our new file.
	mv $_SAVE_LOAD_PATH_FILE_TMP $_SAVE_LOAD_PATH_FILE

}

# Alias for removepath
function rmpath() {
	removepath $@
}


# --------------------------------------------------
# @brief: Loads a path from an alias.
# @usage: loadpath [<alias>]
#         <alias> - The alias to load.
#                   Defaults to "" if not provided.
# --------------------------------------------------
function loadpath() {
	if [ "$1" == "-h" -o "$1" == "--help" ]
	then
		loadpath_help
		return 0
	fi

	local _NAME=""
	if [ "$1" != "" ]
	then
		_NAME="$1"
	fi

	local _STATUS="0"


	# Look through our list of paths and find the one we're looking for
	if [ -f $_SAVE_LOAD_PATH_FILE -a -r $_SAVE_LOAD_PATH_FILE ]
	then
		_FOUND="false"
		while IFS=';' read -a line
		do
			local _CUR_ALIAS="${line[0]}"
			local _CUR_PATH="${line[1]}"
		
			if [ "$_CUR_ALIAS" == "$_NAME" ]
			then
				# found it! Let's go there
				_FOUND="true"

				if [ -d "$_CUR_PATH" ]
				then
					echo "cd \"$_CUR_PATH\""
					cd "$_CUR_PATH"
				else
					echo "ERROR: \"$_CUR_PATH\" is not a valid directory." 1>&2
					_STATUS="1"
				fi

				break
			fi
		done < $_SAVE_LOAD_PATH_FILE


		if [ "$_FOUND" == "false" ]
		then
			echo "ERROR: The path alias \"$_NAME\" doesn't exist. Please use \"savepath\" to create it." 1>&2
			_STATUS="1"
		fi
	else
		echo "ERROR: Could not access the path database file. Have you used \"savepath\" previously?" 1>&2
		loadpath_help
		_STATUS="1"
	fi
	return $_STATUS

}

# Alias for loadpath
function lpath() {
	loadpath $@
}

