(() => {
  'use strict';
  const STORAGE = { proposals: 'tmb.wiki.design-proposals.v1', requests: 'tmb.wiki.change-requests.v1' };
  const page = document.querySelector('#page');
  const nav = document.querySelector('#nav');
  const searchInput = document.querySelector('#global-search');
  const state = { catalog: null, progress: null, view: 'dashboard', selected: null, selectedSkillId: '', query: '', statusFilter: 'all', schoolFilter: 'all', page: 0, progressPage: 0, progressFilters: { query: '', school: 'all', branch: 'all', axis: 'all', status: 'all' } };
  const titles = { dashboard:'Bảng phát triển', progress:'Tiến độ kỹ năng V2', 'skill-detail':'Chi tiết kỹ năng', work:'Việc cần xử lý', gaps:'Gap Analysis', schools:'Môn phái', branches:'36 nhánh', skills:'Kỹ năng V6.3', techniques:'Công pháp', realms:'Cảnh giới', disciples:'Đệ tử & thuộc tính', roots:'Linh căn', medicine:'Đan dược', equipment:'Trang bị', resources:'Tài nguyên', vfx:'VFX & asset', editor:'Design Editor', requests:'Change Request Manager' };
  const labels = { id:'ID', name:'Tên', schoolName:'Môn phái', schoolId:'School ID', branchId:'Nhánh', generation:'Cảnh giới skill', slot:'Slot', element:'Ngũ hành', effect:'Hiệu ứng catalog', damageRatio:'damage_ratio', range:'Tầm', castTime:'Cast time', cooldown:'Cooldown', shape:'Hình dạng', radius:'Bán kính', targetLimit:'Giới hạn mục tiêu', power:'Power', duration:'Thời lượng', poisonStacks:'Độc stack', animationKey:'Animation key', vfxKey:'VFX key', sourceCodexId:'Codex ID', candidateStatus:'Candidate', balanceStatus:'Balance', formulaStatus:'Nguồn công thức', presentationStatus:'Presentation', runtimeStatus:'Runtime', artStatus:'Mỹ thuật', silhouette:'Silhouette', motionSignature:'Motion', skillCount:'Skill IDs', inD1Registry:'D1 registry', cultivationName:'Tu Vi', bodyName:'Luyện Thể', rank:'Thứ tự', family:'Nhóm', realm:'Cảnh giới', quality:'Chất lượng', craftability:'Chế tạo', slot:'Slot', path:'Path', realmRank:'Hạng cảnh giới', eventCount:'Event cue', assetFileCount:'Asset file', foundationAttributes:'Sáu nền tảng', sourcePath:'Source path', sourceSha:'Source SHA-256', version:'Version', qaEvidence:'QA evidence' };

  function esc(value) {
    return String(value ?? '').replace(/[&<>"']/g, char => ({ '&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#39;' }[char]));
  }
  function textValue(value) {
    if (value === null || value === undefined || value === '') return '—';
    if (typeof value === 'object') return JSON.stringify(value);
    if (typeof value === 'boolean') return value ? 'Có' : 'Không';
    return String(value);
  }
  function normalize(value) {
    return String(value ?? '').toLowerCase().replace(/[đĐ]/g, 'd').normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  }
  function currentArray(view) {
    const c = state.catalog;
    const map = { schools:c.schools, branches:c.branches, skills:c.skills, techniques:c.techniques, realms:c.realms, disciples:c.disciples, roots:c.spiritualRoots, medicine:c.medicine, equipment:c.equipmentRecipes, resources:c.resources, vfx:c.vfx, gaps:c.gaps };
    if (view === 'equipment') return [...c.equipmentRecipes, c.equipmentAuthority];
    return map[view] || [];
  }
  function proposalRows() { try { return JSON.parse(localStorage.getItem(STORAGE.proposals) || '[]'); } catch { return []; } }
  function requestRows() { try { return JSON.parse(localStorage.getItem(STORAGE.requests) || '[]'); } catch { return []; } }
  function persist(key, rows) { localStorage.setItem(key, JSON.stringify(rows)); updateCounters(); }
  function updateCounters() {
    document.querySelector('#gap-count').textContent = String(state.catalog?.gaps?.length || 0);
    document.querySelector('#request-count').textContent = String(requestRows().filter(row => !['DONE','REJECTED'].includes(row.status)).length);
  }
  function setView(view) {
    state.view = view; state.page = 0; state.query = '';
    if (searchInput) searchInput.value = '';
    nav.querySelectorAll('[data-view]').forEach(button => button.classList.toggle('active', button.dataset.view === (view === 'skill-detail' ? 'progress' : view)));
    document.querySelector('#crumb-title').textContent = titles[view] || view;
    document.querySelector('#sidebar').classList.remove('open');
    render();
  }
  function pageHead(title, desc, meta = '') {
    return `<div class="page-head"><div><div class="eyebrow">TMB · DESIGN CONTROL</div><h1>${esc(title)}</h1><p>${esc(desc)}</p></div><div class="head-meta">${meta}</div></div>`;
  }
  function statusBadge(value) {
    const s = String(value || 'UNKNOWN');
    let tone = 'gray';
    if (/LIVE|PRESENT|AUTHORED|PASS|APPROVED|SUCCESS/.test(s)) tone = 'green';
    if (/GATED|PENDING|DESIGN|UNKNOWN|NOT_|MISSING|DIVERGE|OFF|DISABLED/.test(s)) tone = 'gold';
    if (/BLOCKER|FAIL|CONFLICT/.test(s)) tone = 'red';
    return `<span class="badge ${tone}">${esc(s.replaceAll('_',' '))}</span>`;
  }
  function tracePanel(item) {
    const qa = item.qaEvidence || {};
    const path = item.sourcePath || '';
    const sourceLink = path ? `<a href="/${esc(path)}" target="_blank" rel="noopener">${esc(path)}</a>` : 'Không có nguồn';
    const qaLink = qa.sourcePath ? `<a href="/${esc(qa.sourcePath)}" target="_blank" rel="noopener">${esc(qa.sourcePath)}</a>` : 'Chưa liên kết bằng chứng';
    const extra = item.additionalSourcePath ? `<div class="trace-line"><span>Nguồn bổ sung</span><b><a href="/${esc(item.additionalSourcePath)}" target="_blank" rel="noopener">${esc(item.additionalSourcePath)}</a><br>${esc(item.additionalSourceSha || '')}</b></div>` : '';
    return `<div class="trace"><h3>Traceability · không suy diễn trạng thái</h3>
      <div class="trace-line"><span>Source path</span><b>${sourceLink}</b></div>
      <div class="trace-line"><span>Source SHA-256</span><b>${esc(item.sourceSha || 'UNKNOWN')}</b></div>
      <div class="trace-line"><span>Version</span><b>${esc(textValue(item.version))}</b></div>
      ${extra}
      <div class="trace-line"><span>Runtime</span><b>${statusBadge(item.runtimeStatus || 'UNKNOWN')}</b></div>
      <div class="trace-line"><span>QA source / status</span><b>${qaLink}<br>${esc(qa.status || 'UNKNOWN')}</b></div>
      <div class="trace-line"><span>Owner approval</span><b>${esc(item.approvalStatus || 'UNKNOWN / không có bản ghi phê duyệt theo ID')}</b></div>
    </div>`;
  }
  function detailPanel(item, kind) {
    if (!item) return `<div class="panel detail-panel"><div class="empty">Chọn một dòng để xem chi tiết, nguồn, phiên bản, trạng thái runtime và QA.</div></div>`;
    const id = item.id || item.schoolId || '—';
    const name = item.name || item.title || id;
    const exclude = new Set(['sourcePath','sourceSha','version','exists','additionalSourcePath','additionalSourceSha','qaEvidence','description','long_description_vi','short_description_vi','flavor_vi','mechanics_tooltip_template']);
    const fields = Object.entries(item).filter(([key,value]) => !exclude.has(key) && value !== '' && value !== null && value !== undefined && typeof value !== 'object').slice(0,18);
    const description = item.description || item.summary || item.silhouette || '';
    return `<div class="panel detail-panel"><div class="detail-title"><h2>${esc(name)}</h2><div class="id">${esc(id)}</div><div class="status-strip">${statusBadge(item.runtimeStatus || item.status || 'UNKNOWN')}${item.candidateStatus ? statusBadge(item.candidateStatus) : ''}${item.balanceStatus ? statusBadge(item.balanceStatus) : ''}</div></div>
      <div class="detail-content">${description ? `<p class="detail-description">${esc(description)}</p>` : ''}<div class="detail-grid">${fields.map(([key,value]) => `<div class="detail-cell"><small>${esc(labels[key] || key)}</small><b>${esc(textValue(value))}</b></div>`).join('')}</div>${tracePanel(item)}<div class="detail-actions"><button class="button secondary" data-edit-id="${esc(id)}">Đề xuất thay đổi</button></div></div></div>`;
  }
  function dashboard() {
    const c = state.catalog.counts;
    const systemCards = state.catalog.systems;
    const cards = [
      ['12','Môn phái trong thiết kế',`${c.schools} ID taxonomy · nguồn V6.3`,'schools'],
      ['36','Nhánh đã thiết kế',`${c.branches} dòng art guide · chưa là animation runtime`,'branches'],
      [c.skills.toLocaleString('vi-VN'),'Skill V6.3 trong catalog',`${c.skillIdsUnique} ID duy nhất · candidate`,'skills'],
      [String(c.v63Enabled),'Skill gate đang bật','V6.3 release gate OFF','gaps'],
      [String(c.techniques),'Công pháp catalog',`learning gate OFF · ${c.techniques} ID nguồn`,'techniques'],
      [String(c.realms),'Đại cảnh giới',`30 Tu Vi + 30 Luyện Thể · QA còn mở`,'realms'],
      [String(c.medicineIdentities),'Định danh đan dược',`${c.authoredMedicineRecipes} recipe V2 + ${c.legacyMedicineRecipes} legacy`,'medicine'],
      [String(c.presentationEntries),'Presentation metadata',`${c.presentationMissing} skill chưa link · metadata ≠ artwork`,'vfx'],
    ];
    const dashboardValueLabels = {
      NOT_IN_RELEASE_SCOPE_WHILE_GATE_OFF: 'Ngoài phạm vi<br>(gate OFF)',
      AUTHORITY_DIVERGENCE: 'Chờ quyết định',
    };
    const dashboardCell = (value, pending = false) => {
      const raw = textValue(value);
      const label = dashboardValueLabels[raw] || esc(raw);
      return `<div class="system-num${pending ? ' pending' : ''}" title="${esc(raw)}">${label}</div>`;
    };
    const statusRow = (sys) => `<div class="system-row"><div class="system-cell"><strong>${esc(sys.name)}</strong><small>${esc(sys.runtimeStatus)}</small></div>${dashboardCell(sys.designed)}${dashboardCell(sys.implemented)}${dashboardCell(sys.tested, true)}${dashboardCell(sys.approved, true)}${dashboardCell(sys.missing)}</div>`;
    const gaps = state.catalog.gaps.slice(0,4).map(gap => `<div class="gap-row"><div><h3>${esc(gap.title)}</h3><p>${esc(gap.summary)}</p></div>${statusBadge(gap.severity)}</div>`).join('');
    return `${pageHead('Bảng phát triển','Bảng điều hành thiết kế nội bộ. Mỗi số liệu có thể mở về nguồn; trạng thái thiếu bằng chứng luôn để PENDING hoặc UNKNOWN.',`SOURCE HEAD<br><b>${esc(state.catalog.sourceCommitSha.slice(0,12))}</b><br>12 · 36 · schema ${esc(state.catalog.schemaVersion)}`)}
      <div class="stat-grid">${cards.map(([value,label,note,view]) => `<button class="stat-card" data-go="${view}" style="text-align:left;color:inherit"><div class="stat-label">${esc(label)}</div><div class="stat-value">${esc(value)}</div><div class="stat-note">${esc(note)}</div></button>`).join('')}</div>
      ${state.progress ? `<div class="v2-callout"><div><small>V2 · COVERAGE PER SKILL</small><strong>${state.progress.summary.skillCandidates.toLocaleString('vi-VN')} skill candidate · ${state.progress.summary.directVfxPackets} packet theo đúng ID</strong><span>V6.3 OFF · animation từng skill UNKNOWN nếu chưa có mapping · Owner art độc lập với TECH QA.</span></div><button class="button" data-go="progress">Mở bảng tiến độ →</button></div>` : ''}
      <div class="section-grid"><div class="panel"><div class="panel-head"><div><h2>Tiến độ hệ thống</h2><small>Designed / implemented / tested / approved / missing · dữ liệu gắn nguồn</small></div><span class="badge blue">LIVE SOURCE SNAPSHOT</span></div><div class="panel-body"><div class="system-row header"><div>Hệ thống</div><div class="system-num">Thiết kế</div><div class="system-num">Mã/registry</div><div class="system-num">Đã test</div><div class="system-num">Đã duyệt</div><div class="system-num">Còn thiếu</div></div>${systemCards.map(statusRow).join('')}<p class="footnote">“Đã có code” không đồng nghĩa release/live. Test source chưa được chạy lại tại exact Wiki SHA nên hiển thị PENDING; phê duyệt owner không có nguồn ID thì hiển thị UNKNOWN.</p></div></div>
        <div class="panel"><div class="panel-head"><div><h2>Gap cần chú ý</h2><small>${state.catalog.gaps.length} vấn đề có nguồn</small></div><button class="link-button" data-go="gaps">Mở danh sách</button></div><div class="panel-body">${gaps}</div></div></div>
      <div class="section-grid"><div class="panel"><div class="panel-head"><div><h2>Coverage nguồn</h2><small>Snapshot sinh tự động, không gồm save cá nhân</small></div><span class="badge green">SHA CHECKED</span></div><div class="panel-body"><div class="detail-grid"><div class="detail-cell"><small>Source HEAD</small><b>${esc(state.catalog.sourceCommitSha)}</b></div><div class="detail-cell"><small>Skill family / IDs</small><b>${esc(c.skillFamilies)} family · ${esc(c.skillIdsUnique)} skill</b></div><div class="detail-cell"><small>Đan</small><b>${esc(c.medicineIdentities)} identity · ${esc(c.authoredMedicineRecipes)} recipe V2 · ${esc(c.legacyMedicineRecipes)} legacy</b></div><div class="detail-cell"><small>Trang bị / resource</small><b>${esc(c.equipmentRecipes)} recipe · ${esc(c.resources)} resource ID</b></div></div><div class="notice">Nguồn có spec 10 slot trang bị nhưng EquipmentSystem đang dùng 3 slot; đây là gap cần chủ dự án quyết định, Wiki không tự hợp nhất.</div></div></div>
        <div class="panel"><div class="panel-head"><div><h2>Quy tắc trạng thái</h2><small>Ngăn nhầm thiết kế với sản phẩm</small></div></div><div class="panel-body"><div class="gap-row"><div><h3>SPEC_ONLY ≠ LIVE_VERIFIED</h3><p>Spec và catalog có thể tra cứu nhưng không tự chứng minh runtime được bật.</p></div>${statusBadge('PENDING')}</div><div class="gap-row"><div><h3>TECH_PASS ≠ ART_APPROVED</h3><p>Test code không phải nghiệm thu hình ảnh hoặc animation.</p></div>${statusBadge('UNKNOWN')}</div><div class="gap-row"><div><h3>Wiki proposal ≠ gameplay source</h3><p>Phê duyệt ở đây chỉ ghi quyết định/đề nghị; thay đổi game cần packet code và QA riêng.</p></div>${statusBadge('LOCAL ONLY')}</div></div></div></div>`;
  }
  function renderGaps() {
    const rows = state.catalog.gaps.filter(item => !state.query || normalize(`${item.id} ${item.title} ${item.summary} ${item.category} ${item.status}`).includes(normalize(state.query)));
    const gapAction = item => item.severity === 'STATUS_ONLY' ? '<span class="badge blue">Chỉ theo dõi</span>' : `<button class="small-button" data-create-gap-cr="${esc(item.id)}">Tạo CR</button>`;
    return `${pageHead('Gap Analysis','So sánh spec, registry, runtime, asset/VFX, QA và release. Các gap là tín hiệu có bằng chứng, không tự sửa gameplay.',`${rows.length} GAP<br>đọc từ ${esc(state.catalog.sourceCommitSha.slice(0,12))}`)}
      <div class="toolbar"><input id="gap-search" placeholder="Lọc gap theo ID, nhóm, tình trạng…" value="${esc(state.query)}"><select id="gap-severity"><option value="all">Mọi mức độ</option>${[...new Set(state.catalog.gaps.map(g=>g.severity))].map(s=>`<option value="${esc(s)}">${esc(s)}</option>`).join('')}</select></div>
      <div class="panel"><div class="panel-head"><div><h2>Gap register</h2><small>Chỉ gap cần quyết định mới có hành động tạo CR</small></div>${statusBadge('SOURCE-BACKED')}</div><div class="panel-body" id="gap-list">${rows.map(item=>`<article class="gap-row" data-gap-severity="${esc(item.severity)}"><div><h3>${esc(item.id)} · ${esc(item.title)}</h3><p class="gap-summary">${esc(item.summary)}</p><div class="gap-sources"><span class="pill">${esc(item.category)}</span><span class="pill">${esc(item.status)}</span><span class="pill">${esc(item.sourcePath)}</span><span class="pill">SHA ${esc(item.sourceSha.slice(0,12))}</span></div></div><div style="display:grid;gap:7px;justify-items:end">${statusBadge(item.severity)}${gapAction(item)}</div></article>`).join('') || '<div class="empty">Không có gap khớp bộ lọc.</div>'}</div></div>
      <p class="footnote">Duplicate skill ID được kiểm bằng validator. Cặp kỹ năng cùng ID là 0 tại snapshot; tương đồng thiết kế/tên chưa được coi là lỗi nếu chưa có tiêu chí đủ bằng chứng.</p>`;
  }
  function recordId(item) { return item.id || item.schoolId || ''; }
  function recordName(item) { return item.name || item.title || item.id || ''; }
  function rowSub(item, view) {
    if (view === 'skills') return `${item.schoolName || ''} · ${item.branchId || 'common'} · ${item.generation || ''} · ${item.slot || ''}`;
    if (view === 'branches') return `${item.schoolName || ''} · ${item.motionSignature || ''}`;
    if (view === 'medicine') return `${item.family} · Cảnh ${item.realm} · phẩm ${item.quality} · ${item.craftability}`;
    if (view === 'realms') return `Tu Vi ${item.cultivationName} · Luyện Thể ${item.bodyName}`;
    if (view === 'techniques') return `${item.schoolName} · ${item.branchId} · ${item.generation}`;
    if (view === 'equipment') return `${item.slot || ''} · ${item.path || ''}`;
    if (view === 'resources') return `${item.family} · rank ${item.realmRank ?? 'UNKNOWN'}`;
    return item.id === 'equipment_authority' ? `VALID_SLOTS: ${item.runtimeSlots?.join(', ')}` : (item.id || '');
  }
  function listFor(view) { return currentArray(view); }
  function catalogView(view) {
    const rows = listFor(view);
    const query = normalize(state.query);
    const selectedSchool = state.schoolFilter;
    let filtered = rows.filter(item => {
      const searchText = normalize(Object.entries(item).filter(([key])=>!['qaEvidence'].includes(key)).map(([,v])=>typeof v === 'object' ? JSON.stringify(v) : v).join(' '));
      if (query && !searchText.includes(query)) return false;
      if (selectedSchool !== 'all' && item.schoolId && item.schoolId !== selectedSchool) return false;
      if (state.statusFilter !== 'all' && !String(item.runtimeStatus || item.status || '').includes(state.statusFilter)) return false;
      return true;
    });
    filtered = filtered.sort((a,b)=>recordName(a).localeCompare(recordName(b),'vi'));
    const pageSize = view === 'skills' || view === 'medicine' ? 50 : 60;
    const start = state.page * pageSize;
    const visible = filtered.slice(start,start+pageSize);
    if (!state.selected || !rows.some(row => recordId(row) === state.selected.id)) state.selected = visible[0] ? { id: recordId(visible[0]), kind:view } : null;
    const selected = state.selected ? rows.find(row => recordId(row) === state.selected.id) : null;
    const filters = `<div class="toolbar"><input id="catalog-search" placeholder="Tìm trong ${esc(titles[view])}…" value="${esc(state.query)}"><select id="catalog-status"><option value="all" ${state.statusFilter==='all'?'selected':''}>Mọi trạng thái runtime</option><option value="GATED_OFF" ${state.statusFilter==='GATED_OFF'?'selected':''}>GATED_OFF</option><option value="DESIGN_ONLY" ${state.statusFilter==='DESIGN_ONLY'?'selected':''}>DESIGN_ONLY</option><option value="PRESENT" ${state.statusFilter==='PRESENT'?'selected':''}>PRESENT / CODE</option><option value="PENDING" ${state.statusFilter==='PENDING'?'selected':''}>PENDING / UNKNOWN</option></select>${['skills','techniques','branches'].includes(view)?`<select id="catalog-school"><option value="all">Tất cả môn phái</option>${state.catalog.schools.map(s=>`<option value="${esc(s.id)}" ${selectedSchool===s.id?'selected':''}>${esc(s.name)}</option>`).join('')}</select>`:''}<span class="mobile-count">${filtered.length.toLocaleString('vi-VN')} mục</span></div>`;
    const tableRows = visible.map(item=>`<tr data-record="${esc(recordId(item))}" data-record-kind="${esc(view)}"><td><div class="primary">${esc(recordName(item))}</div><div class="sub">${esc(rowSub(item,view))}</div></td><td><code>${esc(recordId(item))}</code></td><td>${statusBadge(item.runtimeStatus || item.status || 'UNKNOWN')}</td><td>${esc(item.sourcePath || '')}<div class="sub">${esc((item.sourceSha||'').slice(0,12))}</div></td></tr>`).join('');
    const pager = `<div class="panel-head"><small>Hiển thị ${filtered.length ? start+1 : 0}–${Math.min(start+pageSize,filtered.length)} / ${filtered.length}</small><div class="head-actions"><button class="small-button" data-page="-1" ${start===0?'disabled':''}>‹ Trước</button><button class="small-button" data-page="1" ${start+pageSize>=filtered.length?'disabled':''}>Tiếp ›</button></div></div>`;
    return `${pageHead(titles[view],catalogDescriptions[view] || 'Bản ghi có liên kết source path, source SHA, phiên bản, runtime status và QA evidence.',`${rows.length.toLocaleString('vi-VN')} BẢN GHI<br>${esc(state.catalog.sourceCommitSha.slice(0,12))}`)}${filters}<div class="catalog-layout"><div class="panel"><div class="panel-head"><div><h2>Danh mục tra cứu</h2><small>Chọn một hàng để xem field và traceability</small></div>${statusBadge('ONE-WAY SNAPSHOT')}</div><div class="table-wrap"><table class="data-table"><thead><tr><th>Tên / mô tả ngắn</th><th>ID</th><th>Trạng thái</th><th>Nguồn / SHA</th></tr></thead><tbody>${tableRows || '<tr><td colspan="4" class="empty">Không tìm thấy bản ghi phù hợp.</td></tr>'}</tbody></table></div>${pager}</div>${detailPanel(selected,view)}</div>`;
  }
  const catalogDescriptions = {
    schools:'12 trường phái theo design authority; đối chiếu registry D1, không gán nhánh chưa có nguồn.',
    branches:'36 nhánh từ art guide; pose/motion là thiết kế, không có nghĩa đã tồn tại clip.',
    skills:'2.196 skill IDs từ catalog V6.3. Mọi giá trị hệ số là dữ liệu candidate, gate OFF; không phải authority runtime live.',
    techniques:'Công pháp theo learning catalog; phân biệt định nghĩa dữ liệu với hệ học công pháp đã bật.',
    realms:'Hai đường tiến trình Tu Vi và Luyện Thể lấy tên từ DiscipleRealmProgressV2. Checkpoint DV2-03 QA vẫn mở.',
    disciples:'Mô hình canonical của đệ tử và sáu thuộc tính nền; không nạp save hoặc dữ liệu đệ tử cá nhân.',
    roots:'Linh Căn V2: thiết kế và code được liên kết riêng, feature gate vẫn OFF.',
    medicine:'Định danh catalog không đồng nghĩa có recipe. Recipe V2 và recipe legacy được tách status.',
    equipment:'Đối chiếu EquipmentSystem đang có với spec; Wiki không tự chọn một authority thay cho chủ dự án.',
    resources:'Tài nguyên từ ResourceRegistry. Giá trị/spec không có consumer được đánh dấu rõ.',
    vfx:'Manifest VFX, presentation metadata và capture status; không coi manifest là asset đã duyệt.',
  };
  function findRecord(id) {
    const all = ['schools','branches','skills','techniques','realms','disciples','roots','medicine','equipment','resources','vfx'].flatMap(view=>listFor(view));
    return all.find(item => recordId(item) === id) || null;
  }
  function currentField(recordIdValue, fieldPath) {
    const item = findRecord(recordIdValue);
    if (!item || !fieldPath) return { found:false, value:null };
    const keys = fieldPath.split('.').filter(Boolean);
    let value = item;
    for (const key of keys) { if (value === null || typeof value !== 'object' || !(key in value)) return {found:false,value:null}; value = value[key]; }
    return { found:true, value };
  }
  function editorView() {
    const chosenId = state.selected?.id || '';
    const record = chosenId ? findRecord(chosenId) : null;
    const before = record ? JSON.stringify(record, null, 2) : '{}';
    const proposals = proposalRows().slice().reverse();
    return `${pageHead('Design Editor','Ghi giá trị đề xuất, lý do và ghi chú. Mọi thay đổi chỉ nằm trong local profile; nguồn game không bị ghi.',`${proposals.length} PROPOSAL<br>${state.catalog.counts.approvedFromExplicitSource} phê duyệt được ghi nguồn`)}
      ${ownerBackupControls()}
      <div class="notice">Chế độ đề xuất. Nút lưu chỉ ghi vào localStorage của browser. Không có đường ghi ngược vào godot/, spec hoặc source runtime.</div>
      <div class="two-column"><div class="panel"><div class="panel-head"><div><h2>Soạn đề xuất</h2><small>Chọn ID trong danh mục rồi nêu field cụ thể</small></div>${statusBadge('NO SOURCE WRITE')}</div><div class="panel-body"><form id="proposal-form" class="form-grid">
        <div class="field"><label for="p-id">ID liên quan</label><input id="p-id" class="form-control" list="record-ids" value="${esc(chosenId)}" placeholder="tmb.skill…"><datalist id="record-ids">${allRecordIds().map(item=>`<option value="${esc(item.id)}">${esc(item.name)}</option>`).join('')}</datalist></div>
        <div class="field"><label for="p-field">Field path</label><input id="p-field" class="form-control" placeholder="ví dụ: cooldown"></div>
        <div class="field"><label>Giá trị hiện tại (snapshot)</label><textarea id="p-before" class="form-control tall" readonly>${esc(before)}</textarea></div>
        <div class="field"><label for="p-after">Giá trị đề xuất · JSON hoặc text</label><textarea id="p-after" class="form-control tall" placeholder='ví dụ: 2.4 hoặc "nội dung đề xuất"'></textarea></div>
        <div class="field"><label for="p-note">Ghi chú</label><textarea id="p-note" class="form-control" placeholder="Ghi chú nội bộ…"></textarea></div>
        <div class="field"><label for="p-reason">Lý do chỉnh sửa</label><textarea id="p-reason" class="form-control" placeholder="Vì sao cần thay đổi?"></textarea></div>
        <div class="field full"><div class="compare-box"><div><small>Trước · snapshot source</small><pre id="compare-before">${esc(before)}</pre></div><div><small>Sau · đề xuất local</small><pre id="compare-after">Chưa nhập đề xuất</pre></div></div></div>
        <div class="field full"><div class="head-actions"><button class="button" type="submit">Lưu đề xuất local</button><button class="button secondary" type="button" id="proposal-export">Xuất bản sao JSON</button><button class="button secondary" type="button" id="proposal-import">Nhập JSON</button><input type="file" id="proposal-file" accept="application/json" hidden></div></div>
      </form></div></div><div class="panel"><div class="panel-head"><div><h2>Đề xuất gần đây</h2><small>Không bị source sync ghi đè</small></div><span class="badge blue">LOCAL PROFILE</span></div><div class="panel-body">${proposals.slice(0,8).map(proposalCard).join('') || '<div class="empty-state">Chưa có đề xuất. Chọn một item ở Danh mục rồi bấm “Đề xuất thay đổi”.</div>'}</div></div></div>`;
  }
  function allRecordIds() {
    const arr = ['schools','branches','skills','techniques','realms','disciples','roots','medicine','equipment','resources','vfx'].flatMap(view=>listFor(view));
    return arr.map(item=>({id:recordId(item),name:recordName(item)})).filter(item=>item.id);
  }
  function proposalCard(row) {
    return `<article class="proposal-card"><span class="badge gold proposal-status">${esc(row.status || 'DRAFT')}</span><h3>${esc(row.relatedId || 'Chưa gắn ID')} · ${esc(row.fieldPath || 'Field chưa ghi')}</h3><p>${esc(row.reason || row.note || 'Chưa có lý do')}</p><p>${esc(JSON.stringify(row.before ?? null))} → ${esc(JSON.stringify(row.after ?? null))}</p><p>${esc(new Date(row.createdAt).toLocaleString('vi-VN'))}</p><div class="card-actions"><button class="small-button" data-proposal-cr="${esc(row.localId)}">Tạo CR</button><button class="small-button" data-delete-proposal="${esc(row.localId)}">Xóa local</button></div></article>`;
  }
  function requestView() {
    const rows = requestRows().slice().reverse();
    return `${pageHead('Change Request Manager','Tạo danh sách việc cần Codex sửa. CR không kích hoạt thay đổi code; trạng thái chỉ là tiến độ quản trị nội bộ.',`${rows.length} CR LOCAL<br>${rows.filter(r=>r.status==='DONE').length} DONE · owner-only`)}
      ${ownerBackupControls()}
      <div class="two-column"><div class="panel"><div class="panel-head"><div><h2>Tạo Change Request</h2><small>ID, before/after, priority và tiêu chí nghiệm thu bắt buộc</small></div>${statusBadge('DRAFT')}</div><div class="panel-body"><form id="cr-form" class="form-grid">
        <div class="field"><label for="cr-title">Tiêu đề</label><input id="cr-title" class="form-control" required placeholder="Ví dụ: Link VFX skill ID…"></div>
        <div class="field"><label for="cr-id">ID liên quan</label><input id="cr-id" class="form-control" list="record-ids" value="${esc(state.selected?.id || '')}" placeholder="ID source"><datalist id="record-ids">${allRecordIds().map(item=>`<option value="${esc(item.id)}">${esc(item.name)}</option>`).join('')}</datalist></div>
        <div class="field"><label for="cr-before">Dữ liệu hiện tại</label><textarea id="cr-before" class="form-control" placeholder="Giá trị/source evidence hiện tại…"></textarea></div>
        <div class="field"><label for="cr-after">Dữ liệu đề xuất</label><textarea id="cr-after" class="form-control" placeholder="Giá trị mong muốn; không ghi ngược vào code"></textarea></div>
        <div class="field"><label for="cr-priority">Ưu tiên</label><select id="cr-priority" class="form-control"><option>P0</option><option selected>P1</option><option>P2</option><option>P3</option></select></div>
        <div class="field"><label for="cr-status">Trạng thái</label><select id="cr-status" class="form-control"><option>DRAFT</option><option>READY_FOR_OWNER_REVIEW</option><option>APPROVED_FOR_CODE_PACKET</option><option>IN_PROGRESS</option><option>QA_PENDING</option><option>DONE</option><option>REJECTED</option></select></div>
        <div class="field full"><label for="cr-criteria">Tiêu chí nghiệm thu</label><textarea id="cr-criteria" class="form-control" required placeholder="Điều kiện quan sát/test cụ thể để đóng CR…"></textarea></div>
        <div class="field full"><label for="cr-note">Ghi chú nội bộ</label><textarea id="cr-note" class="form-control" placeholder="Chỉ lưu trong browser profile."></textarea></div>
        <div class="field full"><button type="submit" class="button">Lưu Change Request local</button></div>
      </form></div></div><div class="panel"><div class="panel-head"><div><h2>Backlog nội bộ</h2><small>Đổi trạng thái không đồng nghĩa đã thực thi</small></div><div class="head-actions"><button class="small-button" id="cr-import">Nhập JSON</button><input type="file" id="cr-file" accept="application/json" hidden><button class="small-button" id="cr-export">Xuất JSON</button></div></div><div class="panel-body">${rows.map(requestCard).join('') || '<div class="empty-state">Chưa có CR local. Tạo mới hoặc chuyển gap thành CR.</div>'}</div></div></div>
      <div class="notice">“APPROVED_FOR_CODE_PACKET” chỉ là ghi chú local, không tự tạo quyền sửa hệ thống. Gói code vẫn phải được Owner yêu cầu/cho phép riêng và qua QA.</div>`;
  }
  function requestCard(row) {
    return `<article class="proposal-card"><span class="badge ${row.priority==='P0'?'red':'gold'} proposal-status">${esc(row.priority)}</span><h3>${esc(row.title)} <span class="badge blue">${esc(row.status)}</span></h3><p>ID: ${esc(row.relatedIds || row.relatedId || '—')}</p><p>Hiện tại: ${esc(row.current || '—')}</p><p>Đề xuất: ${esc(row.proposed || '—')}</p><p>Acceptance: ${esc(row.criteria || '—')}</p><p>${esc(row.note || '')}</p><div class="field"><label>Trạng thái thực hiện</label><select class="form-control" data-request-status="${esc(row.localId)}">${['DRAFT','READY_FOR_OWNER_REVIEW','APPROVED_FOR_CODE_PACKET','IN_PROGRESS','QA_PENDING','DONE','REJECTED'].map(status=>`<option ${row.status===status?'selected':''}>${status}</option>`).join('')}</select></div><div class="card-actions"><button class="small-button" data-delete-request="${esc(row.localId)}">Xóa local</button></div></article>`;
  }
  function changePage(delta) {
    state.page = Math.max(0, state.page + delta);
    render();
  }
  function progressAxisValue(row, axis) {
    if (axis === 'design') return row.design.status;
    if (axis === 'runtime') return row.runtime.status;
    if (axis === 'vfx') return row.vfx.technicalStatus;
    if (axis === 'animation') return row.animation.status;
    if (axis === 'qa') return row.qa.status;
    if (axis === 'owner') return row.vfx.ownerStatus;
    return 'ALL';
  }
  function renderProgress() {
    if (!state.progress) return pageHead('Tiến độ kỹ năng V2','Projection chưa được nạp. Kiểm tra source sync.', 'PENDING');
    const p = state.progress, f = state.progressFilters, allRows = p.skills;
    const axes = [['all','Mọi trục'],['design','Thiết kế'],['runtime','Runtime'],['vfx','VFX kỹ thuật'],['animation','Animation'],['qa','QA'],['owner','Owner Art']];
    const filtered = allRows.filter(row => {
      if (f.school !== 'all' && row.schoolId !== f.school) return false;
      if (f.branch !== 'all' && (f.branch === 'shared' ? row.branch !== 'shared' : row.branchId !== f.branch)) return false;
      if (f.axis !== 'all' && f.status !== 'all' && progressAxisValue(row,f.axis) !== f.status) return false;
      if (f.query && !normalize(JSON.stringify(row)).includes(normalize(f.query))) return false;
      return true;
    });
    const pageSize=40, pages=Math.max(1,Math.ceil(filtered.length/pageSize));
    state.progressPage=Math.min(state.progressPage,pages-1);
    const visible=filtered.slice(state.progressPage*pageSize,(state.progressPage+1)*pageSize);
    const statusSet=[...new Set(allRows.map(row=>progressAxisValue(row,f.axis)).filter(v=>v&&v!=='ALL'))].sort();
    const branches=p.branches.filter(b=>f.school==='all'||b.id.startsWith('tmb.branch.'+f.school+'.'));
    const sharedOption=allRows.some(row=>row.branch==='shared')?'<option value="shared" '+(f.branch==='shared'?'selected':'')+'>Dùng chung</option>':'';
    const s=p.summary;
    const cards=[
      [s.skillCandidates.toLocaleString('vi-VN'),'V6.3 candidate IDs','Metadata thiết kế · không active'],
      [s.runtimeActive.toLocaleString('vi-VN'),'Runtime active','V6.3 đang OFF'],
      [s.directVfxPackets.toLocaleString('vi-VN'),'Packet đúng skill ID','Có packet ≠ art approved'],
      [s.exactShaActionEvidenceSkills.toLocaleString('vi-VN'),'Skill có Action exact-SHA','Chỉ bằng chứng đã liên kết'],
      [s.ownerApprovedRecorded.toLocaleString('vi-VN'),'Owner Art approval ghi nhận','Raw ledger source'],
      [s.animationSkillMappingsVerified.toLocaleString('vi-VN'),'Skill→animation mapping','UNKNOWN đến khi có bằng chứng'],
    ];
    const rows=visible.map(row=>`<tr data-progress-skill="${esc(row.id)}"><td><b>${esc(row.name)}</b><code>${esc(row.id)}</code></td><td>${esc(row.schoolName)}<small>${esc(row.branchName||row.branch||'Nhánh chưa gán')} · ${esc(row.generation)}</small></td><td>${statusBadge(row.design.status)}</td><td>${statusBadge(row.runtime.status)}</td><td><span title="${esc(row.vfx.ledgerStatus)}">${statusBadge(row.vfx.technicalStatus)}</span><small>${esc(row.vfx.ledgerStatus)}</small></td><td>${statusBadge(row.animation.status)}</td><td>${statusBadge(row.qa.status)}</td><td>${statusBadge(row.vfx.ownerStatus)}</td></tr>`).join('');
    const schoolRows=p.schools.map(school=>`<button class="school-progress" data-filter-school="${esc(school.id)}"><b>${esc(school.name)}</b><strong>${school.designedCandidates}</strong><small>${school.ownerArtApprovedRecorded} duyệt · ${school.animationUnknown} animation UNKNOWN</small></button>`).join('');
    return `${pageHead('Tiến độ kỹ năng V2','Theo dõi 12 môn phái, 36 nhánh và từng skill ID. Mỗi trục có nguồn riêng; candidate không đồng nghĩa gameplay.',`${filtered.length.toLocaleString('vi-VN')} KẾT QUẢ<br>SHA ${esc(p.sourceCommitSha.slice(0,12))}`)}
      <div class="notice">V6.3 hiện <b>OFF</b>. 2.196 skill là candidate metadata. TECH_PASS không phải Owner Art Approval; clip/asset cấp nhân vật không chứng minh animation của từng skill.</div>
      <div class="progress-metrics">${cards.map(([v,l,n])=>`<div class="progress-metric"><strong>${esc(v)}</strong><span>${esc(l)}</span><small>${esc(n)}</small></div>`).join('')}</div>
      <div class="panel"><div class="panel-head"><div><h2>12 môn phái · 36 nhánh</h2><small>Coverage số lượng theo từng môn phái; bấm để lọc bảng skill</small></div><span class="badge blue">SOURCE-BACKED</span></div><div class="panel-body"><div class="school-progress-grid">${schoolRows}</div></div></div>
      <div class="toolbar progress-filters"><input id="progress-search" placeholder="Tìm tên, skill ID, packet, source…" value="${esc(f.query)}"><select id="progress-school"><option value="all">Mọi môn phái</option>${p.schools.map(x=>`<option value="${esc(x.id)}" ${f.school===x.id?'selected':''}>${esc(x.name)}</option>`).join('')}</select><select id="progress-branch"><option value="all">Mọi nhánh</option>${branches.map(x=>`<option value="${esc(x.id)}" ${f.branch===x.id?'selected':''}>${esc(x.name)} · ${x.designedCandidates}</option>`).join('')}${sharedOption}</select><select id="progress-axis">${axes.map(x=>`<option value="${x[0]}" ${f.axis===x[0]?'selected':''}>${x[1]}</option>`).join('')}</select><select id="progress-status"><option value="all">Mọi trạng thái</option>${statusSet.map(x=>`<option value="${esc(x)}" ${f.status===x?'selected':''}>${esc(x)}</option>`).join('')}</select></div>
      <div class="panel"><div class="panel-head"><div><h2>Skill matrix</h2><small>${filtered.length.toLocaleString('vi-VN')} dòng · trang ${state.progressPage+1}/${pages} · click skill để xem traceability</small></div><div class="head-actions"><button class="small-button" data-progress-page="-1" ${state.progressPage===0?'disabled':''}>←</button><button class="small-button" data-progress-page="1" ${state.progressPage>=pages-1?'disabled':''}>→</button><button class="small-button" data-go="work">Mở việc cần xử lý</button></div></div><div class="table-wrap progress-table-wrap"><table class="data-table progress-table"><thead><tr><th>Skill / ID</th><th>Môn phái / nhánh</th><th>Thiết kế</th><th>Runtime</th><th>VFX kỹ thuật</th><th>Animation</th><th>QA</th><th>Owner Art</th></tr></thead><tbody>${rows||'<tr><td colspan="8" class="empty">Không có kết quả.</td></tr>'}</tbody></table></div></div>`;
  }
  function evidenceLink(path, sha, label) {
    if (!path) return '<div class="trace-line"><span>Nguồn</span><b>UNKNOWN</b></div>';
    const href='/'+String(path).replace(/^\//,'');
    return `<div class="trace-line"><span>${esc(label||'Source')}</span><b><a href="${esc(href)}" target="_blank" rel="noopener">${esc(path)}</a><br><code>${esc(sha||'SHA UNKNOWN')}</code></b></div>`;
  }
  function skillDetailView() {
    const row=state.progress?.skills.find(item=>item.id===state.selectedSkillId);
    if(!row) return `${pageHead('Chi tiết kỹ năng','Chưa chọn skill.','UNKNOWN')}<button class="button" data-go="progress">← Trở lại tiến độ</button>`;
    const packets=row.vfx.packets.map(packet=>`<article class="evidence-card"><h3>${esc(packet.packetId)} · ${esc(packet.revision)}</h3>${evidenceLink(packet.path,packet.sourceSha256,'VFX packet')}<p>Gate packet: <code>${esc(typeof packet.gateStatus==='string'?packet.gateStatus:JSON.stringify(packet.gateStatus))}</code></p><div class="asset-list">${packet.refs.map(ref=>`<div class="asset-ref"><span>${statusBadge(ref.exists?'PRESENT':'MISSING')} ${esc(ref.kind)}</span><a href="/${esc(ref.projectPath||ref.path)}" target="_blank" rel="noopener">${esc(ref.path)}</a><code>${esc(ref.sourceSha256||'NO FILE HASH')}</code></div>`).join('')||'<small>Packet không liệt kê asset/scene path.</small>'}</div></article>`).join('')||'<div class="empty">Chưa có packet gắn đúng skill ID.</div>';
    const tests=row.qa.tests.map(test=>`<div class="trace-line"><span>${statusBadge(test.status)}</span><b><a href="/${esc(test.path)}" target="_blank" rel="noopener">${esc(test.path)}</a><br><code>${esc(test.sourceSha256)}</code></b></div>`).join('')||'<div class="empty">Không có test source match ID này.</div>';
    const runs=row.qa.githubRuns.map(run=>`<div class="evidence-card"><h3><a href="${esc(run.url)}" target="_blank" rel="noopener">${esc(run.name)} · run ${esc(run.runId)}</a> ${statusBadge(run.status)}</h3><code>${esc(run.headSha)}</code><p>${esc(run.scope)}</p></div>`).join('')||'<div class="empty">Chưa có GitHub Action exact-SHA gắn đúng ID.</div>';
    const actorAssets=row.animation.relatedSchoolAssets.map(asset=>`<div class="asset-ref"><span>${statusBadge(asset.hashStatus)}</span><a href="/${esc(asset.projectPath||asset.path)}" target="_blank" rel="noopener">${esc(asset.clip||asset.assetId||asset.path)}</a><small>${esc(asset.frames||'')} frames · hash manifest ${esc(asset.declaredSha256||'')}</small></div>`).join('')||'<div class="empty">Không có actor asset cấp môn phái trong snapshot.</div>';
    const schoolVfx=row.vfx.relatedSchoolAssets.filter(asset=>asset.kind==='vfx_master').map(asset=>`<div class="asset-ref"><span>${statusBadge(asset.hashStatus)}</span><a href="/${esc(asset.projectPath||asset.path)}" target="_blank" rel="noopener">${esc(asset.assetId||asset.path)}</a><small>${esc((asset.branches||[]).join(', '))} · sha ${esc(asset.declaredSha256||'')}</small></div>`).join('')||'<div class="empty">Không có VFX master cấp môn phái trong snapshot.</div>';
    return `${pageHead(row.name,'Traceability theo skill ID. Mọi trạng thái giữ riêng nguồn, runtime, asset, QA và Owner.',String(row.generation||'UNKNOWN').toUpperCase()+' · '+row.schoolName)}
      <div class="head-actions"><button class="button secondary" data-go="progress">← Tiến độ</button><button class="button" data-skill-cr="${esc(row.id)}">Tạo Change Request cho skill</button></div>
      <div class="skill-hero"><div><small>SKILL ID</small><code>${esc(row.id)}</code><p>Family: ${esc(row.familyId)} · Branch: ${esc(row.branch||'Chưa gán')} · Slot: ${esc(row.slot)}</p></div><div>${statusBadge(row.design.status)} ${statusBadge(row.runtime.status)} ${statusBadge(row.vfx.technicalStatus)} ${statusBadge(row.animation.status)} ${statusBadge(row.qa.status)} ${statusBadge(row.vfx.ownerStatus)}</div></div>
      <div class="axis-grid">
        <section class="panel"><div class="panel-head"><h2>Thiết kế & runtime</h2></div><div class="panel-body">${evidenceLink(row.design.sourcePath,row.design.sourceSha256,'Catalog source')}<div class="notice">Runtime: <b>${esc(row.runtime.status)}</b> · V6.3 OFF. Giá trị catalog không được coi là công thức/gameplay đang dùng.</div>${row.runtime.sourcePaths.map(ref=>evidenceLink(ref.sourcePath,ref.sourceSha256,'Gate/registry source')).join('')}</div></section>
        <section class="panel"><div class="panel-head"><h2>VFX</h2><small>Ledger: ${esc(row.vfx.ledgerStatus)}</small></div><div class="panel-body">${evidenceLink(row.vfx.ledgerPath,row.vfx.ledgerSha256,'VFX ledger')}<div class="detail-grid"><div class="detail-cell"><small>Owner raw gate</small><b>${esc(row.vfx.ownerGateRaw)}</b></div><div class="detail-cell"><small>Live integration</small><b>${esc(row.vfx.liveIntegration)}</b></div><div class="detail-cell"><small>VFX declaration</small><b>${esc(row.vfx.declaredKey)}</b></div><div class="detail-cell"><small>Technical status</small><b>${esc(row.vfx.technicalStatus)}</b></div></div>${packets}</div></section>
        <section class="panel"><div class="panel-head"><h2>Animation</h2>${statusBadge(row.animation.status)}</div><div class="panel-body"><p>animationKey: <code>${esc(row.animation.key)}</code></p><p>${esc(row.animation.note)}</p>${actorAssets}</div></section>
        <section class="panel"><div class="panel-head"><h2>QA & Owner Art</h2></div><div class="panel-body"><p>QA state: ${statusBadge(row.qa.status)}</p><p>Owner state: ${statusBadge(row.vfx.ownerStatus)} · raw: <code>${esc(row.vfx.ownerGateRaw)}</code></p><h3>Test source</h3>${tests}<h3>GitHub evidence exact SHA</h3>${runs}</div></section>
        <section class="panel"><div class="panel-head"><h2>VFX master cấp môn phái</h2><small>Không suy ra mapping per-skill</small></div><div class="panel-body">${schoolVfx}</div></section>
      </div>`;
  }
  function workQueueView() {
    const p=state.progress;
    if(!p) return pageHead('Việc cần xử lý','Chưa nạp projection V2.','PENDING');
    const s=p.summary;
    const missingRefs=p.skills.filter(row=>row.vfx.packets.some(packet=>packet.refs.some(ref=>!ref.exists)));
    const vfxPending=p.skills.filter(row=>row.vfx.ownerStatus!=='OWNER_APPROVED_RECORDED');
    const noExactRun=p.skills.filter(row=>!row.qa.githubRuns.length);
    const failedActions=p.skills.filter(row=>row.qa.status==='ACTION_FAILURE_AT_RECORDED_SHA');
    const inProgressActions=p.skills.filter(row=>row.qa.status==='ACTION_IN_PROGRESS_AT_RECORDED_SHA');
    const tasks=[
      {id:'ANIM-MAPPING',title:'Ánh xạ skill ID → clip animation',count:s.animationSkillMappingsVerified+'/'+s.skillCandidates,scope:'Không có bằng chứng per-skill; clip/actor docs chỉ là cấp nhân vật.',status:'UNKNOWN'},
      {id:'VFX-OWNER-GATE',title:'Nghiệm thu mỹ thuật VFX theo từng skill',count:vfxPending.length,scope:'TECH_PASS và provisional không tự thành Owner Art Approval.',status:'OWNER_PENDING'},
      {id:'QA-EXACT-SHA',title:'Bằng chứng QA exact-SHA theo skill',count:noExactRun.length+' chưa có run được liên kết',scope:'Source ID trong test chỉ chứng minh có liên kết code, không chứng minh đã chạy.',status:'PENDING'},
      {id:'QA-ACTION-FAIL',title:'Action exact-SHA gần nhất thất bại',count:failedActions.length,scope:'Hiển thị lỗi ở SHA đã chạy; không nâng run cũ thành PASS.',status:failedActions.length?'FAIL':'NONE'},
      {id:'QA-ACTION-PENDING',title:'Action exact-SHA đang chạy',count:inProgressActions.length,scope:'Run đã được liên kết nhưng chưa có kết luận; không tính là PASS.',status:inProgressActions.length?'IN_PROGRESS':'NONE'},
      {id:'PACKET-ASSETS',title:'Đối chiếu asset/scene được khai báo trong packet',count:missingRefs.length+' skill có ít nhất một đường dẫn thiếu',scope:'Kết quả dựa trên file thực có trong checkout khi build projection.',status:missingRefs.length?'MISSING':'PENDING'},
      {id:'V63-GATE',title:'V6.3 gameplay',count:s.runtimeActive+'/'+s.skillCandidates+' active',scope:'Gate OFF là trạng thái phát hành chủ động, không được tính là lỗi tự động cần sửa.',status:'GATED_OFF'},
    ];
    return `${pageHead('Việc cần xử lý','Backlog bằng chứng và gap. Đây là đề xuất theo dõi; không tự tạo quyền sửa gameplay.',tasks.length+' NHÓM')}
      <div class="notice">Các mục bên dưới không thay đổi 10 gap V1. Gap trang bị 3/10 slot cần Owner quyết định; Wiki chỉ giữ bằng chứng và đề xuất, không sửa authority.</div>
      <div class="panel"><div class="panel-head"><h2>Evidence backlog</h2><span class="badge gold">PENDING ≠ FAIL</span></div><div class="panel-body">${tasks.map(task=>`<article class="gap-row"><div><h3>${esc(task.id)} · ${esc(task.title)}</h3><p>${esc(task.scope)}</p><small>${esc(task.count)}</small></div>${statusBadge(task.status)}</article>`).join('')}</div></div>
      <div class="panel"><div class="panel-head"><div><h2>Gap register gốc</h2><small>${p.gapRegister.length} gap · sao chép từ Wiki V1, không tự đóng</small></div><button class="small-button" data-go="gaps">Mở Gap Analysis</button></div><div class="panel-body">${p.gapRegister.map(gap=>`<article class="gap-row"><div><h3>${esc(gap.id)} · ${esc(gap.title)}</h3><p>${esc(gap.summary)}</p><small>${esc(gap.sourcePath)} · ${esc(gap.sourceSha)}</small></div>${statusBadge(gap.status)}</article>`).join('')}</div></div>
      <div class="panel"><div class="panel-head"><h2>Skill chưa có Action exact-SHA</h2><small>${noExactRun.length.toLocaleString('vi-VN')} candidate</small></div><div class="panel-body"><div class="toolbar"><input id="work-search" placeholder="Lọc backlog theo ID / tên / môn phái"></div><div class="table-wrap"><table class="data-table"><thead><tr><th>Skill</th><th>School</th><th>QA</th><th>Owner</th></tr></thead><tbody>${noExactRun.slice(0,50).map(row=>`<tr data-progress-skill="${esc(row.id)}"><td><b>${esc(row.name)}</b><code>${esc(row.id)}</code></td><td>${esc(row.schoolName)}</td><td>${statusBadge(row.qa.status)}</td><td>${statusBadge(row.vfx.ownerStatus)}</td></tr>`).join('')}</tbody></table></div><button class="small-button" data-go="progress">Duyệt toàn bộ / lọc</button></div></div>`;
  }
  function render() {
    if (!state.catalog) return;
    if (state.view === 'dashboard') page.innerHTML = state.query ? globalResults() : dashboard();
    else if (state.view === 'progress') page.innerHTML = renderProgress();
    else if (state.view === 'skill-detail') page.innerHTML = skillDetailView();
    else if (state.view === 'work') page.innerHTML = workQueueView();
    else if (state.view === 'gaps') page.innerHTML = renderGaps();
    else if (state.view === 'editor') page.innerHTML = editorView();
    else if (state.view === 'requests') page.innerHTML = requestView();
    else page.innerHTML = catalogView(state.view);
    bindPage();
  }
  function globalResults() {
    const q = normalize(state.query);
    const results = ['schools','branches','skills','techniques','realms','disciples','roots','medicine','equipment','resources','vfx','gaps'].flatMap(view=>listFor(view).map(item=>({view,item}))).filter(({item})=>normalize(JSON.stringify(item)).includes(q)).slice(0,120);
    return `${pageHead('Kết quả tìm kiếm',`Tìm “${state.query}” trong taxonomy, catalog, nguồn và gap.`,`${results.length} KẾT QUẢ<br>local snapshot`)}<div class="panel"><div class="table-wrap"><table class="data-table"><thead><tr><th>Danh mục / tên</th><th>ID</th><th>Trạng thái</th><th>Nguồn</th></tr></thead><tbody>${results.map(({view,item})=>`<tr data-result-view="${esc(view)}" data-result-id="${esc(recordId(item))}"><td><div class="primary">${esc(recordName(item))}</div><div class="sub">${esc(titles[view])}</div></td><td><code>${esc(recordId(item))}</code></td><td>${statusBadge(item.runtimeStatus||item.status)}</td><td>${esc(item.sourcePath||'')}</td></tr>`).join('') || '<tr><td colspan="4" class="empty">Không tìm thấy.</td></tr>'}</tbody></table></div></div>`;
  }
  function bindPage() {
    page.querySelectorAll('[data-go]').forEach(button=>button.addEventListener('click',()=>setView(button.dataset.go)));
    page.querySelectorAll('[data-record]').forEach(row=>row.addEventListener('click',()=>{state.selected={id:row.dataset.record,kind:row.dataset.recordKind};render();}));
    page.querySelectorAll('[data-result-view]').forEach(row=>row.addEventListener('click',()=>{state.view=row.dataset.resultView;state.selected={id:row.dataset.resultId,kind:state.view};state.query='';searchInput.value='';nav.querySelectorAll('[data-view]').forEach(button=>button.classList.toggle('active',button.dataset.view===state.view));document.querySelector('#crumb-title').textContent=titles[state.view];render();}));
    page.querySelectorAll('[data-page]').forEach(button=>button.addEventListener('click',()=>changePage(Number(button.dataset.page))));
    page.querySelectorAll('[data-edit-id]').forEach(button=>button.addEventListener('click',()=>{state.selected={id:button.dataset.editId,kind:state.view};setView('editor');}));
    const catalogSearch=page.querySelector('#catalog-search'); if(catalogSearch) catalogSearch.addEventListener('input',event=>{state.query=event.target.value;state.page=0;const pos=event.target.selectionStart;render();const next=page.querySelector('#catalog-search');next?.focus();next?.setSelectionRange(pos,pos);});
    const catalogStatus=page.querySelector('#catalog-status'); if(catalogStatus) catalogStatus.addEventListener('change',event=>{state.statusFilter=event.target.value;render();});
    const catalogSchool=page.querySelector('#catalog-school'); if(catalogSchool) catalogSchool.addEventListener('change',event=>{state.schoolFilter=event.target.value;render();});
    const gapSearch=page.querySelector('#gap-search'); if(gapSearch) gapSearch.addEventListener('input',event=>{state.query=event.target.value;render();const next=page.querySelector('#gap-search');next?.focus();next?.setSelectionRange(next.value.length,next.value.length);});
    const severity=page.querySelector('#gap-severity'); if(severity) severity.addEventListener('change',event=>page.querySelectorAll('[data-gap-severity]').forEach(row=>row.hidden=event.target.value!=='all'&&row.dataset.gapSeverity!==event.target.value));
    const proposalForm=page.querySelector('#proposal-form'); if(proposalForm) bindProposalForm(proposalForm);
    const crForm=page.querySelector('#cr-form'); if(crForm) crForm.addEventListener('submit',saveRequest);
    page.querySelectorAll('[data-proposal-cr]').forEach(button=>button.addEventListener('click',()=>{const row=proposalRows().find(item=>item.localId===button.dataset.proposalCr);if(row){state.selected={id:row.relatedId,kind:'proposal'};setView('requests');setTimeout(()=>{const title=page.querySelector('#cr-title'); if(title) title.value=`${row.relatedId} · ${row.fieldPath}`;const before=page.querySelector('#cr-before');if(before)before.value=JSON.stringify(row.before);const after=page.querySelector('#cr-after');if(after)after.value=JSON.stringify(row.after);},0);}}));
    page.querySelectorAll('[data-delete-proposal]').forEach(button=>button.addEventListener('click',()=>{persist(STORAGE.proposals,proposalRows().filter(row=>row.localId!==button.dataset.deleteProposal));render();}));
    page.querySelectorAll('[data-delete-request]').forEach(button=>button.addEventListener('click',()=>{persist(STORAGE.requests,requestRows().filter(row=>row.localId!==button.dataset.deleteRequest));render();}));
    page.querySelectorAll('[data-request-status]').forEach(select=>select.addEventListener('change',()=>{const rows=requestRows();const row=rows.find(item=>item.localId===select.dataset.requestStatus);if(row){row.status=select.value;row.updatedAt=new Date().toISOString();persist(STORAGE.requests,rows);}}));
    page.querySelectorAll('[data-create-gap-cr]').forEach(button=>button.addEventListener('click',()=>{const gap=state.catalog.gaps.find(item=>item.id===button.dataset.createGapCr);if(!gap)return;setView('requests');setTimeout(()=>{const title=page.querySelector('#cr-title');if(title)title.value=gap.title;const id=page.querySelector('#cr-id');if(id)id.value=gap.id;const before=page.querySelector('#cr-before');if(before)before.value=JSON.stringify({status:gap.status,summary:gap.summary,sourcePath:gap.sourcePath,sourceSha:gap.sourceSha},null,2);const criteria=page.querySelector('#cr-criteria');if(criteria)criteria.value=`Đóng ${gap.id} chỉ khi có source/QA evidence tại SHA cụ thể và trạng thái được xác nhận; không ghi PASS từ spec-only.`;},0);}));
    const exportProposals=page.querySelector('#proposal-export'); if(exportProposals) exportProposals.addEventListener('click',()=>downloadJson('tmb-wiki-local-proposals.json',exportBundle({proposals:proposalRows(),changeRequests:requestRows()})));
    const importButton=page.querySelector('#proposal-import'); if(importButton) importButton.addEventListener('click',()=>page.querySelector('#proposal-file').click());
    const fileInput=page.querySelector('#proposal-file'); if(fileInput) fileInput.addEventListener('change',importLocalData);
    const exportCr=page.querySelector('#cr-export'); if(exportCr) exportCr.addEventListener('click',()=>downloadJson('tmb-wiki-local-change-requests.json',exportBundle({changeRequests:requestRows()})));
    const importCr=page.querySelector('#cr-import'); if(importCr) importCr.addEventListener('click',()=>page.querySelector('#cr-file').click());
    const crFile=page.querySelector('#cr-file'); if(crFile) crFile.addEventListener('change',event=>importLocalData(event,'changeRequests'));
    page.querySelectorAll('[data-progress-skill]').forEach(row=>row.addEventListener('click',()=>{state.selectedSkillId=row.dataset.progressSkill;setView('skill-detail');}));
    page.querySelectorAll('[data-filter-school]').forEach(button=>button.addEventListener('click',()=>{state.progressFilters.school=button.dataset.filterSchool;state.progressFilters.branch='all';state.progressPage=0;setView('progress');}));
    page.querySelectorAll('[data-progress-page]').forEach(button=>button.addEventListener('click',()=>{state.progressPage=Math.max(0,state.progressPage+Number(button.dataset.progressPage));render();}));
    const progressSearch=page.querySelector('#progress-search'); if(progressSearch) progressSearch.addEventListener('input',event=>{state.progressFilters.query=event.target.value;state.progressPage=0;const pos=event.target.selectionStart;render();const next=page.querySelector('#progress-search');next?.focus();next?.setSelectionRange(pos,pos);});
    const progressSchool=page.querySelector('#progress-school'); if(progressSchool) progressSchool.addEventListener('change',event=>{state.progressFilters.school=event.target.value;state.progressFilters.branch='all';state.progressPage=0;render();});
    const progressBranch=page.querySelector('#progress-branch'); if(progressBranch) progressBranch.addEventListener('change',event=>{state.progressFilters.branch=event.target.value;state.progressPage=0;render();});
    const progressAxis=page.querySelector('#progress-axis'); if(progressAxis) progressAxis.addEventListener('change',event=>{state.progressFilters.axis=event.target.value;state.progressFilters.status='all';render();});
    const progressStatus=page.querySelector('#progress-status'); if(progressStatus) progressStatus.addEventListener('change',event=>{state.progressFilters.status=event.target.value;state.progressPage=0;render();});
    const workSearch=page.querySelector('#work-search'); if(workSearch) workSearch.addEventListener('input',event=>{const q=normalize(event.target.value);page.querySelectorAll('[data-progress-skill]').forEach(row=>row.hidden=!normalize(row.textContent).includes(q));});
    page.querySelectorAll('[data-skill-cr]').forEach(button=>button.addEventListener('click',()=>{const row=state.progress?.skills.find(item=>item.id===button.dataset.skillCr);if(!row)return;setView('requests');setTimeout(()=>{const set=(selector,value)=>{const el=page.querySelector(selector);if(el)el.value=value;};set('#cr-title','Bổ sung bằng chứng/hoàn thiện '+row.id);set('#cr-id',row.id);set('#cr-before',JSON.stringify({runtime:row.runtime.status,vfx:row.vfx.ledgerStatus,animation:row.animation.status,qa:row.qa.status,owner:row.vfx.ownerGateRaw},null,2));set('#cr-after','Đề xuất: bổ sung mapping/bằng chứng cụ thể; không tự bật runtime hoặc phê duyệt mỹ thuật.');set('#cr-criteria','Có source/asset/test hoặc Action exact-SHA gắn đúng skill ID; giữ TECH, Owner Art và runtime thành các trạng thái độc lập.');},0);}));
    const backupExport=page.querySelector('#owner-backup-export'); if(backupExport) backupExport.addEventListener('click',()=>downloadJson('tmb-wiki-owner-backup-v2.json',ownerBackupBundle()));
    const backupImport=page.querySelector('#owner-backup-import'); if(backupImport) backupImport.addEventListener('click',()=>{if(confirm('Restore sẽ chỉ thêm bản ghi mới; dữ liệu Owner hiện có được giữ nguyên. Tiếp tục chọn backup JSON?'))page.querySelector('#owner-backup-file')?.click();});
    const backupFile=page.querySelector('#owner-backup-file'); if(backupFile) backupFile.addEventListener('change',event=>importLocalData(event,'all'));
  }
  function bindProposalForm(form) {
    const id=page.querySelector('#p-id'), field=page.querySelector('#p-field'), before=page.querySelector('#p-before'), after=page.querySelector('#p-after'), compareBefore=page.querySelector('#compare-before'), compareAfter=page.querySelector('#compare-after');
    function refreshBefore() { const record=findRecord(id.value);const value=currentField(id.value,field.value);const preview=record?JSON.stringify(record,null,2):'Không tìm thấy record ID trong snapshot.';before.value=preview;compareBefore.textContent=value.found?JSON.stringify(value.value,null,2):'Field chưa tồn tại hoặc chưa chọn.'; }
    id.addEventListener('input',refreshBefore);field.addEventListener('input',refreshBefore);after.addEventListener('input',()=>{compareAfter.textContent=after.value||'Chưa nhập đề xuất';});
    form.addEventListener('submit',event=>{event.preventDefault();if(!id.value||!field.value){alert('Cần ID và field path trước khi lưu.');return;}const current=currentField(id.value,field.value);let proposed;try{proposed=JSON.parse(after.value);}catch{proposed=after.value;}const rows=proposalRows();rows.push({localId:crypto.randomUUID(),relatedId:id.value,fieldPath:field.value,before:current.found?current.value:null,after:proposed,note:page.querySelector('#p-note').value,reason:page.querySelector('#p-reason').value,status:'DRAFT',createdAt:new Date().toISOString(),sourceHead:state.catalog.sourceCommitSha});persist(STORAGE.proposals,rows);render();});
  }
  function saveRequest(event) {
    event.preventDefault();const rows=requestRows();rows.push({localId:crypto.randomUUID(),title:page.querySelector('#cr-title').value,relatedIds:page.querySelector('#cr-id').value,current:page.querySelector('#cr-before').value,proposed:page.querySelector('#cr-after').value,priority:page.querySelector('#cr-priority').value,status:page.querySelector('#cr-status').value,criteria:page.querySelector('#cr-criteria').value,note:page.querySelector('#cr-note').value,createdAt:new Date().toISOString(),sourceHead:state.catalog.sourceCommitSha});persist(STORAGE.requests,rows);render();
  }
  function exportBundle(data) { return { schemaVersion:1, exportedAt:new Date().toISOString(), sourceHead:state.catalog.sourceCommitSha, ...data }; }
  function ownerBackupBundle() { return { schemaVersion:2, bundleType:'tmb-wiki-owner-data', exportedAt:new Date().toISOString(), sourceHead:state.catalog.sourceCommitSha, proposals:proposalRows(), changeRequests:requestRows() }; }
  function ownerBackupControls() { return '<div class="backup-actions"><span>Backup/restore chỉ hợp nhất dữ liệu local; bản ghi đã có không bị ghi đè hoặc xóa.</span><button class="small-button" id="owner-backup-export" type="button">Backup toàn bộ JSON · v2</button><button class="small-button" id="owner-backup-import" type="button">Restore hợp nhất</button><input type="file" id="owner-backup-file" accept="application/json" hidden></div>'; }
  function mergeLocalRows(existing, incoming, requiredFields) {
    if (!Array.isArray(incoming)) throw new Error('Danh sách JSON không hợp lệ.');
    const merged=[...existing];const known=new Set(existing.map(row=>row.localId));let added=0;
    for(const raw of incoming){
      if(!raw||typeof raw!=='object'||requiredFields.some(key=>!String(raw[key]??'').trim())) throw new Error(`Bản ghi thiếu trường bắt buộc: ${requiredFields.join(', ')}`);
      const row={...raw,localId:raw.localId||crypto.randomUUID()};
      if(known.has(row.localId)) continue;
      merged.push(row);known.add(row.localId);added++;
    }
    return {rows:merged,added};
  }
  function downloadJson(filename, data) {
    const blob=new Blob([JSON.stringify(data,null,2)],{type:'application/json'});const url=URL.createObjectURL(blob);const link=document.createElement('a');link.href=url;link.download=filename;link.click();setTimeout(()=>URL.revokeObjectURL(url),1500);
  }
  function persistImportedBundles(updates) {
    const keys=Object.keys(updates);
    const before=Object.fromEntries(keys.map(key=>[key,localStorage.getItem(key)]));
    try {
      for(const key of keys) localStorage.setItem(key,JSON.stringify(updates[key]));
    } catch(error) {
      for(const key of keys) {
        try { if(before[key]===null) localStorage.removeItem(key); else localStorage.setItem(key,before[key]); } catch {}
      }
      throw error;
    }
    updateCounters();
  }
  function importLocalData(event, onlyKind='all') {
    const file=event.target.files?.[0];if(!file)return;
    const reader=new FileReader();
    reader.onload=()=>{
      try {
        const data=JSON.parse(reader.result);
        if(![1,2].includes(data.schemaVersion))throw new Error('Schema không hỗ trợ. Chỉ nhận phiên bản 1 hoặc 2.');
        if(data.schemaVersion===2&&data.bundleType!=='tmb-wiki-owner-data')throw new Error('Backup schema 2 sai bundleType.');
        for(const key of ['proposals','changeRequests']) if(Array.isArray(data[key])) {
          const ids=new Set();
          for(const row of data[key]) { if(!row||typeof row!=='object') throw new Error('Bản ghi JSON không hợp lệ.'); if(row.localId&&ids.has(row.localId)) throw new Error('Backup có localId trùng lặp: '+row.localId); if(row.localId) ids.add(row.localId); }
        }
        if(onlyKind==='changeRequests'&&!Array.isArray(data.changeRequests))throw new Error('File CR phải có danh sách changeRequests.');
        if(onlyKind==='proposals'&&!Array.isArray(data.proposals))throw new Error('File đề xuất phải có danh sách proposals.');
        const hasProposals=Array.isArray(data.proposals);
        const hasRequests=Array.isArray(data.changeRequests);
        if(!hasProposals&&!hasRequests)throw new Error('JSON không có danh sách proposals hoặc changeRequests.');
        const updates={};let added=0;
        if(onlyKind!=='changeRequests'&&hasProposals) {
          const merged=mergeLocalRows(proposalRows(),data.proposals,['relatedId','fieldPath']);
          updates[STORAGE.proposals]=merged.rows;added+=merged.added;
        }
        if(onlyKind!=='proposals'&&hasRequests) {
          const merged=mergeLocalRows(requestRows(),data.changeRequests,['title','criteria']);
          updates[STORAGE.requests]=merged.rows;added+=merged.added;
        }
        if(!Object.keys(updates).length)throw new Error('File không chứa loại dữ liệu cần nhập.');
        persistImportedBundles(updates);
        render();
        alert('Đã nhập ' + added + ' bản ghi mới. Dữ liệu local trùng ID được giữ nguyên.');
      } catch(error) {
        alert('Không nhập được JSON: ' + error.message + '. Dữ liệu local hiện tại không bị thay đổi.');
      }
    };
    reader.readAsText(file);event.target.value='';
  }
  nav.addEventListener('click',event=>{const button=event.target.closest('[data-view]');if(button)setView(button.dataset.view);});
  searchInput.addEventListener('input',event=>{state.query=event.target.value;state.page=0;if(state.view==='dashboard'&&state.query)document.querySelector('#crumb-title').textContent='Kết quả tìm kiếm';render();});
  document.querySelector('#mobile-menu').addEventListener('click',()=>document.querySelector('#sidebar').classList.toggle('open'));
  document.querySelector('#sync-command').addEventListener('click',()=>document.querySelector('#sync-dialog').showModal());
  document.querySelectorAll('[data-close="sync-dialog"]').forEach(button=>button.addEventListener('click',()=>document.querySelector('#sync-dialog').close()));
  document.querySelector('#sync-dialog').addEventListener('click',event=>{if(event.target===event.currentTarget)event.currentTarget.close();});
  document.querySelector('#copy-sync').addEventListener('click',async()=>{try{await navigator.clipboard.writeText('tools/wiki/SYNC_WIKI_SOURCE.cmd');document.querySelector('#copy-sync').textContent='Đã sao chép';}catch{document.querySelector('#copy-sync').textContent='Copy bị chặn';}});
  document.querySelector('#privacy-close').addEventListener('click',()=>document.querySelector('.privacy-banner').remove());
  document.addEventListener('keydown',event=>{if((event.ctrlKey||event.metaKey)&&event.key.toLowerCase()==='k'){event.preventDefault();searchInput.focus();}if(event.key==='Escape')document.querySelector('#sidebar').classList.remove('open');});

  if (!['localhost','127.0.0.1','::1'].includes(location.hostname)) {
    page.innerHTML='<div class="panel"><div class="panel-body"><div class="eyebrow">LOCAL-ONLY ACCESS GATE</div><h1>Tàng Kinh Các không phục vụ trên host từ xa</h1><p class="detail-description">Để bảo vệ ghi chú quản trị trong profile trình duyệt, Wiki chỉ chạy trên localhost. Hãy dùng <code>tools/wiki/OPEN_TANG_KINH_CAC.cmd</code> trong checkout nội bộ.</p></div></div>';
    document.querySelector('#sync-state').textContent='LOCAL ONLY';
  } else Promise.all([
    fetch('./data/catalog.json',{cache:'no-store'}).then(response=>{if(!response.ok)throw new Error('catalog.json HTTP '+response.status);return response.json();}),
    fetch('./data/skill_progress_v2.json',{cache:'no-store'}).then(response=>{if(!response.ok)throw new Error('skill_progress_v2.json HTTP '+response.status);return response.json();}).catch(error=>({__loadError:error.message}))
  ]).then(([catalog,progress])=>{
    state.catalog=catalog;
    state.progress=progress?.__loadError?null:progress;
    document.querySelector('#sync-state').textContent=state.progress?'V1 + V2 đã nạp':'V1 nạp · V2 pending';
    document.querySelector('#head-mini').textContent=catalog.sourceCommitSha.slice(0,12);
    updateCounters();render();
  }).catch(error=>{
    page.innerHTML=`<div class="panel"><div class="panel-body"><div class="eyebrow">LOCAL LAUNCH REQUIRED</div><h1>Không tải được source snapshot</h1><p class="detail-description">${esc(error.message)}. Hãy mở qua <code>tools/wiki/OPEN_TANG_KINH_CAC.cmd</code> để chạy HTTP server chỉ bind 127.0.0.1.</p></div></div>`;
    document.querySelector('#sync-state').textContent='Chưa nạp catalog';
  });
})();
