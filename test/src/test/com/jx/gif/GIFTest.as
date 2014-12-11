// -----------------------------------------------------------------------
//  async-gif-decoder
//  Copyright 2014 Jan Břečka. All Rights Reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
// -----------------------------------------------------------------------

package test.com.jx.gif
{
	import com.jx.gif.GIF;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;

	public class GIFTest
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
		
		[Test(expects="com.jx.gif.FunctionSequenceError")]
		public function callCurrentFrameBeforeLoad():void
		{
			gif.currentFrame;
		}
		
		[Test(expects="com.jx.gif.FunctionSequenceError")]
		public function callFramesLoadedBeforeLoad():void
		{
			gif.framesLoaded;
		}
		
		[Test(expects="com.jx.gif.FunctionSequenceError")]
		public function callTotalFramesBeforeLoad():void
		{
			gif.totalFrames;
		}
		
		[Test(expects="com.jx.gif.FunctionSequenceError")]
		public function callIsPlayingBeforeLoad():void
		{
			gif.isPlaying;
		}
		
		[Test(expects="com.jx.gif.FunctionSequenceError")]
		public function callGotoAndPlayBeforeLoad():void
		{
			gif.gotoAndPlay(1);
		}
		
		[Test(expects="com.jx.gif.FunctionSequenceError")]
		public function callGotoAndStopBeforeLoad():void
		{
			gif.gotoAndStop(1);
		}
		
		[Test(expects="com.jx.gif.FunctionSequenceError")]
		public function callNextFrameBeforeLoad():void
		{
			gif.nextFrame();
		}
		
		[Test(expects="com.jx.gif.FunctionSequenceError")]
		public function callPrevFrameBeforeLoad():void
		{
			gif.prevFrame();
		}
		
		[Test(expects="com.jx.gif.FunctionSequenceError")]
		public function callPlayBeforeLoad():void
		{
			gif.play();
		}
		
		[Test(expects="com.jx.gif.FunctionSequenceError")]
		public function callStopBeforeLoad():void
		{
			gif.stop();
		}
		
		[Test(expects="com.jx.gif.FunctionSequenceError")]
		public function callFramesBeforeLoad():void
		{
			gif.frames;
		}
		
		[Test(async)]
		public function unexistingFile():void
		{
			Async.handleEvent(this, gif, IOErrorEvent.IO_ERROR, null);
			gif.load(new URLRequest("../fixtures/unexisting.gif"));
		}
		
		[Test(async)]
		public function badFileFormat():void
		{
			Async.handleEvent(this, gif, ErrorEvent.ERROR, null);
			gif.load(new URLRequest("../fixtures/1x1.png"));
		}
		
		[Test(async)]
		public function loadAndDecode():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertEquals(1, gif.framesLoaded);
				assertEquals(1, gif.totalFrames);
				assertEquals(0, gif.currentFrame);
				assertEquals(1, gif.frames.length);
			});
			gif.load(new URLRequest("../fixtures/1x1_orange.gif"));
		}
		
		[Test(async)]
		public function playing():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertFalse(gif.isPlaying);
				
				gif.play();
				assertTrue(gif.isPlaying);
				
				gif.stop();
				assertFalse(gif.isPlaying);
			});
			gif.load(new URLRequest("../fixtures/1x1_orange.gif"));
		}
		
		[Test(async)]
		public function nextFrame():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertEquals(0, gif.currentFrame);
				gif.nextFrame();
				assertEquals(1, gif.currentFrame);
				gif.nextFrame();
				assertEquals(2, gif.currentFrame);
				gif.nextFrame();
				assertEquals(3, gif.currentFrame);
				gif.nextFrame();
				assertEquals(4, gif.currentFrame);
				gif.nextFrame();
				assertEquals(0, gif.currentFrame);
			}, TIMEOUT);
			gif.load(new URLRequest("../fixtures/m1.gif"));
		}
		
		[Test(async)]
		public function prevFrame():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertEquals(0, gif.currentFrame);
				gif.prevFrame();
				assertEquals(4, gif.currentFrame);
				gif.prevFrame();
				assertEquals(3, gif.currentFrame);
				gif.prevFrame();
				assertEquals(2, gif.currentFrame);
				gif.prevFrame();
				assertEquals(1, gif.currentFrame);
				gif.prevFrame();
				assertEquals(0, gif.currentFrame);
			}, TIMEOUT);
			gif.load(new URLRequest("../fixtures/m1.gif"));
		}
		
		[Test(async)]
		public function gotoAndStop():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				gif.gotoAndStop(3);
				assertEquals(2, gif.currentFrame);
				assertFalse(gif.isPlaying);
			}, TIMEOUT);
			gif.load(new URLRequest("../fixtures/m1.gif"));
		}
		
		[Test(async)]
		public function gotoAndPlay():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				gif.gotoAndPlay(3);
				assertEquals(2, gif.currentFrame);
				assertTrue(gif.isPlaying);
			}, TIMEOUT);
			gif.load(new URLRequest("../fixtures/m1.gif"));
		}
		
		[Test(async, expects="RangeError")]
		public function invalidGotoAndPlayIndex():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				gif.gotoAndPlay(0);
			});
			gif.load(new URLRequest("../fixtures/1x1_orange.gif"));
		}
		
		[Test(async, expects="RangeError")]
		public function invalidGotoAndStopIndex():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				gif.gotoAndStop(2);
			});
			gif.load(new URLRequest("../fixtures/1x1_orange.gif"));
		}
		
	}
}