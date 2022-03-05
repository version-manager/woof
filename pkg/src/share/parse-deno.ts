if (import.meta.main) {
	await parseDeno()
}

async function parseDeno() {
	for (let page = 1; page < 100; ++page) {
		let res: Response
		let json: any
		try {
			res = await fetch(
				`https://api.github.com/repos/denoland/deno/releases?per_page=100&page=${page}`,
				{
					headers: {
						Authorization: `token ${token}`,
					},
				}
			)
			json = await res.json()
		} catch (err) {
			console.error(err)
			break
		}

		if (json.message) {
			console.error(json)
			break
		}

		if (!Array.isArray(json) || json.length === 0) {
			break
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
					`Deno|${version}|${os}|${arch}|${download_url}|${created_at}#${download_count}`
				)
			}
		}
	}
}
