#!/usr/bin/env node
// ONE Browser QA for VFX Web Review. A green headless Godot log is NOT proof
// an actor/monster appears in Chromium; this checks actual canvas pixels.
const { chromium } = require('playwright-core');
const { PNG } = require('pngjs');
const fs = require('fs');
const path = require('path');

// Calibrated against the real AS48 native WebGL screenshot at 1×:
// actor=42 sampled nonbackground pixels, monster=61. Previous broken export:
// actor=0, monster=0. Use conservative nonzero minima without requiring
// a large actor that would falsify the actual gameplay 1× scale.
const ACTOR_PIXEL_MIN = 30;
const MONSTER_PIXEL_MIN = 40;
const url = process.env.VFX_REVIEW_URL || 'http://127.0.0.1:8679/vfx/';
const output = process.env.VFX_BROWSER_PROOF || './vfx-browser-proof';
fs.mkdirSync(output, { recursive: true });

function pixelCount(png, bounds) {
  const scaleX = png.width / 1280, scaleY = png.height / 720;
  const backgrounds = [
    [217,230,237], [178,186,174], [134,155,141],
    [23,33,43], [56,62,60], [89,102,91], [115,127,117]
  ];
  let count = 0;
  for (let y = Math.round(bounds[1]*scaleY); y < Math.round(bounds[3]*scaleY); y += 2) {
    for (let x = Math.round(bounds[0]*scaleX); x < Math.round(bounds[2]*scaleX); x += 2) {
      const ix = 4 * (y * png.width + x);
      if (ix < 0 || ix + 3 >= png.data.length) continue;
      const rgb = [png.data[ix], png.data[ix+1], png.data[ix+2]];
      const distance = Math.min(...backgrounds.map(c =>
        Math.abs(rgb[0]-c[0]) + Math.abs(rgb[1]-c[1]) + Math.abs(rgb[2]-c[2])));
      if (distance > 72 && png.data[ix+3] > 180) count++;
    }
  }
  return count;
}

(async () => {
  const chrome = process.env.CHROME_EXECUTABLE;
  if (!chrome) throw Error('CHROME_EXECUTABLE missing (do not skip browser QA)');
  const browser = await chromium.launch({
    executablePath: chrome, headless: true,
    args: ['--no-sandbox','--disable-dev-shm-usage','--enable-webgl',
      '--enable-unsafe-swiftshader','--use-gl=angle',
      '--use-angle=swiftshader','--ignore-gpu-blocklist']
  });
  try {
    const page = await browser.newPage({ viewport: { width: 1280, height: 720 }, deviceScaleFactor: 1 });
    const faults = [];
    page.on('pageerror', error => faults.push(String(error)));
    await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60000 });
    const canvas = page.locator('canvas').first();
    await canvas.waitFor({ state: 'visible', timeout: 60000 });
    let actor=0, monster=0, screenshot;
    // Browser WebGL startup is asynchronous; check the final screen rather than
    // racing the Godot startup splash or a blank first frame.
    for (let attempt=0; attempt<25; attempt++) {
      await page.waitForTimeout(850);
      screenshot = await canvas.screenshot({ timeout: 30000 });
      const img = PNG.sync.read(screenshot);
      actor = pixelCount(img, [270, 475, 445, 630]);
      monster = pixelCount(img, [760, 430, 985, 610]);
      if (actor >= ACTOR_PIXEL_MIN && monster >= MONSTER_PIXEL_MIN) break;
    }
    fs.writeFileSync(path.join(output, 'vfx-real-canvas.png'), screenshot);
    const record = {
      url, actor_pixels: actor, monster_pixels: monster,
      actor_pixel_min: ACTOR_PIXEL_MIN, monster_pixel_min: MONSTER_PIXEL_MIN,
      actor_visible: actor>=ACTOR_PIXEL_MIN, monster_visible: monster>=MONSTER_PIXEL_MIN,
      browser_console_errors: faults.slice(0, 8),
      verdict: actor>=ACTOR_PIXEL_MIN && monster>=MONSTER_PIXEL_MIN ? 'BROWSER_CANVAS_PIXELS_PASS' : 'BROWSER_CANVAS_PIXELS_FAIL',
      vfx_g3_art: 'SOURCE_PENDING', owner_art: 'PENDING', pve: 'HOLD'
    };
    fs.writeFileSync(path.join(output, 'result.json'), JSON.stringify(record, null, 2));
    console.log(JSON.stringify(record));
    if (actor < ACTOR_PIXEL_MIN || monster < MONSTER_PIXEL_MIN) throw Error('EMPTY_ACTOR_OR_MONSTER: render regression (screenshot saved)');
    console.log('VFX_WEB_BROWSER_RENDER_PASS actual_AS48_and_moving_monster_pixels=true');
  } finally {
    await browser.close();
  }
})().catch(e => { console.error(e.stack || String(e)); process.exitCode = 1; });
