# Information

In this repository you can find the setup of a small prometheus exporter written in powershell for retrieving one specific information from a keystore file which is deployed as secret in Kubernetes -> Days left until Expiration date. 

## Background
If you have for example a Kubernes Cluster with an internal Kafka running and an application written in Spring which wants to connect to Kafka, you have to use (because of security reasons) a certificate. This certificate is normally deployed as secret in a namespace. The secret has normally the keystore file (jks) which includes the certificate itself. 

So what does this means?  
Use case: you have a secret `kafka-secret` with following content `keystore.jks` file which normally will be mounted into your application (file or environmet variables). To make sure your certificate is up to date this exporter will also get the certificate/secret mounted. 

## Note 
In the "implementation" folder you can find an existing dummy keystore file which password is "password". This keystore fill will be replaced by the mounted file in your Kubernetes Cluster.
 
# Deployment
You can build the image by using everything inside "implementation" folder. Inside "deployment" folder you find a helm chart for running the exporter im Kubernetes. The helm chart have annotations for security (runAsUser,securityGroup) and also for Prometheus (scrape targets) defined. `pullSecret`, `keyStorePassword`, `kafkaSecretName` have to be replaced by you. 


# Important
Big thank you to: Joris Beckers: https://github.com/jobec/powershell-prom-client  
I have reused his provided Powershell Exporter and extended it with my custom code. 
