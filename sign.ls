require! <[
  path
]>

require! {
  \sodium-6du : sodium
  \fs-extra : fs
}

read = (name)~>
  fs.readFile(
    path.join(
      __dirname, "../private/key/6du.#name"
    )
  )

class Sign
  (@pk, @sk)->
  verify:(msg)~>
    sodium.verify(@pk ,msg)
  hash-sign:(msg)~>
    sodium.hash-sign(@sk, msg)


module.exports = ~>
  [
    pk
    sk
  ] = await Promise.all [
    read("pk")
    read("sk")
  ]
  new Sign(pk, sk)
