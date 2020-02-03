# Base Image
FROM tomcat

# Maintainer
MAINTAINER Vikas

# Copy the addressbook war to tomcat container
COPY target/addressbook.war /usr/local/tomcat/webapps/

# Start the tomcat service
CMD ["catalina.sh", "run"]
