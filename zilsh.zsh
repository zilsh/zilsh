[[ -z "$ZILSH_VERBOSITY" ]] && ZILSH_VERBOSITY=2

zilsh_error () {
	if (( $ZILSH_VERBOSITY >= 1 )); then
		printf "${fg_bold[red]}[Zilsh Error]${reset_color} $1\n" 1>&2
	fi
}

zilsh_warn () {
	if (( $ZILSH_VERBOSITY >= 2 )); then
		printf "${fg_bold[yellow]}[Zilsh Warning]${reset_color} $1\n" 1>&2
	fi
}

zilsh_debug () {
	if (( $ZILSH_VERBOSITY >= 3 )); then
		printf "${fg_bold[blue]}[Zilsh Debug]${reset_color} $1\n" 1>&2
	fi
}

zilsh_load_bundle () {
	# Keep the old BUNDLE_DIR so that we can restore it later, allowing
	# bundles to be loaded recursively
	local old_bundle_dir=$BUNDLE_DIR
	BUNDLE_DIR=$1

	zilsh_debug "Loading bundle from $BUNDLE_DIR"

	# Log debug messages for missing directories and files
	[[ -f "$BUNDLE_DIR/guard.zsh" ]]       || zilsh_debug "  No guard file found."
	[[ -d "$BUNDLE_DIR/functions" ]]       || zilsh_debug "  No functions directory found."
	[[ -d "$BUNDLE_DIR/themes" ]]          || zilsh_debug "  No themes directory found."
	[[ -f "$BUNDLE_DIR/aliases.zsh" ]]     || zilsh_debug "  No aliases file found."
	[[ -f "$BUNDLE_DIR/keybindings.zsh" ]] || zilsh_debug "  No keybindings file found."
	[[ -f "$BUNDLE_DIR/init.zsh" ]]        || zilsh_debug "  No init file found."

	if [[ -f "$BUNDLE_DIR/guard.zsh" ]] && zsh "$BUNDLE_DIR/guard.zsh"; then
		zilsh_warn "  Guardfile exited nonzero, aborting load."
		return 1
	fi

	# Add themes to $zsh_themes array
	if [[ -d "$BUNDLE_DIR/themes" ]]; then
		for theme_file ($BUNDLE_DIR/themes/*.zsh-theme); do
			zsh_themes[${theme_file:t:r}]=${theme_file:a}
		done
	fi

	# Add functions to the fpath
	if [[ -d "$BUNDLE_DIR/functions" ]]; then
		fpath=($BUNDLE_DIR/functions(:a) $fpath)
		autoload $BUNDLE_DIR/functions/*(:t)
		zilsh_debug "  Functions loaded."
	fi

	# Load aliases
	# This is temporary, eventually the plan is to use `aliases/*.zsh-alias` instead.  But that takes
	# a bit more work to get right, this is more loose and can easily be switched to that without
	# breaking anything.
	[[ -f "$BUNDLE_DIR/aliases.zsh" ]] && source "$BUNDLE_DIR/aliases.zsh" && zilsh_debug "  Aliases loaded."

	# load keybindings
	[[ -f "$BUNDLE_DIR/keybindings.zsh" ]] && source "$BUNDLE_DIR/keybindings.zsh" && zilsh_debug "  Keybindings loaded."

	# Source the init.zsh file
	[[ -f "$BUNDLE_DIR/init.zsh" ]] && source "$BUNDLE_DIR/init.zsh" && zilsh_debug "Bundle in $BUNDLE_DIR initialized."

	zilsh_debug "Done loading $BUNDLE_DIR"
	BUNDLE_DIR=$old_bundle_dir
}

zilsh_init () {
	zilsh_debug "Starting in $1..."

	# Throw errors for missing path parameter
	if [[ -z "$1" ]]; then
		zilsh_error "No path was passed to the zilsh_init function."
		return
	fi

	local zilshdir=${${~1}:a}

	# Throw error if $zilshdir is nonexistent
	if [[ ! -d "$zilshdir" ]]; then
		zilsh_error "Nonexistent path $zilshdir passed to the zilsh_init function."
		return
	fi
	zilsh_debug "Initialized in $zilshdir"
	
	typeset -Ag zsh_themes

	# Load and run compinit
	autoload -U compinit
	compinit -id "/tmp/.zcompdump"

	# Load the bundles
	for bundle ($zilshdir/*(N-/)); do
		zilsh_load_bundle $bundle
	done

	# Load the theme
	if (( ${+ZILSH_THEME} )); then
		if [[ -f $zsh_themes[$ZILSH_THEME] ]]; then
			source $zsh_themes[$ZILSH_THEME]
		fi
	fi
	wait
}

# this is here just to preserve compatibility, it's deprecated and will be
# removed in a later version
_zilsh_init() {
	zilsh_init "$@"
}
