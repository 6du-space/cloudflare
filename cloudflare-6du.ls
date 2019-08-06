#!/usr/bin/env -S node -r livescript-transform-implicit-async/register

require! <[
  path
  semver
]>
require! {
  \./dns_encode : dns_encode
  \config-6du/6du : config
  \axios-6du : axios6du
}
HOST = \6du.space


class Dns
  (@host)->

  _req : (method, url, option={})~>
    option = {
      headers:{
         "X-Auth-Email":@email
         "X-Auth-Key":@key
      }
      method
      url:"https://api.cloudflare.com/client/v4/#url"
    } <<< option
    try
      {data} = await @axios(
        option
      )
    catch err
      console.error err.request._header
      for i in err.response.data.errors
        console.log i
      throw err
    data

  get : (url, params={})~>
    @_req(\get,url,{params})

  post : (url, data={})~>
    @_req(\post, url, {data})

  put : (url, data={})~>
    @_req(\put, url, {data})

  txt : (host, txt, _if, before)~>
    option = {
      type:\TXT
      name:host
    }
    prefix = "zones/#{@zone-id}/dns_records"
    {result} = await @get(prefix, option)
    if result.length
      {id, content} = result[0]
      if _if and (_if(content) === false)
        return
      url = "/" + id
      method = \put
    else
      method = \post
      url = ""
    if before
      await before()
    option.content = txt
    await @[method](prefix+url, option)
    return true

  update:(version, txt)->
    @axios = await axios6du()
    li = await config.li(\dns/cloudflare)
    if not li or li.length < 2
      console.log "请配置 cloudflare 的 api key"
      return
    [@email,@key] = li

    {result} = await @get(
      \zones
      {
        name : @host
      }
    )
    @zone-id = result[0].id
    await @txt(
      \v. + @host
      version
      (content)!~>
        if semver.lte(version, content)
          console.log(
            "package.json version #version , TXT content version #content , ignore update"
          )
          return false
      ~>
        @txt(
          version+"."+@host
          await dns_encode(version, txt)
        )
    )


do !~>
  txt = <[
    gitshell.com/6du/sh/raw/blob
    gitee.com/www-6du-space/sh/raw
    raw.githubusercontent.com/6du-space/sh
    gitlab.com/6du/sh/raw
    bitbucket.org/6du-space/sh/raw
  ]>
  txt.sort()
  txt = txt.join("\n")
  dns = new Dns(\6du.space)
  {version} = require(path.join(__dirname,'../sh/package.json'))
  await dns.update(version, txt)


