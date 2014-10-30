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
		public function isPlaying():void
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
		
	}
}