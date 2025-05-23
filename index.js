const express = require('express');
const puppeteer = require('puppeteer'); // <-- Убедитесь, что это "puppeteer", а не "puppeteer-core"

const app = express();
app.use(express.json());

// Маршрут для проверки работоспособности сервиса (необязательно, но полезно)
app.get('/', (req, res) => {
  res.send('Puppeteer screenshot service is operational!');
});

app.post('/screenshot', async (req, res) => {
  const { url } = req.body;
  if (!url) return res.status(400).send({ error: 'Missing URL' });

  let browser;
  try {
    browser = await puppeteer.launch({
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
      // executablePath: process.env.PUPPETEER_EXECUTABLE_PATH || '/usr/bin/google-chrome', // <--- ЭТУ СТРОКУ НУЖНО УДАЛИТЬ!
      headless: "new"
    });

    const page = await browser.newPage();
    await page.goto(url, { waitUntil: 'load' });

    const screenshot = await page.screenshot({ type: 'png' });

    res.set('Content-Type', 'image/png');
    res.send(screenshot);
  } catch (error) {
    console.error('Screenshot error:', error);
    res.status(500).send({ error: 'Failed to take screenshot', details: error.message });
  } finally {
    if (browser) {
      await browser.close();
    }
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Puppeteer service listening on port ${PORT}`);
});