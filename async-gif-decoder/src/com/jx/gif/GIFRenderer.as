// -----------------------------------------------------------------------
//  async-gif-decoder
//  Copyright 2014 Jan Břečka. All Rights Reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
// -----------------------------------------------------------------------

package com.jx.gif
{
	import flash.display.BitmapData;

	public class GIFRenderer
	{
		
		private var renderedFrames:Vector.<GIFFrame>;
		
		public function GIFRenderer(decoder:GIFDecoder)
		{
			var framesLength:uint = decoder.frames.length
			var bitmapData:BitmapData = new BitmapData(decoder.size.width, decoder.size.height);
			var last3:uint = 0;
			var previous:uint;
			var frame:GIFFrame;
			
			renderedFrames = new Vector.<GIFFrame>(framesLength, true);
			
			for (var i:uint = 0; i < framesLength; i++) {
				frame = decoder.frames[i];
				
				if (frame.dispose == 1) {
					bitmapData.draw(frame.bitmapData);
				} else if (frame.dispose == 3) {
					previous = decoder.frames[i - 1].dispose == 3 ? 0 : last3;
					bitmapData = decoder.frames[previous].bitmapData.clone();
					bitmapData.draw(frame.bitmapData);
					last3 = i;
				} else {
					bitmapData = frame.bitmapData.clone();
				}
				
				renderedFrames[i] = new GIFFrame(bitmapData.clone(), frame.delay == 0 ? 100 : frame.delay, frame.dispose);
			}
		}
		
		public function get frames():Vector.<GIFFrame>
		{
			return renderedFrames;
		}
		
		public function dispose():void
		{
			renderedFrames = null;
		}
		
	}
}