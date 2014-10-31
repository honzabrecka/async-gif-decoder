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
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;

	public class GIFTest
	{
		
		private var gif:GIF;
		
		[Before]
		public function setUp():void
		{
			gif = new GIF();
		}
		
		[After]
		public function tearDown():void
		{
			gif.unload();
			gif = null;
		}
		
		[Test(expects="com.jx.gif.FunctionSequenceError")]
		public function callCurrentFrameBeforeLoad():void
		{
			gif.currentFrame;
		}
		
		[Test(expects="com.jx.gif.FunctionSequenceError")]
		public function callCurrentFrameLabelBeforeLoad():void
		{
			gif.currentFrameLabel;
		}
		
		[Test(expects="com.jx.gif.FunctionSequenceError")]
		public function callCurrentSceneBeforeLoad():void
		{
			gif.currentScene;
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
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function callNextSceneBeforeLoad():void
		{
			gif.nextScene();
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function callPrevSceneBeforeLoad():void
		{
			gif.prevScene();
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
		public function existingFile():void
		{
			Async.handleEvent(this, gif, Event.COMPLETE, function(event:Event, data:Object):void
			{
				assertEquals(1, gif.framesLoaded);
				assertEquals(1, gif.totalFrames);
				assertEquals(0, gif.currentFrame);
				assertEquals("0", gif.currentFrameLabel);
				assertEquals(16744448, drawToBitmapData(gif).getPixel(0, 0));
				assertEquals(1, gif.frames.length);
			});
			gif.load(new URLRequest("../fixtures/1x1_orange.gif"));
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
		
		private function drawToBitmapData(gif:GIF):BitmapData
		{
			var bitmapData:BitmapData = new BitmapData(gif.width, gif.height);
				bitmapData.draw(gif);
			
			return bitmapData;
		}
		
	}
}