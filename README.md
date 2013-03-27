# Zilsh
Zilsh is a Zshell configuration framework designed to **get the fuck out of your
way.**


Zilsh is a fork of oh-my-zsh, and **is** backwards-compatible, but the legacy
systems are permanantly deprecated.  Use zshbundles where possible.

If you're looking for an out-of-the-box, pre-configured shell, this is not for
you.  This is for the power users who want to go through the manual labor of
configuring their shell by hand, just to get every detail perfect.

It's not feature-rich; it's feature-less.  By design.

-----
-----

# This is prerelease software and is not yet recommended for everyday usage; use it at your own risk

-----
-----

# Installation
## As a git submodule
Simply add this git repository as a submodule, and source `zilsh.sh` at the
bottom of your `zshrc`. Zilsh configuration options should be added **above**
zilsh, or else zilsh will not be able to access them (obviously)

## The manual way

	$ cd ~/.zsh
	$ git clone https://github.com/NuckChorris/zilsh.git
	$ echo "source ~/.zsh/zilsh/zilsh.sh" >> ~/.zshrc

# Configuration
Zilsh provides a number of useful configuration options which allow you to fine-
tune it to your exact needs.

## `$ZILSH_VERBOSITY`
Controls the logging levels of Zilsh.
 * `3` — Shows debug, warning, and error messages.  Generally not required
 unless you're actually working on Zilsh itself.
 * `2` — **(DEFAULT)** Shows warning and error messages. This is recommended for
 everyday usage; warnings are no less evil than errors, except they aren't
 immediately harmful and Zilsh still loads.
 * `1` — Shows error messages.  This one sounds safe at first, **but it isn't.**
 Trust me, you don't want to use this setting.  Yes, it bitches at you less, but
 you won't see deprecation warnings and so upgrading is dangerous.
 * `0` — no logging, not even errors.  Probably a bad idea.

