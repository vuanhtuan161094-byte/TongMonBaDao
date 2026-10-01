# Tông Môn Bá Đạo — Nghiên cứu sâu hệ Đệ tử

Date: 2026-10-01
Status: RESEARCH BASELINE / NOT A PHASE LOCK

## 1. Mục tiêu

Nghiên cứu này tập trung vào câu hỏi: **một đệ tử trong game tông môn phải là gì để người chơi cảm thấy mình đang nuôi, dùng, phân công và quản lý con người chứ không phải quản lý thẻ tướng?**

Khung vận hành chính vẫn lấy cảm giác của Evil Hunter Tycoon: nhân vật tự sống/tự chạy, người chơi quản cơ sở/chính sách và can thiệp trực tiếp khi cần. Chiều sâu đệ tử tham khảo từ các game tông môn/colony sim khác.

Nguồn tham khảo chính:

- Evil Hunter Tycoon — official help center.
- 最强祖师 — TapTap official/community guides + video gameplay user supplied.
- The Lost Village / 山门与幻境 — Steam + community feedback.
- Amazing Cultivation Simulator / 了不起的修仙模拟器 — BWIKI/Fandom/Steam community.
- 鬼谷八荒 Tale of Immortal — Steam community sect-system descriptions.
- 宗门经理人 Sect Master — official Steam page (pre-release, Q4 2026 target).
- 修仙家族模拟器 — TapTap guides/update notes.
- 我要当掌门 — App Store/TapTap descriptions.
- RimWorld / Oxygen Not Included — work-priority/schedule patterns for large autonomous populations.

## 2. Quan sát trực tiếp từ video 最强祖师 người dùng cung cấp

Màn đệ tử trong video tách rất rõ nhiều lớp dữ liệu:

### Trạng thái nền

- chủng tộc;
- lập trường;
- giới tính;
- thọ nguyên;
- thương tích;
- trung thành.

### Sáu thuộc tính nền

- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

### Đặc chất

Video cho thấy cùng lúc có đặc chất tích cực/tiêu cực, thiên mệnh và linh căn. Ví dụ có thiên mệnh, nhiều linh căn, khí vận và một quái tật xấu. Điều quan trọng là đệ tử không được mô tả bằng một rarity duy nhất.

### Tám chuyên môn sản xuất

Quan sát trực tiếp thấy các chuyên môn:

- Bồi Thực;
- Đan Đạo;
- Thương Đạo;
- Phù Lục;
- Luyện Khí;
- Trận Pháp;
- Nuôi Dưỡng;
- Tụ Linh.

Mỗi chuyên môn có cấp và tiến độ riêng. Điều này xác nhận mạnh nguyên tắc: **năng lực sản xuất là progression của nhân vật, không phải flag nghề cố định.**

### Combat/build layer tách riêng

Video còn có các tab riêng cho:

- Trang bị;
- Kỹ năng/Công pháp;
- Pháp bảo;
- Thiên mệnh;
- Linh căn;
- chỉ số chiến đấu chi tiết.

=> Bài học: nghề nghiệp, đời sống, tu luyện và chiến đấu nên là các trục độc lập, không dồn vào một `class` hay một `overall score`.

## 3. 最强祖师 — bài học về giá trị đa chiều

Nguồn tham khảo:
- https://www.taptap.cn/moment/518641440847299228
- https://www.taptap.cn/moment/460461188975690006
- https://www.taptap.cn/moment/492413644118691459
- https://www.taptap.cn/moment/753034292782694524
- https://www.taptap.cn/moment/711612668670118357

Điểm đáng lấy:

1. Sáu thuộc tính định hướng nhiều loại giá trị khác nhau, không chỉ combat.
2. `聪慧/Thông Tuệ` tăng tốc học chuyên môn sản xuất.
3. Chuyên môn tăng khi làm việc và tăng hiệu suất sản xuất.
4. Trait có thể thay đổi tốc độ học nghề, thời gian làm việc, sản lượng, hành vi.
5. Đệ tử chất lượng chiến đấu thấp vẫn đáng giữ nếu có chuyên môn/trait sản xuất tốt.
6. Cơ Duyên phù hợp thám hiểm/sự kiện; Mị Lực phù hợp tuyển dụng/xã giao.

