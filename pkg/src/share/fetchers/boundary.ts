import { die, getToken, getGithubReleases } from './util/util.ts'

if (import.meta.main) {
	await parseBoundary()
}

async function parseBoundary() {
	const releases = await getGithubReleases('hashicorp/boundary', {
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
				const download_url = `https://releases.hashicorp.com/boundary/${version}/boundary_${version}_${os}_${arch}.zip`
				console.info(`Boundary|${version}|${os}|${arch}|${download_url}`)
			}
		}
	}
}
