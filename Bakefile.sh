# shellcheck shell=bash

task.knowledge() {
	cd ./knowledge
	./knowledge "$@"

	

	# json to typescript types
	for file_name in InputNodejs InputZig Output; do
		json2ts --input "./validators/$file_name.schema.json" --output "./types/$file_name.generated.d.ts"
	done

}

task.generate() {
	local import_file='./pkg/src/share/imports.ts'

	> "$import_file"
	for file in ./pkg/src/share/fetchers/*.ts; do
		local file_name=${file##*/}; file_name=${file_name%.*}

		printf '%s\n' "import { parse${file_name^} } from \"./fetchers/$file_name\"" >> "$import_file"
	done

	# deno run --allow-net --allow-env ./pkg/src/share/parse-crystal.ts > ./output/Crystal.txt
	# bash ./pkg/src/share/parse-dart.sh > ./output/Dart.txt
	# deno run --allow-net --allow-env ./pkg/src/share/parse-deno.ts > ./output/Deno.txt
	# deno run --allow-net --allow-env ./pkg/src/share/parse-go.ts > ./output/Go.txt
	# deno run --allow-net --allow-env ./pkg/src/share/parse-haskell.ts > ./output/Haskell.txt
	# bash ./pkg/src/share/parse-nim.sh > ./output/Nim.txt
	# bash ./pkg/src/share/parse-nodejs.sh > ./output/Nodejs.txt
}
