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
		/** background color */
		private var bgColor:int;
		/** background color index */
		private var bgIndex:int;
		/** pixel aspect ratio */
		private var pixelAspect:int;
		/** global color table */
		private var gct:Vector.<uint>;
		
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
			cleanUp();
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
			
			if (gctFlag) {
				gct = readColorTable(gctSize);
				bgColor = gct[bgIndex];
			}
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
		
		/**
		 * Reads color table as 256 RGB integer values
		 *
		 * @param ncolors int number of colors to read
		 * @return int array containing 256 colors (packed ARGB with full alpha)
		 */
		private function readColorTable(ncolors:int):Vector.<uint>
		{
			var nbytes:int = 3 * ncolors;
			var tab:Vector.<uint>;
			var c:ByteArray = new ByteArray;
			var n:int = 0;
			
			try {
				stream.readBytes(c, 0, nbytes);
				n = nbytes;
			} catch (e:Error) { }
			
			if (n < nbytes) {
				throw new Error("Format error.");
			} else {
				tab = new Vector.<uint>(256, true);// max size to avoid bounds checks
				
				var i:int = 0;
				var j:int = 0;
				var r:int;
				var g:int;
				var b:int;
				
				while (i < ncolors) {
					r = (c[j++]) & 0xff;
					g = (c[j++]) & 0xff;
					b = (c[j++]) & 0xff;
					tab[i++] = (0xff000000 | (r << 16) | (g << 8) | b);
				}
			}
			
			return tab;
		}
		
		private function enterFrameHandler(event:Event):void
		{
			if (decodeBody()) {
				cleanUp();
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function decodeBody():Boolean
		{
			return true;
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
		
		private function cleanUp():void
		{
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
	}
}