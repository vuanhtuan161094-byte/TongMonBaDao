using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Events;
using UnityEngine.UI;

namespace TMBDPilot
{
    // Independent Unity scene; NOT a port or a second authority for the Godot game.
    // UI structure is source-referenced. Artwork is placeholder until real asset bytes are available.
    public sealed class PilotBootstrap : MonoBehaviour
    {
        private static readonly Color Ink = Hex("#283832");
        private static readonly Color Paper = Hex("#F3E8CA");
        private static readonly Color PalePaper = Hex("#FFF3D9");
        private static readonly Color Gold = Hex("#BD8D48");
        private static readonly Color Cinnabar = Hex("#B15D39");
        private static readonly Color Jade = Hex("#416D60");
        private static readonly Color Landscape = Hex("#B9C6A6");
        private PilotMineDomain domain;
        private Font font;
        private RectTransform uiRoot;
        private RectTransform rightPanel;
        private RectTransform modal;
        private RectTransform gridHost;
        private Text summaryText;
        private Text timerText;
        private Text stockText;
        private Text rosterInfo;
        private InputField searchInput;
        private int page;
        private bool onlyIdle;
        private float nextUiRefresh;

        private void Start()
        {
            domain = new PilotMineDomain();
            font = Resources.GetBuiltinResource<Font>("Arial.ttf");
            Application.targetFrameRate = 60;
            SetupEventSystem();
            CreateCanvas();
            DrawWorld();
            DrawBuildingPanel();
            rightPanel.gameObject.SetActive(false);
            RefreshHud();
        }

        private void Update()
        {
            if (domain == null) return;
            domain.Advance(Time.deltaTime);
            if (Time.unscaledTime >= nextUiRefresh)
            {
                nextUiRefresh = Time.unscaledTime + .25f;
                RefreshHud();
            }
        }

        private void SetupEventSystem()
        {
            if (FindObjectOfType<EventSystem>() == null)
                new GameObject("EventSystem", typeof(EventSystem), typeof(StandaloneInputModule));
        }

        private void CreateCanvas()
        {
            var go = new GameObject("TMBD Unity Pilot Canvas", typeof(RectTransform),
                typeof(Canvas), typeof(CanvasScaler), typeof(GraphicRaycaster));
            Canvas canvas = go.GetComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.sortingOrder = 0;
            CanvasScaler scaler = go.GetComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution = new Vector2(1280, 720);
            scaler.screenMatchMode = CanvasScaler.ScreenMatchMode.MatchWidthOrHeight;
            scaler.matchWidthOrHeight = .5f;
            uiRoot = go.GetComponent<RectTransform>();
        }

