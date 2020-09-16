# You can set the Swift version to what you need for your app. 
# Versions can be found here: https://hub.docker.com/_/swift
FROM swift as builder

WORKDIR /app

COPY ./Package.* ./

RUN swift package resolve

COPY . .

RUN swift build \
    --enable-test-discovery \
    -c release \
    -Xswiftc -g \
    -j 4

# RUN swift test --enable-test-discovery