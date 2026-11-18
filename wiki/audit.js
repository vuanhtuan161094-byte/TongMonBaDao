(() => {
"use strict";
const branch="integration/pve-p0-playable-ui-20261103";
const GH="https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/"+branch+"/";
const state={s:null,i:null,tab:"overview",query:"",featureStatus:"all",featureGroup:"all",buildingState:"all",itemsGroup:"medicine",itemMode:"all",page:1,pageSize:30,moduleFilter:"all"};
const $=id=>document.getElementById(id);
const fmt=x=>Number(x).toLocaleString("vi-VN");
const esc=s=>String(s==null?"":s).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
const normal=s=>String(s||"").toLocaleLowerCase("vi-VN").normalize("NFD").replace(/[\u0300-\u036f]/g,"").replace(/đ/g,"d");
const link=(path,name,line=0)=>path?'<a class="ga-row-link" target="_blank" rel="noopener" href="'+GH+esc(path)+(line?"#L"+line:"")+'">'+esc(name||"Xem mã nguồn")+'</a>':"—";
function alert(text,green=false){return '<div class="ga-alert'+(green?" green":"")+'">'+text+'</div>';}
function panel(title,desc,body){return '<section class="ga-panel"><header><h2>'+esc(title)+'</h2><p>'+esc(desc||"")+'</p></header><div class="ga-body">'+body+'</div></section>';}
function summary(label,num,desc){return '<div class="ga-stat"><strong>'+esc(num)+'</strong><label>'+esc(label)+'</label><small>'+esc(desc||"")+'</small></div>';}
function table(head,rows){return '<div class="ga-table-wrap"><table class="ga-table"><thead><tr>'+head.map(x=>'<th>'+esc(x)+'</th>').join("")+'</tr></thead><tbody>'+rows.map(r=>'<tr>'+r.map(x=>'<td>'+x+'</td>').join("")+'</tr>').join("")+'</tbody></table></div>';}
function selector(id,opts,value){return '<select id="'+id+'">'+opts.map(o=>'<option value="'+esc(o[0])+'"'+(String(o[0])===String(value)?' selected':'')+'>'+esc(o[1])+'</option>').join("")+'</select>';}
function metric(n,label,desc){return '<div>'+summary(label,fmt(n),desc)+'</div>';}
function chip(label,sty="warn"){return '<span class="ga-chip '+sty+'">'+esc(label)+'</span>';}
function readable(status){
 const dict={
 CODE_PRESENT_PARTIAL:["Có mã một phần","warn"],
 CODE_PRESENT_GATED:["Có mã — cổng đang khóa","off"],
 CODE_PRESENT_QA_PENDING:["Có mã — còn QA","warn"],
 IDENTITY_ONLY:["Mới có dữ liệu nhân vật","off"],
 DESIGN_ONLY:["Chỉ có thiết kế V2","plan"],
 DESIGN_DEFERRED:["Thiết kế hoãn thực hiện","plan"],
 CATALOG_PARTIAL:["Có danh mục, thiếu nguồn sử dụng","warn"],
 PROPOSED_NOT_APPROVED:["Mới đề xuất — chưa duyệt","plan"],
 ART_PARTIAL:["Mỹ thuật chưa nghiệm thu toàn bộ","warn"],
 DEVICE_QA_PENDING:["QA máy thực chưa hoàn thành","off"]
 };
 return dict[status]||[status,"grey"];
}
function statChip(status){const q=readable(status);return chip(q[0],q[1]);}
const itemGroups=[
 ["medicine","Đan dược (476 mã)"],["nativeResources","Tài nguyên nền (34)"],
 ["archiveItems","Vật phẩm Bí Kíp V6.3 (154)"],["codices","Bí Kíp/Điển tịch (159)"],
 ["techniques","Công pháp V6.3 (84)"],["legacyEquipment","Công thức trang bị cũ (5)"],
 ["crops","Cây trồng (3)"],["legacyAlchemyRecipes","Công thức đan cũ (2)"]
];
function tabs(){return '<div class="ga-tabs" role="group" aria-label="Các phần kiểm kê">'+[
 ["overview","Tổng quan"],["features","Chức năng"],["buildings","Công trình"],["equipment","Trang bị & đồ bộ"],["items","Vật phẩm & đan"],["coverage","Mã nguồn & QA"]
 ].map(x=>'<button class="ga-tab'+(state.tab===x[0]?" active":"")+'" data-audit-tab="'+x[0]+'">'+x[1]+'</button>').join("")+'</div>';}
function overview(){
 const d=state.s.summary,it=state.i.summary;
 const critical=[
 ["Trang bị V2","Thiết kế 10 ô, 12 phẩm, 24 bộ; mã trang bị cũ chỉ 3 ô, 3 phẩm, 5 công thức.","equipment"],
 ["Công trình","Có 26 loại trong cây thiết kế dài hạn. Chỉ 6 trùng định nghĩa BuildingSystem; thêm 2 công trình code riêng. 20 chưa đăng ký.","buildings"],
 ["Đan dược","Có "+it.medicineItems+" mã nhưng chỉ "+it.medicineItemVariantsWithAuthoredFamilyRealm+" biến thể thuộc 8 họ/cảnh giới đã có công thức; phần còn lại thiếu.","items"],
 ["101 đặc tính","Có ID và trọng số sinh; chưa có xác minh hiệu ứng V2 thực tế theo từng đặc tính.","features"],
 ["V6.3","Catalog Bí Kíp/technique và cổng combat đang OFF mặc định, không phải tất cả đã live.","features"],
 ["Vật liệu SX-07B","630 mã vật liệu dự kiến, mới 11 mã thuộc phạm vi đó đăng ký; 270 tuyến nguồn vẫn là thiết kế.","items"],
 ["QA thực tế","Bài kiểm thử source không thay thế chạy thử Godot đúng SHA và nghiệm thu Windows/Android.","coverage"]
 ];
 const blocks=critical.map(x=>'<button class="item-button" data-audit-tab="'+x[2]+'"><span><b>'+esc(x[0])+'</b><small>'+esc(x[1])+'</small></span><span class="tip">Mở →</span></button>').join("");
 return '<div class="ga-grid">'+
 summary("Hạng mục được rà",d.featureChecklist,"Kiểm kê thiết kế & code")+
 summary("Loại công trình trong thiết kế",d.designedBuildingTypes,"Trong đó "+d.designNotRegistered+" chưa đăng ký BuildingSystem")+
 summary("Mã đan dược",it.medicineItems,"Không đồng nghĩa đều luyện được")+
 summary("Mô-đun mô phỏng",d.sourceModules,fmt(d.sourceSimulationGd)+" tập tin mã Godot")+'</div>'+
 alert('<b>Phạm vi:</b> kiểm toán tĩnh dựa trên mã nguồn và tài liệu hiện có trên PR #72. Chưa thực hiện kiểm thử tương tác Godot/Windows/Android cho từng chức năng trong lần rà soát này; các mục có source chỉ được đánh dấu <b>có mã</b>, không gắn nhãn hoàn thành.')+
 panel("Những lỗ hổng cần xử lý trước","Các mục thiết kế nhưng chưa có đường gameplay hoàn chỉnh.",'<div class="ga-two">'+blocks+'</div>')+
 panel("Các con số cần hiểu đúng","Không cộng các danh mục khác loại thành số vật phẩm chơi được.",
 '<div class="ga-mini-grid"><div><strong>'+it.nativeResources+'</strong><small>Tài nguyên cơ bản có đăng ký</small></div><div><strong>'+it.archiveItems+'</strong><small>Vật phẩm kho V6.3 có ID nhưng gate OFF</small></div><div><strong>'+it.codices+'</strong><small>Bí Kíp lưu trữ định danh</small></div><div><strong>'+it.learningTechniques+'</strong><small>Công pháp V6.3, catalog OFF</small></div><div><strong>'+d.plannedSetFamilies+'</strong><small>Bộ trang bị V2, thiết kế chưa code</small></div><div><strong>'+it.crops+'</strong><small>Cây trồng có định nghĩa</small></div></div>')+
 panel("Đọc theo chu trình game thực","Mỗi hệ cần qua đủ các cổng, không thể chỉ kiểm tra số dòng code.",
 '<div class="ga-two">'+[
 ["1","Thiết kế có công thức","Định nghĩa điều kiện, chi phí và kết quả"],
 ["2","Mã nguồn và định danh","Đúng ID; có mã nghiệp vụ, không chỉ catalog"],
 ["3","Kết nối nơi sử dụng","Thực sự thay đổi EXP, HP, vật phẩm hoặc hàng tồn"],
 ["4","Kiểm thử và lưu tải","Chứng minh trước/sau, Save/Reload, cổng bật/tắt"],
 ["5","Giao diện và thiết bị","Người chơi click được và thấy kết quả trên Windows/Android"],
 ["6","Duyệt phát hành","Chỉ xác nhận PASS khi có bằng chứng đúng mã Git"]
 ].map(x=>'<div class="ga-step"><span class="ga-step-num">'+x[0]+'</span><div><b>'+x[1]+'</b>'+x[2]+'</div></div>').join("")+'</div>')+
 panel("Còn gì chưa được kiểm chứng?","Giới hạn của đợt audit này",
 alert('Chưa chạy các kịch bản nhân vật, công trình, vật phẩm và chiến đấu end-to-end trong Godot 4.7.2 tại HEAD hiện hành. Chưa thẩm định mỗi asset VFX, tỉ lệ farm, giá cân bằng hay mọi script/prefab riêng lẻ; các mô-đun và danh mục hiển thị đủ phạm vi mã nguồn để tiếp tục kiểm toán có hướng đích. Các trạng thái là mức chứng cứ, không phải tỷ lệ hoàn thành phần trăm.'));
}
function featureCard(x){
 return '<article class="ga-card"><h3>'+esc(x.name)+'</h3><div class="ga-meta">'+esc(x.category)+' · '+esc(x.id)+'</div>'+statChip(x.status)+
 '<p>'+esc(x.finding)+'</p>'+
 '<details><summary>Xem mã, thiết kế và việc kiểm thử</summary>'+
 '<p>'+link(x.codeSource,"Mã nghiệp vụ (hoặc mã nền)")+' · '+link(x.designSource,"Thiết kế/authority")+'</p>'+
 '<p class="ga-note"><b>Chưa có chứng cứ chạy thật ở HEAD trong audit:</b> '+(x.status==="DESIGN_ONLY"||x.status==="DESIGN_DEFERRED"?"Chỉ có tài liệu, không gọi là code V2 hoàn thành.":"Cần đối chiếu consumer, source test, Save/Reload và runtime kết quả thực tế.")+'</p></details></article>';
}
function features(){
 const d=state.s;
 const groupOpts=[["all","Tất cả hệ"]].concat([...new Set(d.features.map(x=>x.category))].sort().map(x=>[x,x]));
 const statusOpts=[["all","Tất cả trạng thái"]].concat([...new Set(d.features.map(x=>x.status))].sort().map(s=>[s,readable(s)[0]]));
 const q=normal(state.query);
 const rows=d.features.filter(x=>(state.featureStatus==="all"||x.status===state.featureStatus)&&(state.featureGroup==="all"||x.category===state.featureGroup)&&(!q||normal(x.name+" "+x.finding+" "+x.id).includes(q)));
 return '<div class="ga-grid">'+summary("Toàn bộ hạng mục",d.features.length,"Có evidence thiết kế/mã")+
 summary("Có mã một phần",d.features.filter(x=>x.status==="CODE_PRESENT_PARTIAL").length,"Không có nghĩa đã PASS")+
 summary("Có mã nhưng gate OFF",d.features.filter(x=>x.status==="CODE_PRESENT_GATED").length,"Chưa mở mặc định")+
 summary("Chỉ thiết kế, hoãn hoặc đề xuất",d.features.filter(x=>["DESIGN_ONLY","DESIGN_DEFERRED","PROPOSED_NOT_APPROVED"].includes(x.status)).length,"Chưa thành gameplay")+'</div>'+
 '<div class="ga-filters"><label>Trạng thái'+selector("ga-feature-status",statusOpts,state.featureStatus)+'</label><label>Nhóm'+selector("ga-feature-group",groupOpts,state.featureGroup)+'</label></div>'+
 '<p class="ga-compact">'+rows.length+'/'+d.features.length+' hạng mục phù hợp. Dùng ô tìm kiếm ở góc trên để tìm thêm.</p>'+
 '<div class="ga-rows">'+(rows.map(featureCard).join("")||'<div class="ga-card">Không có kết quả.</div>')+'</div>';
}
function buildings(){
 const d=state.s;const statusOptions=[["all","Tất cả"],["REGISTERED_BUILDING","Đã đăng ký công trình"],["NOT_REGISTERED_AS_BUILDING","Chỉ có trong cây thiết kế"],["UPGRADE_BLOCKED","Nâng cấp bị chặn"],["UPGRADE_GATED_20","Nâng cấp giới hạn"]];
 const q=normal(state.query);
 const rows=d.buildings.filter(x=>(state.buildingState==="all"||state.buildingState==="UPGRADE_BLOCKED"&&x.upgradeStatus==="UPGRADE_BLOCKED"||state.buildingState==="UPGRADE_GATED_20"&&x.upgradeStatus==="UPGRADE_GATED_20"||x.codeStatus===state.buildingState)&&(!q||normal(x.name+" "+x.summary+" "+x.id).includes(q)));
 return '<div class="ga-grid">'+summary("Loại trong thiết kế dài hạn",d.summary.designedBuildingTypes,"Chưa phải công trình chạy")+
 summary("Loại đã đăng ký vào game",d.summary.registeredBuildingTypes,"Bao gồm 2 loại ngoài cây thiết kế")+
 summary("Thiết kế nhưng chưa đăng ký",d.summary.designNotRegistered,"Chưa có công trình để xây/nâng")+
 summary("Điểm chặn nâng cấp rõ ràng",2,"Rèn Thân, Dẫn Tiên")+'</div>'+
 alert("Sự khác biệt: <b>Kho Tông Môn</b> có hệ lưu trữ WarehouseSystem nhưng <b>chưa được đăng ký như một công trình nâng cấp</b>. Các công trình có <code>max_level:100</code> vẫn có thể bị chặn bởi nguyên liệu, Đại Điện, mốc hoặc cổng chưa hoàn thiện.")+
 '<div class="ga-filters"><label>Lọc công trình'+selector("ga-building-status",statusOptions,state.buildingState)+'</label></div>'+
 '<div class="ga-rows">'+(rows.map(x=>'<article class="ga-card"><h3>'+esc(x.name)+'</h3><div class="ga-meta">'+esc(x.id)+'</div>'+
 (x.codeStatus==="REGISTERED_BUILDING"?chip("Có loại công trình trong code","neutral"):chip("Chỉ thiết kế — không có loại building trong code","plan"))+
 (x.upgradeStatus==="UPGRADE_BLOCKED"?chip("Không được nâng cấp","off"):x.upgradeStatus==="UPGRADE_GATED_20"?chip("Bị chặn sau Lv20","off"):x.codeStatus==="REGISTERED_BUILDING"?chip("Có cơ chế nâng cấp có điều kiện","warn"):"")+
 '<p>'+esc(x.summary)+'</p>'+
 '<details><summary>Việc còn thiếu & nguồn gốc</summary><p>'+esc(x.upgradeNote)+'</p><p>'+link(x.designSource,"Trang thiết kế",x.designLine)+' · '+(x.runtimePath?link(x.runtimePath,"Mã công trình"):"Chưa đăng ký loại công trình trong BuildingSystem")+'</p></details></article>').join("")||'<div class="ga-card">Không có kết quả.</div>')+'</div>';
}
function statName(key){return ({combat_power:"Sức chiến đấu",skill_effect:"Hiệu quả kỹ năng",basic_speed:"Tốc đánh thường",basic_ratio:"Hệ số đòn thường",defense_reduction:"Giảm sát thương nhận",basic_range:"Tầm cơ bản",move_speed:"Tốc di chuyển"})[key]||key;}
function equipment(){
 const d=state.s,it=state.i;
 const slots=["Vũ khí","Mũ","Giáp","Phi phong","Hộ uyển","Thủ sáo","Đai lưng","Giày","Ngọc bội","Nhẫn"];
 const gearTable=table(["Trang bị cũ","Ô/Phân loại","Nguyên liệu","Chỉ số nền"],it.legacyEquipment.map(x=>['<b>'+esc(x.name)+'</b><span class="ga-id">'+esc(x.id)+'</span>',esc(x.slot),Object.entries(x.materials).map(([k,v])=>esc(k)+": "+fmt(v)).join(", "),Object.entries(x.stats).map(([k,v])=>esc(statName(k))+": "+(["combat_power","basic_range"].includes(k)?fmt(v):fmt(v*100)+"%")).join("; ")]));
 return '<div class="ga-grid">'+summary("V2 thiết kế vị trí thường",10,"Còn 3 phù & 2 pháp bảo riêng")+
 summary("V2 thiết kế phẩm chất",12,"Chưa có 12 phẩm trong code cũ")+
 summary("Bộ trang bị V2",24,"Thiết kế 96 mảnh vị trí")+
 summary("Công thức trang bị trong code",5,"Chỉ thuộc hệ cũ, 3 ô")+'</div>'+
 alert("<b>Khoảng cách thiết kế/code:</b> trang bị V2 có <b>10 ô thông thường + 3 ô Phù + 2 ô Pháp Bảo</b>; EquipmentSystem cũ mới có <b>weapon, armor, talisman</b> và 3 cấp chất lượng. Không được trình bày 10 ô hoặc 24 bộ là đã chơi được.")+
 panel("5 công thức rèn đã có mã nghiệp vụ","Có craft/equip/unequip và hệ số chất lượng cũ; QA trên HEAD hiện hành chưa được xác minh.",gearTable+link("godot/src/simulation/equipment/equipment_system.gd","Mã EquipmentSystem"))+
 panel("Trang bị V2 — phần chưa được hiện thực","Cấu trúc đã được duyệt, không đồng nghĩa có trong game.",
 '<p><b>10 ô thường:</b> '+slots.join(", ")+'.</p><p><b>12 phẩm:</b> Phàm, Tinh, Thượng, Cực, Linh, Huyền, Địa, Thiên, Vương, Thánh, Đế, Chí Tôn.</p>'+
 alert("<b>Còn thiếu:</b> chuyển Save/Load từ 3 ô lên 10 ô; nguyên liệu rèn thật và thời gian chế tạo; phẩm 4–12; chỉ số phụ/Chân Văn; cường hóa, tinh luyện, thăng phẩm, kế thừa, phân giải; set bonus 2/3/4; trang bị tự động tôn trọng bộ.")+
 link("docs/WEAPON_EQUIPMENT_V2_SPEC.md","Thiết kế 10 ô & 12 phẩm")+' · '+link("docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md","Lộ trình nâng cấp chưa làm"))+
 panel("24 bộ trang bị — đang ở mức thiết kế","18 bộ chiến đấu và 6 bộ nghề nghiệp. Mỗi bộ có 4 mảnh và mốc 2/3/4; hiệu ứng chưa có consumer live.",
 table(["Bộ trang bị","Nhóm","Số mảnh/mốc","Hiện trạng"],d.setFamilies.map(x=>['<b>'+esc(x.name)+'</b>',esc(x.group),"4 mảnh; mốc 2/3/4",chip("Chưa triển khai V2","plan")]))+
 link("docs/EQUIPMENT_SETS_V2_SPEC.md","Ma trận 24 bộ/96 mảnh"));
}
function itemList(){
 const d=state.i, group=state.itemsGroup;
 let items=d[group]||[];
 const q=normal(state.query);
 const filtered=items.filter(x=>(!q||normal(x.name+" "+x.id+" "+(x.family||x.kind||x.school||x.source||"")).includes(q))&&
 (state.itemMode==="all"||
 (state.itemMode==="authored"&&((group==="medicine"&&x.hasRecipe)||group==="legacyEquipment"||group==="crops"||group==="legacyAlchemyRecipes"))||
 (state.itemMode==="unavailable"&&((group==="medicine"&&!x.hasRecipe)||["archiveItems","codices","techniques"].includes(group)))));
 const maxPages=Math.max(1,Math.ceil(filtered.length/state.pageSize));if(state.page>maxPages)state.page=maxPages;
 const start=(state.page-1)*state.pageSize;
 const shown=filtered.slice(start,start+state.pageSize);
 const kind=x=>({
 medicine:x.hasRecipe?chip("Có họ/cảnh giới đã viết công thức","warn"):chip("Chưa có công thức cấp này","off"),
 archiveItems:chip("Catalog V6.3 OFF — chưa có tỷ lệ rơi","off"),
 codices:chip("Định danh Bí Kíp — catalog OFF","off"),
 techniques:chip("Công pháp V6.3 — học OFF","off"),
 nativeResources:chip("Đã đăng ký — nguồn farm cần đối chiếu","warn"),
 crops:chip("Có mã gieo trồng (QA chưa xác nhận)","warn"),
 legacyEquipment:chip("Có mã rèn hệ cũ","warn"),
 legacyAlchemyRecipes:chip("Có công thức đan hệ cũ","warn")
 })[group];
 function desc(x){
  if(group==="medicine")return esc(x.family==="break"?"Cộng "+x.potency+" điểm % khi đột phá":(x.family==="heal"?"Hồi phục":x.family==="body"?"EXP Luyện Thể":"EXP Tu Vi")+" "+fmt(x.potency))+" · "+(x.hasRecipe?"Công thức cấp 1–2 có trong mã; điều kiện chế tạo/đạt Q cần xác minh":"Chưa có recipe_definition")+
  ' · '+kind(x);
  if(group==="archiveItems")return esc(x.kind+" · "+(x.tier||""))+" · "+kind(x);
  if(group==="codices")return esc((x.school||"")+" · "+(x.generation||""))+" · "+kind(x);
  if(group==="techniques")return esc((x.school||"")+" · "+(x.generation||""))+" · "+kind(x);
  if(group==="nativeResources")return esc("Nhóm "+x.family+"; bậc "+x.realmRank)+" · "+kind(x);
  if(group==="legacyEquipment")return esc("Ô "+x.slot+"; vật liệu: "+Object.entries(x.materials||{}).map(([k,v])=>k+" ×"+v).join(", "))+" · "+kind(x);
  if(group==="crops")return esc("Linh Điền cấp "+x.fieldLevel+"; gieo "+x.plantCost+" linh thạch; thu "+x.baseYield+" / "+x.baseCycleTicks+" ticks")+" · "+kind(x);
  return kind(x);
 }
 const rows=shown.map(x=>['<b>'+esc(x.name)+'</b><span class="ga-id">'+esc(x.id)+'</span>',desc(x),link(x.source||d.sources[group]||"","Nguồn")]);
 const firstKey=group==="medicine"?d.sources.medicine:group==="nativeResources"?d.sources.resource:group==="legacyEquipment"?d.sources.equipment:group==="archiveItems"||group==="codices"?d.sources.archive:group==="techniques"?d.sources.learning:group==="crops"?d.sources.crop:d.sources.alchemy;
 const results=shown.map(x=>['<b>'+esc(x.name)+'</b><span class="ga-id">'+esc(x.id)+'</span>',desc(x),link(x.source||firstKey,"Mã nguồn")]);
 const pager='<div class="ga-pagination"><span>'+fmt(filtered.length)+' / '+fmt(items.length)+' mục · Trang '+state.page+'/'+maxPages+'</span><div><button id="ga-prev"'+(state.page===1?" disabled":"")+'>Trang trước</button> <button id="ga-next"'+(state.page===maxPages?" disabled":"")+'>Trang sau</button></div></div>';
 return '<div class="ga-grid">'+summary("Tài nguyên nền",d.summary.nativeResources,"Không suy ra đủ nguồn rơi")+
 summary("Đan dược",d.summary.medicineItems,"Chỉ "+d.summary.medicineItemVariantsWithAuthoredFamilyRealm+" biến thể thuộc công thức đã viết")+
 summary("Vật phẩm kho V6.3",d.summary.archiveItems,"Catalog chưa bật")+
 summary("Công pháp V6.3",d.summary.learningTechniques,"Catalog chưa bật")+'</div>'+
 alert('<b>Lưu ý:</b> 476 định danh đan có thể tính hiệu lực theo mã; chỉ 8 cặp <b>họ đan–cảnh giới</b> (32 biến thể phẩm) có định nghĩa công thức cấp 1–2. <b>444 mã còn lại không có recipe_definition.</b> Có mã ≠ chế được; có công thức ≠ bảo đảm đủ nguồn nguyên liệu, chọn đúng phẩm, hoặc nút UI hoạt động.')+
 alert('<b>Lỗ hổng vật liệu V5.5-D/SX07B:</b> 630 ô vật liệu trong thiết kế, mới <b>11/630</b> thuộc phạm vi đó được đăng ký. <b>619</b> chưa đăng ký (112 ID được giữ từ tài liệu gốc, 507 mới đề xuất/chưa xác minh). <b>270 tuyến nguồn</b> vẫn ở dạng bảng thiết kế, không được coi là điểm farm live. '+link("docs/qa/SX07B_PRESERVED_MATERIALS_SOURCE_GATE_20261109.md","Nguồn SX-07B")+'.')+
 '<div class="ga-filters"><label>Danh mục'+selector("ga-item-group",itemGroups,state.itemsGroup)+'</label>'+
 '<label>Trạng thái'+selector("ga-item-mode",[["all","Tất cả"],["authored","Có công thức/nguồn viết mã"],["unavailable","Chưa có công thức hoặc gate OFF"]],state.itemMode)+'</label></div>'+
 pager+table(["Tên / định danh","Dữ liệu và trạng thái","Căn cứ"],results)+pager;
}
function coverage(){
 const s=state.s;
 const modOpts=[["all","Tất cả 24 mô-đun"]].concat(s.modules.map(x=>[x.id,x.name]));
 const list=s.modules.filter(x=>state.moduleFilter==="all"||state.moduleFilter===x.id);
 const moduleRows=list.map(x=>[
 '<b>'+esc(x.name)+'</b><span class="ga-id">'+esc(x.id)+'</span>',fmt(x.sourceFiles),
 String(x.testsByFilename)+" (chỉ trùng tên thư mục, không phải PASS)",
 '<details><summary style="color:#176a63;cursor:pointer">Xem mã và thiết kế</summary><div class="ga-compact">'+
 x.sources.slice(0,15).map(path=>'<div>'+link(path,path.split("/").pop())+'</div>').join("")+
 (x.sources.length>15?'<div>... còn '+(x.sources.length-15)+' file nữa</div>':'')+'</div><p>'+link(x.spec,"Spec/authority")+'</p></details>'
 ]);
 return '<div class="ga-grid">'+summary("Nhóm mô phỏng",s.summary.sourceModules,"Bao phủ thư mục simulation")+
 summary("Tập tin simulation .gd",s.summary.sourceSimulationGd,"Chỉ là số mã nguồn")+
 summary("Tập tin test Godot .gd",s.summary.testGdFiles,"Không tự suy ra test xanh")+
 summary("Tập tin trong repository",s.summary.allRepositoryFiles,"Bao gồm cả nội dung nghệ thuật, docs, QA")+'</div>'+
 alert("<b>Cảnh báo kiểm toán:</b> cột test chỉ đếm file trùng tên thư mục, không khẳng định test đã chạy hay đi qua chức năng thật. Audit này không gán PASS cho runtime chỉ nhờ tồn tại mã, CI cũ, tài liệu hoặc asset.")+
 '<div class="ga-filters"><label>Lọc hệ mã nguồn'+selector("ga-module-filter",modOpts,state.moduleFilter)+'</label></div>'+
 panel("Bản đồ mã mô phỏng","Dùng để phát hiện nhánh có thiết kế nhưng thiếu consumer, test, UI và nguồn dữ liệu.",table(["Hệ mô phỏng","Số tệp .gd","Tệp test cùng tên","Chi tiết"],moduleRows))+
 panel("Yêu cầu để gắn nhãn hoàn thành","Các việc QA tiếp theo theo đúng phạm vi",
 '<div class="ga-two">'+[
 ["Người chơi thấy được","Mở được màn, có nút/hành động hợp lệ; thông số thay đổi đúng và bấm được"],
 ["Nguồn vật phẩm thật","Có nơi rơi, trồng, đào, chế tạo hoặc giao dịch; đúng cấp & nguyên liệu"],
 ["Trước/sau rõ ràng","EXP, HP, vật phẩm, thu hoạch, sát thương thay đổi khi có và không có hiệu ứng"],
 ["Mã đúng và cổng bật","Feature flags, tương thích dữ liệu cũ, không sinh item giả"],
 ["Save/Reload/Anti-duplication","Nâng cấp/tạo item/đột phá không trừ hai lần, không roll lại"],
 ["Máy thật & bản phát hành","Exact SHA, Windows/Android, hiệu năng và QA thị giác; owner phê duyệt"]
 ].map((x,i)=>'<div class="ga-step"><span class="ga-step-num">'+(i+1)+'</span><div><b>'+x[0]+'</b>'+x[1]+'</div></div>').join("")+'</div>')+
 panel("Nguồn chính","Tập hợp đường dẫn rà soát",
 s.sources.map(x=>'<p>'+link(x,x)+'</p>').join("")+
 '<p>'+link("docs/DISCIPLE_V2_EFFECT_SOURCE_MATRIX.md","Ma trận đặc tính V2")+'</p>'+
 '<p>'+link("godot/src/simulation/combat/v63_feature_gates.gd","Các cổng V6.3")+'</p>');
}
function redraw(){
 const body={overview,features,buildings,equipment,items:itemList,coverage};
 $("audit-root").innerHTML=tabs()+(body[state.tab]||overview)();
}
function openTab(tab){state.tab=tab;state.page=1;history.replaceState(null,"","#"+tab);redraw();window.scrollTo({top:0,behavior:"instant"});}
document.getElementById("menu-toggle").addEventListener("click",()=>document.getElementById("sidebar").classList.toggle("open"));
document.addEventListener("click",e=>{
 const el=e.target.closest("[data-audit-tab]");if(el){openTab(el.dataset.auditTab);return;}
 if(e.target.id==="ga-prev"){state.page=Math.max(1,state.page-1);redraw();return;}
 if(e.target.id==="ga-next"){state.page++;redraw();}
});
document.addEventListener("change",e=>{
 const keys={"ga-feature-status":"featureStatus","ga-feature-group":"featureGroup","ga-building-status":"buildingState","ga-item-group":"itemsGroup","ga-item-mode":"itemMode","ga-module-filter":"moduleFilter"};
 let k=keys[e.target.id];if(k){state[k]=e.target.value;state.page=1;redraw();}
});
$("global-search").addEventListener("input",e=>{state.query=e.target.value;state.page=1;redraw();});
const site=["localhost","127.0.0.1","::1","vuanhtuan161094-byte.github.io"];
if(!site.includes(location.hostname)){$("audit-root").innerHTML=alert("Chỉ mở trang này qua GitHub Pages chính thức hoặc localhost hợp lệ.");return;}
Promise.all(["./data/game_system_audit.json","./data/game_items_audit.json"].map(path=>fetch(path,{cache:"no-store"}).then(r=>{if(!r.ok)throw Error(path+" HTTP "+r.status);return r.json();}))).then(([s,i])=>{
 if(s.summary.sourceModules!==24||s.summary.featureChecklist!==49||s.buildings.length!==28||s.setFamilies.length!==24||i.summary.medicineItems!==476||i.summary.nativeResources!==34||i.summary.archiveItems!==154||i.summary.legacyEquipmentRecipes!==5)throw Error("Thiếu dữ liệu kiểm toán; vui lòng kiểm tra bản triển khai.");
 state.s=s;state.i=i;const tab=location.hash.slice(1);if(["overview","features","buildings","equipment","items","coverage"].includes(tab))state.tab=tab;redraw();
}).catch(e=>$("audit-root").innerHTML=alert("Không tải được bảng kiểm kê: "+esc(e.message)));
})();