        private void DrawWorld()
        {
            Panel(uiRoot, "World / illustration placeholder", Vector2.zero,
                new Vector2(1280, 720), Landscape);
            Panel(uiRoot, "Mountains", new Vector2(0, 105),
                new Vector2(1280, 440), Hex("#CAD0B4"));
            Panel(uiRoot, "Courtyard", new Vector2(0, -104),
                new Vector2(1280, 300), Hex("#B8BDA0"));

            Panel(uiRoot, "Tông Môn Đại Điện (placeholder)", new Vector2(-20, 125),
                new Vector2(260, 140), Hex("#8A9C85"));
            Label(uiRoot, "TÔNG MÔN ĐẠI ĐIỆN", new Vector2(-20, 125),
                new Vector2(260, 58), 22, PalePaper, TextAnchor.MiddleCenter);
            Panel(uiRoot, "Linh Lâm (placeholder)", new Vector2(-370, 0),
                new Vector2(220, 145), Hex("#819D87"));
            Label(uiRoot, "LINH LÂM", new Vector2(-370, 0),
                new Vector2(220, 58), 23, PalePaper, TextAnchor.MiddleCenter);
            ButtonAt(uiRoot, "MỎ THANH THIẾT\\nChạm để quản lý", new Vector2(-25, -85),
                new Vector2(280, 160), Hex("#8C8B72"), OpenMine, 22);

            Panel(uiRoot, "Resource top HUD", new Vector2(0, 333),
                new Vector2(1260, 60), Hex("#314C47"));
            Label(uiRoot, "TÔNG MÔN BÁ ĐẠO", new Vector2(-468, 333),
                new Vector2(305, 50), 24, PalePaper, TextAnchor.MiddleLeft);
            Label(uiRoot, "UNITY PILOT • 1280 × 720", new Vector2(-62, 333),
                new Vector2(365, 40), 18, PalePaper, TextAnchor.MiddleCenter);
            stockText = Label(uiRoot, "", new Vector2(457, 333),
                new Vector2(335, 45), 19, PalePaper, TextAnchor.MiddleCenter);

            Panel(uiRoot, "Tasks", new Vector2(-530, 180),
                new Vector2(214, 220), Paper);
            Label(uiRoot, "TÔNG MÔN", new Vector2(-528, 267),
                new Vector2(190, 34), 23, Ink, TextAnchor.MiddleCenter);
            Label(uiRoot, "• Quản lý Mỏ\\n• Phân công đệ tử\\n• Quan sát tiến độ\\n• Thử Spine 3.8 sau",
                new Vector2(-527, 167), new Vector2(184, 155), 20, Ink,
                TextAnchor.MiddleLeft);

            Panel(uiRoot, "Bottom game navigation", new Vector2(0, -335),
                new Vector2(790, 56), Hex("#314C47"));
            Label(uiRoot, "ĐỆ TỬ          KHO          CÔNG TRÌNH          THẾ GIỚI",
                new Vector2(0, -335), new Vector2(760, 42), 20,
                PalePaper, TextAnchor.MiddleCenter);
            Label(uiRoot, "DEMO ĐỘC LẬP • Không ghi dữ liệu sang Godot V2",
                new Vector2(-280, -268), new Vector2(630, 30), 17, Ink,
                TextAnchor.MiddleCenter);
        }

        private void OpenMine()
        {
            rightPanel.gameObject.SetActive(true);
            DrawBuildingPanel();
            RefreshHud();
        }

        private void DrawBuildingPanel()
        {
            if (rightPanel == null)
                rightPanel = Panel(uiRoot, "Mine management", new Vector2(445, -3),
                    new Vector2(348, 592), Paper);
            ClearChildren(rightPanel);

            Label(rightPanel, "MỎ THANH THIẾT", new Vector2(0, 256),
                new Vector2(300, 43), 25, Ink, TextAnchor.MiddleCenter);
            ButtonAt(rightPanel, "×", new Vector2(144, 262), new Vector2(32, 32),
                Cinnabar, delegate { rightPanel.gameObject.SetActive(false); }, 26);
            Label(rightPanel, "Cấp 1  •  KHAI THÁC", new Vector2(0, 212),
                new Vector2(310, 31), 18, Ink, TextAnchor.MiddleCenter);

            summaryText = Label(rightPanel, "", new Vector2(0, 172),
                new Vector2(310, 34), 20, Ink, TextAnchor.MiddleCenter);
            for (int i = 0; i < PilotMineDomain.SlotLimit; i++)
            {
                int slot = i;
                float y = 100 - i * 90;
                bool assigned = i < domain.MineWorkerIds.Count;
                string name = assigned ? domain.Find(domain.MineWorkerIds[i]).Name : "+ Ô TRỐNG";
                Panel(rightPanel, "Disciple slot " + i, new Vector2(0, y),
                    new Vector2(300, 78), PalePaper);
                Label(rightPanel, assigned ? "NHÂN" : "+", new Vector2(-112, y),
                    new Vector2(55, 50), 17, Jade, TextAnchor.MiddleCenter);
                Label(rightPanel, name, new Vector2(6, y + 12),
                    new Vector2(200, 34), 21, Ink, TextAnchor.MiddleLeft);
                Label(rightPanel, assigned ? "Đang khai thác" : "Chạm để chọn đệ tử",
                    new Vector2(6, y - 20), new Vector2(200, 25), 17,
                    assigned ? Jade : Cinnabar, TextAnchor.MiddleLeft);
                if (!assigned)
                    ButtonAt(rightPanel, "CHỌN", new Vector2(116, y), new Vector2(73, 40),
                        Cinnabar, OpenPicker, 18);
            }

            timerText = Label(rightPanel, "", new Vector2(0, -196),
                new Vector2(310, 50), 20, Ink, TextAnchor.MiddleCenter);
            ButtonAt(rightPanel, "PHÂN CÔNG ĐỆ TỬ", new Vector2(0, -254),
                new Vector2(294, 50), Cinnabar, OpenPicker, 21);
        }

