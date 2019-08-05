#!/usr/bin/env -S node -r livescript-transform-implicit-async/register

require! <[
  path
  klaw
  zlib
]>

require! {
  \sodium-6du : sodium
  \config-6du/6du : config
  \fs-extra : fs
}

{promisify} = require "util"

read = (name)~>
  fs.readFile(
    path.join(
      __dirname, "../private/key/6du.#name"
    )
  )


hash = (sk, cwd)~>
  cut = cwd.length+1
  li = []
  new Promise(
    (resolve, reject)~>
      klaw(cwd)
        .on(
          \data
          ({path, stats})~>
            if stats.isDirectory!
              return
            li.push [
              path.slice(cut)
              sodium.hash(await fs.readFile(path))
            ]
        )
        .on(
          \error
          (err, item) ~>
            console.log err.message
            console.log item.path
        )
        .on(
          'end'
          ~>
            li.sort (a,b)!~>
              if a > b
                return -1
              else
                return 1

            n = Buffer.allocUnsafe(6)
            n.writeUIntLE(li.length,0,6)

            fileli = []
            hashli = []
            for [f,h] in li
              fileli.push f
              hashli.push h

            hashli.unshift Buffer.from(fileli.join("\n"))
            hashli.unshift(n)

            b = Buffer.concat(hashli)
            resolve Buffer.concat(
              [
                b
                sodium.sign(sk, sodium.hash(b))
              ]
            )
        )

  )

pack = (sk, dirpath)!~>
  result = await hash(sk, dirpath)
  return promisify(zlib.brotliCompress,{
    params:{
      "#{zlib.constants.BROTLI_PARAM_QUALITY}":zlib.constants.BROTLI_MAX_QUALITY
      "#{zlib.constants.BROTLI_PARAM_SIZE_HINT}":result.length
    }
  })(result)

# https://github.com/davideicardi/live-plugin-manager#readme
do !->
  # console.log zlib.constants.BROTLI_MAX_QUALITY
  dirpath = "/root/tmp/sh"
  sk = await read("sk")
  packed = await pack(sk, dirpath)
  console.log packed
  console.log packed.length

  # console.log dirpath
  # sk = await read('sk')
  # msg = Buffer.from(\11)
  # signed = sodium.sign(sk, msg)
  # console.log signed

  # pk = await read('pk')
  # msg = sodium.verify(pk, signed)
  # console.log msg.toString()

