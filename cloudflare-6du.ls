require! <[
  path
  axios 
]>
require! {
  \config-6du : Config
}

do !~>
  config = new Config(
    \_6DU_ROOT
    \.6du/config
  )
  token = await config.line(\cloudflare)
  console.log token
  url = "https://api.cloudflare.com/client/v4/user/tokens/verify"
  r = await axios.get(
    url
    {
      headers:{
       \Authorization : "Bearer #token"
      }
    }
  )
  console.log r.data

