extends RefCounted

# LAB_ONLY visual art direction. Canonical V6.3 catalog governs effects,
# ranges, cooldown, shape, number of real targets and all HP/status outcomes.
# No combat balance, Save, loot or gameplay state is authored by these briefs.
# Motifs are original presentation identifiers, not executable skill mechanics.
const PREFIX := "tmb.skill.poison."
const HUMAN := {
    "basic.human": {"description": "Độc châm cơ bản vút thẳng tới một mục tiêu.", "vfx": "Kim nhỏ tím-bạc có lõi ngọc sáng, dư ảnh ngắn, trúng tạo một tia xuyên gọn.", "motif": "needle_basic"},
    "mobility.human": {"description": "Bước ẩn thân né đòn và dịch chuyển khi cần tiếp cận mục tiêu.", "vfx": "Bóng tím tan thành ba vệt khói mỏng, ánh kim chớp ở điểm đến; không giả lập trúng đòn.", "motif": "shadow_step"},
    "doc_cham.active_01.human": {"description": "Kim độc đâm xuyên mục tiêu đơn.", "vfx": "Kim xuyên xương thân sắc, viền tím đậm, lóe bạc khi găm trúng; không nổ tròn.", "motif": "needle_pierce"},
    "doc_cham.active_02.human": {"description": "Kim tẩm độc thâm nhập một mục tiêu.", "vfx": "Kim tím-vàng đâm vào thân, đường độc nhỏ cuộn dọc mục tiêu rồi tan.", "motif": "needle_venom"},
    "doc_cham.active_03.human": {"description": "Tán châm ảnh hưởng một vùng theo giới hạn mục tiêu thực.", "vfx": "Đuôi kim tụ về tâm rồi tỏa thành quạt mưa châm; ranh giới AoE dưới chân quái.", "motif": "needle_fan"},
    "doc_cham.active_04.human": {"description": "Khí độc bộc phát trên một vùng được khóa tâm.", "vfx": "Khói tím than cuộn thấp, lục quang co về tâm như xung độc; viền vùng mỏng.", "motif": "miasma_pulse"},
    "doc_cham.ultimate.human": {"description": "Tuyệt kỹ kim độc diện rộng với phạm vi mục tiêu theo catalog.", "vfx": "Trận đồ châm huyền tím-bạc; kim từ ngoài hội tụ, lóe sáng xuyên tâm rồi tàn dư ngọc.", "motif": "thousand_needles"},
    "co_doc.active_01.human": {"description": "Đòn cổ trùng đánh trực tiếp vào một mục tiêu.", "vfx": "Cổ trùng một đầu sáng lục-vàng, thân có đốt; cắn gọn, không hiện như viên cầu.", "motif": "gu_bite"},
    "co_doc.active_02.human": {"description": "Xà ảnh gieo độc lên một mục tiêu.", "vfx": "Xà ảnh uốn mảnh quấn từ vai xuống thân, để lại vệt độc mờ rồi tan.", "motif": "serpent_bind"},
    "co_doc.active_03.human": {"description": "Cổ vụ bao phủ vùng tác động đã được xác định.", "vfx": "Màn sương lục đen bám thấp mặt đất, cổ trùng li ti ánh vàng hiện rồi ẩn.", "motif": "gu_mist"},
    "co_doc.active_04.human": {"description": "Cổ trùng phân tán trong vùng kỹ năng.", "vfx": "Vệt cổ trùng tỏa từ tâm thành các đường cong ngắn, ánh lục tắt dần.", "motif": "gu_scatter"},
    "co_doc.ultimate.human": {"description": "Tuyệt kỹ cổ độc diện rộng, số mục tiêu theo catalog.", "vfx": "Xà ảnh lớn cuốn quanh tâm vùng, nhiều đốm cổ quang đồng pha dồn vào một nhịp.", "motif": "gu_domain"},
    "duoc_doc.active_01.human": {"description": "Ấn dược ngọc đánh trúng một mục tiêu; đây là chiêu sát thương.", "vfx": "Dược châu lam ngọc lao tới, cánh liên hoa nhọn bung tại điểm va chạm.", "motif": "jade_strike"},
    "duoc_doc.active_02.human": {"description": "Linh dược hồi phục HP cho một đồng minh.", "vfx": "Liên hoa ngọc nở dưới chân đồng minh, ánh vàng lam nâng lên qua cơ thể.", "motif": "jade_heal"},
    "duoc_doc.active_03.human": {"description": "Dược thuật thanh tẩy một mục tiêu.", "vfx": "Dược ấn ngọc xoay ngược, kéo sắc độc ra ngoài rồi biến thành mảnh ánh sáng.", "motif": "jade_cleanse"},
    "duoc_doc.active_04.human": {"description": "Linh tán giải trừ trạng thái cho một mục tiêu.", "vfx": "Cánh hoa nhỏ tỏa thành luồng khí ngọc trong, tan thành bụi phấn dịu.", "motif": "jade_scatter"},
    "duoc_doc.ultimate.human": {"description": "Tuyệt kỹ hồi phục một đồng minh, không phải AoE.", "vfx": "Đại liên hoa nhiều lớp nở tuần tự; tâm vàng ngọc sáng lên rồi dịu hẳn.", "motif": "jade_ultimate"},
}

static func profile(skill_id: String) -> Dictionary:
    if not skill_id.begins_with(PREFIX):
        return {}
    var short_id := skill_id.trim_prefix(PREFIX)
    return HUMAN.get(short_id, {})

static func mechanic(definition: Dictionary) -> String:
    var effect := str(definition.get("effect", ""))
    match effect:
        "damage": return "Sát thương trực tiếp"
        "poison": return "Áp dụng độc theo kết quả chiến đấu"
        "heal": return "Hồi phục HP cho mục tiêu hợp lệ"
        "cleanse": return "Giải hiệu ứng bất lợi cho mục tiêu hợp lệ"
        "guard": return "Hộ thể theo kết quả chiến đấu"
        "mark": return "Đặt ấn lên mục tiêu"
        "consume_poison": return "Tiêu hao độc đã được ghi nhận"
        "mobility": return "Thân pháp di chuyển và né tránh"
        "passive": return "Nội tại - không có đòn đánh trực tiếp"
        "innate": return "Thiên phú - không có đòn đánh trực tiếp"
        _: return "Xem hiệu ứng thực trong catalog"

static func geometry(definition: Dictionary) -> String:
    var slot := str(definition.get("slot", ""))
    if slot in ["passive", "innate"]:
        return "Nội tại - không có đường bay, tầm đánh hay AoE"
    var reach := float(definition.get("range", 0.0))
    var radius := float(definition.get("radius", 0.0))
    var cap := int(definition.get("target_limit", 1))
    var shape := str(definition.get("shape", "single_target"))
    if shape == "circle" and radius > 0.0:
        return "Thi triển %.1f ô · vùng bán kính %.1f ô · tối đa %d mục tiêu" % [reach, radius, cap]
    if shape == "line":
        return "Thi triển %.1f ô · dạng đường · tối đa %d mục tiêu" % [reach, cap]
    return "Tầm %.1f ô · %s" % [reach, "một mục tiêu" if cap == 1 else "tối đa %d mục tiêu" % cap]
