import { die, getJson } from './util/util.ts'

if (import.meta.main) {
	await parseZig()
}

type ZigReleases = {
	[key: string]: {
		date: string
		docs: string
		stdDocs: string
		notes: string
		[key: string]: // TODO: should not have 'string' below
		| string
			| {
					tarball: string
					shasum: string
					size: string
			  }
	}
}

async function parseZig() {
	const mirror = 'https://ziglang.org'
	const releases = await getJson<ZigReleases>(`${mirror}/download/index.json`)

	for (const [version, versionInfo] of Object.entries(releases)) {
		for (const [os, arches] of [
			['darwin', ['x84_64', 'aarch64']],
			['linux', ['i386', 'x86_64', 'armv7a', 'aarch64', 'riscv64']],
			['freebsd', ['x86_64']],
		]) {
			for (const arch of arches) {
				if (versionInfo?.[`${arch}-${os}`]) {
					const downloadUrl = `${mirror}/download/${version}/zig-${os}-${arch}-${version}.tar.xz`
					console.info(`Zig|${version}|${os}|${arch}|${downloadUrl}`)
				}
			}
		}
	}
}