Điểm không nên sao chép:

- rarity màu/điểm tổng làm tiêu chuẩn giá trị chính;
- quá nhiều modifier % nhỏ chồng chéo khiến người chơi chỉ nhìn spreadsheet;
- loop gacha/refresh là trọng tâm tuyển dụng.

Chuẩn hóa cho game mình:

- không có `overall_score`;
- mỗi thuộc tính chỉ tồn tại khi có hậu quả gameplay rõ;
- mỗi trait phải thay đổi hành vi, tốc độ học, yield, cost hoặc lựa chọn AI;
- cùng một người có thể rất dở ở chiến đấu nhưng là nhân sự then chốt của tông môn.

## 4. Amazing Cultivation Simulator — bài học về con người sống thật

Nguồn:
- https://wiki.biligame.com/acs/角色面板
- https://wiki.biligame.com/acs/外门工作
- https://wiki.biligame.com/acs/内门修炼
- https://wiki.biligame.com/acs/基本概述
- https://amazing-cultivation-simulator.fandom.com/wiki/Work_Schedule_Planner

Điểm đáng lấy:

### A. Work priority thật sự

Ngoại môn có danh sách việc bật/tắt, thứ tự ưu tiên và một việc `đặc biệt ưu tiên`. Nhân vật tự chọn task phù hợp trong tập việc được phép.

### B. Schedule và nhu cầu chen vào công việc

Lịch bao gồm làm việc, ngủ, ăn, tu luyện. Khi đói/mệt nhân vật tự xử lý. Nếu ép làm quá mức, tâm trạng giảm và có thể bỏ việc.

### C. Tâm trạng có hậu quả

Tâm trạng thấp có thể dẫn tới:

- ngoại môn lười biếng/không nghe lệnh;
- nội môn sinh tâm ma, tu luyện kém;
- thành viên bị ngược đãi lâu có thể bỏ môn phái.

### D. Nội/ngoại môn tạo chi phí cơ hội

Ngoại môn là workforce thường ngày; nội môn tập trung tu luyện, luyện đan/luyện khí cấp cao, thám hiểm. Khi nâng quá nhiều người khỏi workforce, kinh tế thiếu lao động.

Không nên copy cứng việc nội môn tuyệt đối không được lao động. Với game mình nên dùng **opportunity cost**: người cảnh giới cao vẫn có thể làm việc thường nếu Tông Chủ ép, nhưng đó là sử dụng thời gian rất lãng phí.

### E. Sư đồ có tác dụng thật

Sư phụ cảnh giới cao hơn tăng tốc tu luyện; cùng công pháp còn tốt hơn; sư phụ có thể hỗ trợ đột phá và truyền bí pháp.

### F. Chức vị quản lý gắn với năng lực

ACS cho bổ nhiệm chưởng môn/đường chủ; vị trí khác nhau yêu cầu năng lực khác nhau, và năng lực người giữ chức ảnh hưởng bonus của đường.

Chuẩn hóa cho game mình:

- work priority + schedule + needs phải là ba lớp riêng;
- mood/discipline/loyalty là hệ tương lai đáng có nhưng không nên nhồi vào P2.7 vertical slice;
- master-disciple nên là hệ sau workforce, vì nó có thể nối thẳng vào cultivation/technique/relationship đã tồn tại;
- vị trí quản lý phải tạo hiệu ứng hệ thống chứ không chỉ danh hiệu.

## 5. The Lost Village — bài học về phân việc và lỗi cần tránh

Nguồn:
- https://store.steampowered.com/app/1963040/The_Lost_Village/
- Steam community discussions về task/work/schedule.

Điểm đáng lấy:

- gán người vào công trình/nhiệm vụ;
- tính cách/tài năng ảnh hưởng hiệu quả;
- nhân vật có làm việc, nghỉ, tu luyện, thám hiểm;
- có thể dùng nhóm/chức danh để quản nhiều người.

