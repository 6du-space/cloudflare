require! <[
  path
]>
require! {
  \config-6du/6du : config
  \axios-6du : axios
}

do !~>
  console.log axios
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
  # console.log r.data

