import { die, getToken, getGithubReleases } from './util/util.ts'

if (import.meta.main) {
	await parseTerraform()
}

async function parseTerraform() {
	const releases = await getGithubReleases('hashicorp/terraform')

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
				const downloadUrl = `https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${os}_${arch}.zip`
				console.info(`Boundary|${version}|${os}|${arch}|${downloadUrl}`)
			}
		}
	}
}
