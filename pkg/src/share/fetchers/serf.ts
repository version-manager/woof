import { die, getGithubReleases } from './util/util.ts'

if (import.meta.main) {
	await parseSerf()
}

async function parseSerf() {
	const product = 'serf'
	const releases = await getGithubReleases(`hashicorp/${product}`)

	for (const release of releases) {
		if (!release.name) {
			continue
		}

		const version = release.name

		for (const [os, arches] of [
			['darwin', ['386', 'amd64']],
			['linux', ['386', 'amd64', 'arm']],
			['freebsd', ['386', 'amd64', 'arm']],
			['openbsd', ['386', 'amd64']],
			['solaris'],
		]) {
			for (const arch of arches) {
				const downloadUrl = `https://releases.hashicorp.com/${product}/${version}/${product}_${version}_${os}_${arch}.zip`
				console.info(`${product}|${version}|${os}|${arch}|${downloadUrl}`)
			}
		}
	}
}
