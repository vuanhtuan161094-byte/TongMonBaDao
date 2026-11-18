(() => {
"use strict";
const content=document.getElementById("character-dashboard");
const repo="https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/integration/pve-p0-playable-ui-20261103/";
const qualityNames=["Phàm Thường","Xuất Chúng","Thiên Kiêu","Tuyệt Luân","Nghịch Thiên"];
const qualityBounds=["Dưới 360","360–599","600–999","1.000–1.799","Từ 1.800"];
const personalities=[
 ["Dũng Cảm",80,50,35,"Thích thử thách, thiên về mạo hiểm"],
 ["Thận Trọng",20,32,86,"Ít mạo hiểm, chú trọng sinh tồn"],
 ["Cân Bằng",50,50,55,"Giữ nhịp giữa liều lĩnh và an toàn"],
 ["Thủ Thành Tiết Kiệm",28,22,74,"Chi tiêu dè dặt, ưu tiên phòng thủ"],
 ["Liều Lĩnh",92,58,22,"Mạo hiểm cao, ít chú trọng bảo toàn"],
 ["Biết Tính Toán",42,62,82,"Cân nhắc kỹ trước khi hành động"]
];
const attributes=[
 ["Tư Chất","Tam Căn","+0,25% tốc độ tu vi tự nhiên mỗi điểm"],
 ["Căn Cốt","Tam Căn","+0,20% hệ số EXP luyện thể tự nhiên mỗi điểm"],
 ["Tâm Tính","Tam Căn","Chưa có hiệu ứng tự động tổng quát được xác nhận"],
 ["Tiềm Lực","Tứ Tính","+0,05% hệ số tiềm năng mỗi điểm"],
 ["Thông Tuệ","Tứ Tính","+0,15% hệ số lĩnh hội mỗi điểm"],
 ["Cơ Duyên","Tứ Tính","Điểm may mắn, phụ thuộc phép kiểm tra cụ thể"],
 ["Mị Lực","Tứ Tính","Điểm xã giao, phụ thuộc phép kiểm tra cụ thể"]
];
const state={data:null,aptitude:100,focus:"natural",source:"ordinary",group:"traits",nature:"all",query:""};
const fmt=n=>Number(n).toLocaleString("vi-VN",{maximumFractionDigits:2});
const esc=s=>String(s==null?"":s).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
function table(cols,rows){return '<div class="char-scroll"><table class="char-table"><thead><tr>'+cols.map(x=>'<th>'+esc(x)+'</th>').join("")+'</tr></thead><tbody>'+rows.map(row=>'<tr>'+row.map(cell=>'<td>'+cell+'</td>').join("")+'</tr>').join("")+'</tbody></table></div>';}
function section(title,subtitle,body){return '<section class="char-panel"><header><h2>'+esc(title)+'</h2><p>'+esc(subtitle)+'</p></header><div class="inner">'+body+'</div></section>';}
function select(id,options,current){return '<select id="'+id+'">'+options.map(x=>'<option value="'+esc(x[0])+'"'+(String(x[0])===String(current)?' selected':'')+'>'+esc(x[1])+'</option>').join("")+'</select>';}
function source(path){return '<p class="char-muted">Nguồn số liệu: <a target="_blank" rel="noopener" href="'+repo+esc(path)+'">'+esc(path.split("/").pop())+'</a>. Các hiệu ứng chưa kích hoạt không được tính như đang chạy.</p>';}
function draw(){
 const d=state.data;if(!d)return;
 const apt=Math.max(0,Math.min(50000,Number(state.aptitude)||0));
 const focused=state.focus==="focus";
 const rateMinute=d.tuvi.basePerSimMinute*(focused?d.tuvi.cultivateMultiplier:1)*(1+apt*d.tuvi.aptitudeBonusPerPoint);
 const rateSecond=rateMinute/d.tuvi.wallSecPerSimMinute;
 const available=d.rates.qualityBySource[state.source];
 const groupOptions=[["traits","Đặc tính"],["fates","Thiên mệnh"],["physiques","Thể chất"],["bloodlines","Huyết mạch"]];
 const natures={H:"Có lợi",S:"Hai mặt",B:"Bất lợi"};
 const all=d[state.group]||[];
 const q=state.query.toLocaleLowerCase("vi-VN").trim();
 const found=all.filter(x=>(state.nature==="all"||state.group!=="traits"||x.nature===state.nature)&&(!q||(x.name+" "+x.id).toLocaleLowerCase("vi-VN").includes(q)));
 const odds=[
 ["Số linh căn","1 hệ / 2 hệ / 3 hệ / 4 hệ / 5 hệ",d.rates.rootsCount.map(x=>fmt(x)+"%").join(" · ")],
 ["Đặc tính hiển lộ","1 / 2 / 3 đặc tính",d.rates.traitCount.map(x=>fmt(x)+"%").join(" · ")],
 ["Tính chất đặc tính","Có lợi / Hai mặt / Bất lợi",d.rates.traitNature.map(x=>fmt(x)+"%").join(" · ")],
 ["Đặc tính ẩn","Có thể xuất hiện thêm một đặc tính ẩn",fmt(d.rates.traitLatent)+"%"],
 ["Huyết mạch","Có huyết mạch bẩm sinh",fmt(d.rates.bloodline)+"%"],
 ["Thể chất","Có thể chất đặc biệt",fmt(d.rates.physique)+"%"],
 ["Thiên mệnh","Có thiên mệnh bẩm sinh",fmt(d.rates.destiny)+"%"],
 ["Dị căn","Có dị linh căn bẩm sinh",fmt(d.rates.mutation)+"%"]
 ];
 content.innerHTML=
 '<div class="char-hero"><h2>Hồ sơ một đệ tử</h2><p>Mỗi người có tư chất, tính cách, linh căn và các đặc tính khác nhau. Xem tỷ lệ sinh, chọn chỉ số để tính thử tốc độ tu luyện.</p></div>'+
 '<div class="char-stat"><div><strong>101</strong><span>Đặc tính V2</span></div><div><strong>24</strong><span>Thiên mệnh</span></div><div><strong>14</strong><span>Thể chất</span></div><div><strong>5</strong><span>Huyết mạch</span></div></div>'+
 section("Tu vi mỗi giây của đệ tử","Tính thử từ Tư Chất và trạng thái tu luyện — không đọc bản lưu nhân vật.",
 '<div class="char-filter"><label>Điểm Tư Chất<input id="aptitude" type="number" min="0" max="50000" step="1" value="'+fmt(apt).replace(/\./g,"")+'"></label>'+
 '<label>Đang làm gì?'+select("focus",[["natural","Tăng tự nhiên"],["focus","Chuyên tâm tu luyện ×2"]],state.focus)+'</label></div>'+
 '<div class="grid-3">'+
 '<div class="metric"><small>Tốc độ bình quân</small><strong>'+fmt(rateSecond)+' EXP/s</strong><span>Chưa cộng bổ trợ từ công trình</span></div>'+
 '<div class="metric"><small>Tu vi mỗi phút</small><strong>'+fmt(rateMinute)+' EXP</strong><span>60 giây thực = 1 phút mô phỏng</span></div>'+
 '<div class="metric"><small>Tăng do Tư Chất</small><strong>+'+fmt(apt*0.25)+'%</strong><span>Mỗi điểm tăng 0,25%</span></div></div>'+
 '<div class="char-callout">Công thức: 1.000 × '+(focused?'2':'1')+' × (1 + 0,0025 × Tư Chất) ÷ 60. Tu vi được cộng theo nhịp mô phỏng, không phải liên tục từng khung hình. Đây là <b>ví dụ giả định</b>: thực tế còn có buff, nguồn EXP, điều kiện nhân vật và cờ bật Tu Vi V2. Luyện Thể không có tốc độ EXP/s chung.</div>')+
 section("Tam Căn & Tứ Tính","Bảy chỉ số chính trong hồ sơ nhân vật.",table(["Chỉ số","Nhóm","Tác dụng"],attributes.map(x=>x.map(esc))))+
 section("Phẩm chất & tỷ lệ xuất hiện","Tỷ lệ theo nguồn chiêu mộ của bộ sinh D7.",
 '<div class="char-filter"><label>Kiểu chiêu mộ'+select("source",[["ordinary","Chiêu mộ thường"],["gacha","Triệu hồi"],["fate","Cơ duyên"]],state.source)+'</label></div>'+
 table(["Phẩm chất","Tỷ lệ","Tổng điểm quy đổi"],qualityNames.map((name,i)=>['<b>'+esc(name)+'</b>','<b>'+fmt(available[i])+'%</b>',esc(qualityBounds[i])]))+
 '<div class="char-callout">Ngưỡng là tổng điểm quy đổi theo hệ Tam Căn & Tứ Tính. Một số nguồn có cơ chế ép phẩm chất; tỷ lệ trên không đại diện cho mọi lần tạo nhân vật.</div>')+
 section("Sáu kiểu tính cách","Điểm xu hướng hành vi trên thang 100, không phải phần trăm thành công.",
 table(["Tính cách","Mạo hiểm","Chi tiêu","Sinh tồn"],personalities.map(x=>['<b>'+esc(x[0])+'</b><div class="char-muted">'+esc(x[4])+'</div>',fmt(x[1])+'/100',fmt(x[2])+'/100',fmt(x[3])+'/100']))+
 '<p class="char-muted">Khi sinh đệ tử V2, từng xu hướng có thể dao động khoảng ±7 điểm. Chỉ số được giới hạn từ 5 đến 95.</p>')+
 section("Xác suất bẩm sinh","Tính theo từng bước gieo độc lập trong DiscipleBirthRollV2.",
 table(["Thuộc tính","Điều kiện","Tỷ lệ"],odds.map(row=>row.map(esc)))+
 '<div class="char-callout">Các tỷ lệ không cộng lại thành 100%. Một nhân vật có thể đồng thời có linh căn, huyết mạch, thiên mệnh, thể chất và nhiều đặc tính.</div>')+
 section("Tra cứu toàn bộ đặc tính & thiên mệnh","Danh mục sinh nhân vật V2, có trọng số và giới hạn xuất hiện.",
 '<div class="char-filter"><label>Loại'+select("group",groupOptions,state.group)+'</label>'+
 (state.group==="traits"?'<label>Phân loại'+select("nature",[["all","Tất cả"],["H","Có lợi"],["S","Hai mặt"],["B","Bất lợi"]],state.nature)+'</label>':"")+
 '<label>Tìm tên<input type="search" id="trait-query" value="'+esc(state.query)+'" placeholder="Ví dụ: Ham Học"></label></div>'+
 '<p class="char-muted">'+fmt(found.length)+' / '+fmt(all.length)+' mục. Trọng số là mức ưu tiên tương đối khi chọn, không phải phần trăm sở hữu độc lập.</p>'+
 table(["Tên","Nhóm","Trọng số","Tình trạng"],found.map(x=>[
 '<b>'+esc(x.name)+'</b><div class="char-muted">'+esc(x.id)+'</div>',
 esc(state.group==="traits"?(natures[x.nature]||x.nature):groupOptions.find(g=>g[0]===state.group)[1]),
 x.weight==null?'Phân bổ đều':fmt(x.weight)+' điểm',
 x.birthAvailable===false?'<span class="char-soft">Không được sinh ngẫu nhiên</span>':'<span class="char-good">Có trong danh mục sinh</span>'
 ])))+
 source(d.generatedFrom.catalogue)+source(d.generatedFrom.roll)+source(d.generatedFrom.generator)+source(d.generatedFrom.flow);
}
document.getElementById("menu-toggle").addEventListener("click",()=>document.getElementById("sidebar").classList.toggle("open"));
document.addEventListener("change",e=>{
 const id=e.target.id,v=e.target.value;
 if(id==="aptitude"){state.aptitude=Math.max(0,Math.min(50000,Number(v)||0));draw();}
 if(id==="focus"){state.focus=v;draw();}
 if(id==="source"){state.source=v;draw();}
 if(id==="group"){state.group=v;state.query="";draw();}
 if(id==="nature"){state.nature=v;draw();}
});
document.addEventListener("input",e=>{if(e.target.id==="trait-query"){state.query=e.target.value;draw();let el=document.getElementById("trait-query");if(el){el.focus();el.setSelectionRange(state.query.length,state.query.length);}}});
document.getElementById("header-search").addEventListener("input",e=>{state.query=e.target.value;draw();});
if(!["localhost","127.0.0.1","::1","vuanhtuan161094-byte.github.io"].includes(location.hostname)){
 content.innerHTML='<div class="char-callout">Trang này chỉ mở tại GitHub Pages chính thức hoặc máy chủ localhost hợp lệ.</div>';return;
}
fetch("./data/character_reference.json",{cache:"no-store"}).then(r=>{if(!r.ok)throw Error("HTTP "+r.status);return r.json();}).then(x=>{if(x.traits?.length!==101||x.fates?.length!==24||x.physiques?.length!==14||x.bloodlines?.length!==5)throw Error("Dữ liệu nhân vật chưa đầy đủ");state.data=x;draw();}).catch(e=>{content.innerHTML='<div class="char-callout">Chưa thể tải dữ liệu nhân vật: '+esc(e.message)+'</div>';});
})();