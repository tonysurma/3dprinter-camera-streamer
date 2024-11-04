import sys
import pyprusalink
import asyncio
from pyprusalink import PrusaLink


async def main():
    try:

        # Instantiate the printer with IP address and API key
        async with pyprusalink.AsyncClient() as client:
            printer = PrusaLink(client, "http://hostname", "maker", "???")

            status = await printer.get_status()
            state = status["printer"]["state"];

            print(f"{state}")
            sys.exit(0)

    except Exception as e:
        print(f"PYFAIL")
        sys.exit(500)

asyncio.run(main())
