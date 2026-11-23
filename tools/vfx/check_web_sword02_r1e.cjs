#!/usr/bin/env node
// Independent Chromium proof: R1E selectable on canonical /vfx/; actual AS48,
// moving monster pixels and three held VFX phases; no runtime combat authority.
const {chromium}=require('playwright-core');
const {PNG}=require('pngjs');
const fs=require('fs');
const path=require('path');
const base=process.env.VFX_REVIEW_URL||'http://127.0.0.1:8679/vfx/';
const out=process.env.VFX_BROWSER_PROOF||'./vfx-browser-proof';
fs.mkdirSync(out,{recursive:true});
function pixelDelta(a,b,rect){
  const A=PNG.sync.read(a),B=PNG.sync.read(b);
  if(A.width!==B.width||A.height!==B.height) throw Error('CANVAS_RESIZED');
  let count=0;
  for(let y=rect[1];y<rect[3];y+=2)for(let x=rect[0];x<rect[2];x+=2){
    const p=4*(y*A.width+x);
    const d=Math.abs(A.data[p]-B.data[p])+Math.abs(A.data[p+1]-B.data[p+1])+Math.abs(A.data[p+2]-B.data[p+2]);
    if(d>55)count++;
  }
  return count;
}
function nonGround(png,rect){
  const im=PNG.sync.read(png);let n=0;
  for(let y=rect[1];y<rect[3];y+=2)for(let x=rect[0];x<rect[2];x+=2){
    const p=4*(y*im.width+x),r=im.data[p],g=im.data[p+1],b=im.data[p+2];
    if((r>125||g>135||b>145)&&(Math.abs(r-43)+Math.abs(g-56)+Math.abs(b-59)>90))n++;
  }
  return n;
}
(async()=>{
  const browser=await chromium.launch({executablePath:process.env.CHROME_EXECUTABLE,headless:true,args:['--no-sandbox','--disable-dev-shm-usage','--enable-webgl','--enable-unsafe-swiftshader','--use-gl=angle','--use-angle=swiftshader','--ignore-gpu-blocklist']});
  try{
    const page=await browser.newPage({viewport:{width:1280,height:720},deviceScaleFactor:1});
    const faults=[],logs=[];
    page.on('pageerror',e=>faults.push(String(e)));
    page.on('console',m=>logs.push(m.text()));
    await page.goto(base+(base.includes('?')?'&':'?')+'skill=r1e',{waitUntil:'domcontentloaded',timeout:60000});
    const canvas=page.locator('canvas').first();
    await canvas.waitFor({state:'visible',timeout:60000});
    let selected=false;
    for(let i=0;i<25;i++){
      await page.waitForTimeout(800);
      if(logs.some(x=>x.includes('WEB_VFX_SCENE_LOADED id=tmb.skill.sword.ngu_kiem.active_01.human')))break;
    }
    // Stable query deeplink selects R1E in the canonical Godot Web hub.
    for(let i=0;i<15;i++){
      await page.waitForTimeout(700);
      if(logs.some(x=>x.includes('WEB_VFX_SCENE_LOADED id=tmb.skill.sword.ngu_kiem.active_02.human'))){selected=true;break;}
    }
    const initial=await canvas.screenshot();
    fs.writeFileSync(path.join(out,'R1E-selection.png'),initial);
    if(!selected) throw Error('R1E_NOT_SELECTED_ON_SINGLE_CANONICAL_VFX_SITE');
    const actor=nonGround(initial,[260,475,425,632]);
    const monsters=nonGround(initial,[730,412,1008,632]);
    const samples=[];
    for(const item of [
      {phase:'charge',x:1058,bounds:[315,380,525,600]},
      {phase:'projectile',x:1132,bounds:[490,365,750,570]},
      {phase:'contact',x:1204,bounds:[775,380,1010,615]},
    ]){
      await canvas.click({position:{x:item.x,y:480}});
      await page.waitForTimeout(330);
      const held=logs.some(x=>x.includes('R1E_SWORD02_PHASE_HELD='+item.phase));
      const visible=await canvas.screenshot();
      fs.writeFileSync(path.join(out,'R1E-'+item.phase+'-on.png'),visible);
      await canvas.click({position:{x:1133,y:311}});
      await page.waitForTimeout(190);
      const hidden=await canvas.screenshot();
      await canvas.click({position:{x:1133,y:311}});
      const pixels=pixelDelta(visible,hidden,item.bounds);
      samples.push({phase:item.phase,receipt:held,vfx_delta_pixels:pixels,passed:held&&pixels>=20});
    }
    const verdict=selected&&actor>=30&&monsters>=40&&samples.every(x=>x.passed)&&faults.length===0?'R1E_BROWSER_REAL_AS48_VFX_PASS':'R1E_BROWSER_FAIL';
    const result={verdict,selected,actor_pixels:actor,monsters_pixels:monsters,phase_samples:samples,page_errors:faults.slice(0,8),source:'R1E_OWNER_ACCEPTED_VFX_ONLY',front_only:true,pve:'HOLD',logs:logs.filter(x=>/R1E_|WEB_VFX_SCENE_LOADED/.test(x)).slice(-20)};
    fs.writeFileSync(path.join(out,'R1E-browser-result.json'),JSON.stringify(result,null,2));
    console.log(JSON.stringify(result));
    if(verdict!=='R1E_BROWSER_REAL_AS48_VFX_PASS')throw Error(verdict);
  }finally{await browser.close()}
})().catch(e=>{console.error(e.stack||String(e));process.exitCode=1});