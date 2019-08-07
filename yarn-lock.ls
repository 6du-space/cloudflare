#!/usr/bin/env -S node -r livescript-transform-implicit-async/register

require! <[
  crypto
  path
  os
  @yarnpkg/lockfile
  ./Down
]>
require! {
  \fs-extra : fs
  \sodium-6du : sodium
}


module.exports = (root='')~>
  root = path.join os.homedir!, ".cache/6du", root
  fs.ensureDirSync(root)
  new Down(root)

do !~>
  hash_func = (hash)~>
    hasher = crypto.createHash(hash)
    (filepath)~>
      new Promise (resolve, reject)~>
        fs.createReadStream(filepath).pipe(hasher).on(
          \finish
          !->
            resolve(@read())
        )

  down = module.exports(\npm)

  lock = lockfile.parse fs.readFileSync path.join(__dirname,'../sh/yarn.lock'),'utf-8'
  li = []
  fileset = new Set()
  for k, v of lock.object
    [hash, bin] =  v.integrity.split("-",2)
    bin = Buffer.from(bin, 'base64')
    filename = path.basename(v.resolved).split("#")[0]
    if fileset.has(filename)
      continue
    fileset.add filename
    li.push down.get_and_verify(v.resolved, hash_func(hash), bin)

  li = await Promise.all(li)
  for i in li
    hash = await sodium.hash_path(path.join(down.root,i))
    console.log [hash.toString('base64'), i.slice(0,-4)]
