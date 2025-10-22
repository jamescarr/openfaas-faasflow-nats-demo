'use strict'

module.exports = async (event, context) => {
  const body = event.body
  const text = typeof body === 'string' ? body : (Buffer.isBuffer(body) ? body.toString('utf-8') : String(body))
  const reversed = text.split('').reverse().join('')
  console.log(reversed)
  return context.status(200).succeed('ok')
}


