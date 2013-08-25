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
	local olddir=$PWD
	cd $1
	_zilsh_debug "Loading bundle from $1"

	# Log debug messages for missing directories and files
	[[ -f "guard.zsh" ]]       || _zilsh_debug "  No guard file found."
	[[ -d "functions" ]]       || _zilsh_debug "  No functions directory found."
	[[ -d "themes" ]]          || _zilsh_debug "  No themes directory found."
	[[ -f "aliases.zsh" ]]     || _zilsh_debug "  No aliases file found."
	[[ -f "keybindings.zsh" ]] || _zilsh_debug "  No keybindings file found."
	[[ -f "init.zsh" ]]        || _zilsh_debug "  No init file found."

	if [[ -f "guard.zsh" ]] && zsh "./guard.zsh"; then
		_zilsh_warn "  Guardfile exited nonzero, aborting load."
		return 1
	fi

	# Add themes to $zsh_themes array
	if [[ -d "themes" ]]; then
		for theme_file (themes/*.zsh-theme); do
			zsh_themes[$theme_name]=${theme_file:a}
		done
	fi

	# Add functions to the fpath
	[[ -d "functions" ]] && fpath=(functions(:a) $fpath) && _zilsh_debug "  Functions loaded."

	# Load aliases
	# This is temporary, eventually the plan is to use `aliases/*.zsh-alias` instead.  But that takes
	# a bit more work to get right, this is more loose and can easily be switched to that without
	# breaking anything.
	[[ -f "aliases.zsh" ]] && source "aliases.zsh" && _zilsh_debug "  Aliases loaded."

	# load keybindings
	[[ -f "keybindings.zsh" ]] && source "keybindings.zsh" && _zilsh_debug "  Keybindings loaded."

	# Source the init.zsh file
	[[ -f "init.zsh" ]] && source "init.zsh" && _zilsh_debug "Bundle in $1 initialized."
	_zilsh_debug "Done loading $1"
	cd $olddir
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
