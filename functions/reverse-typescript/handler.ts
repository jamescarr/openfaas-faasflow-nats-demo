type Context = {
  status: (code: number) => Context
  succeed: (body: string) => any
}

type Event = {
  body?: any
}

module.exports = async (event: Event, context: Context) => {
  const body = event.body
  const text = typeof body === 'string' ? body : (Buffer.isBuffer(body) ? body.toString('utf-8') : String(body))
  const reversed = text.split('').reverse().join('')
  console.log(reversed)
  return context.status(200).succeed('ok')
}


