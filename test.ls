require! <[
  zlib
  ./sign
]>

z85 = require('ascii85').ZeroMQ

{promisify} = require "util"


do !~>
  msg = <[
    gitshell.com/6du/sh/raw/blob
    gitee.com/www-6du-space/sh/raw
    raw.githubusercontent.com/6du-space/sh
    gitlab.com/6du/sh/raw
    bitbucket.org/6du-space/sh/raw
  ]>
  msg.sort()
  msg = msg.join("\n")

  console.log msg
  console.log msg.length
  ziped = await promisify(zlib.brotliCompress,{
    params:{
      "#{zlib.constants.BROTLI_PARAM_QUALITY}":zlib.constants.BROTLI_MAX_QUALITY
      "#{zlib.constants.BROTLI_PARAM_SIZE_HINT}":msg.length
      "#{zlib.constants.BROTLI_PARAM_MODE}":zlib.constants.BROTLI_MODE_TEXT
    }
  })(msg)
  # console.log ziped.length
  # console.log ziped
  buf = Buffer.concat [sign.hash_sign(ziped), ziped]
  # console.log buf, buf.length
  r = z85.encode(buf)
  console.log r.toString!
  # console.log r.toString().length
  # console.log r.toString()
  # console.log (await promisify(
  #   zlib.brotliDecompress
  # )(z85.decode(r))).toString()
