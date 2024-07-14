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

# This script is adapted from ocr-fake-duplex-adf from the brother-scand repo.
# It will merge the current and previous files into one PDF, assuming that the
# pages with identical numbers in both files are front and back of the same
# physical page.

set -e -x

if [ -z "$SCANNER_FILENAME" ]; then
  # Remember the previous filename and set a temporary destination file.
  [ -e destfilename ] && cp destfilename prevfilename
  echo "tmp/$(date "+%Y-%m-%d_%H%M%S")" > destfilename
  export COMBINED_OUTPUT_FILENAME=$(cat destfilename)
fi

# This will exit unless SCANNER_FILENAME is empty.
export NO_OCR=1
. scripts/text_pdf.sh

if [ -e prevfilename ]; then
  PREV_FILENAME=$(cat prevfilename)
  A=$PREV_FILENAME.pdf
  B=$COMBINED_OUTPUT_FILENAME.pdf
  if [ "$A" = "$B" ]; then
    echo "This is the wrong instance of the script, for the first document."
    exit 0
  fi
  if [ -e $A ]; then
    PREV_PAGES=$(pdftk $A dump_data | awk '/NumberOfPages/{print $2}')
    # Heuristic: if there were multiple pages scanned and the previous PDF
    # has the same number of pages, then assume it's front and back of a
    # duplex ADF scan and merge them.
    if [ $SCANNER_PAGE -eq $PREV_PAGES ]; then
      pdftk A=$A B=$B shuffle A Bend-1 output $1/$(date "+%Y-%m-%d_%H%M%S").pdf
      rm $A
      rm $B
      rm destfilename
      rm prevfilename
    fi
  fi
fi
