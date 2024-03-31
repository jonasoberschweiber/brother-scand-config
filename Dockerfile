FROM --platform=linux/amd64 ubuntu:24.04

# First, install everything we need to build brother-scand.
RUN echo "Installing packages" \
  && apt-get update \
  && apt-get install -y --no-install-recommends build-essential git ca-certificates \
  && echo "Done installing packages."

# Now pull the repo
RUN echo "Pulling repository from GitHub" \
  && mkdir -p /src \
  && cd /src \
  && git clone https://github.com/jonasoberschweiber/brother-scand \
  && cd /src/brother-scand \
  && git submodule init \
  && git submodule update \
  && echo "Cloned repository to /src/brother-scand"

# Finally, build the thing.
RUN cd /src/brother-scand \
  && make

FROM --platform=linux/amd64 ubuntu:24.04

RUN mkdir /brother-scand
COPY --from=0 /src/brother-scand/build/brother-scand /brother-scand

RUN echo "Installing packages" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    python3 \
    python3-pil \
    tesseract-ocr \
    tesseract-ocr-eng \
    tesseract-ocr-deu \
    msmtp \
    mutt \
    imagemagick \
    ca-certificates \
  && echo "Done installing packages"

ADD scripts /brother-scand/scripts

RUN mkdir /brother-scand/tmp

WORKDIR /brother-scand

ENTRYPOINT ["/brother-scand/brother-scand", "-c", "/brother-scand/brother.config"]
