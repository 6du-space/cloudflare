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
  get : (url)~>
    filename = path.basename(url)
    filename = filename.slice(0, filename.indexOf("#"))
    outpath = path.join @root,filename
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

module.exports = (root='')~>
  root = path.join os.homedir!, ".cache/6du", root
  console.log root
  fs.ensureDirSync(root)
  new Down(root)



do !~>
  down = module.exports(\npm)

  lock = lockfile.parse fs.readFileSync path.join(__dirname,'../sh/yarn.lock'),'utf-8'
  for k, v of lock.object
    #console.log outpath, resolved
    console.log v.resolved
    r = await down.get(v.resolved)
    filepath = r['file-name'].originalFile
    [hash, bin] =  v.integrity.split("-",2)
    bin = Buffer.from(bin, 'base64')
    filestream = fs.createReadStream(filepath).pipe(crypto.createHash(hash)).on(
      \finish
      !->
        if bin.compare(@read())
          console.log '文件错误'
    )

    break