Lỗi cần tránh từ phản hồi cộng đồng:

- gán một việc cố định khiến nhân vật làm mãi và bỏ tu luyện;
- thiếu priority/tag/filter khiến quản nhiều người khó;
- phải click từng người gây mệt khi roster lớn.

Chuẩn hóa:

- `assignment` là ưu tiên, không phải xiềng xích;
- schedule có quota tu luyện/nghỉ mặc định;
- group/template phải hỗ trợ bulk management;
- cá nhân chỉ override khi thật sự cần.

## 6. Evil Hunter Tycoon — khung vận hành chính

Nguồn official:
- https://evilhunter.zendesk.com/hc/en-us/articles/360039885551-Conversing-with-a-hunter

Điểm giữ làm xương sống:

- hunter tự di chuyển và chiến đấu;
- người chơi gọi một hunter riêng để bảo mua/nâng/bán/đi vùng/ăn/nghỉ/chữa/học;
- nhân vật có tiền cá nhân và dùng dịch vụ/cửa hàng của căn cứ;
- căn cứ tạo hàng hóa mà nhân vật tiêu dùng;
- người chơi chủ yếu tạo điều kiện và ra lệnh ngoại lệ.

Chuẩn hóa cho Tông Môn Bá Đạo:

`Autonomy by default + Direct Sect Master command as temporary override`.

Không sao chép class cứng và không yêu cầu thao tác thủ công lặp lại trên từng người.

## 7. 鬼谷八荒 — cấp bậc và phân quyền

Nguồn:
- https://steamcommunity.com/app/1468810/discussions/0/3118172724621705341/

Điểm đáng lấy:

- ngoại môn -> nội môn -> chân truyền -> trưởng lão -> đại trưởng lão -> tông chủ;
- quyền phân công tăng theo chức vị;
- trưởng lão trở lên có thể giao nhiệm vụ;
- tông chủ điều phối người/tài nguyên và quyết định chiến lược;
- mission hall chia người sang tuyển dụng, tuần tra, ngoại vụ, xây dựng/học tập...

Điểm cần cải tiến:

- không biến đệ tử thường thành `population number` vô danh;
- các named disciples vẫn phải có bản sắc và lịch sử cá nhân.

## 8. 修仙家族模拟器 — tự động hóa workforce, loyalty, lương, đời người

Nguồn:
- https://www.taptap.cn/moment/267428253508044528
- https://www.taptap.cn/moment/270585099408378082
- https://www.taptap.cn/moment/411967876325443000
- https://www.taptap.cn/moment/571667014435735927

Đây là nguồn rất đáng học cho khi roster lớn.

### A. Tự phân công theo điều kiện

Game cho định nghĩa chức vị + điều kiện cảnh giới/linh căn/năng lực, rồi tự quét đệ tử rảnh để phân việc. Đây là pattern tốt hơn click từng người.

Chuẩn hóa cho game mình:

Ví dụ rule:

`outer + mining_level >= 20 + not_in_expedition + healthy -> Mining Group`.

### B. Lương và trung thành

Game có stipend định kỳ. Trả dưới mức tối thiểu làm giảm trung thành; trả tốt/tặng quà tăng trung thành; trung thành quá thấp có thể rời thế lực.

Đây là cực hợp với P2.6 vì ta đã có `wallet` cá nhân và `treasury`.

Vòng kinh tế tương lai có thể là:

`sect treasury -> stipend/reward -> disciple wallet -> disciple buys sect goods/services -> sect treasury`.

Đây vẫn là tiền nội bộ kín nếu không khai báo source/sink bên ngoài.

Không đưa vào P2.7 vertical slice; cân nhắc P2.8/P2.9.

### C. Sư đồ và di sản

Sư đồ có bonus tu luyện/công pháp; khi sư phụ chết, đồ có thể truyền cho hậu duệ/đệ tử. Đây tạo lịch sử thế hệ rất mạnh nhưng nên để sau khi workforce/rank ổn định.

### D. Tuổi thọ và cái chết

