import type { OutputSchema } from '../types/OutputSchema.d.ts'

type InputSchema = {
	[key: string]: {
		date: string
		docs: string
		stdDocs: string
		notes: string
		[key: string]:
			| string // TODO this 'string' should not exist
			| {
					tarball: string
					shasum: string
					size: string
			  }
	}
}

export function transformZig(inputJson: InputSchema) {
	const outputJson: OutputSchema = {
		name_id: 'zig',
		name_pretty: 'Zig',
		releases: [],
	}

	for (const [releaseVersion, releaseInfo] of Object.entries(inputJson)) {
		const platforms: OutputSchema['releases'][0]['platforms'] = []

		for (const [platformName, platformData] of Object.entries(releaseInfo)) {
			if (typeof platformData === 'string') {
				continue
			}

			if (platformName === 'src' || platformName === 'bootstrap') {
				continue
			}

			let arch: OutputSchema['releases'][0]['platforms'][0]['arch']
			let os: OutputSchema['releases'][0]['platforms'][0]['os']
			switch (platformName) {
				case 'x86_64-linux':
					arch = 'amd64'
					os = 'linux'
					break
				case 'aarch64-linux':
					arch = 'arm64'
					os = 'linux'
					break
				case 'armv7a-linux':
					arch = 'armv7l'
					os = 'linux'
					break
				case 'armv6kz-linux':
					arch = 'armv6'
					os = 'linux'
					break
				case 'i386-linux':
					arch = 'x86'
					os = 'linux'
					break
				case 'riscv64-linux':
					arch = 'riscv64'
					os = 'linux'
					break
				case 'x86_64-freebsd':
					arch = 'amd64'
					os = 'freebsd'
					break
				case 'x86_64-macos':
					arch = 'amd64'
					os = 'darwin'
					break
				case 'aarch64-macos':
					arch = 'arm64'
					os = 'darwin'
					break
				case 'x86_64-windows': // TODO
				case 'i386-windows':
				case 'aarch64-windows':
					continue
				default:
					console.log('error', platformName)
					Deno.exit(1) // EXIT
			}

			platforms.push({
				arch,
				os,
				download_url: platformData.tarball,
				download_sha256sum: platformData.shasum,
				download_size: platformData.size,
			})
		}

		outputJson.releases.push({
			version: releaseVersion,
			platforms,
		})
	}

	return outputJson
}

// const releases = await getJson<ZigReleases>(`${mirror}/download/index.json`)

// 	for (const [version, versionInfo] of Object.entries(releases)) {
// 		for (const [os, arches] of [
// 			['darwin', ['x84_64', 'aarch64']],
// 			['linux', ['i386', 'x86_64', 'armv7a', 'aarch64', 'riscv64']],
// 			['freebsd', ['x86_64']],
// 		]) {
// 			for (const arch of arches) {
// 				if (versionInfo?.[`${arch}-${os}`]) {
// 					const downloadUrl = `${mirror}/download/${version}/zig-${os}-${arch}-${version}.tar.xz`
// 					console.info(`Zig|${version}|${os}|${arch}|${downloadUrl}`)
// 				}
// 			}
// 		}
// 	}
