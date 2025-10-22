'use strict'

const axios = require('axios')

module.exports = async (event, context) => {
  const services = [
    'orders-service',
    'users-service',
    'billing-service'
  ]

  const gateway = process.env.OPENFAAS_GATEWAY || 'http://gateway.openfaas:8080'

  const asyncInvoke = (fn, body) => axios.post(`${gateway}/async-function/${fn}`, body, {
    headers: { 'Content-Type': 'text/plain' }
  })

  await Promise.all(
    services.flatMap((svc) => [
      asyncInvoke('uppercase-python', svc),
      asyncInvoke('reverse-typescript', svc)
    ])
  )

  return context
    .status(202)
    .succeed('Async invocations queued via NATS')
}


