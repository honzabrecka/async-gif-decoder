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
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Scene;
	import flash.errors.IllegalOperationError;
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
	
	public class GIF extends MovieClip
	{
		
		private var _frames:Vector.<GIFFrame>;
		private var _currentFrame:int = -1;
		
		private var bitmap:Bitmap;
		private var timer:Timer;
		private var cachedBitmapData:Vector.<BitmapData>;
		
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
			function clearCachedBitmapData():void
			{
				cachedBitmapData = null;
			}
			
			function clearFrames():void
			{
				while (_frames && _frames.length > 0) {
					_frames.pop();
				}
				_frames = null;
			}
			
			function clearTimer():void
			{
				if (timer) {
					stop();
					timer.removeEventListener(TimerEvent.TIMER, timer_tickHandler);
					timer = null;
				}
			}
			
			function clearBitmap():void
			{
				if (bitmap) {
					removeChild(bitmap);
					bitmap = null;
				}
			}
			
			clearFrames();
			clearCachedBitmapData();
			clearTimer();
			clearBitmap();
			_currentFrame = -1;
		}
		
		public function decode(stream:ByteArray):void
		{
			function complete(event:Event):void
			{
				_frames = decoder.frames;
				_currentFrame = 0;
				bitmap = new Bitmap();
				addChild(bitmap);
				timer = new Timer(0, 0);
				timer.addEventListener(TimerEvent.TIMER, timer_tickHandler);
				cacheBitmapData(decoder.size.width, decoder.size.height);
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
			return _frames;
		}
		
		override public function get currentFrame():int
		{
			hasBeenLoaded();
			return _currentFrame;
		}
		
		override public function get currentFrameLabel():String
		{
			hasBeenLoaded();
			return _currentFrame.toString();
		}
		
		override public function get currentScene():Scene
		{
			throw new IllegalOperationError("Method is not implemented.");
			return null;
		}
		
		override public function get framesLoaded():int
		{
			hasBeenLoaded();
			return _frames.length;
		}
		
		override public function get totalFrames():int
		{
			hasBeenLoaded();
			return _frames.length;
		}
		
		override public function get isPlaying():Boolean
		{
			hasBeenLoaded();
			return timer.running;
		}
		
		override public function gotoAndPlay(frame:Object, scene:String=null):void
		{
			hasBeenLoaded();
			_currentFrame = checkFrame(uint(frame));
			draw();
			play();
		}
		
		override public function gotoAndStop(frame:Object, scene:String=null):void
		{
			hasBeenLoaded();
			_currentFrame = checkFrame(uint(frame));
			draw();
			stop();
		}
		
		override public function nextFrame():void
		{
			hasBeenLoaded();
			_currentFrame = (_currentFrame + 1) % totalFrames;
			draw();
		}
		
		override public function prevFrame():void
		{
			hasBeenLoaded();
			_currentFrame--;
			if (_currentFrame == -1) _currentFrame = totalFrames - 1;
			draw();
		}
		
		override public function play():void
		{
			hasBeenLoaded();
			
			if (!isPlaying) {
				timer.start();
			}
		}
		
		override public function stop():void
		{
			hasBeenLoaded();
			
			if (isPlaying) {
				timer.stop();
			}
		}
		
		override public function nextScene():void
		{
			throw new IllegalOperationError("Method is not implemented.");
		}
		
		override public function prevScene():void
		{
			throw new IllegalOperationError("Method is not implemented.");
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
			timer.delay = frame.delay == 0 ? 100 : frame.delay;
			bitmap.bitmapData = cachedBitmapData[currentFrame];
		}
		
		private function timer_tickHandler(event:TimerEvent):void
		{
			nextFrame();
		}
		
		private function cacheBitmapData(width:uint, height:uint):void
		{
			cachedBitmapData = new Vector.<BitmapData>(totalFrames, true);
			
			var bitmapData:BitmapData = new BitmapData(width, height);
			
			for (var i:uint = 0; i < totalFrames; i++) {
				if (_frames[i].dispose == 1) {
					bitmapData.draw(_frames[i].bitmapData);
				} else if (_frames[i].dispose == 3) {
					bitmapData = _frames[0].bitmapData.clone();
					bitmapData.draw(_frames[i].bitmapData);
				} else {
					bitmapData = _frames[i].bitmapData.clone();
				}
				
				cachedBitmapData[i] = bitmapData.clone();
			}
		}
		
	}
}