package test.com.jx.gif
{
	public class Fixtures
	{
		
		public function Fixtures() { }
		
		[Embed(source = "../../../../../fixtures/1x1_orange.gif", mimeType = "application/octet-stream")]
		public static const GIF_1x1_orange:Class;
		
		[Embed(source = "../../../../../fixtures/1x1_transparent.gif", mimeType = "application/octet-stream")]
		public static const GIF_1x1_transparent:Class;
		
		[Embed(source = "../../../../../fixtures/animated.gif", mimeType = "application/octet-stream")]
		public static const GIF_animated:Class;
		
		[Embed(source = "../../../../../fixtures/1x1.png", mimeType = "application/octet-stream")]
		public static const PNG_1x1:Class;
		
	}
}