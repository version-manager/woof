import * as util from '../util/util.ts'

export function transformNodejs(inputJson: any) {
	const outputJson: OutputJson = {
		id: 0,
		name: 'nodejs',
		name_pretty: 'NodeJS',
		versions: [],
	}

	for (const releaseData of inputJson as any as Array<Record<string, any>>) {
		const vendor = {
			npmVersion: releaseData.npm,
			v8Version: releaseData.v8,
			uvVersion: releaseData.uv,
			zlibVersion: releaseData.zlib,
			opensslVersion: releaseData.openssl,
			modulesVersion: releaseData.modules,
			lts: releaseData.lts,
			security: releaseData.security,
		}

		const supported_platforms = []
		for (const file of releaseData.files) {
			const [os, ...attrs] = (file as string).split('-')

			if (os === 'headers' || os === 'src') {
				continue
			}

			supported_platforms.push({
				arch: attrs?.[1],
				os: attrs?.[1],
			})
		}

		outputJson.versions.push({
			version: (releaseData.version as string).slice(1),
			supported_platforms,
		})
	}
}
