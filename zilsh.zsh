#!/usr/bin/env zsh

[[ -z "$ZILSH_VERBOSITY" ]] && ZILSH_VERBOSITY=2

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

_zilsh_load_bundle () {
	_zilsh_debug "Loading bundle from $1"

        # Keep the old BUNDLE_DIR so that we can restore it later, allowing
        # bundles to be loaded recursively
	local old_bundle_dir=$BUNDLE_DIR
	BUNDLE_DIR=$1

	# Log debug messages for missing directories and files
	[[ -f "$1/guard.zsh" ]]       || _zilsh_debug "  No guard file found."
	[[ -d "$1/functions" ]]       || _zilsh_debug "  No functions directory found."
	[[ -d "$1/themes" ]]          || _zilsh_debug "  No themes directory found."
	[[ -f "$1/aliases.zsh" ]]     || _zilsh_debug "  No aliases file found."
	[[ -f "$1/keybindings.zsh" ]] || _zilsh_debug "  No keybindings file found."
	[[ -f "$1/init.zsh" ]]        || _zilsh_debug "  No init file found."

	if [[ -f "$1/guard.zsh" ]] && zsh "$1/guard.zsh"; then
		_zilsh_warn "  Guardfile exited nonzero, aborting load."
		return 1
	fi

	# Add themes to $zsh_themes array
	if [[ -d "$1/themes" ]]; then
		for theme_file ($1/themes/*.zsh-theme); do
			zsh_themes[$theme_name]=${theme_file:a}
		done
	fi

	# Add functions to the fpath
	if [[ -d "$1/functions" ]]; then
		fpath=($1/functions(:a) $fpath)
		autoload $1/functions/*(:t)
		_zilsh_debug "  Functions loaded."
	fi

	# Load aliases
	# This is temporary, eventually the plan is to use `aliases/*.zsh-alias` instead.  But that takes
	# a bit more work to get right, this is more loose and can easily be switched to that without
	# breaking anything.
	[[ -f "$1/aliases.zsh" ]] && source "$1/aliases.zsh" && _zilsh_debug "  Aliases loaded."

	# load keybindings
	[[ -f "$1/keybindings.zsh" ]] && source "$1/keybindings.zsh" && _zilsh_debug "  Keybindings loaded."

	# Source the init.zsh file
	[[ -f "$1/init.zsh" ]] && source "$1/init.zsh" && _zilsh_debug "Bundle in $1 initialized."

	BUNDLE_DIR=$old_bundle_dir
	_zilsh_debug "Done loading $1"
}

_zilsh_init () {
	_zilsh_debug "Starting in $1..."

	# Throw errors for missing path parameter
	if [[ -z "$1" ]]; then
		_zilsh_error "No path was passed to the zilsh_init function."
		return
	fi

	zilshdir=${${~1}:a}

	# Throw error if $zilshdir is nonexistent
	if [[ ! -d "$zilshdir" ]]; then
		_zilsh_error "Nonexistent path $zilshdir passed to the zilsh_init function."
		return
	fi
	_zilsh_debug "Initialized in $zilshdir"
	
	typeset -Ag zsh_themes

	# Load and run compinit
	autoload -U compinit
	compinit -id "/tmp/.zcompdump"

	# Load the bundles
	for bundle ($zilshdir/*(N-/)); do
		_zilsh_load_bundle $bundle
	done

	# Load the theme
	if (( ${+ZILSH_THEME} )); then
		if [[ -f $zsh_themes[$ZILSH_THEME] ]]; then
			source $zsh_themes[$ZILSH_THEME]
		fi
	fi
	wait
}
