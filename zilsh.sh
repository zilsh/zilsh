#!/bin/zsh

[[ -z "$ZILSH_VERBOSITY" ]] && ZILSH_VERBOSITY=3

_zilsh_error () {
	if (( $ZILSH_VERBOSITY >= 1 )); then
		printf "${fg_bold[red]}[Zilsh Error]${reset_color} $1\n" 1>&2
	fi
}

_zilsh_warn () {
	if (( $ZILSH_VERBOSITY >= 2 )); then
		printf "${fg_bold[yellow]}[Zilsh Warning]${reset_color} $1\n" 1>&2
	fi
}

_zilsh_debug () {
	if (( $ZILSH_VERBOSITY >= 3 )); then
		printf "${fg_bold[blue]}[Zilsh Debug]${reset_color} $1\n" 1>&2
	fi
}

_zilsh_init () {
	
	_zilsh_debug "Starting..."

	#################
	# ERROR HANDLING
	###############

	# Throw errors for missing or nonexistent path parameter.
	if [[ -z "$1" ]]; then
		_zilsh_error "No path was passed to the zilsh_init function."
		return
	elif [[ ! -d "$1" ]]; then
		_zilsh_error "Nonexistent path passed to the zilsh_init function."
		return
	fi

	# Warn for missing directories
	[[ -d "$ZILSHDIR/configs" ]]     || _zilsh_warn "No configs directory found."
	[[ -d "$ZILSHDIR/plugins" ]]     || _zilsh_warn "No plugins directory found."
	[[ -d "$ZILSHDIR/completions" ]] || _zilsh_warn "No completions directory found."
	[[ -d "$ZILSHDIR/functions" ]]   || _zilsh_warn "No functions directory found."
	[[ -d "$ZILSHDIR/themes" ]]      || _zilsh_warn "No themes directory found."

	# So basically, this is a roundabout way to ensure that all directories are absolute.
	command -v greadlink >/dev/null 2>&1 && {
		# On OS X, if the GNU readlink(1) is installed, we use that instead of readlink
		ZILSHDIR="$(greadlink --canonicalize $1)" && _zilsh_debug "Initialized in $ZILSHDIR"
	} || {
		# We feed the path into readlink using the --canonicalize flag to turn it absolute.
		ZILSHDIR="$(readlink --canonicalize $1)" && _zilsh_debug "Initialized in $ZILSHDIR"
	} 2>/dev/null || {
		_zilsh_error "Your readlink implementation lacks the --canonicalize flag.\nIf you are on OS X, install the GNU coreutils package."
		return
	}

	# Sets up the functions/ and completions/ directories
	fpath=($ZILSHDIR/functions $ZILSHDIR/completions $fpath)

	# Load all of the config files in configs/ that end in .zsh
	if [[ -d "$ZILSHDIR/configs" ]]; then
		for config_file ($ZILSHDIR/configs/*.zsh); do
			source $config_file
		done
	fi

	# Add all defined plugins to the function path. This must be done before running compinit.
	for plugin ($plugins); do
		if test -f $ZILSHDIR/plugins/$name/$name.plugin.zsh || test -f $ZSH/plugins/$name/_$name; then
			fpath=($ZILSHDIR/plugins/$plugin $fpath)
		fi
	done

	# Load and run compinit
	autoload -U compinit
	compinit -id "/tmp/.zcompdump"

	# Load all defined plugins.
	for plugin ($plugins); do
		if [ -f $ZILSHDIR/plugins/$plugin/$plugin.plugin.zsh ]; then
			source $ZILSHDIR/plugins/$plugin/$plugin.plugin.zsh
		fi
	done

	# Load the theme
	if (( ${+ZSH_THEME} )); then
		if [[ -f "$ZILSHDIR/themes/$ZSH_THEME.zsh-theme" ]]; then
			source "$ZILSHDIR/themes/$ZSH_THEME.zsh-theme"
		fi
	fi
}
