import { die, getToken, getGithubReleases } from './util/util.ts'

if (import.meta.main) {
	await parseVagrant()
}

async function parseVagrant() {
	const product = 'vagrant'
	const releases = await getGithubReleases(`hashicorp/${product}`, {
		Authorization: `token ${await getToken()}`,
	})

	for (const release of releases) {
		if (!release.name) {
			continue
		}

		const version = release.name

		for (const [os, arches] of [
			['darwin', ['x86_64']],
			['linux', ['amd64']],
		]) {
			for (const arch of arches) {
				const download_url = `https://releases.hashicorp.com/${product}/${version}/${product}_${version}_${os}_${arch}.zip`
				console.info(`Vagrant|${version}|${os}|${arch}|${download_url}`)
			}
		}
	}
}
