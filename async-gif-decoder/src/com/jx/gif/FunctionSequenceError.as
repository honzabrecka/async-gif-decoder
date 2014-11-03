// -----------------------------------------------------------------------
//  async-gif-decoder
//  Copyright 2014 Jan Břečka. All Rights Reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
// -----------------------------------------------------------------------

package com.jx.gif
{
	public class FunctionSequenceError extends Error
	{
		
		public function FunctionSequenceError()
		{
			super("Call load() or decode() first.");
		}
		
	}
}