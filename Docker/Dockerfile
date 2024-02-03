FROM ubuntu:22.04
LABEL com.example.version="0.0.1-beta" com.example.release-date="2024-02-12"
RUN apt-get update && apt-get -y curl
EXPOSE 8080
ENV DB_PASSWORD=password
CMD [ "python" ]