// -----------------------------------------------------------------------
//  async-gif-decoder
//  Copyright 2014 Jan Břečka. All Rights Reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
// -----------------------------------------------------------------------

package test.com.jx.gif
{
	import com.jx.gif.GIFDecoder;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.async.Async;

	public class GIFDecoderTest
	{
		
		private var decoder:GIFDecoder;
		
		[Before]
		public function setUp():void
		{
			decoder = new GIFDecoder();
		}
		
		[After]
		public function tearDown():void
		{
			decoder.destroy();
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
			assertNull(decoder.size);
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
		public function decode1x1SingleFrame():void
		{
			Async.handleEvent(this, decoder, Event.COMPLETE, function(event:Event, data:Object):void
			{
				var size:Rectangle = decoder.size;
				assertEquals(0, size.x);
				assertEquals(0, size.y);
				assertEquals(1, size.width);
				assertEquals(1, size.height);
				assertEquals(1, decoder.frames.length);
				assertEquals(16744448, decoder.frames[0].image.getPixel(0, 0));
				assertEquals(0, decoder.loopCount);
				assertEquals(0, decoder.frames[0].delay);
				assertEquals(0, decoder.frames[0].dispose);
			});
			decoder.decode(new Fixtures.GIF_1x1_orange() as ByteArray);
		}
		
		[Test(async)]
		public function decodeTransparent():void
		{
			Async.handleEvent(this, decoder, Event.COMPLETE, function(event:Event, data:Object):void
			{
				var size:Rectangle = decoder.size;
				assertEquals(0, size.x);
				assertEquals(0, size.y);
				assertEquals(1, size.width);
				assertEquals(1, size.height);
				assertEquals(1, decoder.frames.length);
				assertEquals(0, decoder.frames[0].image.getPixel(0, 0));
				assertEquals(0, decoder.loopCount);
				assertEquals(0, decoder.frames[0].delay);
				assertEquals(0, decoder.frames[0].dispose);
			});
			decoder.decode(new Fixtures.GIF_1x1_transparent() as ByteArray);
		}
		
		[Test(async)]
		public function decodeAnimated():void
		{
			Async.handleEvent(this, decoder, Event.COMPLETE, function(event:Event, data:Object):void
			{
				var size:Rectangle = decoder.size;
				assertEquals(0, size.x);
				assertEquals(0, size.y);
				assertEquals(72, size.width);
				assertEquals(36, size.height);
				assertEquals(5, decoder.frames.length);
				assertEquals(0, decoder.loopCount);
				
				assertEquals(500, decoder.frames[0].delay);
				assertEquals(0, decoder.frames[0].dispose);
				assertEquals(500, decoder.frames[1].delay);
				assertEquals(1, decoder.frames[1].dispose);
				assertEquals(500, decoder.frames[2].delay);
				assertEquals(1, decoder.frames[2].dispose);
				assertEquals(500, decoder.frames[3].delay);
				assertEquals(1, decoder.frames[3].dispose);
				assertEquals(500, decoder.frames[4].delay);
				assertEquals(1, decoder.frames[4].dispose);
			});
			decoder.decode(new Fixtures.GIF_m1() as ByteArray);
		}
		
		[Test(async)]
		public function zeroFrameTime():void
		{
			decoder = new GIFDecoder(0);
			Async.handleEvent(this, decoder, Event.COMPLETE, function(event:Event, data:Object):void
			{
				var size:Rectangle = decoder.size;
				assertEquals(0, size.x);
				assertEquals(0, size.y);
				assertEquals(1, size.width);
				assertEquals(1, size.height);
				assertEquals(1, decoder.frames.length);
				assertEquals(16744448, decoder.frames[0].image.getPixel(0, 0));
				assertEquals(0, decoder.loopCount);
				assertEquals(0, decoder.frames[0].delay);
				assertEquals(0, decoder.frames[0].dispose);
			});
			decoder.decode(new Fixtures.GIF_1x1_orange() as ByteArray);
		}
		
	}
}