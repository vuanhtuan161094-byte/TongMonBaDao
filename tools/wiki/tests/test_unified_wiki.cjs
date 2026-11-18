#!/usr/bin/env node
"use strict";
// Smoke test for the ONE player encyclopedia. This is not gameplay QA.
const fs=require("node:fs");
const path=require("node:path");
const vm=require("node:vm");
const assert=require("node:assert/strict");
const root=path.resolve(__dirname,"../../..");
const read=p=>fs.readFileSync(path.join(root,p),"utf8");
const json=p=>JSON.parse(read(p));
const html=read("wiki/guide.html");
const workflow=read(".github/workflows/wiki-player-pages.yml");
const combat=json("wiki/data/combat_stats_reference.json");
const mind=json("wiki/data/mind_nature_reference.json");
assert.equal(mind.combat.status,"DESIGN_CANDIDATE_NUMERICS_NOT_APPROVED");
assert.equal(mind.combat.channel,"effect_resistance");
assert.equal(mind.combat.maxBonusPp,50);
assert.equal(mind.combat.ppPerPoint,0.1);
assert.equal(mind.candidates.length,1);
assert.equal(mind.candidates[0].id,"D1-CULT-R2");
assert.equal(mind.candidates[0].status,"DESIGN_CANDIDATE_NOT_APPROVED");
const mindBonus=score=>Math.min(mind.combat.maxBonusPp,Math.max(0,score)*mind.combat.ppPerPoint);
for(const [score,expected] of [[0,0],[100,10],[200,20],[300,30],[500,50],[800,50],[1200,50]])assert.equal(mindBonus(score),expected);
const cultivate=mind.candidates[0];
const focus=score=>cultivate.baseCultivateMultiplier*(1+Math.min(cultivate.maxFocusBonus,cultivate.focusBonusPerPoint*Math.max(0,score)));
for(const [score,expected] of [[0,2],[100,2.1],[300,2.3],[500,2.5],[800,2.5]]){
 assert(Math.abs(focus(score)-expected)<1e-9,"Focus multiplier mismatch "+score);
}
assert.equal(cultivate.baseTuViPerSimMinute*focus(500)*(1+100*cultivate.aptitudeNaturalGainPerPoint),3125);
assert.match(read("docs/design/D1_MIND_NATURE_V2_EFFECT_CONTRACT_20261118.md"),/D1-COMBAT-R2/);
assert(workflow.includes("cp wiki/data/mind_nature_reference.json _site/wiki/data/"),"Mind glossary must be published");
assert.equal(combat.stats.length,16);
assert.equal(combat.resistances.length,10);
assert.equal(new Set(combat.stats.map(x=>x.id)).size,16);
assert.equal(new Set(combat.resistances.map(x=>x.id)).size,10);
const code=read("godot/src/simulation/combat/combat_stats_v2.gd");
const statConst=code.match(/const PRIMARY_CHANNELS := \[([\s\S]*?)\]/);
assert(statConst,"Missing Godot 16-stat registry");
const registered=[...statConst[1].matchAll(/"([^"]+)"/g)].map(x=>x[1]);
assert.deepEqual([...combat.stats.map(x=>x.id)].sort(),registered.sort(),"Wiki stats differ from Godot canonical registry");
const elementConst=code.match(/const ELEMENTS := \[([^\]]+)\]/);
assert(elementConst,"Missing element registry");
const elements=[...elementConst[1].matchAll(/"([^"]+)"/g)].map(x=>x[1]);
assert.deepEqual([...combat.resistances.map(x=>x.id)].sort(),elements.sort(),"Wiki resistance names differ");
assert(workflow.includes("cp wiki/data/combat_stats_reference.json _site/wiki/data/"),"Combat glossary must deploy");

