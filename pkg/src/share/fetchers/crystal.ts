import { die, getGithubReleases } from './util/util.ts'

if (import.meta.main) {
	await parseCrystal()
}

async function parseCrystal() {
	const token = Deno.env.get('GITHUB_TOKEN')
	let url = new URL(
		'https://api.github.com/repos/crystal-lang/crystal/releases'
	)

	const json = await getGithubReleases(url, {
		headers: {
			Authorization: `token ${token}`,
		},
	})

	console.info(json)

	return

	if (!Array.isArray(json)) {
		die('Expected array')
	}

	for (const release of json) {
		let version: string = release.name || release.tag_name

		if (version.startsWith('Release ')) {
			version = version.slice('Release '.length)
		}

		for (const asset of release.assets) {
			const asset_name: string = asset.name
			const download_count = asset.download_count
			const created_at: string = asset.created_at
			const download_url: string = asset.browser_download_url
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
				`Crystal|v${version}|${os}|${arch}|${download_url}|${created_at}#${download_count}`
			)
		}
	}
}
