#!/usr/bin/env -S node -r livescript-transform-implicit-async/register

require! <[
  crypto
  path
  os
  @yarnpkg/lockfile
  ./Down
  ./file-li
]>
require! {
  \fs-extra : fs
  \sodium-6du : sodium
}
{trimEnd} = require \buffertrim

module.exports = (root='')~>
  root = path.join os.homedir!, ".cache/6du", root
  fs.ensureDirSync(root)
  new Down(root)

yarn-lock-pack = (sk, yarn-lock-path)~>
  hash-func = (hash)~>
    hasher = crypto.createHash(hash)
    (filepath)~>
      new Promise (resolve, reject)~>
        fs.createReadStream(filepath).pipe(hasher).on(
          \finish
          !->
            resolve(@read())
        )

  down = module.exports(\npm)
  lock = await fs.readFile path.join(yarn-lock-path,'yarn.lock'),'utf-8'
  lock = lockfile.parse(lock)
  li = []
  fileset = new Set()
  for k, v of lock.object
    [hash, bin] =  v.integrity.split("-",2)
    bin = Buffer.from(bin, 'base64')
    filename = path.basename(v.resolved).split("#")[0]
    if fileset.has(filename)
      continue
    fileset.add filename
    li.push down.get_and_verify(v.resolved, hash-func(hash), bin)

  li = await Promise.all(li)
  file-hash-li = []
  for i in li
    hash = await sodium.hash-path(path.join(down.root,i))
    file-hash-li.push [i.slice(0,-4), hash]
  return file-li.pack(sk, file-hash-li)

_path = (p)->
  path.resolve(__dirname,"..",p)

version = (path-v)!~>
  if await fs.exists path-v
    n = Buffer.alloc(6)
    (await fs.readFile path-v).copy n
    return n.readUIntLE(0,6)
  else
    version = parseInt(new Date()/(86400000)) - 18115
    n = Buffer.allocUnsafe(6)
    n.writeUIntLE(version,0,6)
    n = trimEnd n
    fs.outputFile(path-v, n)
    return version

do !~>
  sk = await fs.readFile _path \private/key/6du.sk
  bin = await yarn-lock-pack(sk, _path \sh)
  path-v = _path \dns/v/6du/v
  version = await version path-v
  hash = sodium.hash-path(path-v)
  console.log hash

  # dns-path = path.join(__dirname../dns/v/6du/)
  # console.log bin
