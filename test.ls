#!/usr/bin/env -S node -r livescript-transform-implicit-async/register
require! <[
  zlib
]>
require! {
  \sodium-6du : sodium
}

z85 = require('ascii85').ZeroMQ
Sign = require './sign'

{promisify} = require "util"


do !~>
  sign = await Sign()
  msg = <[
    gitshell.com/6du/sh/raw/blob
    gitee.com/www-6du-space/sh/raw
    raw.githubusercontent.com/6du-space/sh
    gitlab.com/6du/sh/raw
    bitbucket.org/6du-space/sh/raw
  ]>
  msg.sort()
  msg = msg.join("\n")

  ziped = await promisify(zlib.brotliCompress,{
    params:{
      "#{zlib.constants.BROTLI_PARAM_QUALITY}":zlib.constants.BROTLI_MAX_QUALITY
      "#{zlib.constants.BROTLI_PARAM_SIZE_HINT}":msg.length
      "#{zlib.constants.BROTLI_PARAM_MODE}":zlib.constants.BROTLI_MODE_TEXT
    }
  })(msg)
  buf = Buffer.concat [sign.hash_sign(ziped), ziped]
  r = z85.encode(buf)
  console.log r.toString!
  msg = z85.decode(r)
  hash_sign = msg.slice(0,96)
  msg = msg.slice(96)
  console.log sign.verify(hash_sign)
  console.log sodium.hash(msg)
  console.log (await promisify(zlib.brotliDecompress)(msg)).toString!.split('\n')
  # console.log r.toString().length
  # console.log r.toString()
  # console.log (await promisify(
  #   zlib.brotliDecompress
  # )(z85.decode(r))).toString()
