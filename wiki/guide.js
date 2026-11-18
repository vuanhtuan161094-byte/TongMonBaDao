(() => {
"use strict";
const ROOT="https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/integration/pve-p0-playable-ui-20261103/";
const TOTAL=[10000000,12700000,16200000,20500000,26000000,33000000,42000000,53300000,67700000,86000000,109200000,138700000,176000000,223700000,284000000,360700000,458000000,581700000,738700000,938200000,1191500000,1513200000,1921700000,2440500000,3099500000,3936300000,4999200000,6349000000,8063200000,10240200000];
const WEIGHTS=[700,750,800,850,900,1000,1100,1200,1300,1400];
const Q1=[1166,1234,1334,1435,1516,1593,1729,1865,1974,2075,2184,2311,2464,2609,2761,2935,3112,3283,3470,3668,3879,4105,4339,4592,4864,5150,5450,5771,6108,6463];
const BUILDINGS=[
{id:"main_hall",name:"Tông Môn Đại Điện",wood:25,ore:20,stone:500,workers:0,step:0,max:100,desc:"Trung tâm điều hành tông môn. Cấp Đại Điện còn giới hạn cấp nâng của công trình khác."},
{id:"residence",name:"Đệ Tử Xá",wood:35,ore:25,stone:500,workers:0,step:0,max:100,desc:"Nơi ở của đệ tử; liên quan sức chứa và quản lý cư trú."},
{id:"mine",name:"Mỏ Linh Khoáng",wood:4,ore:6,stone:20,workers:2,step:5,max:100,desc:"Đào quặng và chuyển về kho; có thể mở quặng Huyền Thiết ở cấp 10."},
{id:"linh_forest",name:"Linh Lâm",wood:4,ore:6,stone:20,workers:2,step:5,max:100,desc:"Khai thác linh mộc qua chu kỳ làm việc và vận chuyển."},
{id:"alchemy_hall",name:"Luyện Đan Điện",wood:6,ore:4,stone:12,workers:2,step:10,max:100,desc:"Chế tạo đan dược từ công thức đã mở và nguyên liệu thực có."},
{id:"spirit_field",name:"Linh Điền",wood:6,ore:3,stone:18,workers:4,step:5,max:100,desc:"Trồng linh thảo, linh cốc, thu hoạch và cất vào kho. Cây trồng mở theo cấp."},
{id:"ren_than_duong",name:"Rèn Thân Đường",wood:null,ore:null,stone:null,workers:2,step:0,max:100,desc:"Cơ sở hỗ trợ luyện thể. Nội dung giá nâng cấp chưa được phê duyệt."},
{id:"dan_tien_dai",name:"Dẫn Tiên Đài",wood:5,ore:4,stone:24,workers:0,step:0,max:100,desc:"Tiếp đón đệ tử. Nâng quá cấp 20 hiện còn bị chặn bởi điều kiện thiết kế."}
];
const CROPS=[
{name:"Thanh Linh Thảo",id:"thanh_linh_thao",lv:1,stone:4,ticks:12,yield:3,aff:"Mộc, Thủy",tag:"Luyện đan"},
{name:"Linh Cốc",id:"linh_coc",lv:1,stone:3,ticks:10,yield:5,aff:"Thổ, Thủy",tag:"Lương thực"},
{name:"Tử Vân Thảo",id:"tu_van_thao",lv:10,stone:14,ticks:24,yield:3,aff:"Mộc",tag:"Dược liệu cao cấp"}
];
const EQUIP=[
{name:"Thanh Thiết Kiếm",slot:"Vũ khí",mats:"3 Thanh Thiết + 1 Linh Mộc",bonus:"Sức chiến đấu +6; hiệu quả kỹ năng +10%; tốc đánh cơ bản +8%; hệ số đòn đánh +5%"},
{name:"Huyền Thiết Quyền Sáo",slot:"Vũ khí",mats:"3 Thanh Thiết + 1 Tinh Lang Bì",bonus:"Sức chiến đấu +5,5; hiệu quả kỹ năng +11%; giảm phòng thủ +4%; hệ số đòn đánh +9%"},
{name:"Linh Mộc Pháp Trượng",slot:"Vũ khí",mats:"3 Linh Mộc + 1 Yêu Đan",bonus:"Sức chiến đấu +4,5; hiệu quả kỹ năng +13%; tầm đánh cơ bản +0,45"},
{name:"Tinh Lang Giáp",slot:"Áo giáp",mats:"3 Tinh Lang Bì + 1 Thanh Thiết",bonus:"Sức chiến đấu +1,5; giảm sát thương phòng thủ +12%; tốc di chuyển −3%"},
{name:"Hỏa Vân Ngọc",slot:"Pháp bảo",mats:"2 Yêu Đan + 1 Linh Mộc",bonus:"Sức chiến đấu +2; hiệu quả kỹ năng +16%; tầm đánh cơ bản +0,2"}
];
const bodyGroups={A:["Thanh Linh Thảo","Tinh Lang Bì"],B:["Tử Vân Thảo","Linh Tủy"],C:["Huyết Linh Sâm","Huyết Thú Tinh Huyết"],D:["Kim Cốt Thảo","Linh Thú Cốt Ngọc"],E:["Tiên Tủy Liên","Tiên Thú Chân Cốt"],F:["Bất Hoại Tủy Dịch","Đại La Kim Cốt"],G:["Thần Mạch Tinh","Thần Thú Cốt"],H:["Hỗn Độn Tủy Hoa","Bất Diệt Thần Cốt"]};
const bodyRows=[["A",12,4],["A",18,5],["A",24,6],["B",12,1],["B",16,2],["B",24,3],["C",12,3],["C",16,4],["C",22,6],["C",32,8],["D",12,3],["D",16,4],["D",20,5],["D",24,6],["E",12,3],["E",16,4],["E",22,6],["F",14,4],["F",20,6],["F",30,9],["G",12,3],["G",16,4],["G",20,5],["G",24,6],["G",30,8],["H",12,3],["H",18,5],["H",24,7],["H",32,10]];
const state={data:null,tab:"home",realm:2,track:"cultivation",building:"spirit_field",buildingLevel:1,fieldLevel:1,school:"all",skill:null,limit:48,query:""};
const names={home:"Tổng quan",realms:"Cảnh giới & tu luyện",skills:"Kỹ năng & sát thương",buildings:"Công trình",fields:"Linh Điền & cây trồng",medicine:"Đan dược & đột phá",equipment:"Trang bị",schools:"Môn phái & tài nguyên"};
const content=document.getElementById("content"),search=document.getElementById("search");
// Engineering Studio remains localhost-only and is intentionally excluded from Pages.
if(location.hostname==="vuanhtuan161094-byte.github.io"){document.querySelectorAll(".studio-link,.footer a").forEach(el=>{el.style.display="none";});}
const fmt=n=>Number(n).toLocaleString("vi-VN",{maximumFractionDigits:2});
const esc=s=>String(s==null?"":s).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
function source(path){return '<p class="source-note">Nguồn trong game: <a target="_blank" rel="noopener" href="'+ROOT+esc(path)+'">'+esc(path.split("/").pop())+'</a>. Số liệu là thiết kế/mã nguồn hiện tại, không tự chứng minh tính năng đã phát hành.</p>';}
function heading(kicker,title,sub){return '<div class="eyebrow">'+esc(kicker)+'</div><h1 class="title">'+esc(title)+'</h1><p class="lead">'+esc(sub)+'</p>';}
function panel(title,sub,body){return '<section class="panel"><div class="panel-head"><h2>'+esc(title)+'</h2><p>'+esc(sub||"")+'</p></div><div class="panel-body">'+body+'</div></section>';}
function metric(label,value,note){return '<div class="metric"><small>'+esc(label)+'</small><strong>'+esc(value)+'</strong><span>'+esc(note||"")+'</span></div>';}
function table(head,rows){return '<div class="table-scroll"><table><thead><tr>'+head.map(h=>'<th>'+esc(h)+'</th>').join("")+'</tr></thead><tbody>'+rows.map(row=>'<tr>'+row.map(c=>'<td>'+c+'</td>').join("")+'</tr>').join("")+'</tbody></table></div>';}
function select(id,opts,value){return '<select id="'+id+'">'+opts.map(o=>'<option value="'+esc(o[0])+'"'+(String(o[0])===String(value)?' selected':'')+'>'+esc(o[1])+'</option>').join("")+'</select>';}
function floorCosts(realm){let total=TOTAL[realm-1],out=[],sum=0;for(let i=0;i<9;i++){let v=Math.round((total*WEIGHTS[i]/10000)/10)*10;out.push(v);sum+=v;}out.push(total-sum);return out;}
function goto(tab){state.tab=tab;state.limit=48;history.replaceState(null,"","#"+tab);document.getElementById("sidebar").classList.remove("open");render();}
function home(){
  const quick=[["☯","Cảnh giới","EXP 300 tầng & đột phá","realms"],["✦","Kỹ năng","Hệ số damage, hồi chiêu, tầm đánh","skills"],["⌂","Công trình","Cấp, giá nâng cấp, chức năng","buildings"],["❧","Linh Điền","Hạt giống, năng suất, thời gian","fields"],["丹","Đan dược","Hỗ trợ tăng tu vi & đột phá","medicine"],["⚔","Trang bị","Nguyên liệu rèn và chỉ số","equipment"],["門","Môn phái","12 môn phái, 36 nhánh","schools"]];
  return '<section class="hero"><div class="eyebrow">Cẩm nang dành cho người chơi</div><h1 class="title">Tu luyện, xây dựng và xưng bá</h1><p>Tra cứu những gì cần để chơi: mỗi tầng tốn bao nhiêu EXP, đột phá cần gì, kỹ năng mạnh bao nhiêu, Linh Điền trồng được cây nào. Không cần biết thuật ngữ lập trình.</p><div class="hero-actions"><button data-tab="realms">Xem Luyện Khí →</button><button data-tab="fields" class="ghost">Xem Linh Điền →</button></div></section>'+
  '<div class="quick-grid">'+quick.map(x=>'<button class="quick" data-tab="'+x[3]+'"><span class="q-icon">'+x[0]+'</span><b>'+x[1]+'</b><small>'+x[2]+'</small></button>').join("")+'</div>'+
  panel("Bắt đầu từ đâu?","Một số câu hỏi thường gặp",'<div class="grid-2">'+[
  ['Muốn lên Luyện Khí tầng 2?','Cần 889.000 EXP. Từng tầng có yêu cầu riêng; vượt đại cảnh giới cần đột phá.','realms'],
  ['Muốn trồng Thanh Linh Thảo?','Linh Điền cấp 1 đã trồng được. Giá gieo 4 linh thạch/lượt.','fields'],
  ['Kỹ năng ghi 108% nghĩa là gì?','Đó là hệ số kỹ năng trong thiết kế, không có nghĩa trừ 108% máu đối thủ.','skills'],
  ['Nâng Linh Điền cần gì?','Chọn cấp đang có để xem số Linh Mộc, Thanh Thiết, linh thạch và vật liệu mốc.','buildings']
  ].map(x=>'<button class="item-button" data-tab="'+x[2]+'"><span><b>'+x[0]+'</b><small>'+x[1]+'</small></span><span class="tip">Xem →</span></button>').join("")+'</div>')+
  '<div class="note neutral">Chú ý: 2.196 kỹ năng của hệ V6.3 hiện là nội dung thiết kế <b>chưa kích hoạt</b>. Bách khoa hiển thị số liệu dự kiến nhưng không khẳng định chúng đã có thể sử dụng trong trận PvE.</div>';
}
function realms(){
  const realms=state.data?.realms||[];const r=state.realm,body=state.track==="body",row=realms[r-1]||{};const name=body?row.bodyName:row.cultivationName;const costs=floorCosts(r);
  const rs=realms.map((x,i)=>[i+1,(i+1)+". "+(body?x.bodyName:x.cultivationName)]);
  let items='Không bắt buộc dùng Đột Phá Đan. Có thể dùng đan đúng cảnh giới để tăng cơ hội thành công thêm 5 / 6 / 7 / 8 điểm %.';
  if(body&&r<30){const b=bodyRows[r-1],a=bodyGroups[b[0]];items='Điều kiện luyện thể trong bản thiết kế: '+b[1]+' '+a[0]+' và '+b[2]+' '+a[1]+'. Chưa xác minh là chức năng đang mở.';}
  if(r===30)items="Cảnh giới cuối trong bảng hiện tại, không có cửa đột phá lên cảnh giới thứ 31.";
  const requirement=body?'Luyện Thể: khi đủ EXP và điều kiện vật phẩm đã được xác minh thì vượt cảnh giới theo cơ chế chắc chắn; bản nội dung vật phẩm chưa mở đầy đủ.':'Tu Vi: đột phá cơ bản 25%; cùng cửa này, mỗi lần thất bại cộng thêm 5 điểm %. Thất bại mất 10% EXP ở tầng 10. Đột Phá Đan là tùy chọn.';
  return heading('CON ĐƯỜNG TU LUYỆN','Cảnh giới & đột phá','Xem EXP cần cho từng tầng, yêu cầu vượt cảnh giới và đan dược hỗ trợ.')+
   '<div class="controls"><label>Hệ tu luyện'+select("track-select",[["cultivation","Tu Vi"],["body","Luyện Thể"]],state.track)+'</label><label>Chọn cảnh giới'+select("realm-select",rs,r)+'</label></div>'+
   '<div class="grid-3">'+metric('Cảnh giới đang xem',name||'Cảnh giới '+r,'Thứ '+r+' trong 30 cảnh giới')+metric('Tổng EXP 10 tầng',fmt(TOTAL[r-1]),'Giống nhau ở hai hệ')+metric('EXP tầng 1 → 2',fmt(costs[0]),'EXP cần để qua tầng 1')+'</div>'+
   panel('Chi phí từng tầng — '+name,'Mỗi dòng là EXP cần để tiến từ tầng hiện tại sang tầng tiếp theo.',table(['Tầng hiện tại','Đích đến','EXP cần'],costs.map((x,i)=>['<b>Tầng '+(i+1)+'</b>',i===9?(r===30?'Cảnh giới cuối':'Cửa đột phá → cảnh giới kế tiếp'):'Tầng '+(i+2),'<b>'+fmt(x)+'</b>'])))+
   panel('Đột phá từ '+name, r<30?'Điều kiện sau khi đã tích đủ EXP tầng 10':'Cảnh giới tối đa','<div class="note">'+esc(requirement)+'</div><p><b>Vật phẩm cần / có thể sử dụng:</b> '+esc(items)+'</p>')+
   source('godot/src/simulation/cultivation/disciple_progression_balance_v2.gd')+
   source(body?'godot/src/simulation/cultivation/disciple_body_gate_content_v2.gd':'godot/src/simulation/cultivation/cultivation_gate_v57.gd');
}
function buildings(){
 const d=BUILDINGS.find(x=>x.id===state.building),l=state.buildingLevel,milestones=[10,20,30,50,75,100],target=l+1;
 const factor=1+.15*l+.01*l*l,mult=milestones.includes(target)?2:1;
 let price= d.wood!=null && target<=d.max?{wood:Math.ceil(d.wood*factor*mult),ore:Math.ceil(d.ore*factor*mult),stone:Math.ceil(d.stone*factor*mult)}:null;
 let extra='';
 if(milestones.includes(target)&&d.id==='spirit_field')extra=' + Linh Tuyền Chi Tâm (số lượng theo cấp mốc)';
 if(milestones.includes(target)&&d.id==='mine')extra=' + Tầm Mạch Bàn (số lượng theo cấp mốc)';
 if(d.id==='dan_tien_dai'&&target>20)price=null;
 let upper=price?'<div class="grid-3">'+metric('Linh Mộc',fmt(price.wood),'Dự kiến cho '+l+' → '+target)+metric('Thanh Thiết',fmt(price.ore),'Dự kiến cho '+l+' → '+target)+metric('Linh thạch',fmt(price.stone),'Dự kiến cho '+l+' → '+target)+'</div>':'<div class="note">Cấp này chưa có nội dung nâng cấp được phép dùng, hoặc đã đạt giới hạn.</div>';
 const note=extra?'<div class="note">Cấp mốc đặc biệt: '+esc(extra)+'. Giá trên chưa bao gồm vật phẩm mốc.</div>':'';
 return heading('KINH DOANH TÔNG MÔN','Công trình','Chọn công trình và cấp hiện tại để xem chi phí nâng cấp, công dụng và giới hạn.')+
  '<div class="controls"><label>Chọn công trình'+select("building-select",BUILDINGS.map(x=>[x.id,x.name]),d.id)+'</label><label>Cấp hiện tại'+select("level-select",Array.from({length:100},(_,i)=>[i+1,'Cấp '+(i+1)]),l)+'</label></div>'+
  '<div class="grid-3">'+metric('Tên công trình',d.name,d.desc)+metric('Cấp tối đa',fmt(d.max),'Công trình có bảng tối đa 100')+metric('Nhân công ban đầu',fmt(d.workers),d.step?'Thêm chỗ theo mỗi '+d.step+' cấp':'Không tăng theo mốc cố định')+'</div>'+
  panel('Nâng cấp '+l+' → '+target,'Chi phí theo hệ số tăng dần trong BuildingSystem.',upper+note+'<div class="note neutral">Chi phí trên là công thức nâng cấp cơ bản. Khi bật cơ chế sản xuất hàng loạt hoặc điều kiện công trình chính, chi phí/khả năng nâng cấp thực tế có thể khác.</div>')+
  panel('Các công trình đang có trong game','Danh sách từ BuildingSystem.',table(['Công trình','Công dụng'],BUILDINGS.map(x=>['<b>'+esc(x.name)+'</b>',esc(x.desc)])))+
  source('godot/src/simulation/building/building_system.gd');
}
function fields(){
 const lv=state.fieldLevel;
 return heading('LINH DƯỢC CỦA TÔNG MÔN','Linh Điền & cây trồng','Xem cây nào có thể trồng, số linh thạch gieo trồng, chu kỳ cơ bản và thu hoạch.')+
 '<div class="controls"><label>Cấp Linh Điền'+select("field-select",Array.from({length:100},(_,i)=>[i+1,'Cấp '+(i+1)]),lv)+'</label></div>'+
 '<div class="grid-3">'+metric('Cây trồng đã mở',CROPS.filter(x=>lv>=x.lv).length+' / 3','Tùy cấp Linh Điền')+metric('Nhân công ban đầu','4 người','Tăng vị trí theo mỗi 5 cấp')+metric('Cấp tối đa','100','Tử Vân Thảo mở ở cấp 10')+'</div>'+
 panel('Danh sách cây trồng','Các thông số dưới đây là giá trị cơ bản, trước khi tính buff/chính sách sản xuất.',table(['Cây trồng','Điều kiện','Phí gieo','Một vụ cơ bản','Trạng thái'],CROPS.map(x=>[
 '<b>'+esc(x.name)+'</b><div class="fine">'+esc(x.tag)+' · hợp '+esc(x.aff)+'</div>',
 'Linh Điền cấp '+x.lv,
 fmt(x.stone)+' linh thạch',
 '<b>'+fmt(x.yield)+'</b> đơn vị / '+x.ticks+' ticks',
 lv>=x.lv?'<span class="tag">Đã mở theo cấp</span>':'<span class="tag gold">Cần cấp '+x.lv+'</span>'])))+
 '<div class="note">Ticks là nhịp mô phỏng trong game, không phải giây ngoài đời. Chế độ sản xuất hàng loạt có thông số khác, không được cộng lẫn vào năng suất cơ bản.</div>'+
 panel('Nâng Linh Điền thế nào?','Chi phí thay đổi theo cấp', '<p>Chọn <button class="more" data-tab="buildings" data-set-building="spirit_field">Xem bảng nâng cấp Linh Điền →</button> để tính linh mộc, thanh thiết, linh thạch và mốc Linh Tuyền Chi Tâm.</p>')+
 source('godot/src/simulation/building/spirit_crop_registry.gd');
}
function medicine(){
 const r=state.realm,realms=state.data?.realms||[]; const rn=realms[r-1]?.cultivationName||('Cảnh giới '+r);
 const qi=Q1[r-1];
 const m=state.data?.medicine||[];
 const rows=m.filter(x=>x.realm===r).slice(0,16);
 return heading('LUYỆN ĐAN','Đan dược & đột phá','Đan đúng cảnh giới, hiệu lực từng phẩm và điều kiện sử dụng.')+
 '<div class="controls"><label>Chọn cảnh giới'+select("realm-select",realms.map((x,i)=>[i+1,(i+1)+'. '+x.cultivationName]),r)+'</label></div>'+
 '<div class="grid-3">'+metric('Cảnh giới',rn,'Đan phải đúng cảnh giới áp dụng')+metric('Tụ Linh Đan — Hạ phẩm',fmt(qi)+' EXP','Giá trị Q1 trong bảng cân bằng hiện có')+metric('Đột phá cơ bản','25%','Chưa tính số lần thất bại và đan')+'</div>'+
 panel('Các loại đan · '+rn,'Có định danh vật phẩm không đồng nghĩa đã mở công thức luyện.',table(['Đan dược','Phẩm chất','Tác dụng / lưu ý'],rows.map(x=>{
 let effect=x.family==='break'?'Cộng '+([5,6,7,8][x.quality-1])+' điểm % cơ hội đột phá':x.family==='tuvi'?'Bổ sung EXP Tu Vi (tùy phẩm)':x.family==='body'?'Bổ sung EXP Luyện Thể (tùy phẩm)':'Hồi phục';
 return ['<b>'+esc(x.name)+'</b>', ['Hạ','Trung','Thượng','Cực'][x.quality-1]+' phẩm',esc(effect)+'<div class="fine">'+(x.craftability==='AUTHORED_RECIPE_FAMILY_REALM'?'Đã có định nghĩa công thức':'Chưa có công thức được viết cho cấp này')+'</div>'];
 })))+
 panel('Đột phá Tu Vi','Cửa tầng 10 → cảnh giới tiếp theo','<div class="note neutral">Đột Phá Đan <b>không bắt buộc</b>. Bốn phẩm chất lần lượt cộng 5 / 6 / 7 / 8 điểm phần trăm. Tỷ lệ cơ bản 25%, sau mỗi lần thất bại tại cùng cửa cộng thêm 5 điểm %. Thất bại mất 10% EXP của tầng 10.</div>')+
 source('godot/src/simulation/building/medicine_catalogue_v2.gd');
}
function skills(){
 const list=state.data?.skills||[], q=state.query.trim().toLowerCase(); const matches=list.filter(x=>(state.school==='all'||x.schoolId===state.school)&&(!q||((x.name||'')+' '+(x.schoolName||'')+' '+(x.branchId||'')+' '+(x.id||'')).toLowerCase().includes(q)));const selected=list.find(x=>x.id===state.skill)||matches[0];
 const schoolOpts=[["all","Tất cả 12 môn phái"],...(state.data?.schools||[]).map(x=>[x.schoolId||x.id,x.name||x.schoolName||x.id])];
 const rows=matches.slice(0,state.limit);
 const listHtml='<div class="skill-list">'+rows.map(x=>'<button class="item-button'+(x.id===selected?.id?' active':'')+'" data-skill="'+esc(x.id)+'"><span><b>'+esc(x.name)+'</b><small>'+esc(x.schoolName)+' · '+esc(x.generation)+' · '+esc(x.branchId||'Kỹ năng chung')+'</small></span><span class="tip">'+(Number(x.damageRatio)>0?fmt(Number(x.damageRatio)*100)+'%':'Hỗ trợ')+'</span></button>').join('')+'</div>'+(matches.length>state.limit?'<button class="more" id="more-skills">Xem thêm kỹ năng ('+fmt(matches.length-state.limit)+' còn lại)</button>':'');
 let detail='<div class="empty">Chưa có kỹ năng phù hợp. Hãy đổi bộ lọc.</div>';
 if(selected){const ratio=Number(selected.damageRatio||0);let dmg=ratio>0?fmt(ratio*100)+'%':'Không gây sát thương trực tiếp';detail=
 '<div class="kicker">'+esc(selected.schoolName)+' · '+esc(selected.generation)+'</div><h2 style="font-size:25px;margin:6px 0 13px">'+esc(selected.name)+'</h2><span class="tag gold">Thiết kế V6.3 — CHƯA KÍCH HOẠT</span>'+
 '<div class="grid-2" style="margin-top:17px">'+
 metric('Hệ số kỹ năng',dmg,ratio>0?'Hệ số dự kiến, không phải % HP bị trừ':'Chiêu hỗ trợ, di chuyển hoặc phòng thủ')+
 metric('Hồi chiêu',fmt(selected.cooldown||0)+' giây','Theo danh mục thiết kế')+
 metric('Tầm đánh',fmt(selected.range||0),'Đơn vị trong hệ thống game')+
 metric('Số mục tiêu tối đa',fmt(selected.targetLimit||0),'Theo hợp đồng kỹ năng')+
 metric('Thời gian thi triển',fmt(selected.castTime||0)+' giây','Theo catalog')+
 metric('Thời gian hiệu ứng',fmt(selected.duration||0)+' giây','Nếu chiêu có duy trì')+
 '</div><div class="note neutral">Ví dụ: hệ số 108% nghĩa là hệ số 1,08 trong công thức tính, <b>không</b> có nghĩa kẻ địch mất 108% máu. Sát thương thực tế cần Công, Thủ, kháng, buff và kết quả chiến đấu. 2.196 kỹ năng V6.3 hiện chưa được bật.</div>'+
 (selected.description?'<p>'+esc(selected.description)+'</p>':'')+
 '<p class="fine">Loại chiêu: '+esc(selected.effect)+' · Ngũ hành: '+esc(selected.element)+' · Mã kỹ năng: '+esc(selected.id)+'</p>';
 }
 return heading('BÍ KÍP VÕ HỌC','Kỹ năng & sát thương','Tìm kỹ năng theo tên hoặc môn phái. Con số phần trăm là hệ số chiêu thức theo bản thiết kế.')+
 '<div class="controls"><label>Môn phái'+select("school-select",schoolOpts,state.school)+'</label><label>Tìm nhanh<input id="skill-filter" type="search" placeholder="Ví dụ: Đao Pháp, Độc Tu…" value="'+esc(state.query)+'"></label></div><p class="fine">Đang hiện '+fmt(rows.length)+' / '+fmt(matches.length)+' kỹ năng phù hợp.</p>'+
 '<div class="grid-2">'+panel('Danh sách kỹ năng','Bấm một kỹ năng để xem chi tiết',listHtml)+panel('Chi tiết chiêu thức','Thông số số học và cách hiểu',detail)+'</div>'+
 source('godot/data/combat/v63_blade_combat_catalog.json');
}
function equipment(){
 return heading('LÒ RÈN','Trang bị','Nguyên liệu chế tạo, loại trang bị và chỉ số trong hệ thống đang có mã nguồn.')+
 '<div class="grid-3">'+metric('Công thức trang bị',EQUIP.length,'Đã có trong mã EquipmentSystem')+metric('Ô trang bị trong code','3','Vũ khí, giáp, pháp bảo')+metric('Thiết kế đề xuất','10 ô','Chưa thống nhất với code hiện tại')+'</div>'+
 panel('Công thức rèn trang bị','Các nguyên liệu là giá gốc; cơ chế sản xuất hàng loạt có thể thay đổi nhu cầu thực tế.',table(['Tên trang bị','Vị trí','Nguyên liệu','Hiệu quả'],EQUIP.map(x=>['<b>'+esc(x.name)+'</b>',esc(x.slot),esc(x.mats),esc(x.bonus)])))+
 '<div class="note">Bản thiết kế 10 ô trang bị và EquipmentSystem 3 ô chưa được thống nhất. Bách khoa thể hiện đúng tình trạng này, không tự coi là 10 ô đang hoạt động.</div>'+
 source('godot/src/simulation/equipment/equipment_system.gd');
}
function schools(){
 const schools=state.data?.schools||[];const resources=state.data?.resources||[];
 return heading('BẢN ĐỒ MÔN PHÁI','Môn phái & tài nguyên','Danh sách môn phái, hệ phái và các nguyên liệu đã được định danh.')+
 '<div class="grid-3">'+metric('Môn phái',fmt(schools.length),'Theo bản thiết kế')+metric('Nhánh tu luyện',fmt((state.data?.branches||[]).length),'Theo bản thiết kế')+metric('Tài nguyên',fmt(resources.length),'Đã đăng ký định danh')+'</div>'+
 panel('Các môn phái','Nhấp khu kỹ năng để xem chiêu thức từng phái.',table(['Tên môn phái','Đường dẫn'],schools.map(x=>['<b>'+esc(x.name||x.schoolName||x.id)+'</b>','<button class="more" data-tab="skills" data-set-school="'+esc(x.schoolId||x.id)+'">Xem kỹ năng →</button>'])))+
 panel('Danh sách tài nguyên','Nguồn trong ResourceRegistry.',table(['Tài nguyên','Loại','Cảnh giới'],resources.map(x=>[esc(x.name),esc(x.family),x.realmRank?fmt(x.realmRank):'—'])))+
 source('godot/src/simulation/resource/resource_registry.gd');
}
function render(){
 document.querySelectorAll("#menu [data-tab]").forEach(x=>x.classList.toggle("active",x.dataset.tab===state.tab));
 document.getElementById("breadcrumb").textContent=names[state.tab]||names.home;
 const handlers={home,realms,skills,buildings,fields,medicine,equipment,schools};
 content.innerHTML=(handlers[state.tab]||home)();
}
document.addEventListener("click",e=>{
 const menu=e.target.closest("#menu-toggle");if(menu){document.getElementById("sidebar").classList.toggle("open");return;}
 const tab=e.target.closest("[data-tab]");if(tab){
 if(tab.dataset.setBuilding)state.building=tab.dataset.setBuilding;
 if(tab.dataset.setSchool)state.school=tab.dataset.setSchool;
 goto(tab.dataset.tab);return;}
 const skill=e.target.closest("[data-skill]");if(skill){state.skill=skill.dataset.skill;render();return;}
 if(e.target.id==="more-skills"){state.limit+=48;render();}
});
document.addEventListener("change",e=>{
 const v=e.target.value,id=e.target.id;
 if(id==="track-select"){state.track=v;render();}
 if(id==="realm-select"){state.realm=Math.max(1,Math.min(30,Number(v)));render();}
 if(id==="building-select"){state.building=v;state.buildingLevel=1;render();}
 if(id==="level-select"){state.buildingLevel=Number(v);render();}
 if(id==="field-select"){state.fieldLevel=Number(v);render();}
 if(id==="school-select"){state.school=v;state.skill=null;state.limit=48;render();}
});
document.addEventListener("input",e=>{
 if(e.target.id==="skill-filter"){state.query=e.target.value;state.skill=null;state.limit=48;render();const box=document.getElementById("skill-filter");if(box){box.focus();box.setSelectionRange(state.query.length,state.query.length);} }
});
search.addEventListener("input",()=>{state.query=search.value;state.school="all";state.skill=null;state.limit=48;state.tab="skills";render();});
if(!["localhost","127.0.0.1","::1","vuanhtuan161094-byte.github.io"].includes(location.hostname)){content.innerHTML='<div class="note">Bách khoa này chỉ được mở qua máy tính nội bộ (localhost). Hãy sử dụng OPEN_TANG_KINH_CAC.cmd.</div>';return;}
fetch("./data/catalog.json",{cache:"no-store"}).then(r=>{if(!r.ok)throw Error("HTTP "+r.status);return r.json();}).then(data=>{state.data=data;const target=location.hash.replace("#","");state.tab=names[target]?target:"home";render();}).catch(err=>{
 content.innerHTML='<div class="note">Không đọc được dữ liệu catalog: '+esc(err.message)+'. Chạy file <b>tools/wiki/OPEN_TANG_KINH_CAC.cmd</b> trong bản checkout có đầy đủ source, rồi tải lại trang.</div>';
});
})();