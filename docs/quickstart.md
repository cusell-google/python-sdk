# Quickstart

If you're building a Python application with UCP, you can start by installing this SDK.

## Installation

Using `uv`, you can add it to your project:

```bash
uv add ucp-sdk
```

Or using standard `pip`:

```bash
pip install ucp-sdk
```

## Basic Example

Here is a quick example of defining a basic fulfillment update request:

```python
from ucp_sdk.models.schemas.shopping.types.fulfillment_update_request import FulfillmentUpdateRequest

update_request = FulfillmentUpdateRequest(
    fulfillment_id="12345",
    status="SHIPPED"
)
```

See the [Tutorials](tutorials/1-basic-usage.md) for more complex integrations.
