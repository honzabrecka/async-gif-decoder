// -----------------------------------------------------------------------
//  async-gif-decoder
//  Copyright 2014 Jan Břečka. All Rights Reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
// -----------------------------------------------------------------------

package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.flexunit.internals.TraceListener;
	import org.flexunit.listeners.CIListener;
	import org.flexunit.runner.FlexUnitCore;
	
	import test.com.jx.gif.GIFDecoderTest;
	import test.com.jx.gif.GIFFrameTest;
	import test.com.jx.gif.GIFTest;
	
	public class test extends Sprite
	{
		
		public function test()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private function addedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			main();
		}
		
		private function main():void
		{
			var flexUnit:FlexUnitCore = new FlexUnitCore();
				flexUnit.addListener(new TraceListener());
				flexUnit.addListener(new CIListener());
				flexUnit.run(
					GIFDecoderTest,
					GIFFrameTest,
					GIFTest
				);
		}
		
	}
}