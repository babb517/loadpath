#!/bin/bash
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

BASHRC=
LIB_DIR=

# Get script directory
pushd `dirname $0` 2>&1 > /dev/null 
SCRIPTPATH=`pwd`
popd 2>&1 > /dev/null



echo "Installing loadpath functions..."

if [ `id -u` == "0" ]
then
	FAIL="false"
	# Ran as root. Attempt global install.
	if [ -d "/var/lib" ]
	then
		LIB_DIR="/var/lib/loadpath"
	else
		FAIL="true"
	fi

	if [ -e "/etc/.bashrc" ]
	then
		BASHRC="/etc/.bashrc"
	elif [ -e "/etc/bash.bashrc" ]
	then
		BASHRC="/etc/bash.bashrc"
	else
		FAIL="true"
	fi

	if [ "$FAIL" == "true" ]
	then
		echo "ERROR: Loadpath currently doesn't support automatic global installation on your system."
		echo "       Please run the script as non-root to install for your user acount or attempt"
		echo "       a manual installation."
		exit 1
	fi

else
	# Install for just this user.
	if [ -e "$HOME/.bashrc" ]
	then
		BASHRC="$HOME/.bashrc"
		LIB_DIR="$HOME/lib/loadpath"
	else
		echo "ERROR: Loadpath currently doesn't support automatic global installation on your system."
		echo "       Please manually install the loadpath script and ensure it is run upon terminal startup."
		exit 1
	fi


fi

mkdir -p "$LIB_DIR"
cp "$SCRIPTPATH/src/loadpath.sh" "$LIB_DIR/."

if [ -f "$LIB_DIR/loadpath.sh" ]
then
	chown -R "$USER":"$USER" "$LIB_DIR"
	chmod -R 755 "$LIB_DIR"
	echo ". $LIB_DIR/loadpath.sh" >> "$BASHRC"
	. "$LIB_DIR/loadpath.sh"
	

	echo "The loadpath functions have been successfully installed."
	echo "You may now use spath, lpath, lspath, and rmpath commands"
	echo "to manage and use path aliases."
	echo "NOTE: You may need to restart your terminal session."

	lpath -h
	if [ "$?" != "0" ]
	then
		echo "ERROR: An error occurred running the loadpath functions."
		echo "       Please manually install the loadpath script and ensure it is run upon terminal startup."
		exit 1
	fi


else
	echo "ERROR: An error occurred installing loadpath functions."
	echo "       Please manually install the loadpath script and ensure it is run upon terminal startup."
	exit 1
fi


