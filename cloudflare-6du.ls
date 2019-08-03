require! <[
  path
  cloudflare
]>
require! {
  \config-6du : Config
}

do !~>
  config = new Config(
    \_6DU_ROOT
    \.6du/config
  )
  [email, key] = await config.li(\cloudflare)
  cf = cloudflare {
    email
    key
  }
  cf.zones.browse().then ->
    console.log arguments


