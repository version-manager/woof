import { die, getToken, getGithubReleases } from './util/util.ts'

if (import.meta.main) {
	await parseConsul()
}

async function parseConsul() {
	const product = 'consol'
	const releases = await getGithubReleases(`hashicorp/${product}`)

	for (const release of releases) {
		if (!release.name) {
			continue
		}

		const version = release.name

		for (const [os, arches] of [
			['darwin', ['amd64', 'arm64']],
			['linux', ['386', 'amd64', 'arm', 'arm64']],
			['freebsd', ['386', 'amd64']],
			['solaris', ['amd64']],
		]) {
			for (const arch of arches) {
				const downloadUrl = `https://releases.hashicorp.com/${product}/${version}/${product}_${version}_${os}_${arch}.zip`
				console.info(`Consul|${version}|${os}|${arch}|${downloadUrl}`)
			}
		}
	}
}
