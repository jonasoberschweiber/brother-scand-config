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

## Running using Docker

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

## Possible Improvements

- The way I'm writing the TIFF file for the run length data is somewhat
  primitive and could surely be sped up.
