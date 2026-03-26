# Tutorial 1: Basic Usage

This tutorial will cover how to accept UCP payloads in a REST or FastAPI application and how to deserialize them safely.

## Step 1: Initialize the Application

```python
from fastapi import FastAPI
from ucp_sdk.models.schemas.shopping.checkout_create_request import CheckoutCreateRequest

app = FastAPI()

@app.post("/v1/checkout/create")
async def create_checkout(request: CheckoutCreateRequest):
    print(f"Checkout for entity: {request.entity}")
    return {"status": "success"}
```

In the next sections, we will expand on integrating specific protocol versions and handling validation errors.
