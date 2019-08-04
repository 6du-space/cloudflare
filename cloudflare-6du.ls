require! <[
  path
]>
require! {
  \config-6du/6du : config
  \axios-6du : axios6du
}


do !~>
  {version} = require(path.join(__dirname,'../sh/package.json'))
  axios = await axios6du()
  [email,key] = await config.li(\cloudflare)

  _req = (method, url, option={})~>
    option = {
      headers:{
         "X-Auth-Key":key
         "X-Auth-Email":email
      }
      method
      url:"https://api.cloudflare.com/client/v4/#url"
    } <<< option
    try
      {data} = await axios(
        option
      )
    catch err
      console.error err.request._header
      for i in err.response.data.errors
        console.log i
      throw err
    data

  get = (url, params={})~>
    _req(\get,url,{params})

  post = (url, data={})~>
    _req(\post, url, {data})

  put = (url, data={})~>
    _req(\put, url, {data})

  host = \6du.space
  {result} = await get(
    \zones
    {
      name : host
    }
  )

  zone-id = result[0].id
  host-v = \v. + host
  option = {
    type:\TXT
    name:host-v
  }
  {result} = await get("zones/#zone-id/dns_records", option)
  option.content = version
  if result.length
    url = "/" + result[0].id
    method = put
  else
    method = post
    url = ""
  r = await method("zones/#zone-id/dns_records"+url,option)
  console.log method, r
