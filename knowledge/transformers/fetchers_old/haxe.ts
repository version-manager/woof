import { die, getGithubReleases } from './util/util.ts'

if (import.meta.main) {
	await parseHaxe()
}

async function parseHaxe() {
	const releases = await getGithubReleases('HaxeFoundation/haxe')

	for (const release of releases) {
		if (!release.name) {
			continue
		}

		const version = release.name

		for (const [os, arches] of [
			['darwin', ['amd64', 'arm64']],
			['linux', ['386', 'amd64', 'arm', 'arm64']],
		]) {
			for (const arch of arches) {
				const osArch = os + arch
				const downloadUrl = `https://github.com/HaxeFoundation/haxe/releases/downloads/${version}/haxe-${version}-${osArch}.zip`
				console.info(`Haxe|${version}|${os}|${arch}|${downloadUrl}`)
			}
		}
	}
}
