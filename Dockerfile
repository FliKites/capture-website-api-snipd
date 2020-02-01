FROM node:13-slim
RUN apt-get update && apt-get install --no-install-recommends -yq \
    libgconf-2-4 ca-certificates wget gnupg2
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE 1
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub |\
    apt-key add -
RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
RUN apt-get update && apt-get install -y google-chrome-unstable git \
    fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst \
    ttf-freefont --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* /src/*.deb
RUN mkdir /app
COPY package.json yarn.lock app/
COPY src app/src
WORKDIR /app
RUN yarn
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
RUN groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app
USER pptruser
CMD yarn start
