# shellcheck shell=bash

task.knowledge:() {
	cd ./knowledge

	ajv validate -s ./validators/InputNodejs.json -d ./input/NodejsExample.json
	ajv validate -s ./validators/InputZig.json -d ./input/ZigExample.json

	json2ts --input ./validators/InputNodejs.json --output ./types/InputNodejs.d.ts
	json2ts --input ./validators/InputZig.json --output ./types/InputZig.d.ts
	json2ts --input ./validators/OutputSchema.json --output ./types/OutputSchema.d.ts

	deno run --allow-env --allow-net --allow-read --allow-write ./main.ts
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
