# Brother Scripts

These scripts are made to be used with [brother-scand](https://github.com/rumpeltux/brother-scand),
a tool to support the scan button on Brother multi function devices. I
specifically use it to add scan to email and scan to file functionality on a
Brother MFC-L2710DW, which doesn't have those options natively in its firmware.

## Setup

To use these, you need to have the following software installed:

- Python 3
- PIL/Pillow for Python 3
- Tesseract with a language pack
- Mutt for sending emails (I use it in conjunction with msmtp)

You'll also need to build [brother-scand](https://github.com/rumpeltux/brother-scand)
and set it up as a service. If you have a firewall active, you'll need to allow
UDP/54925.

## Running Using Docker

There's also a Docker container available that contains a version of
brother-scand as well as all the required software and the scripts from this
repository. See the `Dockerfile` for how it's built. You should just be able to
build it yourself, but there is also a prebuilt version available
[here on GitHub](https://github.com/jonasoberschweiber/brother-scand-config/pkgs/container/brother-scand-config).

Note that this is currently using [my fork of brother-scand](https://github.com/jonasoberschweiber/brother-scand),
because the original version of brother-scand automatically determines the
local IP address of the local system and sends that to the Brother device. Since
that'll be the IP address of the Docker container, and not of the host system,
the Brother device won't be able to reach brother-scand running inside of the
container. So I've added a new setting called `network.local-ip` to override the
automatic detection.

To use the Docker container, you'll need to

- Expose port UDP/54925 to the container.
- Mount your config file into the container at `/brother-scand/brother.config`.
- Set the local IP address using `network.local-ip` in the config file, as per
  the paragraph above.
- Mount an msmtprc to `/etc/msmtprc` and a muttrc to `/root/.muttrc` if you want
  to use the email functionality.

In a Docker Compose file, that might look something like this:

```yaml
version: '3'
services:
  brother-scand:
    image: ghcr.io/jonasoberschweiber/brother-scand-config:latest
    restart: unless-stopped
    ports:
      - "54925:54925/udp"
    volumes:
      - ./brother.config:/brother-scand/brother.config:ro
      - ./muttrc:/root/.muttrc:ro
      - /etc/msmtprc:/etc/msmtprc:ro
```

## A Quick Guide to the Configuration File

There are three major sections to brother-scand's configuration file: basic
parameters that apply to each device; `define-presets`, which you can use to
define some reusable baseline parameters for scanning (paper size etc.); and
a block per device that contains all the `presets` for the device. These show
up as menu items on the device. See the [example config](https://github.com/rumpeltux/brother-scand/blob/master/out/brother.config)
in the brother-scand repo for more in-depth information on individual parameters.

We won't cover the basic parameters that apply to each device, since I
personally don't use them. See the example config for more information on those.

### define-presets

You can use `define-preset` blocks to set up some basic scan parameters to reuse
later. The basics that I define in my configuration file are the data format,
color depth, paper size, and DPI. The following is the preset that I use for
regular black and white documents. It uses run-length encoding (parameter `C`),
1-bit color depth (parameter `M`), an A4 paper size (parameter `P`), and 300
DPI (parameter `R`).

```
define-preset text
scan.param C RLENGTH
scan.param M TEXT
scan.param P A4
scan.param R 300,300
```

### Per-device Settings

Each Brother device configuration starts with the `ip` configuration option,
which we use to set the IPv4 address of the target device. If you only have one
device, then you'll only have one per-device setting block. Note that this needs
to be an IP address, so it's probably a good idea to assign a static address to
your device. If you're running brother-scand inside of a Docker container, you
also need to set `network.local-ip` to the IP address of the host that's running
the Docker container. This is required because brother-scand needs to advertise
its own IP address to the printer. It'll advertise the Docker-internal IP if we
don't set this, which the printer won't be able to use.

The following would be the correct settings if the printer had the IP address
192.168.1.2 and brother-scand's host had 192.168.1.1.

```
ip 192.168.1.2
network.local-ip 192.168.1.1
```

Afterwards, we can define an arbitrary number of presets using `preset` blocks.
Each preset shows up as a target/menu item on the Brother device. This allows
you to set up different actions such as scanning to separate email addresses,
different shares, and so on. This is also where you'd reference the scripts
in the `scripts` folder, since each target can have its own `scan.func`, which
is executed on the data received from the printer.

A preset to send an email to test@example.com could look like this.

```
preset text EMAIL
hostname 1-BW-Example
scan.func scripts/email_text_pdf.sh test@example.com
```

Note that the preset line contains two parameters: `text` and `EMAIL`. The first
one is the `define-preset` to use, so it sets up the basic scan parameters for
the preset. The second one is the category for the preset on the device. There
are four submenus on Brother devices: `FILE`, `OCR`, `IMAGE`, and `EMAIL`.

The `hostname` is what shows up as the text of the menu item on the Brother
device. It does not need to be valid hostname on your network. Use `scan.func`
to specificy the program to run on the contents received from the printer.

## Included Scripts

This repo contains a few scripts that you can use in your config file.

**text_pdf_file.sh**

Expects data in RLENGTH format (black/white). Creates an OCRed PDF file in the
given directory with the current date and time as a name.

**text_pdf_file_duplex.sh**

Works similarly to `text_pdf_file.sh`, but simulates a duplex scan using two
subsequent scans: feed one side of the document through the scanner first. Then
start another scan for the same target and feed the other side of the document
through the scanner. The script will assemble them into one OCRed PDF file.

**email_text_pdf.sh**

Expects data in RLENGTH format (black/white). Creates an OCRed PDF file and
sends it to the given email address. Note that you'll need to set up mutt on
your system for this to work (for the Docker container: mount config files for
mutt and msmtp).

**email_jpeg_pdf.sh**

Expects data in JPEG format (full color). Sends the resulting PDF file to the
given email address. See `email_text_pdf.sh` for notes on sending emails.

## Possible Improvements

- The way I'm writing the TIFF file for the run length data is somewhat
  primitive and could surely be sped up.
