# Utiliza una imagen base en blanco
FROM php:8.1.19RC1-fpm-alpine3.17

# Instala algunas dependencias de PHP y descarga e instala Composer
RUN docker-php-ext-install pdo pdo_mysql && \
    add https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/ && \
    chmod uga+x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions sockets

# Secuencia alternativa.
# ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/
# RUN chmod uga+x /usr/local/bin/install-php-extensions && sync && \
#     install-php-extensions sockets

# Actualiza el repositorio de paquetes e instala Telnet
RUN apk update && apk add --no-cache busybox-extras

# Instala las dependencias de la extensión GD para PHP (procesamiento de imágenes)
RUN apk add --no-cache libpng-dev libjpeg-turbo-dev && \
    docker-php-ext-configure gd --with-jpeg=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd

# Instala la extensión ZIP para PHP
RUN apk add --no-cache libzip-dev=1.9.2-r2 && \
    docker-php-ext-install -j$(nproc) zip

# Instala Node Package Manager
RUN apk add --no-cache nodejs npm

# Instala Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin --filename=composer

# Copia el binario de Composer a la ubicación de la imagen
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configura el directorio de trabajo
WORKDIR /var/www/html

# Copia los archivos de la aplicación al contenedor
COPY ./app/src/cursatec_gestion /var/www/html

# Copia el archivo init.sql al directorio de inicio de la base de datos
COPY ./db/init/init.sql /docker-entrypoint-initdb.d/
