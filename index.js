const express = require('express');
const puppeteer = require('puppeteer');

const app = express();
app.use(express.json());

// Маршрут для проверки работоспособности сервиса (необязательно, но полезно)
app.get('/', (req, res) => {
  res.send('Puppeteer screenshot service is operational!');
});

app.post('/screenshot', async (req, res) => {
  const { url } = req.body;
  if (!url) return res.status(400).send({ error: 'Missing URL' });

  let browser; // Объявляем browser вне try, чтобы он был доступен в finally
  try {
    browser = await puppeteer.launch({
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
      // Явно указываем путь к исполняемому файлу Chromium
      executablePath: process.env.PUPPETEER_EXECUTABLE_PATH || '/usr/bin/google-chrome',
      // Используем новый headless-режим, как предлагает Puppeteer
      headless: "new"
    });

    const page = await browser.newPage();
    // Попробуем более "мягкое" ожидание загрузки страницы
    await page.goto(url, { waitUntil: 'load' }); // Изменено с 'networkidle2' на 'load'

    const screenshot = await page.screenshot({ type: 'png' }); // encoding: 'binary' не нужен здесь, т.к. PNG уже бинарный

    res.set('Content-Type', 'image/png');
    res.send(screenshot);
  } catch (error) {
    console.error('Screenshot error:', error);
    // Добавим details для более информативного ответа в случае ошибки
    res.status(500).send({ error: 'Failed to take screenshot', details: error.message });
  } finally {
    // Убедимся, что браузер всегда закрывается, чтобы избежать утечек памяти
    if (browser) {
      await browser.close();
    }
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Puppeteer service listening on port ${PORT}`);
});