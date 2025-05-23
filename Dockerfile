# Базовый образ: Node.js, так как ваше приложение на Node
FROM node:20-slim

# Установите необходимые зависимости для Chrome/Chromium
# Эти пакеты нужны для безголового режима Chrome на Debian/Ubuntu
# Список взят из официальных рекомендаций Puppeteer и других источников
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libegl1 \
    libfontconfig1 \
    libgbm1 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpangocairo-1.0-0 \
    libqt5core5a \
    libqt5gui5 \
    libqt5widgets5 \
    libsoup2.4-1 \
    libstdc++6 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libxshmfence6 \
    libxss1 \
    libxtst6 \
    libnss3-dev \
    gconf-service \
    libasound2 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    libgbm-dev \
    libasound2-dev \
    libfontconfig1-dev \
    # Очистка кэша apt, чтобы уменьшить размер образа
    && rm -rf /var/lib/apt/lists/*

# Добавьте официальный репозиторий Google Chrome и установите Chrome Stable
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Рабочая директория внутри контейнера
WORKDIR /app

# Копируем файл package.json, чтобы установить зависимости Node.js.
COPY package.json ./

# Устанавливаем все npm-зависимости.
RUN npm install

# Копируем основной код.
COPY index.js ./

# Указываем путь к исполняемому файлу Chromium.
# Теперь это гарантированный путь, так как мы сами его установили
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome

# Команда запуска приложения.
CMD ["node", "index.js"]