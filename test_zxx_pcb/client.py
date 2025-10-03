# Enable pyserial extensions
import pyftdi.serialext
from pyftdi.ftdi import Ftdi
from io import StringIO
import sys, os

# This is roundabout but works. . .
s = StringIO()
Ftdi.show_devices(out=s)
devlist = s.getvalue().splitlines()[1:-1]
gooddevs = []
for dev in devlist:
    url = dev.split('(')[0].strip()
    name = '(' + dev.split('(')[1]
    if name == '(Single RS232-HS)':
        gooddevs.append(url)
if len(gooddevs) == 0:
    print('Error:  No matching FTDI devices on USB bus!')
    sys.exit(1)
elif len(gooddevs) > 1:
    print('Error:  Too many matching FTDI devices on USB bus!')
    Ftdi.show_devices()
    sys.exit(1)
else:
    print('Success: Found one matching FTDI device at ' + gooddevs[0])

# Open a serial port on the second FTDI device interface (IF/2) @ 3Mbaud
port = pyftdi.serialext.serial_for_url(gooddevs[0], baudrate=9600, timeout=0)

# Send bytes
#port.write(b'Hello World')

while True:
    # Receive bytes
    c = port.read(1)
    if c == b'':
        sys.stdout.flush()
    else:
        print(c.decode("utf-8"), end='')
        # sys.stdout.write(data.decode("utf-8"))
        # print(data.decode("utf-8"))


