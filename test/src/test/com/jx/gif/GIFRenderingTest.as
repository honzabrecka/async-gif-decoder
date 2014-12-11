package test.com.jx.gif
{
	import com.jx.gif.GIF;
	import com.jx.screenshot.Screenshot;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;

	public class GIFRenderingTest
	{
		
		private static const TIMEOUT:uint = 1000;
		
		private var gif:GIF;
		
		[Before]
		public function setUp():void
		{
			gif = new GIF();
		}
		
		[After]
		public function tearDown():void
		{
			gif.dispose();
			gif = null;
		}
		
		[Test(async)]
		public function singleFrame():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertTrue(Screenshot.compare("singleFrame", gif));
			}, TIMEOUT);
			gif.load(new URLRequest("../fixtures/1x1_orange.gif"));
		}
		
		[Test(async)]
		public function m1():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertScreenshot("m1.1", gif);
				gif.nextFrame();
				assertScreenshot("m1.2", gif);
				gif.nextFrame();
				assertScreenshot("m1.3", gif);
				gif.nextFrame();
				assertScreenshot("m1.4", gif);
				gif.nextFrame();
				assertScreenshot("m1.5", gif);
			}, TIMEOUT);
			gif.load(new URLRequest("../fixtures/m1.gif"));
		}
		
		[Test(async)]
		public function m1t():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertScreenshot("m1t.1", gif);
				gif.nextFrame();
				assertScreenshot("m1t.2", gif);
				gif.nextFrame();
				assertScreenshot("m1t.3", gif);
				gif.nextFrame();
				assertScreenshot("m1t.4", gif);
				gif.nextFrame();
				assertScreenshot("m1t.5", gif);
			}, TIMEOUT);
			gif.load(new URLRequest("../fixtures/m1t.gif"));
		}
		
		[Test(async)]
		public function m2():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertScreenshot("m2.1", gif);
				gif.nextFrame();
				assertScreenshot("m2.2", gif);
				gif.nextFrame();
				assertScreenshot("m2.3", gif);
				gif.nextFrame();
				assertScreenshot("m2.4", gif);
				gif.nextFrame();
				assertScreenshot("m2.5", gif);
			}, TIMEOUT);
			gif.load(new URLRequest("../fixtures/m2.gif"));
		}
		
		[Test(async)]
		public function m3():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertScreenshot("m3.1", gif);
				gif.nextFrame();
				assertScreenshot("m3.2", gif);
				gif.nextFrame();
				assertScreenshot("m3.3", gif);
				gif.nextFrame();
				assertScreenshot("m3.4", gif);
				gif.nextFrame();
				assertScreenshot("m3.5", gif);
			}, TIMEOUT);
			gif.load(new URLRequest("../fixtures/m3.gif"));
		}
		
		[Test(async)]
		public function m4nb():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertScreenshot("m4nb.1", gif);
				gif.nextFrame();
				assertScreenshot("m4nb.2", gif);
				gif.nextFrame();
				assertScreenshot("m4nb.3", gif);
				gif.nextFrame();
				assertScreenshot("m4nb.4", gif);
				gif.nextFrame();
				assertScreenshot("m4nb.5", gif);
			}, TIMEOUT);
			gif.load(new URLRequest("../fixtures/m4nb.gif"));
		}
		
		[Test(async)]
		public function m5np():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertScreenshot("m5np.1", gif);
				gif.nextFrame();
				assertScreenshot("m5np.2", gif);
				gif.nextFrame();
				assertScreenshot("m5np.3", gif);
				gif.nextFrame();
				assertScreenshot("m5np.4", gif);
				gif.nextFrame();
				assertScreenshot("m5np.5", gif);
			}, TIMEOUT);
			gif.load(new URLRequest("../fixtures/m5np.gif"));
		}
		
		[Test(async)]
		public function m6nbnb():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertScreenshot("m6nbnb.1", gif);
				gif.nextFrame();
				assertScreenshot("m6nbnb.2", gif);
				gif.nextFrame();
				assertScreenshot("m6nbnb.3", gif);
				gif.nextFrame();
				assertScreenshot("m6nbnb.4", gif);
				gif.nextFrame();
				assertScreenshot("m6nbnb.5", gif);
				gif.nextFrame();
				assertScreenshot("m6nbnb.6", gif);
			}, TIMEOUT);
			gif.load(new URLRequest("../fixtures/m6nbnb.gif"));
		}
		
		[Test(async)]
		public function m7npnp():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertScreenshot("m7npnp.1", gif);
				gif.nextFrame();
				assertScreenshot("m7npnp.2", gif);
				gif.nextFrame();
				assertScreenshot("m7npnp.3", gif);
				gif.nextFrame();
				assertScreenshot("m7npnp.4", gif);
				gif.nextFrame();
				assertScreenshot("m7npnp.5", gif);
				gif.nextFrame();
				assertScreenshot("m7npnp.6", gif);
			}, TIMEOUT);
			gif.load(new URLRequest("../fixtures/m7npnp.gif"));
		}
		
		[Test(async)]
		public function singlePixelTopLeft():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertScreenshot("singlePixelTopLeft", gif);
			}, TIMEOUT);
			gif.load(new URLRequest("../fixtures/400x300_topLeftPixel.gif"));
		}
		
		[Test(async)]
		public function singlePixelCenterCenter():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertScreenshot("singlePixelCenterCenter", gif);
			}, TIMEOUT);
			gif.load(new URLRequest("../fixtures/400x300_centerPixel.gif"));
		}
		
		private function assertScreenshot(fixture:String, gif:GIF):void
		{
			assertTrue(Screenshot.compare(fixture, gif));
		}
		
	}
}