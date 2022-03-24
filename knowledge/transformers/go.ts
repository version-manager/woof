import * as util from '../util/util.ts'
import type { OutputSchema } from '../types/Output.generated.d.ts'

export function transformGo(html: string) {
	const outputJson: OutputSchema = {
		name_id: 'deno',
		name_pretty: 'Deno',
		releases: [],
	}

	const results = html.matchAll(
		/<td class="filename".+? href="(?<uri>.*?)".+?<td>(?<kind>.*?)<\/td>.+?<td>(?<os>.*?)<\/td>.+?<td>(?<arch>.*?)<\/td>.+?<tt>(?<checksum>.*?)<\/tt>/gmsu
	)

	for (const result of results) {
		const asset_name = result?.groups?.uri
		if (asset_name === void 0) {
			continue
		}

		const version = /\/dl\/go(?<version>[0-9]\..+?)\./u.exec(asset_name)?.groups
			?.version
		if (version === void 0) {
			continue
		}

		const url = 'https://go.dev/dl'
		const downloadUrl = url.slice(0, -3) + asset_name

		let os = result?.groups?.os
		if (!os) {
			continue
		} else if (os === 'Linux') {
			os = 'linux'
		} else if (os === 'FreeBSD') {
			os = 'freebsd'
		} else if (os === 'macOS' || os.startsWith('OS X')) {
			os = 'darwin'
		} else if (os === 'Windows') {
			continue
		}

		let arch = result?.groups?.arch
		if (!arch) {
			continue
		} else if (arch === 'x86-64') {
			arch = 'amd64'
		} else if (arch === 'ARM64') {
			arch = 'arm64'
		} else if (arch === 'ARMv6') {
			arch = 'armv6'
		}
		console.info(`Go|v${version}|${os}|${arch}|${downloadUrl}`)

		const downloadUrl = url.slice(0, -3) + asset_name
		platforms.push({
			arch,
			os,
			download_url: asset.browser_download_url,
		})

		// outputJson.releases.push({
		// 	version,
		// 	platforms,
		// })
	}

	return outputJson
}
