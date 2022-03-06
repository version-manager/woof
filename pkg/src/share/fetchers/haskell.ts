const haskellUrl = 'https://downloads.haskell.org/~ghc'
const res = await fetch(haskellUrl)
const text = await res.text()

const promises = []
for (const match of text.matchAll(/<a href="(.*?)"/gu)) {
	const version = match[1].slice(0, -1)

	let int = parseInt(version[0], 10)
	if (Number.isNaN(int)) {
		continue
	}

	promises.push(fetch(`https://downloads.haskell.org/~ghc/${version}`))
}

const result = await promises[0]()

