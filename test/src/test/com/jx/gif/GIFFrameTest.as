// -----------------------------------------------------------------------
//  async-gif-decoder
//  Copyright 2014 Jan Břečka. All Rights Reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
// -----------------------------------------------------------------------

package test.com.jx.gif
{
	import com.jx.gif.GIFFrame;
	
	import flash.display.BitmapData;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;

	public class GIFFrameTest
	{
		
		private var frame:GIFFrame;
		
		[Before]
		public function setUp():void
		{
			frame = new GIFFrame(new BitmapData(1, 1), 2, 3);
		}
		
		[Test]
		public function image():void
		{
			assertNotNull(frame.image);
			assertEquals(1, frame.image.width);
			assertEquals(1, frame.image.height);
		}
		
		[Test]
		public function delay():void
		{
			assertEquals(2, frame.delay);
		}
		
		[Test]
		public function dispose():void
		{
			assertEquals(3, frame.dispose);
		}
		
	}
}