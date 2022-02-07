#!/usr/bin/env python3
import json
import re
import sys

text_json = json.load(sys.stdin)
for release in text_json:
	version = release['name'] or release['tag_name']
	if version.startswith('Release '):
		version = version[len('Release '):]

	for asset in release['assets']:
		asset_name = asset['name']
		download_count = asset['download_count']
		created_at = asset['created_at']
		url = asset['browser_download_url']

		result = re.search('^crystal-(.+?)-1-(?P<os>.+?)-(?P<arch>.+?)\.', asset_name)
		if not hasattr(result, 'group'):
			continue

		os = result.group('os')
		arch = result.group('arch')
		if arch == 'i686':
			arch = 'x86'
		elif arch == 'x86_64':
			arch = 'amd64'
		elif arch == 'x86_64-bundled':
			continue

		print(f'v{version}|{os}|{arch}|{url}|(Released {created_at} and {download_count} downloads)')
