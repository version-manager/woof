import * as path from 'https://deno.land/std@0.128.0/path/mod.ts'

type fetchURL = Parameters<typeof fetch>[0]
type fetchHeaders =
	| NonNullable<Parameters<typeof fetch>[1]>['headers']
	| undefined

export interface GitHubRelease {
	url: string
	assets_url: string
	upload_url: string
	html_url: string
	id: number
	author: UploaderOrAuthor
	node_id: string
	tag_name: string
	target_commitish: string
	name: string
	draft: boolean
	prerelease: boolean
	created_at: string
	published_at: string
	assets?: AssetsEntity[] | null
	tarball_url: string
	zipball_url: string
	body: string
	reactions: Reactions
	mentions_count: number
}
export interface UploaderOrAuthor {
	login: string
	id: number
	node_id: string
	avatar_url: string
	gravatar_id: string
	url: string
	html_url: string
	followers_url: string
	following_url: string
	gists_url: string
	starred_url: string
	subscriptions_url: string
	organizations_url: string
	repos_url: string
	events_url: string
	received_events_url: string
	type: string
	site_admin: boolean
}
export interface AssetsEntity {
	url: string
	id: number
	node_id: string
	name: string
	label?: null
	uploader: UploaderOrAuthor
	content_type: string
	state: string
	size: number
	download_count: number
	created_at: string
	updated_at: string
	browser_download_url: string
}
export interface Reactions {
	url: string
	total_count: number
	'+1': number
	'-1': number
	laugh: number
	hooray: number
	confused: number
	heart: number
	rocket: number
	eyes: number
}

export function die(msg: unknown): never {
	console.error(msg)
	Deno.exit(1)
}

export async function getToken(): Promise<string> {
	const home = Deno.env.get('HOME') as string

	let tokenFile = path.join(home, '.local', 'state', 'woof', 'token')

	const xdgStateHome = Deno.env.get('XDG_STATE_HOME')
	if (xdgStateHome && xdgStateHome[0] === '/') {
		tokenFile = path.join(xdgStateHome, 'woof', 'token')
	}

	try {
		return await Deno.readTextFile(tokenFile)
	} catch {
		// TODO
		die('Please create a token file at .local/state/woof/token')
	}
}

export async function getGithubReleases(
	repo: string,
	headers?: fetchHeaders
): Promise<GitHubRelease[]> {
	let releases: GitHubRelease[] = []

	let json
	let i = 0
	do {
		const url = `https://api.github.com/repos/${repo}/releases?per_page=100&page=${i}`
		const data = await getData(url, headers)
		const json = await data.json()

		console.info(Array.isArray(json), json.length)

		releases = releases.concat(json)
		i = i + 1

		// console.info(
		// 	json.length,
		// 	Array.isArray(json) && (json as Array<unknown>).length !== 0
		// )
	} while (i < 4)

	// } while (Array.isArray(json) && (json as Array<unknown>).length !== 0)

	return releases
}

export async function getText(
	url: fetchURL,
	headers?: fetchHeaders
): Promise<Record<string, unknown>> {
	const data = await getData(url, headers)
	const json = await data.json()
	return json
}

async function getData(
	url: fetchURL,
	headers?: fetchHeaders
): Promise<Response> {
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
