# shellcheck shell=bash

task.generate() {
	export GITHUB_TOKEN="$(<"${XDG_CONFIG_HOME:-$HOME/.config}/woof/token")"

	deno run --allow-net --allow-env ./pkg/src/share/parse-crystal.ts > ./output/Crystal.txt
	bash ./pkg/src/share/parse-dart.sh > ./output/Dart.txt
	deno run --allow-net --allow-env ./pkg/src/share/parse-deno.ts > ./output/Deno.txt
	deno run --allow-net --allow-env ./pkg/src/share/parse-go.ts > ./output/Go.txt
	deno run --allow-net --allow-env ./pkg/src/share/parse-haskell.ts > ./output/Haskell.txt
	bash ./pkg/src/share/parse-nim.sh > ./output/Nim.txt
	bash ./pkg/src/share/parse-nodejs.sh > ./output/Nodejs.txt
	# bash ./pkg/src/share/parse-dart.sh > ./output/Dart.txt
	# bash ./pkg/src/share/parse-dart.sh > ./output/Dart.txt
	# bash ./pkg/src/share/parse-dart.sh > ./output/Dart.txt
}
