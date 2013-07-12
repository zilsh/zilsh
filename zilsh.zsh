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
	olddir=$PWD
	cd $1
	_zilsh_debug "Loading bundle from $1"

	# Warn for missing directories
	[[ -d "configs" ]]     || _zilsh_debug "No configs directory found."
	[[ -d "completions" ]] || _zilsh_debug "No completions directory found."
	[[ -d "functions" ]]   || _zilsh_debug "No functions directory found."
	[[ -d "themes" ]]      || _zilsh_debug "No themes directory found."

	# Warn for missing init file
	[[ -f "init.zsh" ]]    || _zilsh_debug "No init.zsh file found."

	# Load all the .zsh files in configs/
	if [[ -d "configs" ]]; then
		for config_file (configs/*.zsh); do
			source $config_file && _zilsh_debug "Config loaded from $config_file"
		done
	fi

	# Add themes to $zsh_themes array
	if [[ -d "themes" ]]; then
		for theme_file (themes/*.zsh-theme); do
			zsh_themes[$theme_name]=${theme_file:a}
		done
	fi

	# Add functions and completions to the fpath
	[[ -d "completions" ]] && fpath=(completions(:a) $fpath) && _zilsh_debug "Completions loaded."
	[[ -d "functions" ]] && fpath=(functions(:a) $fpath) && _zilsh_debug "Functions loaded."

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

	# Load the bundles
	for bundle ($zilshdir/*(N-/)); do
		_zilsh_load_bundle $bundle
	done

	# Load and run compinit
	autoload -U compinit
	compinit -id "/tmp/.zcompdump"

	# Load the theme
	if (( ${+ZILSH_THEME} )); then
		if [[ -f $zsh_themes[$ZILSH_THEME] ]]; then
			source $zsh_themes[$ZILSH_THEME]
		fi
	fi
}
