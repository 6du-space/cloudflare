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


module.exports = (version, msg)~>
  sign = await Sign()

  ziped = await promisify(zlib.brotliCompress,{
    params:{
      "#{zlib.constants.BROTLI_PARAM_QUALITY}":zlib.constants.BROTLI_MAX_QUALITY
      "#{zlib.constants.BROTLI_PARAM_SIZE_HINT}":msg.length
      "#{zlib.constants.BROTLI_PARAM_MODE}":zlib.constants.BROTLI_MODE_TEXT
    }
  })(msg)
  buf = Buffer.concat [
    sign.hash_sign(
      Buffer.concat([
        Buffer.from(version)
        ziped
      ])
    )
    ziped
  ]
  r = z85.encode(buf)
  return r.toString!
  # msg = z85.decode(r)
  # hash_sign = msg.slice(0,96)
  # msg = msg.slice(96)
  # console.log sodium.hash(Buffer.concat([Buffer.from(version), msg])).compare(sign.verify(hash_sign))
  # console.log (await promisify(zlib.brotliDecompress)(msg)).toString!.split('\n')
  # console.log r.toString().length
  # console.log r.toString()
  # console.log (await promisify(
  #   zlib.brotliDecompress
  # )(z85.decode(r))).toString()