Thọ nguyên làm nghề/chức vụ có tính tạm thời; một đại sư có thể chết, buộc tông môn đào tạo người kế nghiệp. Đây là nguồn tạo câu chuyện mạnh, nhưng activation cần rất thận trọng vì pacing mobile/idle khác simulation PC.

## 9. 我要当掌门 — lịch cá nhân và quyền Tông Chủ

Nguồn:
- https://apps.apple.com/cn/app/id6448977365
- https://www.taptap.cn/moment/426085842130308715

Điểm đáng lấy:

- Tông Chủ không phải tự đi mạo hiểm; đệ tử được phái đi;
- đệ tử có lịch riêng;
- lịch tu luyện quan trọng để nhận kinh nghiệm võ học;
- các đệ tử khác có thể được xếp lịch lao động/khác để tăng hiệu suất.

=> xác nhận lịch không nên chỉ là cosmetic. Lịch phải đổi loại XP/resources mà nhân vật tạo ra.

## 10. Sect Master — vòng expedition-production-economy

Nguồn official Steam:
- https://store.steampowered.com/app/5222440/

Điểm đáng lấy:

- người chơi là sect master, không phải nhân vật tự cầm kiếm;
- expedition tự động;
- nguyên liệu và linh thạch về kho;
- workshop/crafting dùng tài nguyên đó;
- đệ tử có linh thạch cá nhân và tiêu tại cơ sở;
- đội hình/trang bị/kỹ thuật chuẩn bị trước quyết định combat;
- warehouse là nút nối expedition -> production -> build -> battle.

P2.6 đã đi đúng hướng này. P2.7 phải nối workforce vào warehouse và crafting.

Lưu ý: game chưa phát hành; chỉ dùng để học concept, không coi là bằng chứng balance/game-feel đã kiểm chứng.

## 11. RimWorld / Oxygen Not Included — pattern quản 50-100 nhân vật

Không phải tu tiên, nhưng cực đáng học về UI/authority.

### RimWorld

- mỗi pawn có work priorities và schedule theo giờ;
- nhu cầu có thể override công việc tùy schedule;
- pawn thường hoàn thành task hiện tại trước khi chọn task mới;
- player có thể direct-order một việc cụ thể.

### Oxygen Not Included

- mỗi Duplicant có interest/trait/skill;
- task category có priority cá nhân;
- công việc cụ thể còn có sub-priority;
- disable một category nghĩa là người đó không bao giờ làm loại việc đó.

Chuẩn hóa:

P2.7 nên có hai tầng priority:

1. `personal/group profession priority`;
2. `task/order priority`.

Không nên để một số priority duy nhất vừa mô tả người vừa mô tả task.

## 12. Mô hình chuẩn hóa đệ tử cho Tông Môn Bá Đạo

Một đệ tử nên được cấu thành bởi **7 lớp độc lập**:

### Lớp 1 — Identity / tình trạng sống

- tên, giới tính;
- tuổi/thọ nguyên về sau;
- HP, stamina, thương tích;
- mood/loyalty về sau;
- vị trí hiện tại.

### Lớp 2 — Innate potential

Đã có:
- personality biases;
- spiritual roots.

Nên thêm theo consequence:
- comprehension;
- constitution;
- fortune;
- charisma.

Không bắt buộc copy đủ sáu chiều của 最强祖师. `Potential` tổng quát dễ trở thành overall score nên chỉ thêm nếu có use-case riêng thật sự.

### Lớp 3 — Learned history

Đã có:
- cultivation realm/progress;
- technique mastery;
- Sword/Body/Spell path XP;
- combat skills.

Thêm:
- profession XP riêng từng nghề.

### Lớp 4 — Traits / quirks

0-N trait, có tốt/xấu/trade-off.

Ví dụ:
- forge_talent;
- alchemy_talent;
- meticulous;
- workaholic;
- lazy;
- reckless;
- frugal.

Trait phải thay đổi hành vi hoặc outcome, không chỉ text.

### Lớp 5 — Organizational identity

Tách hoàn toàn:

