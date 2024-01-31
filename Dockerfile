# Use an official Swift runtime as a parent image
FROM swift:latest

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . .

# Download Swift package dependencies
RUN swift package resolve

# Command to run tests
CMD ["swift", "test", "--enable-test-discovery"]
