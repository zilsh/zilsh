# Zilsh
Zilsh is a Zshell configuration framework designed to *get the fuck out of your
way.*


Zilsh is a fork of oh-my-zsh, and is backwards-compatible, but the legacy
systems are permanantly deprecated.  Use zshbundles where possible.

If you're looking for an out-of-the-box, pre-configured shell, this is not for
you.  This is for the power users who want to go through the manual labor of
configuring their shell by hand, just to get every detail perfect.

It's not feature-rich; it's feature-less.  By design.

-----
-----

# This is prerelease software and is not yet recommended for everyday usage; use it at your own risk.
## In fact, I can guarantee that it will not work.

-----
-----

# Installation
## As a git submodule
Simply add this git repository as a submodule, and source `zilsh.sh` at the
bottom of your `zshrc`. Zilsh configuration options should be added *above*
zilsh, or else zilsh will not be able to access them (obviously)

## The manual way

	$ cd ~/.zsh
	$ git clone https://github.com/NuckChorris/zilsh.git
	$ echo "source ~/.zsh/zilsh/zilsh.sh" >> ~/.zshrc

# Configuration
Zilsh provides a number of useful configuration options which allow you to fine-
tune it to your exact needs.

## colors
If you want fancy-schmancy colors in the logging messages (as well as the
helpers of `$fg`, `$bg`, `$color_reset`, etc.) you should add the following
above where you source zilsh:

	autoload -U colors && colors

## `$ZILSH_VERBOSITY`
Set this variable to control the logging level of Zilsh.
 * `3` — Shows debug, warning, and error messages.  Generally not required
 unless you're actually working on Zilsh itself.
 * `2` — **(DEFAULT)** Shows warning and error messages. This is recommended for
 everyday usage; warnings are no less evil than errors, except they aren't
 immediately harmful and Zilsh still loads.
 * `1` — Shows error messages.  This one sounds safe at first, *but it isn't.*
 Trust me, you don't want to use this setting.  Yes, it bitches at you less, but
 you won't see deprecation warnings and so upgrading is dangerous.
 * `0` — no logging, not even errors.  Probably a bad idea.

# ZShell Bundles
A ZShell Bundle is a directory containing a set of related functions, utilities,
completions, etc. in the same layout as a full oh-my-zsh install.

**HOWEVER**, there is one difference: lib/ is now configs/ (though lib/ still
works for legacy reasons, it is stronly recommended that you do not use it)

## Backwards Compatibility
In case you haven't already figured it out, it's easy to use anything designed
for oh-my-zsh (including oh-my-zsh's builtins) — just drop it in a bundle, and
it'll work like always.

# Future plans
 * Clean up the zshBundle layout and reduce legacy shit.
 * Add support for zsh-syntax-highlighting highlighters to zshBundles
