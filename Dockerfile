# Используем официальный образ Node.js
FROM node:20-slim

# Устанавливаем минимальные зависимости для Chrome/Chromium.
# Эти пакеты необходимы для запуска Chrome в контейнере.
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
    libxss1 \
    libxtst6 \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Добавляем официальный репозиторий Google Chrome и устанавливаем Chrome Stable
# Это гарантирует, что мы используем последнюю стабильную версию Google Chrome.
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Создаем рабочую директорию
WORKDIR /app

# Копируем package.json и package-lock.json (если есть)
# Это позволяет кешировать npm install
COPY package*.json ./

# Устанавливаем зависимости Node.js
# PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true предотвращает скачивание Chrome Puppeteer'ом,
# так как мы устанавливаем его системно
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
RUN npm install

# Копируем остальной код приложения
COPY . .

# Указываем путь к исполняемому файлу Chrome.
# Puppeteer будет использовать этот путь для запуска браузера.
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome

# Устанавливаем порт, который будет слушать приложение
# Cloud Run ожидает, что приложение будет слушать порт, указанный в переменной окружения PORT
ENV PORT 8080
EXPOSE 8080

# Команда для запуска приложения
CMD ["node", "index.js"]