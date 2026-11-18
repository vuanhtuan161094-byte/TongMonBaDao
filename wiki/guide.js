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
const state={data:null,char:null,traits:null,audit:null,items:null,combatStats:null,tab:"home",realm:2,track:"cultivation",building:"spirit_field",buildingLevel:1,fieldLevel:1,school:"all",skill:null,limit:48,query:"",traitQuery:"",traitGroup:"all",traitPage:1,aptitude:100,focus:"natural",recruitSource:"ordinary",buildStatus:"all",itemGroup:"medicine",itemQuery:"",itemPage:1,featureStatus:"all",featureGroup:"all",featureLimit:16};
const names={home:"Trang chủ",characters:"Đệ tử & đặc tính",realms:"Tu luyện & đột phá",skills:"Môn phái & kỹ năng",buildings:"Công trình & Linh Điền",equipment:"Trang bị & đồ bộ",items:"Vật phẩm & đan dược",systems:"Toàn bộ chức năng",design:"Thiết kế cần hoàn thiện",search:"Kết quả tìm kiếm"};
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
function goto(tab){
 const aliases={traits:"characters",audit:"systems",fields:"buildings",medicine:"items",schools:"skills"};
 const dest=aliases[tab]||tab;
 state.tab=names[dest]?dest:"home";
 state.limit=48;
 history.replaceState(null,"","#"+state.tab);
 document.getElementById("sidebar").classList.remove("open");
 render();
 window.scrollTo({top:0,behavior:"instant"});
}
function status(label,kind="pending"){return '<span class="ency-status '+esc(kind)+'">'+esc(label)+'</span>';}
function auditSource(path,line=0){return path?'<a target="_blank" rel="noopener" href="'+ROOT+esc(path)+(line?'#L'+line:'')+'">Xem mã/thiết kế</a>':"";}
function home(){
 const quick=[
 ["人","Đệ tử & đặc tính","16 chỉ số chiến đấu, 10 kháng hệ, 101 đặc tính","characters"],
 ["☯","Tu luyện & đột phá","EXP mỗi tầng, cách lên cảnh giới","realms"],
 ["✦","Môn phái & kỹ năng","Tìm skill, xem sát thương %","skills"],
 ["⌂","Công trình & Linh Điền","Nâng cấp, cây trồng, công trình còn thiếu","buildings"],
 ["⚔","Trang bị & đồ bộ","5 công thức cũ; 10 ô, 24 bộ V2","equipment"],
 ["丹","Vật phẩm & đan dược","Tìm item, công thức, nguồn vật liệu","items"],
 ["◎","Toàn bộ chức năng","Đã viết mã, chưa chạy, chưa làm","systems"],
 ["◆","Thiết kế cần hoàn thiện","Ưu tiên hoàn tất bản vẽ trước khi viết thêm code","design"]
 ];
 const a=state.audit?.summary||{},i=state.items?.summary||{};
 return '<section class="ency-hero"><div class="eyebrow" style="color:#d9d0a5">BÁCH KHOA TÔNG MÔN BÁ ĐẠO</div><h1>Tìm mọi thứ trong một nơi</h1><p>Xem cách chơi, con số cụ thể và tình trạng đã làm/chưa làm ngay trong từng chuyên mục. Không cần mở trang báo cáo khác.</p></section>'+
 '<div class="ency-home-grid">'+quick.map(x=>'<button class="ency-tile" data-tab="'+x[3]+'"><span class="sym">'+x[0]+'</span><span><b>'+x[1]+'</b><small>'+x[2]+'</small></span></button>').join("")+'</div>'+
 panel('Những phần còn thiếu nổi bật','Tóm tắt để biết những gì thực sự chưa triển khai',
 '<div class="ency-cards">'+[
 ["Đặc tính V2",status("Chưa xác minh chạy","danger"),"101 đặc tính sinh ra được, nhưng chưa có bằng chứng hiệu ứng gameplay đầy đủ.", "characters"],
 ["Công trình",status("20 loại mới chỉ thiết kế","danger"),"26 loại trong thiết kế dài hạn; 8 loại đăng ký trong code, 6 loại trùng thiết kế.", "buildings"],
 ["Trang bị V2",status("Chưa triển khai","danger"),"Bản V2 thiết kế 10 ô và 24 bộ; code cũ có 3 ô.", "equipment"],
 ["Vật liệu & đan",status("Thiếu nguồn/công thức","danger"),"476 mã đan nhưng 444 chưa có công thức; 619/630 vật liệu dài hạn chưa đăng ký.", "items"]
 ].map(x=>'<article class="ency-card"><h3>'+x[0]+'</h3>'+x[1]+'<p>'+x[2]+'</p><button class="more" data-tab="'+x[3]+'">Xem chi tiết</button></article>').join("")+'</div>'+
 '<p class="ency-mini">Dữ liệu được kiểm tra từ mã nguồn. Chưa có kiểm thử Godot trên HEAD cho toàn bộ game. Không đồng nhất tên trong danh mục với tính năng đã chơi được.</p>')+
 '<div class="ency-alert soft"><b>Cách dùng:</b> chọn một chuyên mục, xem thông số trước. Mỗi chức năng có dòng <b>Tình trạng</b> và phần <b>Còn thiếu gì?</b> nếu chưa hoàn thiện. Bấm ô tìm kiếm phía trên để tìm xuyên suốt toàn game.</div>';
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


function combatStatPanel(){
 const d=state.combatStats;
 if(!d)return panel("Chỉ số chiến đấu","Đang tải bảng thuộc tính chiến đấu V2.","");
 const groups=d.groups.map(group=>{
  const rows=d.stats.filter(x=>x.group===group.key).map(x=>[
   '<b>'+esc(x.name)+'</b><div class="ency-mini">'+esc(x.alias)+' · '+esc(x.id)+'</div>',
   esc(x.baseline),
   esc(x.meaning)+'<details><summary>Xem công thức & ví dụ</summary><p>'+esc(x.formula)+'</p></details>'
  ]);
  return '<section class="ency-section" id="stat-group-'+esc(group.key)+'"><h3>'+esc(group.name)+'</h3>'+
   '<p class="ency-mini">'+esc(group.desc)+'</p>'+
   table(["Chỉ số","Giá trị cơ bản","Tác dụng trong game"],rows)+'</section>';
 }).join("");
 const names=d.resistances.map(x=>'<span class="ency-status muted">'+esc(x.name)+'</span>').join(" ");
 return '<section class="ency-section" id="combat-stats"><h2>16 chỉ số chiến đấu & 10 kháng hệ</h2>'+
 '<p class="ency-summary">Tại đây phân biệt Chí mạng, Sát thương chí mạng, Kháng bạo, Xuyên phòng, hiệu ứng và các hệ kháng. Bộ tính <b>CombatStatsV2</b> đã có mã và từng PASS bài test Godot tập trung; <b>PvE chính vẫn còn đường dùng Chiến Lực cũ</b>. Vì vậy không đánh dấu 16 chỉ số là đã tích hợp toàn bộ trận đánh.</p>'+
 '<div class="ency-tags">'+status("16 chỉ số V2 có bộ tính","ok")+status("10 kháng hệ có bộ tính","ok")+status("Chưa chuyển hết PvE sang V2","danger")+'</div>'+
 groups+
 panel("Kháng 10 nguyên tố","Chống sát thương đúng hệ; giảm phần còn lại, không cộng thẳng các nguồn.",
 '<div class="ency-tags">'+names+'</div>'+
 '<div class="ency-alert soft"><b>Ví dụ kháng Hỏa:</b> nguồn A 30% và nguồn B 20% cho tổng kháng hiệu lực 44%, không phải 50%. Hệ khắc Kim–Mộc–Thủy–Hỏa–Thổ được xử lý riêng qua Linh Căn.</div>')+
 panel("Ba phép tính cần nhớ","Ví dụ minh họa theo công thức đã duyệt; không phải chỉ số của một đệ tử trong Save.",
 '<div class="ency-cards">'+[
 ["Bạo kích (Crit)","40% Bạo Kích − 15 điểm % Kháng Bạo = <b>25%</b> cơ hội chí mạng. Mức 1,50× là hệ số sát thương khi đã chí mạng, không phải xác suất."],
 ["Phòng Ngự / Xuyên Phòng","Công 100, Thủ địch 80, Xuyên Phòng 20% → Thủ hiệu lực 64. Hệ số qua Thủ = 200/(200+64) ≈ <b>75,76%</b> sát thương đủ điều kiện."],
 ["Hút Máu","Hút Máu 20%, đối thủ Giảm Hút Máu 5 điểm % → hút thực 15%. Nếu đòn khiến mục tiêu <b>mất 1.000 HP thực</b>, hồi tối đa 150 HP, không vượt phần HP bản thân còn thiếu."]
 ].map(x=>'<article class="ency-card"><h3>'+x[0]+'</h3><p>'+x[1]+'</p></article>').join("")+'</div>')+
 panel("Các kênh phụ không phải chỉ số chính","Để nhân vật có nhiều lối chơi nhưng không thêm 20 thanh chỉ số mới.",
 '<p>Hiệu quả kỹ năng, sát thương Boss/Tinh Anh/chủng tộc, hiệu quả DoT, trị liệu thực hiện/nhận, hộ thuẫn, thời gian khống chế, liên kích thường... chỉ hiện khi có nguồn tác động và consumer hợp lệ.</p>'+
 '<div class="ency-alert">Thiết kế V2 <b>không có</b> Né Tránh/Chính Xác Đánh Thường ngẫu nhiên, Mana chung, Công/Thủ Vật Lý–Pháp Thuật riêng, Kháng Sát Thương Crit riêng hoặc một chỉ số Speed lượt.</div>')+
 '<p class="ency-link">Nguồn: '+auditSource(d.executionContract)+' · '+auditSource(d.runtimeKernel)+' · '+auditSource(d.mainCombat)+'</p></section>';
}

function characters(){
 const d=state.char,t=state.traits;
 if(!d||!t)return heading("ĐỆ TỬ","Đệ tử & đặc tính","Chưa tải được dữ liệu nhân vật.");
 const apt=Math.max(0,Math.min(50000,Number(state.aptitude)||0));
 const focused=state.focus==="focus";
 const rate=d.tuvi.basePerSimMinute*(focused?d.tuvi.cultivateMultiplier:1)*(1+apt*d.tuvi.aptitudeBonusPerPoint);
 const chances=d.rates.qualityBySource[state.recruitSource]||d.rates.qualityBySource.ordinary;
 const qq=state.traitQuery.trim().toLowerCase();
 const traits=t.traits.filter(x=>(state.traitGroup==="all"||x.designClass===state.traitGroup)&&(!qq||(x.name+" "+x.designEffectVi+" "+x.id+" "+x.group).toLowerCase().includes(qq)));
 const pages=Math.max(1,Math.ceil(traits.length/16));state.traitPage=Math.min(state.traitPage,pages);
 const visible=traits.slice((state.traitPage-1)*16,state.traitPage*16);
 const personalities=[
 ["Dũng cảm",80,50,35],["Thận trọng",20,32,86],["Cân bằng",50,50,55],
 ["Thủ thành tiết kiệm",28,22,74],["Liều lĩnh",92,58,22],["Biết tính toán",42,62,82]
 ];
 const attributes=[
 ["Tư Chất","+0,25% tốc độ Tu Vi tự nhiên mỗi điểm"],["Căn Cốt","+0,20% hệ số EXP Luyện Thể mỗi điểm"],
 ["Tâm Tính","Có điểm, chưa có hiệu ứng gameplay độc lập được xác nhận"],
 ["Tiềm Lực","+0,05% hệ số tiềm năng mỗi điểm"],["Thông Tuệ","+0,15% hệ số lĩnh hội mỗi điểm"],
 ["Cơ Duyên","Ảnh hưởng phép kiểm tra may mắn cụ thể"],["Mị Lực","Ảnh hưởng phép kiểm tra xã giao cụ thể"]
 ];
 const badge=x=>x.designClass==="EFFECT_SPEC_PENDING"?status("Có thiết kế, chưa chạy","pending"):x.designClass==="DEPENDENCY_BLOCKED"?status("Thiếu cơ chế phụ thuộc","danger"):status("Chưa chốt thiết kế","idea");
 const cards=visible.map(x=>'<article class="ency-card"><h3>'+esc(x.name)+'</h3>'+
 '<div class="ency-mini">'+esc(x.group)+' · '+esc(x.nature==="H"?"Có lợi":x.nature==="S"?"Hai mặt":"Bất lợi")+' · Trọng số sinh: '+fmt(x.birthWeight)+'</div>'+
 '<div class="ency-tags">'+status("Đã có trong dữ liệu sinh","ok")+badge(x)+(x.birthAvailable?"":status("Không sinh ngẫu nhiên","danger"))+'</div>'+
 '<p><b>Tác dụng theo thiết kế:</b> '+esc(x.designEffectVi)+'</p>'+
 '<details><summary>Còn thiếu gì? Xem nguồn</summary><p>Hiệu ứng V2 chưa được xác minh có nơi áp dụng và kiểm thử riêng. '+esc(x.remainingWorkVi)+'</p>'+
 (x.legacyAnalogue?'<div class="ency-alert">Có hệ cũ khác: '+esc(x.legacyAnalogue.effectVi)+'. '+esc(x.legacyAnalogue.discrepancyVi)+'</div>':'')+
 '<p class="ency-link">'+auditSource(x.evidence.matrixPath,x.evidence.matrixLine)+'</p></details></article>').join("");
 const pager='<div class="ency-pager"><span>'+fmt(traits.length)+' / 101 đặc tính · Trang '+state.traitPage+'/'+pages+'</span><div>'+
 '<button id="traits-prev"'+(state.traitPage===1?" disabled":"")+'>Trước</button> '+
 '<button id="traits-next"'+(state.traitPage===pages?" disabled":"")+'>Sau</button></div></div>';
 return heading('HỒ SƠ NHÂN VẬT','Đệ tử & đặc tính','Đọc chỉ số, tỷ lệ sinh và tác dụng từng đặc tính. Bên dưới mỗi đặc tính ghi rõ đã làm đến đâu.')+
 '<div class="grid-3">'+metric('101 đặc tính','101','Có dữ liệu sinh; chưa xác minh hiệu ứng V2')+
 metric('Thiên mệnh / Thể chất','24 / 14','Có tên và tỷ lệ sinh')+
 metric('Huyết mạch','5 loại','Không đồng nghĩa đều có buff chạy thật')+'</div>'+
 panel('Tu Vi mỗi giây','Nhập Tư Chất để tính thử tốc độ theo cơ chế V2 (không phải số trong bản lưu).',
 '<div class="controls"><label>Điểm Tư Chất<input id="char-apt" type="number" min="0" max="50000" value="'+apt+'"></label>'+
 '<label>Trạng thái'+select("char-focus",[["natural","Tăng tự nhiên"],["focus","Chuyên tâm tu luyện ×2"]],state.focus)+'</label></div>'+
 '<div class="ency-example"><div><strong>'+fmt(rate/60)+' EXP/s</strong><small>Tốc độ bình quân</small></div>'+
 '<div><strong>'+fmt(rate)+' EXP/phút</strong><small>Phút mô phỏng, chưa buff</small></div>'+
 '<div><strong>+'+fmt(apt*.25)+'%</strong><small>Thưởng Tư Chất</small></div></div>'+
 '<p class="ency-mini">Công thức: 1.000 × '+(focused?'2':'1')+' × (1 + 0,0025 × Tư Chất) ÷ 60. Cộng EXP theo nhịp game; còn phụ thuộc cờ bật hệ Tu Vi V2.</p>')+
 panel('Bảy chỉ số nhân vật','Tâm Tính có giá trị sinh nhân vật nhưng chưa có tác dụng gameplay độc lập.',table(['Chỉ số','Tác dụng hiện được xác nhận hoặc thiết kế'],attributes.map(x=>[esc(x[0]),esc(x[1])])))+
 combatStatPanel()+
 panel('Tỷ lệ khi sinh đệ tử','Tỷ lệ từng bước; không cộng tất cả tỷ lệ thành 100%.',
 '<div class="controls"><label>Kiểu chiêu mộ'+select("char-source",[["ordinary","Chiêu mộ thường"],["gacha","Triệu hồi"],["fate","Cơ duyên"]],state.recruitSource)+'</label></div>'+
 table(['Phẩm chất','Tỷ lệ'],["Phàm Thường","Xuất Chúng","Thiên Kiêu","Tuyệt Luân","Nghịch Thiên"].map((x,i)=>[esc(x),'<b>'+fmt(chances[i])+'%</b>']))+
 table(['Thuộc tính','Tỷ lệ sinh'],[
 ["Linh căn 1/2/3/4/5 hệ",d.rates.rootsCount.map(x=>fmt(x)+"%").join(" / ")],
 ["Có 1/2/3 đặc tính",d.rates.traitCount.map(x=>fmt(x)+"%").join(" / ")],
 ["Đặc tính có lợi/hai mặt/bất lợi",d.rates.traitNature.map(x=>fmt(x)+"%").join(" / ")],
 ["Đặc tính ẩn",fmt(d.rates.traitLatent)+"%"],["Huyết mạch",fmt(d.rates.bloodline)+"%"],
 ["Thể chất",fmt(d.rates.physique)+"%"],["Thiên mệnh",fmt(d.rates.destiny)+"%"],["Dị căn",fmt(d.rates.mutation)+"%"]
 ].map(x=>x.map(esc))))+
 panel('Sáu loại tính cách','Điểm xu hướng trên thang 100, không phải tỷ lệ chiến thắng.',table(['Tính cách','Mạo hiểm','Chi tiêu','Sinh tồn'],personalities.map(x=>x.map((v,i)=>i?fmt(v)+'/100':esc(v)))))+
 '<section class="ency-section"><h2>101 đặc tính — tác dụng và tình trạng</h2><p>'+status("41 có thiết kế, chưa chạy")+status("12 thiếu cơ chế","danger")+status("48 chưa chốt thiết kế","idea")+'</p>'+
 '<div class="ency-controls"><label>Tìm đặc tính<input id="trait-search" type="search" placeholder="Ham Học, Cần Mẫn..." value="'+esc(state.traitQuery)+'"></label>'+
 '<label>Lọc tình trạng'+select("trait-group",[["all","Tất cả 101"],["EFFECT_SPEC_PENDING","Có tác dụng thiết kế"],["DEPENDENCY_BLOCKED","Thiếu cơ chế phụ thuộc"],["CONCEPT_UNAPPROVED","Chưa chốt thiết kế"]],state.traitGroup)+'</label></div>'+
 pager+'<div class="ency-cards">'+(cards||'<p>Không có kết quả phù hợp.</p>')+'</div>'+pager+
 '<div class="ency-alert">9 đặc tính của hệ cũ có mã riêng nhưng không được tính là 101 hiệu ứng V2 đã hoàn thành. Ví dụ Cẩu Thả có cơ chế cũ trái với thiết kế mới.</div></section>'+
 panel('Thiên mệnh, thể chất và huyết mạch','Có định danh sinh, chưa có bằng chứng tất cả hiệu ứng V2 đã hoạt động.',
 '<div class="ency-cards">'+[
 ["24 Thiên mệnh",d.fates.map(x=>x.name)],
 ["14 Thể chất",d.physiques.map(x=>x.name)],
 ["5 Huyết mạch",d.bloodlines.map(x=>x.name)]
 ].map(x=>'<article class="ency-card"><h3>'+x[0]+'</h3><p>'+x[1].map(esc).join(' · ')+'</p></article>').join("")+'</div>')+
 source('godot/src/simulation/recruitment/disciple_birth_catalogue_v2.gd');
}
function buildingExtras(){
 const a=state.audit;
 if(!a)return '';
 const rows=a.buildings.filter(x=>state.buildStatus==="all"||
 (state.buildStatus==="coded"&&x.codeStatus==="REGISTERED_BUILDING")||
 (state.buildStatus==="missing"&&x.codeStatus!=="REGISTERED_BUILDING")||
 (state.buildStatus==="blocked"&&["UPGRADE_BLOCKED","UPGRADE_GATED_20"].includes(x.upgradeStatus)));
 return panel('Tình trạng xây dựng của 26 loại công trình','Có loại trong mã không đồng nghĩa mọi công dụng/mốc đã làm.',
 '<div class="ency-alert">Cây thiết kế dài hạn có <b>26 loại</b>. Trong code có <b>8 loại</b> (6 trùng với cây và 2 bổ sung); <b>20 loại thiết kế chưa có loại BuildingSystem tương ứng</b>. Rèn Thân Đường chưa được nâng cấp, Dẫn Tiên Đài chặn trên cấp 20.</div>'+
 '<div class="ency-controls"><label>Xem loại công trình'+select("build-status",[["all","Tất cả 28 trường hợp"],["coded","8 loại có trong code"],["missing","20 loại mới thiết kế"],["blocked","Các loại bị chặn nâng cấp"]],state.buildStatus)+'</label></div>'+
 table(['Tên công trình','Tình trạng','Việc còn thiếu'],rows.map(x=>[
 '<b>'+esc(x.name)+'</b>',x.codeStatus==="REGISTERED_BUILDING"?status("Có mã xây dựng","ok"):status("Chỉ có thiết kế","danger"),
 esc(x.upgradeNote)+'<div class="ency-link">'+auditSource(x.designSource,x.designLine)+'</div>'
 ])));
}
function fieldExtras(){
 return panel('Linh Điền trồng được gì?','3 loại cây có mã gieo trồng; đã có plot, thu hoạch và chế độ làm việc.',
 table(['Loại cây','Mở ở cấp','Giá gieo','Một vụ cơ bản'],CROPS.map(x=>[
 '<b>'+esc(x.name)+'</b>','Cấp '+x.lv,fmt(x.stone)+' linh thạch',fmt(x.yield)+' đơn vị / '+x.ticks+' ticks'
 ]))+
 '<div class="ency-alert">Sản lượng thực tế cần đối chiếu buff, giờ mô phỏng, nhân công và kiểm thử trong game. Tử Vân Thảo cần Linh Điền cấp 10 cùng vật liệu mốc hợp lệ.</div>');
}
function buildingsUnified(){return buildings()+buildingExtras()+fieldExtras();}
function equipmentUnified(){
 const a=state.audit;
 return equipment()+
 panel('Trang bị V2 chưa triển khai','Thiết kế đã duyệt: 10 ô thường, 12 phẩm, 24 bộ (mốc 2/3/4).',
 '<div class="grid-3">'+metric('Đang có mã hệ cũ','3 ô','Vũ khí, Giáp, Pháp bảo cũ')+
 metric('Thiết kế V2','10 ô','Còn 3 ô Phù, 2 ô Pháp Bảo riêng')+
 metric('Công thức rèn cũ','5','Chưa phải hệ rèn V2')+'</div>'+
 '<p class="ency-summary">10 ô thường: Vũ khí, Mũ, Giáp, Phi phong, Hộ uyển, Thủ sáo, Đai lưng, Giày, Ngọc bội, Nhẫn.</p>'+
 '<div class="ency-alert"><b>Còn thiếu:</b> chuyển dữ liệu cũ sang 10 ô; đồ bộ 2/3/4; 12 phẩm và chỉ số phụ; cường hóa, tẩy luyện, thăng phẩm, kế thừa; nguồn rơi và nguyên liệu có thật.</div>'+
 source('docs/WEAPON_EQUIPMENT_V2_SPEC.md'))+
 panel('24 bộ trang bị đã thiết kế','18 bộ chiến đấu, 6 bộ nghề nghiệp; chưa có hiệu ứng set V2 trong EquipmentSystem.',
 table(['Tên bộ','Nhóm','Trạng thái'],(a?.setFamilies||[]).map(x=>[
 '<b>'+esc(x.name)+'</b>',esc(x.group),status('Chưa lập trình V2','danger')
 ]))+source('docs/EQUIPMENT_SETS_V2_SPEC.md'));
}
function itemDirectory(){
 const items=state.items;if(!items)return '';
 const options=[["medicine","Đan dược (476 mã)"],["nativeResources","Tài nguyên nền (34)"],
 ["legacyEquipment","Trang bị hệ cũ (5 mẫu)"],["archiveItems","Bí kíp vật phẩm V6.3 (154)"],
 ["codices","Bí kíp lưu trữ (159)"],["techniques","Công pháp V6.3 (84)"],["crops","Cây Linh Điền (3)"]];
 const group=state.itemGroup;
 const entries=items[group]||[];
 const q=state.itemQuery.toLowerCase().trim();
 const filtered=entries.filter(x=>!q||(x.name+" "+x.id+" "+(x.family||x.school||"")).toLowerCase().includes(q));
 const pages=Math.max(1,Math.ceil(filtered.length/24));state.itemPage=Math.min(pages,state.itemPage);
 const rows=filtered.slice((state.itemPage-1)*24,state.itemPage*24);
 const describe=x=>{
  if(group==="medicine")return (x.family==="break"?("Đột phá: +"+x.potency+" điểm %"):("Hiệu lực theo bảng: "+fmt(x.potency)))+" · "+(x.hasRecipe?"Có công thức cấp này":"Chưa có công thức cấp này");
  if(group==="legacyEquipment")return "Có mã rèn hệ cũ · Nguyên liệu: "+Object.entries(x.materials||{}).map(([k,v])=>k+" ×"+v).join(", ");
  if(group==="crops")return "Linh Điền cấp "+x.fieldLevel+", gieo "+x.plantCost+" linh thạch, thu "+x.baseYield+"/"+x.baseCycleTicks+" ticks";
  if(group==="nativeResources")return "Thuộc nhóm "+x.family+" · Chưa xác minh mọi tuyến kiếm được";
  return "Có trong danh mục V6.3 · Mặc định khóa, không thể suy ra nguồn farm";
 };
 const pagination='<div class="ency-pager"><span>'+fmt(filtered.length)+' mục · Trang '+state.itemPage+'/'+pages+'</span><div>'+
 '<button id="item-prev"'+(state.itemPage===1?' disabled':'')+'>Trước</button> '+
 '<button id="item-next"'+(state.itemPage===pages?' disabled':'')+'>Sau</button></div></div>';
 return panel('Tra cứu mọi loại vật phẩm','Có tên trong danh mục không có nghĩa người chơi kiếm được hoặc chế tạo được.',
 '<div class="ency-controls"><label>Loại vật phẩm'+select("item-group",options,state.itemGroup)+'</label>'+
 '<label>Tìm vật phẩm<input id="item-search" type="search" value="'+esc(state.itemQuery)+'" placeholder="Tên đan, linh thảo, kiếm..."></label></div>'+
 pagination+
 table(['Vật phẩm','Hiệu lực hoặc nguồn','Tình trạng'],rows.map(x=>[
 '<b>'+esc(x.name)+'</b><div class="ency-mini">'+esc(x.id)+'</div>',
 esc(describe(x)),
 group==="medicine"?(x.hasRecipe?status('Có công thức có điều kiện'):status('Chưa có công thức','danger')):
 ["archiveItems","codices","techniques"].includes(group)?status('Chưa bật V6.3','danger'):status('Có mã nguồn','ok')
 ]))+pagination);
}
function itemsUnified(){
 const it=state.items?.summary||{};
 return heading('KHO TÀNG TÔNG MÔN','Vật phẩm & đan dược','Tìm đồ, biết tác dụng và kiểm tra có thật sự kiếm được, chế tạo được hay chưa.')+
 '<div class="grid-3">'+metric('Đan dược','476 mã','444 chưa có công thức theo cấp')+
 metric('Tài nguyên nền',fmt(it.nativeResources||34),'Không đồng nghĩa 630 vật liệu dài hạn')+
 metric('Công thức đan có nội dung','8 / 119','Cấp cảnh giới 1–2; cần đủ nguồn vật liệu')+'</div>'+
 '<div class="ency-alert"><b>Điểm thiếu lớn:</b> 630 ô vật liệu dài hạn thiết kế nhưng mới <b>11 mã</b> trong phạm vi đó được đăng ký; <b>619 mã</b> còn thiếu. 270 tuyến nguồn mới là kế hoạch, không phải 270 nơi farm chạy thật.</div>'+
 itemDirectory()+
 panel('Đan dược & đột phá — cách dùng','Hệ số chất lượng và công thức do MedicineCatalogue quy định.',
 '<p>Đột Phá Đan Q1–Q4 cộng lần lượt <b>5 / 6 / 7 / 8 điểm phần trăm</b> cơ hội đột phá. Tỷ lệ cơ bản của gate là 25% trước các bổ sung.</p>'+
 '<div class="ency-alert">Không phải 476 mã đan đều có thể luyện. Có công thức trong mã vẫn cần đủ nguyên liệu, điều kiện Luyện Đan Điện và tuyến nhận nguyên liệu hợp lệ.</div>'+
 source('godot/src/simulation/building/medicine_catalogue_v2.gd'))+
 panel('Trang bị, vật phẩm, bí kíp còn thiếu đường sử dụng','Các danh mục bị gate mặc định khóa.',
 table(['Nội dung','Đã có gì?','Chưa có gì?'],[
 ['Vật phẩm Bí Kíp V6.3','154 mã','Nguồn rơi/cơ chế thưởng đã chốt và bật V6.3'],
 ['Kho Bí Kíp V6.3','159 mã','Chưa bật hệ thống archive mặc định'],
 ['Công pháp V6.3','84 mã','Chưa bật học/cường hóa mặc định'],
 ['Đan dược cấp cao','444 mã thiếu công thức','Nguồn nguyên liệu + công thức đầy đủ']
 ].map(x=>x.map(esc))));
}

function designUnified(){
 const blocks=[
 ["D1","Đệ tử, Tâm Tính, 101 đặc tính & Combat Stats","Giữ nguyên 16 chỉ số chiến đấu + 10 kháng hệ đã khóa. Đề xuất giảm Tâm Tính về một nguồn Kháng Hiệu Ứng có giới hạn thay vì thêm chỉ số mới hoặc chồng nhiều kháng tinh thần; 41/12/48 đặc tính được phân nhóm theo consumer.","docs/design/D1_CHARACTER_EFFECT_DESIGN_CANDIDATE_20261118.md","Chọn phương án Tâm Tính; khóa điều kiện của 12 Trait hai mặt; duyệt con số cho 48 Trait mở, tránh nhân đôi với Combat Stats"],
 ["D2/D3","28 công trình, nguyên liệu và đan","Đã xác định vai trò/đầu ra của 26 loại công trình dài hạn và 2 bổ sung; chuẩn hóa quy trình nâng cấp, 630 vật liệu, 270 tuyến nguồn, 476 mã đan.","docs/design/D2_D3_BUILDINGS_ITEMS_DESIGN_CANDIDATE_20261118.md","Hệ số Lv1–100, nguồn thật cho vật liệu, 444 công thức đan còn thiếu"],
 ["D4","Trang bị V2, rèn và đồ bộ","Đã soạn quy trình rèn đầy đủ và 9 loại hành động nâng cấp trang bị. Giữ chuẩn 10 ô, 12 phẩm và 24 bộ; bảng xác suất, cấp cường hóa là đề xuất, chưa duyệt.","docs/design/D4_FORGE_TRANSACTION_DESIGN_CANDIDATE_20261118.md","Phê duyệt xác suất rèn, mức cường hóa, nguồn đồ và các công thức"],
 ["D5","Tu Vi, Luyện Thể và đột phá","Giữ 30×10 mỗi hệ. Cần dùng đúng cân bằng cảnh giới trong nguồn gốc, không thêm Tâm Cảnh 300 tầng hay tự nâng tỷ lệ đột phá.","docs/REALM_LADDER_V2_SPEC.md","Đối chiếu thống nhất số EXP và các nguồn XP cấp cao"],
 ["D6","Môn phái, kỹ năng, chiến đấu, VFX","Thiết kế kỹ năng 36 nhánh với 2.196 ID; phân biệt nội dung thiết kế, cổng V6.3 đang tắt và mỹ thuật cần duyệt.","docs/COMBAT_SKILLS_V2_SPEC.md","Khóa những hiệu ứng còn trùng/chờ quyết định, không lẫn art QA với thiết kế"]
 ];
 return heading('HOÀN THIỆN THIẾT KẾ','Thiết kế trước — code sau','Đây là nơi xem những thiết kế đã có căn cứ và phần còn phải chốt. Không mở thêm vòng P0 hay gắn nhãn hoàn thành cho gameplay chưa chạy.')+
 '<div class="ency-alert soft"><b>Định hướng đã đổi:</b> hoàn tất các gói thiết kế còn thiếu trước khi triển khai chức năng mới. Tài liệu D1–D4 là <b>ứng viên đã biên soạn</b>, không tự nhận các hệ số mới đã được phê duyệt. Những quy tắc người dùng đã chốt từ trước không bị sửa.</div>'+
 panel('Bản thiết kế tổng thể','Thứ tự thiết kế và quyền ưu tiên nguồn, không phải lịch chạy test.',
 '<p>'+auditSource('docs/design/TMB_DESIGN_COMPLETION_MASTER_20261118.md')+' — bản tập hợp các quyết định thiết kế còn thiếu của toàn game.</p>')+
 '<div class="ency-cards">'+blocks.map(x=>'<article class="ency-card"><div class="ency-mini">'+esc(x[0])+' · Thiết kế theo hệ</div>'+
 '<h3>'+esc(x[1])+'</h3><div class="ency-tags">'+status("Đã soạn phương án","ok")+status("Chờ duyệt phần mở","pending")+'</div>'+
 '<p>'+esc(x[2])+'</p><details><summary>Còn phải chốt những gì?</summary><p>'+esc(x[4])+'</p>'+
 '<p class="ency-link">'+auditSource(x[3])+'</p></details><p>'+auditSource(x[3])+'</p></article>').join("")+'</div>'+
 '<div class="ency-alert">Số liệu *đang đề xuất* như tỷ lệ phẩm rèn hay hệ số Tâm Tính chưa được dùng làm giá trị chính thức. Khi bạn duyệt thiết kế, phần này mới chuyển từ “Chờ duyệt” sang “Đã khóa thiết kế”; trạng thái code/QA vẫn nằm ở chuyên mục Toàn bộ chức năng.</div>';
}

function systemsUnified(){
 const a=state.audit;if(!a)return heading('KIỂM TRA TOÀN GAME','Toàn bộ chức năng','Dữ liệu chưa tải xong.');
 const statuses=[["all","Tất cả trạng thái"],...Object.entries({
 "CODE_PRESENT_PARTIAL":"Có mã một phần","CODE_PRESENT_GATED":"Có mã nhưng đang khóa",
 "IDENTITY_ONLY":"Mới có tên/dữ liệu","CODE_PRESENT_QA_PENDING":"Có mã, chưa đủ QA",
 "DESIGN_ONLY":"Chỉ thiết kế","DESIGN_DEFERRED":"Hoãn làm","PROPOSED_NOT_APPROVED":"Đề xuất chưa duyệt",
 "CATALOG_PARTIAL":"Có danh mục, thiếu chức năng","ART_PARTIAL":"Mỹ thuật đang làm",
 "DEVICE_QA_PENDING":"Thiết bị chưa nghiệm thu"
 })];
 const groups=[["all","Tất cả hệ"]].concat([...new Set(a.features.map(x=>x.category))].sort().map(x=>[x,x]));
 const matches=a.features.filter(x=>(state.featureStatus==="all"||x.status===state.featureStatus)&&
 (state.featureGroup==="all"||x.category===state.featureGroup));
 const shown=matches.slice(0,state.featureLimit);
 const toStatus=s=>["DESIGN_ONLY","DESIGN_DEFERRED","PROPOSED_NOT_APPROVED"].includes(s)?status("Mới thiết kế","idea"):
 ["IDENTITY_ONLY","CATALOG_PARTIAL"].includes(s)?status("Có dữ liệu, thiếu gameplay","danger"):
 s==="CODE_PRESENT_GATED"?status("Có mã nhưng đang khóa","danger"):
 s==="CODE_PRESENT_QA_PENDING"||s==="ART_PARTIAL"||s==="DEVICE_QA_PENDING"?status("Chưa nghiệm thu"):status("Có mã một phần");
 return heading('TIẾN ĐỘ THẬT CỦA GAME','Toàn bộ chức năng','Tại đây kiểm tra mỗi chức năng có thiết kế gì, đã code gì và còn thiếu gì. Chỉ là kiểm toán nguồn, không phải QA đã nghiệm thu.')+
 '<div class="grid-3">'+metric('Hạng mục',a.features.length,'Có mô tả và nguồn tham chiếu')+
 metric('Nhóm code',a.summary.sourceModules,'Các nhóm mô phỏng')+
 metric('Công trình chưa đăng ký',a.summary.designNotRegistered,'So với thiết kế dài hạn')+'</div>'+
 '<div class="ency-controls"><label>Trạng thái'+select("system-status",statuses,state.featureStatus)+'</label>'+
 '<label>Hệ thống'+select("system-group",groups,state.featureGroup)+'</label></div>'+
 '<p class="ency-mini">'+matches.length+' hạng mục phù hợp. Bấm “Còn thiếu gì?” để xem chi tiết.</p>'+
 '<div class="ency-cards">'+shown.map(x=>'<article class="ency-card"><h3>'+esc(x.name)+'</h3><div class="ency-tags">'+toStatus(x.status)+'</div>'+
 '<p>'+esc(x.finding)+'</p><details><summary>Còn thiếu gì? Xem nguồn</summary>'+
 '<p>Cần xác minh chức năng thực sự thay đổi trạng thái trong game, tương thích Save/Reload, đúng cờ bật và có kiểm thử end-to-end.</p>'+
 '<p class="ency-link">'+auditSource(x.codeSource)+' · '+auditSource(x.designSource)+'</p></details></article>').join("")+'</div>'+
 (shown.length<matches.length?'<button class="more" id="more-systems">Xem thêm '+(matches.length-shown.length)+' mục</button>':'')+
 '<div class="ency-alert">Không tự coi trạng thái <b>có mã</b> là tính năng đã hoàn thành. Để đóng một mục cần kiểm thử Godot đúng commit, GUI thực tế và bằng chứng người chơi thao tác được.</div>'+
 source('docs/GAME_SYSTEM_ARCHITECTURE.md');
}
function searchUnified(){
 const q=state.query.trim(),needle=q.toLowerCase();
 if(!q)return home();
 const data=state.data||{},ch=state.char||{},audit=state.audit||{},items=state.items||{},combat=state.combatStats||{};
 const find=(arr,makeName)=>arr.filter(x=>makeName(x).toLowerCase().includes(needle));
 const skills=find(data.skills||[],x=>x.name+" "+x.schoolName+" "+x.id).slice(0,12);
 const traits=find(state.traits?.traits||[],x=>x.name+" "+x.designEffectVi+" "+x.id).slice(0,12);
 const combatFound=find(combat.stats||[],x=>x.name+" "+x.alias+" "+x.id+" "+x.meaning+" "+x.formula).slice(0,16);
 const buildings=find(audit.buildings||[],x=>x.name+" "+x.id).slice(0,12);
 const features=find(audit.features||[],x=>x.name+" "+x.finding).slice(0,12);
 const inv=find([...(items.medicine||[]),...(items.nativeResources||[]),...(items.legacyEquipment||[]),
 ...(items.crops||[]),...(items.archiveItems||[]),...(items.codices||[]),...(items.techniques||[])],x=>x.name+" "+x.id).slice(0,12);
 const list=(title,rows,tab,type)=>rows.length?panel(title,rows.length+' kết quả đầu tiên',rows.map(x=>{
  const name=x.name||x.id;
  return '<button class="item-button" data-tab="'+tab+'" data-find-type="'+type+'" data-find-id="'+esc(x.id||name)+'"><span><b>'+esc(name)+'</b><small>'+esc(x.designEffectVi||x.finding||x.schoolName||x.family||"Xem chi tiết và trạng thái")+'</small></span><span class="tip">Xem</span></button>';
 }).join("")):"";
 return heading('TRA CỨU TOÀN GAME','Tìm: '+q,'Một nơi tìm xuyên suốt nhân vật, đặc tính, công trình, kỹ năng và vật phẩm. Chọn kết quả để xem trong bách khoa.')+
 (list('Kỹ năng',skills,'skills','skill')+list('Chỉ số chiến đấu',combatFound,'characters','stat')+list('Đặc tính',traits,'characters','trait')+
 list('Công trình',buildings,'buildings','building')+
 list('Vật phẩm & đan dược',inv,'items','item')+
 list('Chức năng game',features,'systems','system')||'<div class="empty">Không tìm được mục phù hợp. Thử từ khóa khác.</div>');
}

function render(){
 document.querySelectorAll("#menu [data-tab]").forEach(x=>x.classList.toggle("active",x.dataset.tab===state.tab));
 document.getElementById("breadcrumb").textContent=names[state.tab]||names.home;
 const handlers={home,characters,realms,skills,buildings:buildingsUnified,equipment:equipmentUnified,items:itemsUnified,systems:systemsUnified,design:designUnified,search:searchUnified};
 content.innerHTML=(handlers[state.tab]||home)();
}
document.addEventListener("click",e=>{
 const menu=e.target.closest("#menu-toggle");if(menu){document.getElementById("sidebar").classList.toggle("open");return;}
 const tab=e.target.closest("[data-tab]");if(tab){
  if(tab.tagName==="A")e.preventDefault();
  if(tab.dataset.setBuilding)state.building=tab.dataset.setBuilding;
  if(tab.dataset.setSchool)state.school=tab.dataset.setSchool;
  if(tab.dataset.findType){
   const id=tab.dataset.findId,kind=tab.dataset.findType;
   if(kind==="trait"){const found=state.traits?.traits?.find(x=>x.id===id);state.traitQuery=found?.name||"";state.traitGroup="all";state.traitPage=1;}
   if(kind==="stat"){state.statScrollId=id;}
   if(kind==="skill"){state.skill=id;state.school="all";}
   if(kind==="building"){const x=state.audit?.buildings.find(z=>z.id===id);if(BUILDINGS.some(z=>z.id===id))state.building=id;state.buildStatus=x?.codeStatus==="REGISTERED_BUILDING"?"coded":"missing";}
   if(kind==="item"){
    for(const key of ["medicine","nativeResources","legacyEquipment","archiveItems","codices","techniques","crops"]){
     const hit=state.items?.[key]?.find(x=>x.id===id);
     if(hit){state.itemGroup=key;state.itemQuery=hit.name;state.itemPage=1;break;}
    }
   }
   if(kind==="system"){
    const feature=state.audit?.features.find(x=>x.id===id);
    state.featureGroup=feature?.category||"all";state.featureStatus="all";state.featureLimit=99;
   }
   search.value="";state.query="";
  }
  goto(tab.dataset.tab);
  if(tab.dataset.findType==="stat" && state.statScrollId){
    const selected=state.combatStats?.stats?.find(x=>x.id===state.statScrollId);
    document.getElementById("stat-group-"+(selected?.group||"core"))?.scrollIntoView({block:"start"});
    state.statScrollId=null;
  }
  return;
 }
 const skill=e.target.closest("[data-skill]");if(skill){state.skill=skill.dataset.skill;render();return;}
 if(e.target.id==="more-skills"){state.limit+=48;render();return;}
 if(e.target.id==="traits-prev"){state.traitPage=Math.max(1,state.traitPage-1);render();return;}
 if(e.target.id==="traits-next"){state.traitPage++;render();return;}
 if(e.target.id==="item-prev"){state.itemPage=Math.max(1,state.itemPage-1);render();return;}
 if(e.target.id==="item-next"){state.itemPage++;render();return;}
 if(e.target.id==="more-systems"){state.featureLimit+=16;render();return;}
});
document.addEventListener("change",e=>{
 const v=e.target.value,id=e.target.id;
 if(id==="track-select"){state.track=v;render();}
 if(id==="realm-select"){state.realm=Math.max(1,Math.min(30,Number(v)));render();}
 if(id==="building-select"){state.building=v;state.buildingLevel=1;render();}
 if(id==="level-select"){state.buildingLevel=Number(v);render();}
 if(id==="field-select"){state.fieldLevel=Number(v);render();}
 if(id==="school-select"){state.school=v;state.skill=null;state.limit=48;render();}
 if(id==="char-apt"){state.aptitude=Math.max(0,Math.min(50000,Number(v)||0));render();}
 if(id==="char-focus"){state.focus=v;render();}
 if(id==="char-source"){state.recruitSource=v;render();}
 if(id==="trait-group"){state.traitGroup=v;state.traitPage=1;render();}
 if(id==="build-status"){state.buildStatus=v;render();}
 if(id==="item-group"){state.itemGroup=v;state.itemQuery="";state.itemPage=1;render();}
 if(id==="system-status"){state.featureStatus=v;state.featureLimit=16;render();}
 if(id==="system-group"){state.featureGroup=v;state.featureLimit=16;render();}
});
document.addEventListener("input",e=>{
 const id=e.target.id;
 if(id==="skill-filter"){state.query=e.target.value;state.skill=null;state.limit=48;}
 else if(id==="trait-search"){state.traitQuery=e.target.value;state.traitPage=1;}
 else if(id==="item-search"){state.itemQuery=e.target.value;state.itemPage=1;}
 else return;
 const pos=e.target.selectionStart;
 render();
 const box=document.getElementById(id);if(box){box.focus();box.setSelectionRange(pos,pos);}
});
search.addEventListener("input",()=>{
 state.query=search.value;state.tab=state.query.trim()?"search":"home";
 render();
});
if(!["localhost","127.0.0.1","::1","vuanhtuan161094-byte.github.io"].includes(location.hostname)){content.innerHTML='<div class="note">Chỉ mở trên GitHub Pages chính thức hoặc localhost.</div>';return;}
Promise.all(["./data/catalog.json","./data/character_reference.json","./data/trait_effect_audit.json","./data/game_system_audit.json","./data/game_items_audit.json","./data/combat_stats_reference.json"].map(path=>fetch(path,{cache:"no-store"}).then(r=>{if(!r.ok)throw Error("HTTP "+r.status+" "+path);return r.json();}))).then(([data,ch,traits,audit,items,combatStats])=>{if(combatStats.stats?.length!==16||combatStats.resistances?.length!==10)throw Error("Dữ liệu 16 chỉ số V2 hoặc 10 kháng hệ không đầy đủ");state.data=data;state.char=ch;state.traits=traits;state.audit=audit;state.items=items;state.combatStats=combatStats;const target=location.hash.replace("#","");const aliases={traits:"characters",audit:"systems",fields:"buildings",medicine:"items",schools:"skills"};state.tab=names[aliases[target]||target]?aliases[target]||target:"home";render();}).catch(err=>{
 content.innerHTML='<div class="note">Không tải được dữ liệu bách khoa: '+esc(err.message)+'. Thử tải lại trang (Ctrl+F5).</div>';
});
})();