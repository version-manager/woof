export function transformZig(inputJson: any) {
	const outputJson: OutputJson = {
		id: 0,
		name: 'zig',
		name_pretty: 'Zig',
		versions: [],
	}

	for (const [releaseVersion, releaseData] of Object.entries(
		inputJson as Json
	)) {
		const supported_platforms = []
		for (const [platformName, platformData] of Object.entries(releaseData)) {
			if (
				platformName === 'version' ||
				platformName === 'date' ||
				platformName === 'docs' ||
				platformName === 'stdDocs' ||
				platformName === 'notes'
			) {
				continue
			}

			if (platformName === 'src') {
				continue
			}

			const [arch, os] = (platformName as string).split('-')

			supported_platforms.push({
				arch,
				os,
				downloadUrl: platformData.tarball,
				downloadShasum: platformData.shasum,
				downloadSize: platformData.size,
			})
		}

		outputJson.versions.push({
			version: releaseVersion,
			supported_platforms,
		})
	}
}