        private void OpenPicker()
        {
            if (modal != null) Destroy(modal.gameObject);
            page = 0;
            onlyIdle = false;
            modal = Panel(uiRoot, "Modal dimmer", Vector2.zero,
                new Vector2(1280, 720), new Color(0f, 0f, 0f, .55f));
            RectTransform parchment = Panel(modal, "Disciple parchment", Vector2.zero,
                new Vector2(922, 600), Paper);
            Label(parchment, "CHỌN ĐỆ TỬ PHÂN CÔNG MỎ", new Vector2(0, 265),
                new Vector2(750, 46), 29, Ink, TextAnchor.MiddleCenter);
            ButtonAt(parchment, "×", new Vector2(421, 264), new Vector2(38, 38),
                Cinnabar, ClosePicker, 26);
            BuildSearchBox(parchment);

            ButtonAt(parchment, "Chỉ hiện người rảnh", new Vector2(260, 209),
                new Vector2(240, 42), Jade, ToggleFree, 17);
            gridHost = Panel(parchment, "Portrait grid host", new Vector2(0, -2),
                new Vector2(872, 375), PalePaper);
            ButtonAt(parchment, "‹ Trang trước", new Vector2(-342, -261),
                new Vector2(168, 43), Jade, delegate { page--; RefreshGrid(); }, 18);
            rosterInfo = Label(parchment, "", new Vector2(0, -261),
                new Vector2(320, 40), 19, Ink, TextAnchor.MiddleCenter);
            ButtonAt(parchment, "Trang sau ›", new Vector2(342, -261),
                new Vector2(168, 43), Jade, delegate { page++; RefreshGrid(); }, 18);
            RefreshGrid();
        }

        private void BuildSearchBox(RectTransform parent)
        {
            RectTransform back = Panel(parent, "Search box", new Vector2(-195, 209),
                new Vector2(438, 42), PalePaper);
            searchInput = back.gameObject.AddComponent<InputField>();
            Text text = Label(back, "", Vector2.zero, new Vector2(413, 37),
                20, Ink, TextAnchor.MiddleLeft);
            Text placeholder = Label(back, "  Tìm tên hoặc nghề...", Vector2.zero,
                new Vector2(413, 37), 19, Gold, TextAnchor.MiddleLeft);
            searchInput.textComponent = text;
            searchInput.placeholder = placeholder;
            searchInput.onValueChanged.AddListener(delegate { page = 0; RefreshGrid(); });
        }

        private void ToggleFree()
        {
            onlyIdle = !onlyIdle;
            page = 0;
            RefreshGrid();
        }

        private void RefreshGrid()
        {
            if (gridHost == null || searchInput == null) return;
            ClearChildren(gridHost);
            List<PilotDisciple> found = domain.Search(searchInput.text, onlyIdle).ToList();
            int totalPages = Math.Max(1, (found.Count + 8) / 9);
            page = Mathf.Clamp(page, 0, totalPages - 1);
            if (rosterInfo != null)
                rosterInfo.text = (onlyIdle ? "Người rảnh • " : "Tất cả • ") +
                    "Trang " + (page + 1) + "/" + totalPages + " • " + found.Count + " đệ tử";
            List<PilotDisciple> view = found.Skip(page * 9).Take(9).ToList();
            for (int i = 0; i < view.Count; i++)
            {
                PilotDisciple d = view[i];
                int col = i % 3, row = i / 3;
                float x = -287 + col * 287;
                float y = 121 - row * 122;
                RectTransform portrait = Panel(gridHost, "Disciple " + d.Id,
                    new Vector2(x, y), new Vector2(272, 112), Paper);
                Label(portrait, "◈", new Vector2(-106, 17),
                    new Vector2(54, 72), 30, Jade, TextAnchor.MiddleCenter);
                Label(portrait, d.Name, new Vector2(28, 33),
                    new Vector2(200, 29), 21, Ink, TextAnchor.MiddleCenter);
                Label(portrait, d.Profession + " • " + d.Skill,
                    new Vector2(30, 2), new Vector2(200, 27), 17, Ink,
                    TextAnchor.MiddleCenter);
                bool idle = d.Job == PilotJob.Idle;
                Button pick = ButtonAt(portrait, idle ? "PHÂN CÔNG" : "ĐANG: " + d.Job,
                    new Vector2(29, -35), new Vector2(198, 36),
                    idle ? Cinnabar : Hex("#8E8A7C"),
                    delegate { AssignDisciple(d.Id); }, 16);
                pick.interactable = idle && domain.MineWorkerIds.Count < PilotMineDomain.SlotLimit;
            }
        }

