import { die, getToken, getGithubReleases } from './util/util.ts'

if (import.meta.main) {
	await parseWaypoint()
}

async function parseWaypoint() {
	const releases = await getGithubReleases('hashicorp/waypoint')

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
				const downloadUrl = `https://releases.hashicorp.com/waypoint/${version}/waypoint_${version}_${os}_${arch}.zip`
				console.info(`Waypoint|${version}|${os}|${arch}|${downloadUrl}`)
			}
		}
	}
}
