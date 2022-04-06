import {
	getGithubReleases,
	getJson,
	getText,
	getToken,
} from './fetchers/util/util.ts'

type downloadSource = {
	tarball: string
	shasum: string
	size: string
}

type RemoveKindField<Type> = {
	[Property in keyof Type as Exclude<Property, 'version'>]: Type[Property]
}

type ReleaseType =
	| ReleaseTypeNoStrings
	| {
			version: string
			date: string
			docs: string
			stdDocs: string
	  }

type ReleaseType2 = {
	[key: string]: downloadSource
}

type ReleaseTypeNoStrings = RemoveKindField<ReleaseType2>

type Json = {
	[key: string]: ReleaseType
	master: ReleaseType
}

type OutputJson = {
	id: number
	name: string
	name_pretty: string
	versions: Array<{
		version: string
		supported_platforms: Array<{
			os: string
			arch: string
		}>
	}>
}

if (import.meta.main) {
	const inputJson = await getJson('https://ziglang.org/download/index.json')
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

	await Deno.writeTextFile(
		'./output/Zig.json',
		JSON.stringify(outputJson, null, '\t')
	)
}

if (import.meta.main) {
	const inputJson = await getJson('https://nodejs.org/dist/index.json')
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

	await Deno.writeTextFile(
		'./output/Node.json',
		JSON.stringify(outputJson, null, '\t')
	)
}
