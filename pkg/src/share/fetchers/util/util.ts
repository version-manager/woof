export function die(msg: any): never {
	console.error(msg)
	Deno.exit(1)
}

type PathLikeT = string | URL | Request

async function getData(url: PathLikeT, headers?: RequestInit): Promise<any> {
	try {
		const res = await fetch(url, {
			headers,
		})

		if (!res.ok) {
			die(res)
		}

		return res
	} catch (err) {
		die(err)
	}
}

export async function getJson(
	url: PathLikeT,
	headers?: RequestInit
): Promise<Record<string, any>> {
	for (let page = 1; page < 100; ++page) {
		const data = await getData(url, headers)
		return await data.json()
	}

	return []
}

export async function getGithubReleases(
	url: URL,
	headers?: RequestInit
): Promise<Array<Record<string, any>>> {
	let releases: Record<string, any>[] = []

	for (let i = 1; i < 25; ++i) {
		const data = await getData(url, {
			...headers,
		})
		const json = await data.json()
		releases = releases.concat(json.releases)
	}

	return releases
}
