using System;
using System.Collections.Generic;
using System.Linq;

namespace TMBDPilot
{
    // ISOLATED DEMO DATA ONLY. Never imported from or written to Godot V2 state.
    public enum PilotJob { Idle, Mine, SpiritField, PvE, Alchemy }

    public sealed class PilotDisciple
    {
        public string Id { get; private set; }
        public string Name { get; private set; }
        public string Profession { get; private set; }
        public int Skill { get; private set; }
        public PilotJob Job { get; set; }

        public PilotDisciple(string id, string name, string profession, int skill, PilotJob job)
        {
            Id = id;
            Name = name;
            Profession = profession;
            Skill = skill;
            Job = job;
        }
    }

    public sealed class PilotMineDomain
    {
        public const int SlotLimit = 3;
        public const int PacketSeconds = 12;
        public const int OrePerPacket = 2;

        public readonly List<PilotDisciple> Disciples = new List<PilotDisciple>();
        public readonly List<string> MineWorkerIds = new List<string>();

        private readonly HashSet<string> settledDemoReceipts = new HashSet<string>();
        private float elapsed;
        private int nextPacketId;

        public int MockOre { get; private set; }
        public int CompletedPackets { get; private set; }
        public float PacketProgress { get { return elapsed / PacketSeconds; } }
        public int SecondsRemaining { get { return Math.Max(0, (int)Math.Ceiling(PacketSeconds - elapsed)); } }

        public PilotMineDomain()
        {
            Add("d01", "Hac Lien", "Khai khoang", 42, PilotJob.Mine);
            Add("d02", "Ly Thanh", "Trong trot", 28, PilotJob.SpiritField);
            Add("d03", "Tieu Dao", "Khai khoang", 33, PilotJob.Idle);
            Add("d04", "Van Nhi", "Khai khoang", 37, PilotJob.Idle);
            Add("d05", "Tuyet Mai", "Luyen dan", 51, PilotJob.Alchemy);
            Add("d06", "Mac Phong", "Khai khoang", 18, PilotJob.Idle);
            Add("d07", "Thien Lan", "Trong trot", 24, PilotJob.Idle);
            Add("d08", "Duong Tam", "Khai khoang", 39, PilotJob.Idle);
            Add("d09", "Luc Vu", "Khai khoang", 22, PilotJob.Idle);
            Add("d10", "Nguyet Ha", "Trong trot", 25, PilotJob.Idle);
            Add("d11", "Lam Du", "Khai khoang", 41, PilotJob.Idle);
            Add("d12", "Phi Yen", "Chien dau", 30, PilotJob.PvE);
            Add("d13", "Tuong Van", "Khai khoang", 35, PilotJob.Idle);
            Add("d14", "Minh Kiet", "Khai khoang", 17, PilotJob.Idle);
            MineWorkerIds.Add("d01");
        }

        private void Add(string id, string name, string profession, int skill, PilotJob job)
        {
            Disciples.Add(new PilotDisciple(id, name, profession, skill, job));
        }

        public PilotDisciple Find(string id)
        {
            return Disciples.FirstOrDefault(d => d.Id == id);
        }

        public bool TryAssign(string discipleId, out string reason)
        {
            PilotDisciple d = Find(discipleId);
            if (d == null) { reason = "Khong tim thay de tu"; return false; }
            if (d.Job != PilotJob.Idle || MineWorkerIds.Contains(d.Id))
            {
                reason = "De tu dang co cong viec; khong duoc chuyen ngam";
                return false;
            }
            if (MineWorkerIds.Count >= SlotLimit)
            {
                reason = "Mo da day cho";
                return false;
            }

            MineWorkerIds.Add(d.Id);
            d.Job = PilotJob.Mine;
            reason = "";
            return true;
        }

        public void Advance(float seconds)
        {
            if (seconds <= 0 || MineWorkerIds.Count == 0) return;
            elapsed += seconds;
            while (elapsed >= PacketSeconds)
            {
                elapsed -= PacketSeconds;
                string receipt = "demo-mine-" + (++nextPacketId);
                if (settledDemoReceipts.Add(receipt))
                {
                    MockOre += OrePerPacket;
                    CompletedPackets++;
                }
            }
        }

        public IEnumerable<PilotDisciple> Search(string text, bool onlyIdle)
        {
            string needle = (text ?? "").Trim();
            return Disciples.Where(d =>
                (!onlyIdle || d.Job == PilotJob.Idle) &&
                (needle.Length == 0 ||
                 d.Name.IndexOf(needle, StringComparison.OrdinalIgnoreCase) >= 0 ||
                 d.Profession.IndexOf(needle, StringComparison.OrdinalIgnoreCase) >= 0))
                .OrderBy(d => d.Job == PilotJob.Idle ? 0 : 1)
                .ThenByDescending(d => d.Skill)
                .ThenBy(d => d.Name);
        }
    }
}
