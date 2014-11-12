// -----------------------------------------------------------------------
//  async-gif-decoder
//  Copyright 2014 Jan Břečka. All Rights Reserved.
//	
//	Based on:
//	 - http://www.java2s.com/Code/Java/2D-Graphics-GUI/GiffileEncoder.htm
//	 - http://code.google.com/p/as3gif/
//	
//	@author Kevin Weiner (original Java version - kweiner@fmsware.com)
//	@author Thibault Imbert (original AS3 version - bytearray.org)
//	@author Jan Břečka (non-blocking AS3 version)
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
// -----------------------------------------------------------------------

package com.jx.gif
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	public class GIFDecoder extends Sprite
	{
		
		// phases
		private static const READING_STREAM:uint = 0;
		private static const START_DECODING_IMAGE:uint = 1;
		private static const DECODING_IMAGE:uint = 2;
		private static const DECODING_IMAGE_DONE:uint = 3;
		private static const GETTING_PIXELS:uint = 4;
		private static const CHECK_LAST_DISPOSE:uint = 5;
		private static const TRANSFERING_PIXELS:uint = 6;
		private static const SETTING_PIXELS:uint = 7;
		private static const PUSHING_FRAME:uint = 8;
		
		/** max decoder pixel stack size */
		private static const MAX_STACK_SIZE:uint = 4096;
		private static const NULL_CODE:int = -1;
		
		private var frameTime:uint;
		private var stream:ByteArray;
		private var currentPhase:uint;
		
		/** global color table used */
		private var gctFlag:Boolean;
		/** size of global color table */
		private var gctSize:int;
		/** local color table flag */
		private var lctFlag:Boolean;
		/** interlace flag */
		private var interlace:Boolean;
		/** local color table size */
		private var lctSize:int;
		/** background color */
		private var bgColor:int;
		/** previous bg color */
		private var lastBgColor:int;
		/** background color index */
		private var bgIndex:int;
		/** pixel aspect ratio */
		private var pixelAspect:int;
		/** global color table */
		private var gct:Vector.<int>;
		/** local color table */
		private var lct:Vector.<int>;
		/** active color table */
		private var act:Vector.<int>;
		/** current data block */
		private var block:ByteArray;
		/** current block size */
		private var blockSize:int = 0;
		/** last graphic control extension info */
		private var frameDispose:int = 0;
		/** 0=no action; 1=leave in place; 2=restore to bg; 3=restore to prev */
		private var lastFrameDispose:int = 0;
		/** use transparent color */
		private var transparency:Boolean = false;
		/** delay in milliseconds */
		private var delay:int = 0;
		/** transparent color index */
		private var transIndex:int;
		/** iterations; 0 = repeat forever */
		private var _loopCount:int = 0;
		/** current frame position&size */
		private var ix:int;
		private var iy:int;
		private var iw:int;
		private var ih:int;
		/** LZW decoder working arrays */
		private var prefix:Array
		private var suffix:Array;
		private var pixelStack:Array;
		private var pixels:Array;
		
		private var image:BitmapData;
		private var bitmap:BitmapData;
		// previous frame
		private var lastImage:BitmapData;
		private var lastRect:Rectangle;
		private var save:int;
		
		private var _frames:Vector.<GIFFrame>;
		private var frameCount:int;
		private var _size:Rectangle;
		
		public function GIFDecoder(frameTime:uint=24)
		{
			this.frameTime = frameTime == 0 ? 1 : frameTime;
		}
		
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
			
			if (stream) {
				stream.clear();
				stream = null;
			}
		}
		
		public function get frames():Vector.<GIFFrame>
		{
			return _frames;
		}
		
		public function get loopCount():uint
		{
			return _loopCount;
		}
		
		public function get size():Rectangle
		{
			return _size;
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
			
			currentPhase = READING_STREAM;
			block = new ByteArray();
			frameCount = 0;
			_frames = new Vector.<GIFFrame>();
			gct = null;
			lct = null;
		}
		
		//------------------------------------------
		// HEAD
		
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
			var byte:int;
			
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
			var width:int = readShort();
			var height:int = readShort();
			// packed fields
			var packed:int = readSingleByte();
			
			_size = new Rectangle(0, 0, width, height);
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
		private function readColorTable(ncolors:int):Vector.<int>
		{
			var nbytes:int = 3 * ncolors;
			var tab:Vector.<int>;
			var c:ByteArray = new ByteArray;
			var n:int = 0;
			
			try {
				stream.readBytes(c, 0, nbytes);
				n = nbytes;
			} catch (e:Error) { }
			
			if (n < nbytes) {
				throw new Error("Format error.");
			} else {
				tab = new Vector.<int>(256, true);// max size to avoid bounds checks
				
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
		
		//------------------------------------------
		// BODY
		
		private function enterFrameHandler(event:Event):void
		{
			try {
				if (decodeBody()) {
					cleanUp();
					dispatchEvent(new Event(Event.COMPLETE));
				}
			} catch (error:Error) {
				dispatchError(error.message);
				cleanUp();
			}
		}
		
		private function decodeBody():Boolean
		{
			var isComplete:Boolean = false;
			var endTime:uint = getTimer() + frameTime;
			
			while (!isComplete && endTime > getTimer()) {
				isComplete = decodeBlock();
			}
			
			return isComplete;
		}
		
		private function decodeBlock():Boolean
		{
			if (currentPhase == START_DECODING_IMAGE) {
				startDecodingImageData();
				return false;
			}
			if (currentPhase == DECODING_IMAGE) {
				decodeImageData();
				return false;
			}
			if (currentPhase == DECODING_IMAGE_DONE) {
				decodeImageDataDone();
				return false;
			}
			if (currentPhase == GETTING_PIXELS) {
				getPixelsNB();
				return false;
			}
			if (currentPhase == CHECK_LAST_DISPOSE) {
				checkLastDispose();
				return false;
			}
			if (currentPhase == TRANSFERING_PIXELS) {
				transferPixels();
				return false;
			}
			if (currentPhase == SETTING_PIXELS) {
				setPixels(dest);
				return false;
			}
			if (currentPhase == PUSHING_FRAME) {
				pushFrame();
				return false;
			}
			
			var isComplete:Boolean = false;
			var byte:int = readSingleByte();
			
			switch (byte) {
				case 0x2C: // image separator
					readImage();
					break;
				
				case 0x21: // extension
					readApplicationExtension();
					break;
				
				case 0x3b : // terminator
					isComplete = true;
					break;
				
				case 0x00 : // bad byte, but keep going and see what happens
					break;
				
				default :
					throw new Error("Format error.");
					break;
			}
			
			return isComplete;
		}
		
		private function readApplicationExtension():void
		{
			var byte:int = readSingleByte();
			
			switch (byte) {
				case 0xf9: // graphics control extension
					readGraphicControlExtension();
					break;
				
				case 0xff: // application extension
					readBlock();
					
					var app:String = "";
					
					for (var i:uint = 0; i < 11; i++) {
						app += block[i];
					}
					
					if (app == "NETSCAPE2.0") {
						readNetscapeExt();
					} else {
						skip(); // don't care
					}
					
					break;
				
				default: // uninteresting extension
					skip();
					break;
			}
		}
		
		private function readGraphicControlExtension():void
		{
			readSingleByte(); // block size
			var packed:int = readSingleByte(); // packed fields
			frameDispose = (packed & 0x1c) >> 2; // disposal method
			
			if (frameDispose == 0) {
				frameDispose = 1; // elect to keep old image if discretionary
			}
			
			transparency = (packed & 1) != 0;
			delay = readShort() * 10; // delay in milliseconds
			transIndex = readSingleByte(); // transparent color index
			readSingleByte(); // block terminator
		}
		
		/**
		 * Reads Netscape extenstion to obtain iteration count
		 */
		private function readNetscapeExt():void
		{
			var b1:int;
			var b2:int;
			
			do {
				readBlock();
				
				if (block[0] == 1) {
					// loop count sub-block
					b1 = (block[1]) & 0xff;
					b2 = (block[2]) & 0xff;
					_loopCount = (b2 << 8) | b1;
				}
			} while (blockSize > 0);
		}
		
		/**
		 * Reads next frame image
		 */
		private function readImage():void
		{
			ix = readShort(); // (sub)image position & size
			iy = readShort();
			iw = readShort();
			ih = readShort();
			save = 0;
			
			var packed:int = readSingleByte();
			lctFlag = (packed & 0x80) != 0; // 1 - local color table flag
			interlace = (packed & 0x40) != 0; // 2 - interlace flag
			// 3 - sort flag
			// 4-5 - reserved
			lctSize = 2 << (packed & 7); // 6-8 - local color table size
			
			if (lctFlag) {
				lct = readColorTable(lctSize); // read table
				act = lct; // make local table active
			} else {
				act = gct; // make global table active
				
				if (bgIndex == transIndex) {
					bgColor = 0;
				}
			}
			
			if (transparency) {
				save = act[transIndex];
				act[transIndex] = 0; // set transparent color if specified
			}
			
			if (!act) {
				throw new Error("Format error."); // no color table defined
			}
			
			currentPhase = START_DECODING_IMAGE;
		}
		
		private var npix:int;
		private var available:int;
		private var clear:int;
		private var code_mask:int;
		private var code_size:int;
		private var end_of_information:int;
		private var in_code:int;
		private var old_code:int;
		private var bits:int;
		private var code:int;
		private var count:int;
		private var i:int;
		private var datum:int;
		private var data_size:int;
		private var first:int;
		private var top:int;
		private var bi:int;
		private var pi:int;
		
		/**
		 * Decodes LZW image data into pixel array.
		 * Adapted from John Cristy's ImageMagick.
		 */
		private function startDecodingImageData():void
		{
			npix = iw * ih;
			
			if ((pixels == null) || (pixels.length < npix)) {
				pixels = new Array ( npix ); // allocate new pixel array
			}
			
			if (prefix == null) prefix = new Array(MAX_STACK_SIZE);
			if (suffix == null) suffix = new Array(MAX_STACK_SIZE);
			if (pixelStack == null) pixelStack = new Array(MAX_STACK_SIZE + 1);
			
			//  Initialize GIF data stream decoder.
			data_size = readSingleByte();
			clear = 1 << data_size;
			end_of_information = clear + 1;
			available = clear + 2;
			old_code = NULL_CODE;
			code_size = data_size + 1;
			code_mask = (1 << code_size) - 1;
			
			for (code = 0; code < clear; code++) {
				prefix[int(code)] = 0;
				suffix[int(code)] = code;
			}
			
			//  Decode GIF pixel stream.
			datum = bits = count = first = top = pi = bi = 0;
			i = 0;
			currentPhase = DECODING_IMAGE;
		}
		
		private function decodeImageData():void
		{
			var to:uint = i + 64;
			if (to > npix) to = npix;
			
			for (; i < to;) {
				if (top == 0) {
					if (bits < code_size) {
						//  Load bytes until there are enough bits for a code.
						if (count == 0) {
							// Read a new data block.
							count = readBlock();
							
							if (count <= 0) {
								break;
							}
							
							bi = 0;
						}
						
						datum += (int((block[int(bi)])) & 0xff) << bits;
						bits += 8;
						bi++;
						count--;
						continue;
					}
					
					//  Get the next code.
					code = datum & code_mask;
					datum >>= code_size;
					bits -= code_size;
					//  Interpret the code
					if ((code > available) || (code == end_of_information)) {
						break;
					}
					
					if (code == clear) {
						//  Reset decoder.
						code_size = data_size + 1;
						code_mask = (1 << code_size) - 1;
						available = clear + 2;
						old_code = NULL_CODE;
						continue;
					}
					
					if (old_code == NULL_CODE) {
						pixelStack[int(top++)] = suffix[int(code)];
						old_code = code;
						first = code;
						continue;
					}
					
					in_code = code;
					
					if (code == available) {
						pixelStack[int(top++)] = first;
						code = old_code;
					}
					
					while (code > clear) {
						pixelStack[int(top++)] = suffix[int(code)];
						code = prefix[int(code)];
					}
					
					first = (suffix[int(code)]) & 0xff;
					
					//  Add a new string to the string table,
					
					if (available >= MAX_STACK_SIZE) {
						break;
					}
					
					pixelStack[int(top++)] = first;
					prefix[int(available)] = old_code;
					suffix[int(available)] = first;
					available++;
					
					if (((available & code_mask) == 0) && (available < MAX_STACK_SIZE)) {
						code_size++;
						code_mask += available;
					}
					
					old_code = in_code;
				}
				
				//  Pop a pixel off the pixel stack.
				
				top--;
				pixels[int(pi++)] = pixelStack[int(top)];
				i++;
			}
			
			if (to == npix) {
				currentPhase = DECODING_IMAGE_DONE;
			}
		}
		
		private function decodeImageDataDone():void
		{
			for (i = pi; i < npix; i++) {
				pixels[i] = 0; // clear missing pixels
			}
			
			///////
			skip();
			frameCount++;
			bitmap = new BitmapData(size.width, size.height);
			image = bitmap;
			currentPhase = GETTING_PIXELS;
		}
		
		private var dest:Array;
		
		private function getPixelsNB():void
		{
			// expose destination image's pixels as int array
			dest = getPixels(bitmap);
			currentPhase = CHECK_LAST_DISPOSE;
		}
		
		private function checkLastDispose():void
		{
			// fill in starting image contents based on last image's dispose code
			if (lastFrameDispose > 0) {
				if (lastFrameDispose == 3) {
					// use image before last
					var n:int = frameCount - 2;
					lastImage = n > 0 ? getFrame(n - 1).bitmapData : null;
				}
				
				if (lastImage != null) {
					var prev:Array = getPixels(lastImage);	
					dest = prev.slice();
					// copy pixels
					if (lastFrameDispose == 2) {
						// fill last image rect area with background color
						var c:Number;
						// assume background is transparent
						c = transparency ? 0x00000000 : lastBgColor;
						// use given background color
						image.fillRect(lastRect, c);
					}
				}
			}
			
			currentPhase = TRANSFERING_PIXELS;
		}
		
		private function transferPixels():void
		{
			// copy each source line to the appropriate place in the destination
			var pass:int = 1;
			var inc:int = 8;
			var iline:int = 0;
			
			for (var i:int = 0; i < ih; i++) {
				var line:int = i;
				
				if (interlace) {
					if (iline >= ih) {
						pass++;
						
						switch (pass) 
						{
							case 2 :
								iline = 4;
								break;
							case 3 :
								iline = 2;
								inc = 4;
								break;
							case 4 :
								iline = 1;
								inc = 2;
								break;
						}
					}
					
					line = iline;
					iline += inc;
				}
				
				line += iy;
				
				if (line < size.height) {
					var k:int = line * size.width;
					var dx:int = k + ix; // start of line in dest
					var dlim:int = dx + iw; // end of dest line
					var sx:int = i * iw; // start of line in source
					var index:int;
					var tmp:int;
					
					if ((k + size.width) < dlim) {
						dlim = k + size.width; // past dest edge
					}
					
					while (dx < dlim) {
						// map color and insert in destination
						index = (pixels[sx++]) & 0xff;
						tmp = act[index];
						
						if (tmp != 0) {
							dest[dx] = tmp;
						}
						
						dx++;
					}
				}
			}
			
			currentPhase = SETTING_PIXELS;
		}
		
		/**
		 * Creates new frame image from current data (and previous
		 * frames as specified by their disposition codes).
		 */
		private function getPixels( bitmap:BitmapData ):Array
		{	
			var pixels:Array = new Array(4 * image.width * image.height);
			var count:int = 0;
			var lngWidth:int = image.width;
			var lngHeight:int = image.height;
			var color:int;
			
			for (var th:int = 0; th < lngHeight; th++) {
				for (var tw:int = 0; tw < lngWidth; tw++) {
					color = bitmap.getPixel (th, tw);
					pixels[count++] = (color & 0xFF0000) >> 16;
					pixels[count++] = (color & 0x00FF00) >> 8;
					pixels[count++] = (color & 0x0000FF);
				}
			}
			
			return pixels;
		}
		
		private function setPixels(pixels:Array):void
		{
			var count:int = 0;
			var color:int;
			var lngWidth:int = image.width;
			var lngHeight:int = image.height;
			
			pixels.position = 0;
			bitmap.lock();
			
			for (var th:int = 0; th < lngHeight; th++) {
				for (var tw:int = 0; tw < lngWidth; tw++) {
					color = pixels[count++];
					bitmap.setPixel32(tw, th, color);
				}
			}
			
			bitmap.unlock();
			currentPhase = PUSHING_FRAME;
		}
		
		private function getFrame(n:int):GIFFrame
		{
			var im:GIFFrame = null;
			
			if ((n >= 0) && (n < frameCount)) {
				im = frames[n];
			} else {
				throw new RangeError("Wrong frame number passed");
			}
			
			return im;
		}
		
		private function pushFrame():void
		{
			_frames.push(new GIFFrame(bitmap, delay, lastFrameDispose)); // add image to frame list
			
			if (transparency) {
				act[transIndex] = save;
			}
			
			resetFrame();
			currentPhase = READING_STREAM;
		}
		
		/**
		 * Resets frame state for reading next image.
		 */
		private function resetFrame():void 
		{
			lastFrameDispose = frameDispose;
			lastRect = new Rectangle(ix, iy, iw, ih);
			lastImage = image;
			lastBgColor = bgColor;
			lct = null;
		}
		
		//------------------------------------------
		// HELPERS
		
		private function readSingleByte():int
		{
			return stream.readUnsignedByte();
		}
		
		/** Reads next 16-bit value, LSB first */
		private function readShort():int
		{
			return readSingleByte() | (readSingleByte() << 8);
		}
		
		/**
		 * Reads next variable length block from input.
		 *
		 * @return number of bytes stored in "buffer"
		 */
		private function readBlock():int
		{
			blockSize = readSingleByte();
			
			var n:int = 0;
			
			if (blockSize > 0) {
				try {
					var count:int = 0;
					
					while (n < blockSize) {
						stream.readBytes(block, n, blockSize - n);
						
						if ((blockSize - n) == -1) {
							break;
						}
						
						n += (blockSize - n);
					}
				} catch (e:Error) { }
				
				if (n < blockSize) {
					throw new Error("Format error.");
				}
			}
			
			return n;
		}
		
		/**
		 * Skips variable length blocks up to and including
		 * next zero length block.
		 */
		private function skip():void
		{
			do {
				readBlock();
			} while (blockSize > 0);
		}
		
		private function cleanUp():void
		{
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
	}
}