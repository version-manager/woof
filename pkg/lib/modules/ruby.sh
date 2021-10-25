# shellcheck shell=bash

# reference: https://github.com/ruby/ruby
# jruby: https://github.com/jruby/jruby
# mruby: https://github.com/mruby/mruby
# truffleruby: https://github.com/oracle/truffleruby
ruby.list() {
	local variant="$1"

	case "$variant" in
	ruby)
		local -a versions=()
		util.versions_from_git 'versions' 'https://github.com/ruby/ruby' 'refs/tags/v'
		versions=("${versions[@]/#/v}")
		;;
	jruby)
		local -a versions=()
		local prefix='refs/tags/'
		local prefix_length="${#prefix}"
		while read -r _sha1 refspec; do
		if [ "${refspec:0:$prefix_length}" = "$prefix" ]; then
			if [[ "$refspec" == @(*openssl*|*list) ]]; then
				continue
			fi
			versions+=("${refspec:$prefix_length}")
		fi
		done < <(git ls-remote --refs --tags https://github.com/jruby/jruby)
		versions=("${versions[@]/#/v}")
		;;
	mruby)
		local -a versions=()
		util.versions_from_git 'versions' 'https://github.com/mruby/mruby' 'refs/tags/'
		versions=("${versions[@]/#/v}")
		;;
	truffleruby)
		local -a versions=()
		util.versions_from_git 'versions' 'https://github.com/oracle/truffleruby' 'refs/tags/'
		;;
	*)
		echo 'no param passed'
		exit 1
	esac

	tty.multiselect 0 "${versions[@]}"
	local selected_version="$REPLY"
	tty.fullscreen_deinit
}
