if (import.meta.main) {
	await parseGo()
}

async function parseGo() {
	const url = 'https://go.dev/dl'
	const text = await getText(url)
	const results = text.matchAll(
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

		const download_url = url.slice(0, -3) + asset_name

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

		console.info(`Go|v${version}|${os}|${arch}|${download_url}`)
	}
}
