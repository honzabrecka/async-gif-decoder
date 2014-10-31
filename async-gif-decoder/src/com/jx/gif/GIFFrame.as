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
		
		private var _bitmapData:BitmapData;
		private var _delay:uint;
		private var _dispose:uint;
		
		public function GIFFrame(bitmapData:BitmapData, delay:uint, dispose:uint)
		{
			_bitmapData = bitmapData;
			_delay = delay;
			_dispose = dispose;
		}
		
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
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