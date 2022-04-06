import { die, getGithubReleases } from './util/util.ts'

if (import.meta.main) {
	await parseElm()
}

async function parseElm() {
	const repo = 'elm/compiler'
	const releases = await getGithubReleases(repo)

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
				const githubMirror = 'https://github.com'
				const downloadUrl = `${githubMirror}/${repo}/releases/downloads/${version}/elm-${version}-${osArch}.zip`
				console.info(`Elm|${version}|${os}|${arch}|${downloadUrl}`)
			}
		}
	}
}
