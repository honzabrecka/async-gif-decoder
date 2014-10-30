// -----------------------------------------------------------------------
//  async-gif-decoder
//  Copyright 2014 Jan Břečka. All Rights Reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
// -----------------------------------------------------------------------

package com.jx.gif
{
	import flash.display.MovieClip;
	import flash.display.Scene;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class GIF extends MovieClip
	{
		
		private var _frames:Vector.<GIFFrame>;
		private var _currentFrame:int = -1;
		private var _isPlaying:Boolean;
		
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
		
		public function unload():void
		{
			resetFrames();
			_currentFrame = -1;
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
			hasBeenLoaded();
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
			return _isPlaying;
		}
		
		override public function gotoAndPlay(frame:Object, scene:String=null):void
		{
			hasBeenLoaded();
		}
		
		override public function gotoAndStop(frame:Object, scene:String=null):void
		{
			hasBeenLoaded();
		}
		
		override public function nextFrame():void
		{
			hasBeenLoaded();
		}
		
		override public function prevFrame():void
		{
			hasBeenLoaded();
		}
		
		override public function play():void
		{
			hasBeenLoaded();
			_isPlaying = true;
		}
		
		override public function stop():void
		{
			hasBeenLoaded();
			_isPlaying = false;
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
			if (_currentFrame == -1) {
				throw new FunctionSequenceError();
			}
		}
		
		private function decode(stream:ByteArray):void
		{
			function complete(event:Event):void
			{
				_frames = decoder.frames;
				_currentFrame = 0;
				_isPlaying = false;
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
				decoder.destroy();
				decoder = null;
			}
			
			var decoder:GIFDecoder = new GIFDecoder();
				decoder.addEventListener(Event.COMPLETE, complete);
				decoder.addEventListener(ErrorEvent.ERROR, error);
				decoder.decode(stream);
		}
		
		private function resetFrames():void
		{
			while (_frames && _frames.length > 0) {
				_frames.pop();
			}
			
			_frames = null;
		}
		
	}
}