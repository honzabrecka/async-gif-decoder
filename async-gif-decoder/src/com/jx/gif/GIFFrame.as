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

	public class GIFFrame
	{
		
		private var _image:BitmapData;
		private var _delay:uint;
		private var _dispose:uint;
		
		public function GIFFrame(image:BitmapData, delay:uint, dispose:uint)
		{
			_image = image;
			_delay = delay;
			_dispose = dispose;
		}
		
		public function get image():BitmapData
		{
			return _image;
		}
		
		public function get delay():uint
		{
			return _delay;
		}
		
		public function get dispose():uint
		{
			return _dispose;
		}
		
	}
}