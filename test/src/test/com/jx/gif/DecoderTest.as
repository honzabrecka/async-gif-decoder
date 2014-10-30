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
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.async.Async;

	public class DecoderTest
	{
		
		private var decoder:Decoder;
		
		[Before]
		public function setUp():void
		{
			decoder = new Decoder();
		}
		
		[After]
		public function tearDown():void
		{
			decoder.dispose();
			decoder = null;
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
			var size:Rectangle = decoder.size;
			assertEquals(0, size.x);
			assertEquals(0, size.y);
			assertEquals(0, size.width);
			assertEquals(0, size.height);
		}
		
		[Test(async)]
		public function decodeNull():void
		{
			Async.handleEvent(this, decoder, ErrorEvent.ERROR, null);
			decoder.decode(null);
		}
		
		[Test(async)]
		public function decodePNG():void
		{
			Async.handleEvent(this, decoder, ErrorEvent.ERROR, null);
			decoder.decode(new Fixtures.PNG_1x1() as ByteArray);
		}
		
		[Test(async)]
		public function decode():void
		{
			Async.handleEvent(this, decoder, Event.COMPLETE, function(event:Event, data:Object):void
			{
				var size:Rectangle = decoder.size;
				assertEquals(0, size.x);
				assertEquals(0, size.y);
				assertEquals(1, size.width);
				assertEquals(1, size.height);
			});
			decoder.decode(new Fixtures.GIF_1x1_orange() as ByteArray);
		}
		
	}
}