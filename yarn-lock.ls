#!/usr/bin/env -S node -r livescript-transform-implicit-async/register

require! <[
  crypto
  path
  os
  @yarnpkg/lockfile
]>
require! {
  \fs-extra : fs
  \sodium-6du : sodium
}

mtd = require('zeltice-mt-downloader')



class Down
  (@root)->
  get : (url, outpath)~>
    new Promise(
      (resolve, reject)~>
        downloader = new mtd(
          outpath
          url
          {
            timeout: 60
            onStart:(meta)!~>
            onEnd:(err,result)!~>
              if err
                reject(err)
                return
              resolve(result)
          }
        )
        downloader.start()

    )

  get_and_verify : (url, hasher, bin)!~>
    filename = path.basename(url)
    filename = filename.slice(0, filename.indexOf("#"))
    outpath = path.join @root,filename
    verify = ~>
      if not bin.compare(await hasher(outpath))
        return true
      await fs.unlink(outpath)

    if await fs.exists(outpath)
      if await verify()
        return filename

    count = 0
    while count < 3
      ++count
      await @get(url, outpath)
      if await verify()
        return filename
      console.log "下载出错，第#{count}次尝试重下 #{url}"
    throw new Error()

module.exports = (root='')~>
  root = path.join os.homedir!, ".cache/6du", root
  console.log root
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
      console.log filename
      continue
    fileset.add filename
    li.push down.get_and_verify(v.resolved, hash_func(hash), bin)

  li = await Promise.all(li)
  for i in li
    hash = await sodium.hash_path(path.join(down.root,i))
    console.log i, hash
