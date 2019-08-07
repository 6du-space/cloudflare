#!/usr/bin/env -S node -r livescript-transform-implicit-async/register

require! <[
  crypto
  path
  os
  @yarnpkg/lockfile
]>
require! {
  \fs-extra : fs
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
    console.log url
    r = await @get(url, outpath)
    filepath = r['file-name'].originalFile
    fs.createReadStream(filepath).pipe(hasher).on(
      \finish
      !->
        if bin.compare(@read())
          console.log '文件错误'
        else
          console.log \校验成功
    )

module.exports = (root='')~>
  root = path.join os.homedir!, ".cache/6du", root
  console.log root
  fs.ensureDirSync(root)
  new Down(root)


do !~>
  down = module.exports(\npm)

  lock = lockfile.parse fs.readFileSync path.join(__dirname,'../sh/yarn.lock'),'utf-8'
  for k, v of lock.object
    [hash, bin] =  v.integrity.split("-",2)
    bin = Buffer.from(bin, 'base64')
    await down.get_and_verify(v.resolved, crypto.createHash(hash), bin)
    break
