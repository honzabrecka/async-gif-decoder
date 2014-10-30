// -----------------------------------------------------------------------
//  async-gif-decoder
//  Copyright 2014 Jan Břečka. All Rights Reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
// -----------------------------------------------------------------------

package test.com.jx.gif
{
	import com.jx.gif.Decoder;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNull;

	public class DecoderTest
	{
		
		private var decoder:Decoder;
		
		[Before]
		public function setUp():void
		{
			decoder = new Decoder();
		}
		
		[Test]
		public function frames():void
		{
			assertNull(decoder.frames);
		}
		
		[Test]
		public function loopCount():void
		{
			assertEquals(0, decoder.loopCount);
		}
		
		[Test]
		public function size():void
		{
			assertNull(decoder.size);
		}
		
	}
}