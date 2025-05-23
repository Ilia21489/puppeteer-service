# Используем официальный образ Puppeteer с Node.js и Chromium
FROM ghcr.io/puppeteer/puppeteer:21.3.0

# Вместо WORKDIR /app в этом образе уже есть /home/pptruser
# Но мы все равно можем использовать /app для ясности, или просто работать в /home/pptruser

WORKDIR /app

# Копируем только те файлы, которые нужны для установки зависимостей
COPY package.json ./

# Устанавливаем зависимости
# В этом образе Chromium уже есть, поэтому apt-get install chromium не нужен
RUN npm install

# Копируем основной код
COPY index.js ./

# Устанавливать ENV PUPPETEER_EXECUTABLE_PATH в этом случае не нужно,
# так как образ уже настроен на использование встроенного Chromium.
# Если очень хочется убедиться, можно добавить:
# ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome # Или другой путь внутри этого образа, который Puppeteer найдет сам

# Запускаем приложение
CMD ["node", "index.js"]