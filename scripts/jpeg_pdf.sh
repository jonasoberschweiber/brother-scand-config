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

# This receives JPEG and bundles them into a PDF file. In addition to the
# environment variables above, it expects a COMBINED_OUTPUT_FILENAME variable
# to contain the destination filename _without_ the PDF extension!

set -x -e

if [ ! -z "$SCANNER_FILENAME" ]; then
	# A SCANNER_FILENAME means that we have received data for one page, temp store
	# that.
	mv $SCANNER_FILENAME tmp/${SCANNER_SCANID}_${SCANNER_PAGE}.jpeg
	exit 0
fi

# Now convert those to one TIFF file.
convert $(for i in $(seq 1 $SCANNER_PAGE); do echo tmp/${SCANNER_SCANID}_$i.jpeg; done) ${COMBINED_OUTPUT_FILENAME}.pdf

rm tmp/${SCANNER_SCANID}_*.jpeg
