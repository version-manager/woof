import { die, getToken, getGithubReleases } from './util/util.ts'

if (import.meta.main) {
	await parseCrystal()
}

async function parseCrystal() {
	const releases = await getGithubReleases('crystal-lang/crystal', {
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
			const result =
				/^crystal[_-](.+?)-1[_-](?:(?<os>.+?)-)?(?<arch>.+?)\./u.exec(
					asset_name
				)

			let os = result?.groups?.os
			if (os === void 0) {
				continue
			}
			let arch = result?.groups?.arch
			if (!arch) {
				continue
			} else if (arch === 'i686') {
				arch = 'x86'
			} else if (arch === 'x86_64') {
				arch = 'amd64'
			} else if (arch === 'x86_64-bundled') {
				continue
			}
			console.info(
				`Crystal|v${version}|${os}|${arch}|${downloadUrl}|${created_at}#${download_count}`
			)
		}
	}
}
