namespace CounterAPI.Tests
{
    [TestClass]
    public class CounterServiceTests
    {
        [TestMethod]
        public void IncrementAndGet_FirstCall_ReturnsOne()
        {
            var service = new CounterService();

            Assert.AreEqual(1, service.IncrementAndGet());
        }
    }
}
