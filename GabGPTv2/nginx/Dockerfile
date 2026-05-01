FROM nginx:alpine

# Copia la configuración de Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Opcional: Si usas autenticación básica
# Para generar -> htpasswd  -c .htpasswd usuario
# RUN apk add --no-cache apache2-utils
# COPY .htpasswd /etc/nginx/.htpasswd

#EXPOSE 80 443