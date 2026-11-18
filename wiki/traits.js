(() => {
"use strict";
const BASE="https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/integration/pve-p0-playable-ui-20261103/";
const host=location.hostname;
const $=id=>document.getElementById(id);
const esc=s=>String(s==null?"":s).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
const fmt=n=>Number(n).toLocaleString("vi-VN");
const normal=s=>String(s||"").toLocaleLowerCase("vi-VN").normalize("NFD").replace(/[\u0300-\u036f]/g,"").replace(/đ/g,"d");
const labels={EFFECT_SPEC_PENDING:"Có thiết kế, chưa chạy V2",DEPENDENCY_BLOCKED:"Thiếu cơ chế phụ thuộc",CONCEPT_UNAPPROVED:"Mới đề xuất, chưa duyệt"};
const ui={data:null,status:"all",group:"all",nature:"all",query:"",birth:"all"};
const htmlAnchor=(path,line=0,label="Xem nguồn")=>'<a target="_blank" rel="noopener" href="'+BASE+esc(path)+(line?'#L'+line:'')+'">'+esc(label)+'</a>';
const classify=s=>s==="EFFECT_SPEC_PENDING"?"ta-warn":s==="DEPENDENCY_BLOCKED"?"ta-bad":"ta-concept";
const natureText={H:"Có lợi",S:"Hai mặt",B:"Bất lợi"};
function card(t){
 const legacy=t.legacyAnalogue;
 const effect=esc(t.designEffectVi);
 return '<article class="ta-card" id="trait-'+esc(t.id)+'"><h3>'+esc(t.name)+'</h3>'+
 '<div class="ta-meta">'+esc(t.group)+' · '+esc(natureText[t.nature]||t.nature)+' · Trọng số sinh: '+fmt(t.birthWeight)+'</div>'+
 '<div class="ta-tags"><span class="ta-status ta-code">Đã code danh tính</span>'+
 '<span class="ta-status '+classify(t.designClass)+'">'+esc(labels[t.designClass])+'</span>'+
 (!t.birthAvailable?'<span class="ta-status ta-bad">Không sinh ngẫu nhiên</span>':'')+
 (legacy?'<span class="ta-status ta-warn">Có cơ chế cũ khác V2</span>':'')+'</div>'+
 '<p class="ta-effect">'+effect+'</p>'+
 '<div class="ta-track"><div><b>ĐÃ CODE</b>Tên, nhóm, trọng số và dữ liệu lưu khi sinh đệ tử'+(!t.birthAvailable?' (đang bị loại khỏi lượt sinh ngẫu nhiên)':'')+'.</div>'+
 '<div class="ta-pending"><b>CHƯA HOÀN THÀNH</b>Hiệu ứng V2 chưa có bằng chứng chạy thật và kiểm thử riêng theo ID.</div></div>'+
 '<details class="ta-expand"><summary>Xem việc còn thiếu & nguồn kiểm toán</summary>'+
 '<p><b>Việc cần làm:</b> '+esc(t.remainingWorkVi)+'</p>'+
 '<p><b>Nơi phải áp dụng:</b> '+esc(t.consumerNeededVi)+'</p>'+
 (legacy?'<div class="ta-rule"><strong>Cảnh báo lệch với hệ cũ:</strong> '+esc(legacy.effectVi)+' — '+esc(legacy.discrepancyVi)+'. Không được coi là đã hoàn thành V2.</div>':'')+
 '<p><b>Đối chiếu:</b> '+htmlAnchor(t.evidence.matrixPath,t.evidence.matrixLine,"Hiệu ứng trong tài liệu")+' · '+
 htmlAnchor(t.evidence.birthPath,0,"Bảng sinh đặc tính")+' · '+htmlAnchor(t.evidence.runtimeReviewPath,0,"Mã hiệu ứng cũ")+'</p>'+
 '<p class="ta-muted"><b>Hiệu ứng mô tả:</b> '+(t.designClass==="CONCEPT_UNAPPROVED"?"Phương án chưa chốt, không phải buff đã có":t.designClass==="DEPENDENCY_BLOCKED"?"Đang bị chặn vì thiếu cơ chế":"Đã ghi công thức/kênh nhưng chưa thực thi")+'</p>'+
 '</details></article>';
}
function legacyTable(data){
 return '<section class="ta-legacy"><h2>9 đặc tính của hệ cũ — không phải 101 hiệu ứng V2</h2>'+
 '<p>Có mã xử lý và bài kiểm thử nguồn <code>p2_9_traits_test.gd</code>, chỉ có tác dụng khi bật <code>disciple_traits_enabled</code>. Chưa xác nhận bài kiểm thử này chạy trên HEAD mới nhất. Không tự áp hệ số cũ cho 101 đặc tính mới.</p>'+
 '<div class="table-scroll"><table><thead><tr><th>Hệ cũ</th><th>Hiệu ứng có trong code</th><th>Khác với V2 / cần đối chiếu</th></tr></thead><tbody>'+
 data.legacyRows.map(x=>'<tr><td><b>'+esc(x.name)+'</b><small style="display:block;color:#687b70">'+esc(x.id)+'</small></td><td>'+esc(x.effect)+'</td><td>'+esc(x.notes)+'</td></tr>').join("")+
 '</tbody></table></div><p class="ta-links">'+htmlAnchor("godot/src/simulation/traits/trait_system.gd",0,"Mã hệ cũ")+' · '+htmlAnchor("godot/tests/simulation/p2_9_traits_test.gd",0,"Bài kiểm thử nguồn P2.9")+'</p></section>';
}
function controls(data){
 const groups=[...new Set(data.traits.map(t=>t.group))].sort((a,b)=>a.localeCompare(b,"vi"));
 const count=data.summary;
 return '<div class="ta-summary">'+
 [['101','Đã có dữ liệu sinh','Không có nghĩa hiệu ứng đã chạy'],[String(count.designEffectSpecified),'Đã ghi hiệu ứng trong thiết kế','Vẫn thiếu kết nối gameplay'],[String(count.dependencyBlocked),'Bị chặn bởi cơ chế phụ thuộc','Chưa đủ điều kiện bật'],[String(count.conceptNotApproved),'Chưa duyệt cách hoạt động','Cần chốt thiết kế trước']].map(x=>'<div class="ta-metric"><strong>'+x[0]+'</strong><span>'+x[1]+'</span><small>'+x[2]+'</small></div>').join("")+'</div>'+
 '<div class="ta-intro"><h2>Hiểu đúng trạng thái</h2><p><span class="ta-status ta-code">Đã code danh tính</span> có nghĩa tên/nhóm/trọng số có trong mã tạo đệ tử, <b>không phải</b> đã cộng sát thương hay EXP.</p>'+
 '<p><span class="ta-status ta-warn">Có thiết kế</span> chỉ là tỷ lệ và điều kiện dự định áp dụng. <span class="ta-status ta-bad">Bị chặn</span> tức là còn thiếu điều kiện đi kèm. <span class="ta-status ta-concept">Chưa duyệt</span> là ý tưởng, kể cả có ghi con số.</p>'+
 '<div class="ta-rule"><strong>Chốt kiểm toán:</strong> '+count.total+' danh tính đã lập; <b>0/101 hiệu ứng V2 được xác minh có kiểm thử chạy thực tế theo từng ID</b>. Không coi 9 đặc tính P2.9 là bằng chứng hoàn thành V2. Đã code dữ liệu sinh không đồng nghĩa gameplay hoàn chỉnh.</div></div>'+
 '<div class="ta-section-head"><h2>Tra cứu chi tiết 101 đặc tính</h2><p>Lọc để xem đúng phần đang thiếu</p></div>'+
 '<div class="ta-controls">'+
 '<label>Tìm tên hoặc tác dụng<input id="ta-query" type="search" placeholder="Ví dụ: Ham Học, +10%, hồi máu…"></label>'+
 '<label>Tiến độ<select id="ta-status"><option value="all">Tất cả</option><option value="EFFECT_SPEC_PENDING">Có thiết kế, thiếu code</option><option value="DEPENDENCY_BLOCKED">Thiếu cơ chế phụ thuộc</option><option value="CONCEPT_UNAPPROVED">Chưa chốt thiết kế</option><option value="legacy">Có hiệu ứng cũ khác V2</option></select></label>'+
 '<label>Nhóm<select id="ta-group"><option value="all">Tất cả nhóm</option>'+groups.map(g=>'<option value="'+esc(g)+'">'+esc(g)+'</option>').join("")+'</select></label>'+
 '<label>Tính chất<select id="ta-nature"><option value="all">Tất cả</option><option value="H">Có lợi</option><option value="S">Hai mặt</option><option value="B">Bất lợi</option></select></label>'+
 '<label>Khả năng sinh<select id="ta-birth"><option value="all">Tất cả</option><option value="yes">Được sinh ngẫu nhiên</option><option value="no">Bị loại khỏi sinh</option></select></label>'+
 '</div><p class="fine" id="ta-count"></p><div class="ta-cards" id="ta-results"></div>'+
 legacyTable(data)+'<div class="ta-rule">Việc ưu tiên: (1) Chốt nơi áp dụng EXP học và EXP nghề; (2) nối đúng ID V2 thay vì dùng hiệu ứng hệ cũ; (3) sửa các xung đột đặc biệt Cẩu Thả/Kinh Mạch; (4) chạy test trước–sau, trạng thái bật/tắt và lưu/tải; (5) mới đánh dấu ĐÃ CHẠY.</div>';
}
function paint(){
 const d=ui.data;if(!d)return;
 const q=normal(ui.query);
 const rows=d.traits.filter(t=>(ui.status==="all"||ui.status==="legacy"&&t.legacyAnalogue||t.designClass===ui.status)&&
 (ui.group==="all"||t.group===ui.group)&&
 (ui.nature==="all"||t.nature===ui.nature)&&
 (ui.birth==="all"||(ui.birth==="yes"?t.birthAvailable:!t.birthAvailable))&&
 (!q||normal(t.name+" "+t.designEffectVi+" "+t.group+" "+t.id).includes(q)));
 $("ta-count").textContent="Hiển thị "+fmt(rows.length)+" / "+fmt(d.traits.length)+" đặc tính. Chọn 'Xem việc còn thiếu' để mở chứng cứ.";
 $("ta-results").innerHTML=rows.length?rows.map(card).join(""):'<div class="ta-empty">Không có đặc tính phù hợp bộ lọc.</div>';
}
$("menu-toggle").addEventListener("click",()=>$("sidebar").classList.toggle("open"));
$("audit-root").addEventListener("input",e=>{if(e.target.id==="ta-query"){ui.query=e.target.value;paint();}});
$("audit-root").addEventListener("change",e=>{const dict={"ta-status":"status","ta-group":"group","ta-nature":"nature","ta-birth":"birth"};const k=dict[e.target.id];if(k){ui[k]=e.target.value;paint();}});
$("top-search").addEventListener("input",e=>{ui.query=e.target.value;const f=$("ta-query");if(f)f.value=ui.query;paint();});
if(!["localhost","127.0.0.1","::1","vuanhtuan161094-byte.github.io"].includes(host)){
 $("audit-root").innerHTML='<div class="ta-rule">Trang này chỉ phục vụ trên GitHub Pages Tông Môn Bá Đạo hoặc máy chủ localhost hợp lệ.</div>';return;
}
fetch("./data/trait_effect_audit.json",{cache:"no-store"}).then(r=>{if(!r.ok)throw Error("HTTP "+r.status);return r.json();}).then(d=>{
 if(d.traits?.length!==101||d.summary.designEffectSpecified!==41||d.summary.dependencyBlocked!==12||d.summary.conceptNotApproved!==48||d.legacyRows?.length!==9)throw Error("Dữ liệu kiểm toán không hợp lệ");
 ui.data=d;$("audit-root").innerHTML=controls(d);paint();
 const key=location.hash.slice(1);if(key){const tr=d.traits.find(x=>x.id===key);if(tr){ui.query=tr.name;$("ta-query").value=tr.name;paint();document.getElementById("trait-"+tr.id)?.scrollIntoView({block:"start"});}}
}).catch(e=>$("audit-root").innerHTML='<div class="ta-rule">Không thể tải báo cáo đặc tính: '+esc(e.message)+'</div>');
})();