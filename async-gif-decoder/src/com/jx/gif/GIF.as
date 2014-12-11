// -----------------------------------------------------------------------
//  async-gif-decoder
//  Copyright 2014 Jan Břečka. All Rights Reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
// -----------------------------------------------------------------------

package com.jx.gif
{
	import flash.display.Bitmap;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	
	public class GIF extends Bitmap
	{
		
		private var _currentFrame:int = -1;
		private var timer:Timer;
		private var renderer:GIFRenderer;
		
		public function GIF() { }
		
		public function load(request:URLRequest):void
		{
			function complete(event:Event):void
			{
				decode(loader.data);
				destroy();
			}
			
			function error(event:Event):void
			{
				dispatchEvent(event);
				destroy();
			}
			
			function destroy():void
			{
				try { loader.close(); } catch (error:Error) { }
				loader.removeEventListener(Event.COMPLETE, complete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, error);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, error);
				loader = null;
			}
			
			var loader:URLLoader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.addEventListener(Event.COMPLETE, complete);
				loader.addEventListener(IOErrorEvent.IO_ERROR, error);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, error);
				loader.load(request);
		}
		
		public function dispose():void
		{
			function clearBitmapData():void
			{
				if (bitmapData) {
					bitmapData.dispose();
				}
			}
			
			function clearRenderer():void
			{
				if (renderer) {
					renderer.dispose();
				}
			}
			
			function clearTimer():void
			{
				if (timer) {
					stop();
					timer.removeEventListener(TimerEvent.TIMER, timer_tickHandler);
					timer = null;
				}
			}
			
			clearBitmapData();
			clearRenderer();
			clearTimer();
			_currentFrame = -1;
		}
		
		public function decode(stream:ByteArray):void
		{
			function complete(event:Event):void
			{
				_currentFrame = 0;
				timer = new Timer(0, 0);
				timer.addEventListener(TimerEvent.TIMER, timer_tickHandler);
				renderer = new GIFRenderer(decoder);
				draw();
				dispatchEvent(event);
				destroy();
			}
			
			function error(event:Event):void
			{
				dispatchEvent(event);
				destroy();
			}
			
			function destroy():void
			{
				decoder.removeEventListener(Event.COMPLETE, complete);
				decoder.removeEventListener(ErrorEvent.ERROR, error);
				decoder.dispose();
				decoder = null;
			}
			
			var decoder:GIFDecoder = new GIFDecoder();
				decoder.addEventListener(Event.COMPLETE, complete);
				decoder.addEventListener(ErrorEvent.ERROR, error);
				decoder.decode(stream);
		}
		
		public function get frames():Vector.<GIFFrame>
		{
			hasBeenLoaded();
			return renderer.frames;
		}
		
		public function get currentFrame():int
		{
			hasBeenLoaded();
			return _currentFrame;
		}
		
		public function get framesLoaded():int
		{
			hasBeenLoaded();
			return frames.length;
		}
		
		public function get totalFrames():int
		{
			hasBeenLoaded();
			return frames.length;
		}
		
		public function get isPlaying():Boolean
		{
			hasBeenLoaded();
			return timer.running;
		}
		
		public function gotoAndPlay(frame:Object, scene:String=null):void
		{
			hasBeenLoaded();
			_currentFrame = checkFrame(uint(frame));
			draw();
			play();
		}
		
		public function gotoAndStop(frame:Object, scene:String=null):void
		{
			hasBeenLoaded();
			_currentFrame = checkFrame(uint(frame));
			draw();
			stop();
		}
		
		public function nextFrame():void
		{
			hasBeenLoaded();
			_currentFrame = (_currentFrame + 1) % totalFrames;
			draw();
		}
		
		public function prevFrame():void
		{
			hasBeenLoaded();
			_currentFrame = (totalFrames + (_currentFrame - 1)) % totalFrames;
			draw();
		}
		
		public function play():void
		{
			hasBeenLoaded();
			
			if (!isPlaying) {
				timer.start();
			}
		}
		
		public function stop():void
		{
			hasBeenLoaded();
			
			if (isPlaying) {
				timer.stop();
			}
		}
		
		private function hasBeenLoaded():void
		{
			if (!timer) {
				throw new FunctionSequenceError();
			}
		}
		
		private function checkFrame(index:uint):uint
		{
			if (index < 1 || index > totalFrames) {
				throw new RangeError("Frame out of range, please specify a frame between 1 and " + totalFrames + ".");
			}
			
			return index - 1;
		}
		
		private function draw():void
		{
			var frame:GIFFrame = frames[currentFrame];
			timer.delay = frame.delay;
			bitmapData = frame.bitmapData;
		}
		
		private function timer_tickHandler(event:TimerEvent):void
		{
			nextFrame();
		}
		
	}
}