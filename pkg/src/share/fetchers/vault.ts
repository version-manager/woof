import { die, getToken, getGithubReleases } from './util/util.ts'

if (import.meta.main) {
	await parseVault()
}

async function parseVault() {
	const releases = await getGithubReleases('hashicorp/vault')

	for (const release of releases) {
		if (!release.name) {
			continue
		}

		const version = release.name

		for (const [os, arches] of [
			['darwin', ['amd64', 'arm64']],
			['linux', ['386', 'amd64', 'arm', 'arm64']],
			['freebsd', ['386', 'amd64', 'arm']],
			['netbsd', ['386', 'amd64', 'arm']],
			['openbsd', ['386', 'amd64', 'arm']],
			['solaris', ['amd64']],
		]) {
			for (const arch of arches) {
				const downloadUrl = `https://releases.hashicorp.com/vault/${version}/vault_${version}_${os}_${arch}.zip`
				console.info(`Vault|${version}|${os}|${arch}|${downloadUrl}`)
			}
		}
	}
}
