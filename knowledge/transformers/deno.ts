import * as util from '../util/util.ts'
import type { OutputSchema } from '../types/Output.generated.d.ts'

export function transformDeno(releases: any) {
	const outputJson: OutputSchema = {
		name_id: 'deno',
		name_pretty: 'Deno',
		releases: [],
	}

	for (const releaseInfo of releases) {
		let version: string = releaseInfo.name || releaseInfo.tag_name

		if (version.startsWith('Release ')) {
			version = version.slice('Release '.length)
		}

		if (!Array.isArray(releaseInfo.assets)) {
			continue
		}

		const platforms: OutputSchema['releases'][0]['platforms'] = []
		for (const asset of releaseInfo.assets) {
			const asset_name: string = asset.name
			const download_count = asset.download_count
			const created_at: string = asset.created_at
			const downloadUrl: string = asset.browser_downloadUrl
			// let result: RegExpExecArray | null
			// if (
			// 	version.startsWith('v0.') &&
			// 	parseInt(version.slice(3, version.lastIndexOf('.'))) < 36
			// ) {
			// 	result = /^deno_(?<os>.+?)_(?<arch>.+?)\./u.exec(asset_name)
			// } else {
			// 	result = /^deno[_-](?<arch>.+?_64?)[_-](?<os>.+?)\./u.exec(asset_name)
			// }
			const name = /^deno[_-](?<name>.*?)\./.exec(asset_name)?.groups?.name
			let arch: OutputSchema['releases'][0]['platforms'][0]['arch']
			let os: OutputSchema['releases'][0]['platforms'][0]['os']
			switch (name) {
				case 'x86_64-unknown-linux-gnu':
					arch = 'arm64'
					os = 'linux'
					break
				case 'aarch64-apple-darwin':
					arch = 'arm64'
					os = 'darwin'
					break
				case 'x86_64-apple-darwin':
					arch = 'arm64'
					os = 'darwin'
					break
				case 'x86_64-pc-windows-msvc':
					continue
				case 'linux_x64':
				case 'osx_x64':
				case 'win_x64':
				case 'mac_x64':
					continue
				case 'src':
				case 'lib.deno.d.ts':
					continue
				case void 0:
					continue
				default:
					console.log('exitingggg', name)
					Deno.exit(1)
			}

			platforms.push({
				arch,
				os,
				download_url: asset.browser_download_url,
			})
		}

		// TODO
		if (platforms.length > 0) {
			outputJson.releases.push({
				version,
				platforms,
			})
		}
	}

	return outputJson
}
