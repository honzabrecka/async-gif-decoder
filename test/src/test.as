// -----------------------------------------------------------------------
//  async-gif-decoder
//  Copyright 2014 Jan Břečka. All Rights Reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
// -----------------------------------------------------------------------

package
{
	import com.jx.screenshot.LoadQueue;
	import com.jx.screenshot.Screenshot;
	import com.jx.screenshot.Upload;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.flexunit.internals.TraceListener;
	import org.flexunit.listeners.CIListener;
	import org.flexunit.runner.FlexUnitCore;
	
	import test.com.jx.gif.GIFDecoderTest;
	import test.com.jx.gif.GIFFrameTest;
	import test.com.jx.gif.GIFRenderingTest;
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
			function runTests():void
			{
				Screenshot.dictionary = queue.dictionary;
				Screenshot.save = new Upload("http://localhost/upload.php");
				
				flexUnit.run(
					GIFDecoderTest,
					GIFFrameTest,
					GIFTest,
					GIFRenderingTest
				);
			}
			
			var flexUnit:FlexUnitCore = new FlexUnitCore();
				flexUnit.addListener(new TraceListener());
				flexUnit.addListener(new CIListener());
			var queue:LoadQueue = new LoadQueue("../screenshots/");
				queue.addEventListener(Event.COMPLETE, runTests);
				queue.load(new <String>[
					"singleFrame", "singlePixelTopLeft", "singlePixelCenterCenter",
					"m1.1", "m1.2", "m1.3", "m1.4", "m1.5",
					"m1t.1", "m1t.2", "m1t.3", "m1t.4", "m1t.5",
					"m2.1", "m2.2", "m2.3", "m2.4", "m2.5",
					"m3.1", "m3.2", "m3.3", "m3.4", "m3.5",
					"m4nb.1", "m4nb.2", "m4nb.3", "m4nb.4", "m4nb.5",
					"m5np.1", "m5np.2", "m5np.3", "m5np.4", "m5np.5",
					"m6nbnb.1", "m6nbnb.2", "m6nbnb.3", "m6nbnb.4", "m6nbnb.5", "m6nbnb.6",
					"m7npnp.1", "m7npnp.2", "m7npnp.3", "m7npnp.4", "m7npnp.5", "m7npnp.6"
				]);
		}
		
	}
}