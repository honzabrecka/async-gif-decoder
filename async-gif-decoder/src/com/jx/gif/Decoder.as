// -----------------------------------------------------------------------
//  async-gif-decoder
//  Copyright 2014 Jan Břečka. All Rights Reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
// -----------------------------------------------------------------------

package com.jx.gif
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public class Decoder extends EventDispatcher
	{
		
		private var stream:ByteArray;
		
		public function Decoder() { }
		
		public function decode(stream:ByteArray):void
		{
			if (!stream) {
				dispatchError("Stream can't be null.");
				return;
			}
			
			this.stream = stream;
			dispatchEvent(new Event(Event.COMPLETE));
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
		
	}
}