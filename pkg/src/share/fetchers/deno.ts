import { die, getToken, getGithubReleases } from './util/util.ts'

if (import.meta.main) {
	await parseDeno()
}

async function parseDeno() {
	const releases = await getGithubReleases('denoland/deno', {
		Authorization: `token ${await getToken()}`,
	})

	for (const release of releases) {
		let version: string = release.name || release.tag_name

		if (version.startsWith('Release ')) {
			version = version.slice('Release '.length)
		}

		if (!Array.isArray(release.assets)) {
			continue
		}

		for (const asset of release.assets) {
			const asset_name: string = asset.name
			const download_count = asset.download_count
			const created_at: string = asset.created_at
			const downloadUrl: string = asset.browser_downloadUrl
			let result: RegExpExecArray | null
			if (
				version.startsWith('v0.') &&
				parseInt(version.slice(3, version.lastIndexOf('.'))) < 36
			) {
				result = /^deno_(?<os>.+?)_(?<arch>.+?)\./u.exec(asset_name)
			} else {
				result = /^deno[_-](?<arch>.+?_64?)[_-](?<os>.+?)\./u.exec(asset_name)
			}

			let os = result?.groups?.os
			if (!os) {
				continue
			} else if (os === 'osx' || os === 'mac' || os === 'apple-darwin') {
				os = 'darwin'
			} else if (os === 'unknown-linux-gnu') {
				os = 'linux'
			} else if (os === 'win' || os === 'pc-windows-msvc') {
				continue
			}

			let arch = result?.groups?.arch
			if (arch === 'x64') {
				arch = 'amd64'
			} else if (arch === void 0) {
				continue
			}

			console.info(
				`Deno|${version}|${os}|${arch}|${downloadUrl}|${created_at}#${download_count}`
			)
		}
	}
}
