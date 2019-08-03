require! <[
  path
]>
require! {
  \config-6du/6du : config
  \axios-6du : axios6du
}



do !~>
  axios = await axios6du()
  [email,key] = await config.li(\cloudflare)

  get = (url, params={})~>
    try
      {data} = await axios.get(
        "https://api.cloudflare.com/client/v4/#url"
        {
          params
          headers:{
             "X-Auth-Key":key
             "X-Auth-Email":email
          }
        }
      )
    catch err
      console.error err.request._header
      console.error err.response.data
      throw err
    data
  {result} = await get(
    \zones
    {
      name : \6du.space
    }
  )

  zone-id = result[0].id

