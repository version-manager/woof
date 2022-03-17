import * as util from '../util/util.ts'
import type { OutputSchema } from '../types/OutputSchema.d.ts'

export function transformNodejs(inputJson: any) {
	const outputJson: OutputSchema = {
		name_id: 'nodejs',
		name_pretty: 'NodeJS',
		releases: [],
	}

	for (const releaseInfo of inputJson as any as Array<Record<string, any>>) {
		const vendor = {
			npmVersion: releaseInfo.npm,
			v8Version: releaseInfo.v8,
			uvVersion: releaseInfo.uv,
			zlibVersion: releaseInfo.zlib,
			opensslVersion: releaseInfo.openssl,
			modulesVersion: releaseInfo.modules,
			lts: releaseInfo.lts,
			security: releaseInfo.security,
		}

		const platforms: OutputSchema['releases'][0]['platforms'] = []
		for (const file of releaseInfo.files) {
			if (file === 'headers' || file === 'src') {
				continue
			}

			let arch: OutputSchema['releases'][0]['platforms'][0]['arch']
			let os: OutputSchema['releases'][0]['platforms'][0]['os']

			switch (file) {
				case 'linux-x64':
					arch = 'amd64'
					os = 'linux'
					break
				case 'linux-x86':
					arch = 'x86'
					os = 'linux'
					break
				case 'linux-arm64':
					arch = 'arm64'
					os = 'linux'
					break
				case 'linux-armv7l':
					arch = 'armv7l'
					os = 'linux'
					break
				case 'linux-armv6l':
					arch = 'armv6'
					os = 'linux'
					break
				case 'linux-ppc64le':
					arch = 'ppc64le'
					os = 'linux'
					break
				case 'linux-s390x':
					arch = 's390x'
					os = 'linux'
					break
				case 'osx-x32-tar':
				case 'osx-x86-tar':
					arch = 'x86'
					os = 'darwin'
					break
				case 'osx-x64-tar':
					arch = 'amd64'
					os = 'darwin'
					break
				case 'osx-arm64-tar':
					arch = 'arm64'
					os = 'darwin'
					break
				case 'osx-x64-pkg':
					continue
				case 'aix-ppc64':
					arch = 'ppc64'
					os = 'aix'
					break
				case 'win-x64-7z': // TODO
				case 'win-x64-exe':
				case 'win-x64-msi':
				case 'win-x64-zip':
				case 'win-x86-7z':
				case 'win-x86-exe':
				case 'win-x86-msi':
				case 'win-x86-zip':
					continue
				case 'sunos-x64': // TODO
				case 'sunos-x86':
					continue
				default:
					console.log('exiting', file)
					Deno.exit(1)
			}

			const mirror = 'https://nodejs.org'
			platforms.push({
				arch,
				os,
				download_url: `${mirror}/download/release/${releaseInfo.version}/node-${releaseInfo.version}-${file}.tar.gz`,
			})
		}

		outputJson.releases.push({
			version: releaseInfo.version.slice(1),
			platforms,
		})
	}

	return outputJson
}
