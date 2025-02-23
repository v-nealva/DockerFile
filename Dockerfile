#Dockerfile SisRenegociacao
#Stage 1 - Dotnet Restore & Publish Application
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 As builder
WORKDIR /app
COPY *.csproj ./
RUN dotnet restore
COPY . ./
RUN dotnet publish -c Release -o out
# Stage 2 - Install Tools
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
RUN apt-get update && apt-get install -y supervisor && apt-get install -y openssh-server && echo "root:Docker!" | chpasswd 
RUN apt-get install -y tcptraceroute && apt-get install -y net-tools && apt-get install -y wget && apt-get install -y telnet && apt-get install -y dnsutils
RUN apt-get install -y locales
RUN dpkg-reconfigure locales
RUN sed -i -e 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LANG pt_BR.UTF-8  
ENV LANGUAGE pt_BR:pt  
ENV LC_ALL pt_BR.UTF-8
RUN mkdir -p /var/log/supervisor /run/sshd
WORKDIR /usr/bin
RUN wget http://www.vdberg.org/~richard/tcpping
RUN chmod 755 tcpping
COPY sshd_config /etc/ssh/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
WORKDIR /app
COPY --from=builder /app/out .
# Stage 3 - Expose Ports
EXPOSE 80 443 2222
# Stage 4 - Run Supervisod
ENTRYPOINT ["/usr/bin/supervisord"]
