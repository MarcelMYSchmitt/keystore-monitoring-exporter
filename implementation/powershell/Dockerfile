FROM mcr.microsoft.com/powershell:latest

# ENV variables will be provided via docker-compose or build pipeline or kubernetes deployment
ENV KEYSTOREPASSWORD "should_be_replaced_from_the_outside"

# Install jdk for getting keytool
# Install dependencies and clean up
RUN apt-get update && apt-get -y install \
        openjdk-8-jdk 


# Copy everything with dummy keystore file  
COPY . . 

# Run script using parameters from compose file
CMD pwsh -File GetMetrics.ps1 -KeyStorePassword ${KEYSTOREPASSWORD}