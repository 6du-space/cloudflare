const base64url = require('base64url')
const dnsPacket = require('dns-packet')
const httpsProxyAgent = require('https-proxy-agent')
const httpProxyAgent = require('http-proxy-agent')

getDnsQuery = ({ type, name, klass, id }) ~>
  {
    type: 'query',
    id,
    flags: dnsPacket.RECURSION_DESIRED,
    questions: [
      {
        "['class']": klass,
        name,
        type,
      },
    ],
  }

getDnsWireformat = ({ name, type, klass }) !~>
  const id = 0 # As mandated by RFC-8484.
  const dnsQuery = getDnsQuery({ type, name, klass, id })
  const dnsQueryBuf = dnsPacket.encode(dnsQuery)
  return dnsQueryBuf


class Doh
  (@axios)!->
    @klass = 'IN'

  get:(nameserver, name, type)!->
    const dnsWireformat = getDnsWireformat({ name, type, @klass })
    try
      r = await @axios.post(
        "https://#nameserver/dns-query"
        dnsWireformat
        {
          responseType: 'arraybuffer',
          headers:{
            'Content-Type':"application/dns-message",
            Accept:'*/*',
          },
        }
      )
    catch err
      console.error 'Doh', nameserver, err.toString()
      return
    return dnsPacket.decode(r.data).answers[0].data[0].toString()

module.exports = Doh

