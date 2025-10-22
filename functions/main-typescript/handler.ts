import axios from 'axios'

type Context = {
  status: (code: number) => Context
  succeed: (body: string) => any
}

type Event = {
  body?: any
}

module.exports = async (_event: Event, context: Context) => {
  const services: string[] = [
    'orders-service',
    'users-service',
    'billing-service'
  ]

  const gateway = process.env.OPENFAAS_GATEWAY || 'http://gateway.openfaas:8080'

  const asyncInvoke = (fn: string, body: string) => axios.post(
    `${gateway}/async-function/${fn}`,
    body,
    { headers: { 'Content-Type': 'text/plain' } }
  )

  await Promise.all(
    services.flatMap((svc) => [
      asyncInvoke('uppercase-python', svc),
      asyncInvoke('reverse-typescript', svc)
    ])
  )

  return context.status(202).succeed('Async invocations queued via NATS')
}


