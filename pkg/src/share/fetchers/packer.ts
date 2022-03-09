import { die, getToken, getGithubReleases } from './util/util.ts'

if (import.meta.main) {
	await parsePacker()
}

async function parsePacker() {
	const releases = await getGithubReleases('hashicorp/packer', {
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
			['freebsd', ['386', 'amd64', 'arm']],
			['openbsd', ['386', 'amd64']],
			['solaris', ['amd64']],
		]) {
			for (const arch of arches) {
				const download_url = `https://releases.hashicorp.com/packer/${version}/packer_${version}_${os}_${arch}.zip`
				console.info(`Packer|${version}|${os}|${arch}|${download_url}`)
			}
		}
	}
}