        private void AssignDisciple(string id)
        {
            string reason;
            if (!domain.TryAssign(id, out reason))
            {
                Debug.LogWarning("Pilot: " + reason);
                RefreshGrid();
                return;
            }
            ClosePicker();
            DrawBuildingPanel();
            RefreshHud();
        }

        private void ClosePicker()
        {
            if (modal != null) Destroy(modal.gameObject);
            modal = null;
            gridHost = null;
            searchInput = null;
            rosterInfo = null;
        }

        private void RefreshHud()
        {
            if (stockText != null)
                stockText.text = "Thanh Thiết (demo): " + domain.MockOre;
            if (rightPanel == null || !rightPanel.gameObject.activeSelf) return;
            if (summaryText != null)
                summaryText.text = "Nhân sự: " + domain.MineWorkerIds.Count + "/" +
                    PilotMineDomain.SlotLimit + "   •   Mẻ: " + domain.CompletedPackets;
            if (timerText != null)
                timerText.text = "Tiến độ: " + Mathf.RoundToInt(domain.PacketProgress * 100f) +
                    "%   •   Còn " + domain.SecondsRemaining + " giây";
        }

        private static Color Hex(string value)
        {
            Color color;
            return ColorUtility.TryParseHtmlString(value, out color) ? color : Color.white;
        }

        private RectTransform Panel(Transform parent, string name, Vector2 pos,
            Vector2 size, Color color)
        {
            var go = new GameObject(name, typeof(RectTransform),
                typeof(CanvasRenderer), typeof(Image));
            go.transform.SetParent(parent, false);
            RectTransform rt = go.GetComponent<RectTransform>();
            Place(rt, pos, size);
            Image img = go.GetComponent<Image>();
            img.color = color;
            return rt;
        }

        private Text Label(Transform parent, string value, Vector2 pos, Vector2 size,
            int fontSize, Color color, TextAnchor alignment)
        {
            var go = new GameObject("Label", typeof(RectTransform),
                typeof(CanvasRenderer), typeof(Text));
            go.transform.SetParent(parent, false);
            RectTransform rt = go.GetComponent<RectTransform>();
            Place(rt, pos, size);
            Text t = go.GetComponent<Text>();
            t.font = font;
            t.text = value.Replace("\\n", "\n");
            t.fontSize = fontSize;
            t.color = color;
            t.alignment = alignment;
            t.horizontalOverflow = HorizontalWrapMode.Wrap;
            t.verticalOverflow = VerticalWrapMode.Truncate;
            return t;
        }

        private Button ButtonAt(Transform parent, string title, Vector2 pos,
            Vector2 size, Color color, UnityAction action, int fontSize = 20)
        {
            RectTransform rt = Panel(parent, "Action: " + title, pos, size, color);
            Button button = rt.gameObject.AddComponent<Button>();
            button.targetGraphic = rt.GetComponent<Image>();
            button.onClick.AddListener(action);
            Label(rt, title, Vector2.zero, new Vector2(size.x - 8, size.y - 6),
                fontSize, PalePaper, TextAnchor.MiddleCenter);
            return button;
        }

        private static void Place(RectTransform rt, Vector2 pos, Vector2 size)
        {
            rt.anchorMin = rt.anchorMax = new Vector2(.5f, .5f);
            rt.pivot = new Vector2(.5f, .5f);
            rt.anchoredPosition = pos;
            rt.sizeDelta = size;
        }

        private static void ClearChildren(Transform transform)
        {
            for (int i = transform.childCount - 1; i >= 0; --i)
                Destroy(transform.GetChild(i).gameObject);
        }
    }
}
