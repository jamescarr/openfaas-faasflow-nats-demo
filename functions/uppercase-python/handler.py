def handle(event, _):
    service_name = event.body
    print(f"Uppercasing {service_name.upper()}", flush=True)
    return {
        "statusCode": 200,  
        "body": service_name.upper(),
    }


