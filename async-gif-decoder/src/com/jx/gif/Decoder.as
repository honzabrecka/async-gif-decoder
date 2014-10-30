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
		
		private var w:uint;
		private var h:uint;
		
		/** global color table used */
		private var gctFlag:Boolean;
		/** size of global color table */
		private var gctSize:int;
		/** background color index */
		private var bgIndex:int;
		/** pixel aspect ratio */
		private var pixelAspect:int;
		
		private var cachedSize:Rectangle;
		
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
			cachedSize ||= new Rectangle(0, 0, w, h);
			return cachedSize;
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
			checkFileType();
			readLSD();
		}
		
		private function checkFileType():void
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
		
		private function readLSD():void
		{
			// logical screen size
			w = readShort();
			h = readShort();
			
			// packed fields
			var packed:uint = readSingleByte();
			
			gctFlag = (packed & 0x80) != 0; // 1   : global color table flag
			// 2-4 : color resolution
			// 5   : gct sort flag
			gctSize = 2 << (packed & 7); // 6-8 : gct size
			bgIndex = readSingleByte(); // background color index
			pixelAspect = readSingleByte(); // pixel aspect ratio
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
		
		/** Reads next 16-bit value, LSB first */
		private function readShort():int
		{
			return readSingleByte() | (readSingleByte() << 8);
		}
		
	}
}