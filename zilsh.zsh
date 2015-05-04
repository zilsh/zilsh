[[ -z "$ZILSH_VERBOSITY" ]] && ZILSH_VERBOSITY=2
[[ -z "$ZILSH_CACHE_DIR" ]] && ZILSH_CACHE_DIR=/var/run/zsh/

fpath=(${0%/*}/functions(:a) $fpath)
autoload ${0%/*}/functions/*(:t)
