// -----------------------------------------------------------------------
//  async-gif-decoder
//  Copyright 2014 Jan Břečka. All Rights Reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
// -----------------------------------------------------------------------

package com.jx.gif
{
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public class Decoder extends Sprite
	{
		
		private var stream:ByteArray;
		
		public function Decoder() { }
		
		public function decode(stream:ByteArray):void
		{
			try {
				this.stream = stream;
				init();
				decodeHead();
				addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			} catch (error:Error) {
				dispatchError(error.message);
			}
		}
		
		public function dispose():void
		{
			
		}
		
		public function get frames():Vector.<GIFFrame>
		{
			return null;
		}
		
		public function get loopCount():uint
		{
			return 0;
		}
		
		public function get size():Rectangle
		{
			return null;
		}
		
		private function dispatchError(message:String):void
		{
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message));
		}
		
		private function init():void
		{
			if (!stream) {
				throw new Error("Stream can't be null.");
			}
		}
		
		private function decodeHead():void
		{
			var id:String = "";
			var byte:uint;
			
			for (var i:uint = 0; i < 6; i++) {
				byte = readSingleByte();
				id += String.fromCharCode(byte);
			}
			
			if (id.indexOf("GIF") != 0) {
				throw new Error("Invalid file type.");
			}
		}
		
		private function enterFrameHandler(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		private function readSingleByte():uint
		{
			return stream.readUnsignedByte();
		}
		
	}
}