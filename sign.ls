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

module.exports = {
  hash_sign:(msg)~>
    sodium.hash_sign(module.exports.sk, msg)
}

do !~>
  module.exports.sk = await read("sk")
