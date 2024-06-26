#!/bin/sh

################################################################################
#
# The following environment variables will be set:
#
#   SCANNER_XDPI
#   SCANNER_YDPI
#   SCANNER_HEIGHT
#   SCANNER_WIDTH
#   SCANNER_PAGE (starts from 1)
#   SCANNER_IP
#   SCANNER_SCANID (to group a set of scanned pages)
#   SCANNER_HOSTNAME (as selected on the device)
#   SCANNER_FUNC (as selected on the device)
#   SCANNER_FILENAME (where the received data was stored), e.g. scan123.jpg
#
# The script is also called after all pages of a set have been received,
# in this case SCANNER_FILENAME will not be set.
# For a set of pages, you can expect the variables to stay the same (except for
# SCANNER_PAGE and SCANNER_FILENAME).
#
################################################################################

# Set a destination file name, call the OCR script and then email that to $1.
# Afterwards, remove the PDF.

export COMBINED_OUTPUT_FILENAME="tmp/$(date "+%Y-%m-%d_%H%M%S")"

. scripts/jpeg_pdf.sh

printf "Finde deinen Scan im Anhang" | mutt -s "Dein Scan $(date "+%Y-%m-%d %H:%M")" -a ${COMBINED_OUTPUT_FILENAME}.pdf -- $1

rm ${COMBINED_OUTPUT_FILENAME}.pdf
