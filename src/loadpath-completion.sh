
_loadpath()
{
	local _SAVE_LOAD_PATH_FILE=$HOME/.path_db

	local cur prev aliases prevprev
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"
	prevprev="${COMP_WORDS[COMP_CWORD-2]}"
	aliases=()

	# Build a list of available aliases
	OLD_IFS=$IFS
	if [ -f $_SAVE_LOAD_PATH_FILE -a -r $_SAVE_LOAD_PATH_FILE ]
	then

		while IFS=';' read -a line
		do
			local _CUR_ALIAS="${line[0]}"
			local _CUR_PATH="${line[1]}"
			if [ "$_CUR_ALIAS" != "" ]
			then
				IFS=$OLD_IFS
				aliases=("${aliases[@]}" "$_CUR_ALIAS")
				IFS=';'
			fi
		done < $_SAVE_LOAD_PATH_FILE
	fi
	# Handle other options
	IFS=$OLD_IFS

	# Handle -p xxxx
	if [[ ${prev} == "-p" ]]
	then
		# Unescape space
		cur=${cur//\\ / }
		# Expand tilde to $HOME
		[[ ${cur} == "~/"* ]] && cur=${cur/\~/$HOME}
		# Show completion if path exist (and escape spaces)
		local files=("${cur}"*)
		[[ -e ${files[0]} ]] && COMPREPLY=( "${files[@]// /\ }" )
		return 0
	fi


	if [[ "${prevprev}" == "" || ( "${prevprev}" == "${cur}" && "${cur}" != "" ) ]]
	then
		COMPREPLY=( `echo "${aliases[@]}" | sed 's/ /\n/g' | grep "^${cur}" | sed ":a;N;\$!ba;s/\\n/\\$IFS/g"` )
		#echo ""
		#echo "test: \"compgen -W \"${aliases[@]}\" -- \"$cur\" \""
		#echo "tes2t: `echo "${aliases[@]}"`"
		#echo "al: ${aliases[@]}"
		#echo "rep: ${COMPREPLY}"
	fi

	return 0
}

complete -F _loadpath loadpath
complete -F _loadpath lpath
complete -F _loadpath savepath
complete -F _loadpath spath
complete -F _loadpath removepath
complete -F _loadpath rmpath
