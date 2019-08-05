__doc__ = """
Implementation of encoding in base85 as detailed in RFC 1924 ( https://tools.ietf.org/html/rfc1924 )

This is a pure JS implementation which differentiates it from the `base85` module that uses a native bignum module. The goal of this module is compatibility across platforms not performance.

This module's focus is on the ipv6 implementation as described in the RFC.

"""

bigInt = require 'big-integer'

ALPHABET = [
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
  '!', '#', '$', '%', '&', '(', ')', '*', '+', '-', ';', '<', '=', '>', '?', '@', '^', '_', '`', '{', '|', '}', '~'
]

module.exports =
  __doc__: __doc__

  ALPHABET: ALPHABET

  encode: (buf) ->
    """Encodes a buffer of data as a base85 string in ipv6 format"""

    if !Buffer.isBuffer buf
      buf = new Buffer buf

    n = new bigInt
    for x in buf
      n = n.multiply(256).add(x)

    chars = []
    for c in [0...20]
      { quotient, remainder } = n.divmod 85
      n = quotient
      chars.push ALPHABET[remainder]

    chars.reverse().join ''