assert.match(html,/script src="\.\/guide\.js"/);
assert.match(html,/stylesheet" href="\.\/unified\.css"/);
assert(!/href="\.\/(?:traits|audit|characters)\.html"/.test(html),"No links to old pages");
const nav=(html.match(/data-tab="(?:home|characters|realms|skills|buildings|equipment|items|systems|design)"/g)||[]);
assert(nav.length===10,"Expected nine sidebar entries plus brand");
assert(workflow.includes("cp wiki/unified.css _site/wiki/"),"Stylesheet must deploy");
for(const [page,tab] of Object.entries({"characters.html":"characters","traits.html":"characters","audit.html":"systems"})){
 assert(read("wiki/"+page).includes("url=./guide.html#"+tab),"Old page redirect: "+page);
}
const refs={};
function el(id){return refs[id]??(refs[id]={
 innerHTML:"",textContent:"",value:"",selectionStart:0,
 classList:{toggle(){},remove(){}},
 addEventListener(event,fn){(this.listeners??={})[event]=fn;},
 focus(){},setSelectionRange(){},scrollIntoView(){}
});}
const documentListeners={};
const document={
 getElementById:el,
 querySelectorAll:()=>[],
 addEventListener:(event,fn)=>{documentListeners[event]=fn;}
};
const location={hostname:"vuanhtuan161094-byte.github.io",hash:"#home"};
const history={replaceState(_a,_b,url){location.hash=url.slice(url.indexOf("#"));}};
const context={
 document,location,history,window:{scrollTo(){}},
 fetch:async url=>({ok:true,json:async()=>json("wiki/"+url.replace(/^\.\//,""))}),
 console
};
const src=read("wiki/guide.js");
new vm.Script(src,{filename:"guide.js"}).runInNewContext(context);
async function settle(){for(let i=0;i<12;i++)await new Promise(resolve=>setImmediate(resolve));}
function clickTab(tab,other={}){
 const obj={dataset:{tab,...other},tagName:"BUTTON"};
 const fake={closest(selector){if(selector==="[data-tab]")return obj;return null;}};
 documentListeners.click({target:fake,preventDefault(){}});
 return el("content").innerHTML;
}
function change(id,value){
 documentListeners.change({target:{id,value}});
 return el("content").innerHTML;
}
(async()=>{
 await settle();
 const view=()=>el("content").innerHTML;
 assert.match(view(),/Tìm mọi thứ trong một nơi/);
 for(const [tab,word] of [
  ["characters","101 đặc tính"],["realms","889.000"],
  ["skills","Kỹ năng"],["buildings","Linh Điền"],
  ["equipment","Trang bị V2"],["items","444"],["systems","Toàn bộ chức năng"],["design","Thiết kế trước"]
 ]){
  clickTab(tab);
  assert(view().includes(word),"Navigation "+tab+" missing "+word);
 }
 clickTab("characters");
 assert.match(view(),/Ham Học/);
 assert.match(view(),/16 chỉ số chiến đấu/);
 assert.match(view(),/Kháng Bạo Kích/);
 assert.match(view(),/1,50×/);
 assert.match(view(),/Giảm Hút Máu/);
 assert.match(view(),/Tâm Tính — Kháng Hiệu Ứng và Tu Luyện/);
 assert.match(view(),/Kháng: mục tiêu trần \+50 điểm %/);
 assert.match(view(),/Chưa có hiệu ứng gameplay/);
 assert.match(view(),/30%/);
 change("mind-score","800");
 assert.match(view(),/\+50 điểm %/);
 assert.match(view(),/30%/);
 change("mind-score","1200");
 assert.match(view(),/\+8 điểm %/);
 assert.match(view(),/Hệ số kháng và Tu Luyện: đề xuất/);
 assert.match(view(),/52,08 Tu Vi\/s/);
 change("mind-score","500");
 assert.match(view(),/20,83 EXP\/s/);
 assert(!view().includes("Vững tâm sau thất bại"),"Mood proposal must not appear");
 assert(!view().includes("Tĩnh Tâm khi nghỉ"),"Mood rest proposal must not appear");
 change("trait-group","DEPENDENCY_BLOCKED");
 assert.match(view(),/Thiếu cơ chế/);
 change("char-focus","focus");
 assert.match(view(),/41,67 EXP\/s/);
 clickTab("buildings");
 assert.match(view(),/20 loại thiết kế/);
 change("build-status","missing");
 assert.match(view(),/KHO TÔNG MÔN/);
 clickTab("items");
 change("item-group","nativeResources");
 assert.match(view(),/Linh Mộc/);
 change("item-group","medicine");
 assert.match(view(),/Hồi Nguyên Đan/);
 clickTab("systems");
 change("system-status","DESIGN_ONLY");
 assert.match(view(),/Mới thiết kế/);
 el("search").value="Ham Học";
 el("search").listeners.input();
 assert.match(view(),/Tìm: Ham Học/);
 assert.match(view(),/Ham Học/);
 el("search").value="Crit";el("search").listeners.input();
 assert.match(view(),/Chỉ số chiến đấu/);
 assert.match(view(),/Crit/);
 console.log("PASS unified Wiki: one nav, redirects, seven categories, real JSON, 101 traits, upgrading, item filter, cross-search.");
})().catch(err=>{console.error(err);process.exitCode=1;});