- `sect_rank` — ngoại môn/nội môn/chân truyền/chấp sự/trưởng lão/đường chủ...
- `work_group` — nhóm khai khoáng/Luyện Khí Đường/Dược Viên...
- `combat_team` — đội săn/đội boss...
- `combat_role` — vai trò chiến thuật.

### Lớp 6 — Social identity

Đã có relationships/memory.

Về sau:
- master-disciple;
- sworn/friend/rival/romance if desired;
- loyalty to sect/mentor;
- lineage/inheritance if lifespan system activated.

### Lớp 7 — Current authority / intent

- emergency need;
- direct Sect Master command;
- mandatory duty;
- schedule block;
- assignment priority;
- personal goal;
- fallback autonomy.

## 13. Authority order chuẩn

Đề xuất khóa logic sau:

1. Critical survival / emergency.
2. Direct Sect Master command.
3. Mandatory sect event/duty.
4. Schedule block.
5. Personal/group work priority.
6. Personal goal/personality.
7. Free autonomous fallback.

Lệnh Tông Chủ là **temporary override**, không biến thành class/job vĩnh viễn.

## 14. P2.7 — phạm vi nên giữ nhỏ

P2.7 không nên kích hoạt ngay mood, loyalty, stipend, lifespan, master-disciple.

Vertical slice chỉ cần chứng minh:

- profession XP;
- comprehension + profession trait;
- work priority/group;
- work schedule quota;
- direct command;
- 2 task thật (mining + forge support);
- output đi vào kho P2.6;
- AI vẫn biết nghỉ/tu luyện;
- recruitment preview có lý do giữ người yếu combat;
- save/load/determinism.

Nếu làm được vòng này thật tốt, các hệ sâu hơn có nền đúng để cắm vào.

## 15. Hệ nên cân nhắc sau P2.7

Ưu tiên nghiên cứu/triển khai theo thứ tự:

### P2.8 candidate — Sect Rank + Contribution + Promotion

- outer/inner/core;
- contribution;
- quyền lợi/nghĩa vụ khác nhau;
- stipend baseline theo rank;
- promotion là quyết định Tông Chủ.

### P2.9 candidate — Loyalty + Mood + Stipend + Sect Services

- treasury -> stipend -> wallet;
- wallet -> food/medicine/equipment/service -> treasury;
- overwork/unpaid/injury/favoritism ảnh hưởng loyalty/mood;
- low loyalty có behavioral consequence.

### P2.10 candidate — Master/Disciple + Teaching

- mentor improves cultivation/technique/profession learning;
- same technique/path gives stronger synergy;
- teaching takes mentor time;
- inheritance/succession hooks.

### Later — Lifespan, death, inheritance, lineage

Chỉ bật khi pacing đã chứng minh phù hợp game mobile/idle.

## 16. Anti-patterns khóa

Không làm:

- một `role` chứa rank + nghề + combat;
- một rarity/overall score quyết định giá trị đệ tử;
- profession chỉ là +X% thụ động không có task/history;
- work assignment khiến nhân vật làm việc 100% vô hạn;
- player phải click từng người khi roster lớn;
- AI được phép đè direct command hoặc manual equipment lock;
- trait chỉ là text màu;
- thêm 8-12 nghề trước khi 2 nghề đầu có vòng gameplay thật;
- hệ thọ nguyên/loyalty/sư đồ cùng lúc trong P2.7 làm phase vỡ scope.

## 17. Kết luận thiết kế

Cảm giác đích:

**Evil Hunter Tycoon ở tầng vận hành + colony-sim priority/schedule ở tầng quản người + cultivation games ở tầng bản sắc tu tiên.**

Người chơi phải có thể nhìn một đệ tử và hiểu:

> Người này là ai? Giỏi gì? Đang muốn gì? Đang làm gì? Tại sao làm? Có đáng đầu tư không? Nếu tôi ra lệnh thì họ phản ứng ra sao? Nếu tôi không động vào thì họ sẽ tự sống như thế nào?

Khi sáu câu hỏi đó có câu trả lời từ simulation thật, đệ tử mới trở thành nhân vật sống thay vì unit.
