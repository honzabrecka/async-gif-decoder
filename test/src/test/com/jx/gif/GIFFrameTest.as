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
	
	import org.flexunit.asserts.assertEquals;

	public class GIFFrameTest
	{
		
		private var frame:GIFFrame;
		
		[Before]
		public function setUp():void
		{
			frame = new GIFFrame();
		}
		
		[Test]
		public function test():void
		{
			assertEquals(1, 1);
		}
		
	}
}