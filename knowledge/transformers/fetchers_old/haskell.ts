import { die, getText } from './util/util.ts'

if (import.meta.main) {
	await parseHaskell()
}

async function parseHaskell() {
	// TODO: SKIP because Stack
	// const url = 'https://downloads.haskell.org/~ghc'
	// const text = await getText(url)
	// const promises = []
	// for (const match of text.matchAll(/<a href="(.*?)"/gu)) {
	// 	const version = match[1].slice(0, -1)
	// 	let int = parseInt(version[0], 10)
	// 	if (Number.isNaN(int)) {
	// 		continue
	// 	}
	// 	promises.push(fetch(`${url}/${version}`))
	// }
	// const result = await promises[0]()
}
