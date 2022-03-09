import { die, getToken, getGithubReleases } from './util/util.ts'

if (import.meta.main) {
	await parseNomad()
}

async function parseNomad() {
	const product = 'nomad'
	const releases = await getGithubReleases(`hashicorp/${product}`, {
		Authorization: `token ${await getToken()}`,
	})

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
				const download_url = `https://releases.hashicorp.com/${product}/${version}/${product}_${version}_${os}_${arch}.zip`
				console.info(`Nomad|${version}|${os}|${arch}|${download_url}`)
			}
		}
	}
}
