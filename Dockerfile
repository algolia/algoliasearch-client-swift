# You can set the Swift version to what you need for your app. 
# Versions can be found here: https://hub.docker.com/_/swift
FROM swift as builder

WORKDIR /app
COPY . .

RUN swift package resolve
RUN swift build \
    --enable-test-discovery \
    -c release \
    -Xswiftc -g \
    -j 4