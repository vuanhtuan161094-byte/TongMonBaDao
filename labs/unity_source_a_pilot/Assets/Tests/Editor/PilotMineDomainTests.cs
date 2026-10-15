using NUnit.Framework;
using TMBDPilot;

namespace TMBDPilot.Tests
{
    public sealed class PilotMineDomainTests
    {
        [Test]
        public void AssignIdleWorker_ClaimsOneSlotAndOneActiveJob()
        {
            var domain = new PilotMineDomain();
            string reason;
            Assert.IsTrue(domain.TryAssign("d03", out reason));
            Assert.AreEqual(PilotJob.Mine, domain.Find("d03").Job);
            Assert.AreEqual(2, domain.MineWorkerIds.Count);
            Assert.IsFalse(domain.TryAssign("d03", out reason));
            Assert.AreEqual(2, domain.MineWorkerIds.Count);
        }

        [Test]
        public void ActiveFieldOrPveWorker_CannotTransferSilently()
        {
            var domain = new PilotMineDomain();
            string reason;
            Assert.IsFalse(domain.TryAssign("d02", out reason));
            Assert.IsFalse(domain.TryAssign("d12", out reason));
            Assert.AreEqual(1, domain.MineWorkerIds.Count);
        }

        [Test]
        public void FullMine_RejectsExtraAssignment()
        {
            var domain = new PilotMineDomain();
            string reason;
            Assert.IsTrue(domain.TryAssign("d03", out reason));
            Assert.IsTrue(domain.TryAssign("d04", out reason));
            Assert.IsFalse(domain.TryAssign("d06", out reason));
            Assert.AreEqual(PilotJob.Idle, domain.Find("d06").Job);
        }

        [Test]
        public void Packet_ProducesOnceOnlyAfterTwelveSeconds()
        {
            var domain = new PilotMineDomain();
            domain.Advance(11);
            Assert.AreEqual(0, domain.MockOre);
            domain.Advance(1);
            Assert.AreEqual(2, domain.MockOre);
            Assert.AreEqual(1, domain.CompletedPackets);
            domain.Advance(0);
            Assert.AreEqual(2, domain.MockOre);
            domain.Advance(24);
            Assert.AreEqual(6, domain.MockOre);
            Assert.AreEqual(3, domain.CompletedPackets);
        }

        [Test]
        public void Query_IsIdleFirstAndSearchable()
        {
            var domain = new PilotMineDomain();
            var result = System.Linq.Enumerable.ToArray(domain.Search("Khai khoang", true));
            Assert.Greater(result.Length, 0);
            foreach (var d in result)
                Assert.AreEqual(PilotJob.Idle, d.Job);
        }
    }
}
