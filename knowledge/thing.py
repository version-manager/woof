import json
from pathlib import Path

for file in Path.cwd().glob('./output/*'):
	if file.is_dir(): continue

	obj = json.loads(file.read_text())	
	output = ''
	for release in obj['releases']:
		for platform in release['platforms']:
			output += f"{obj['name_pretty']}|{release['version']}|{platform['os']}|{platform['arch']}|{platform['download_url']}\n"

	Path.cwd().joinpath('../output', file.stem + '.txt').write_text(output)
