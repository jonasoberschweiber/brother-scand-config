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

## Possible Improvements

- The way I'm writing the TIFF file for the run length data is somewhat
  primitive and could surely be sped up.
