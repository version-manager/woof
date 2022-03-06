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

		result = re.search('^stack-(?:.+?)-(?P<os>.+?)-(?P<arch>.+?)(?:-(?P<variant>.+?))?\.', asset_name)
		if not hasattr(result, 'group'):
			continue

		if url.endswith('.asc') or url.endswith('.sha256'):
			continue

		os = result.group('os')
		if os == 'sdist':
			continue
		arch = result.group('arch')
		if arch == 'i386':
			arch = 'x86'
		elif arch == 'x86_64':
			arch = 'amd64'

		print(f'{version}|{os}|{arch}|{url}|(Released {created_at} and {download_count} downloads)')
