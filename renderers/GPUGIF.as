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
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    
    import starling.display.Image;
    import starling.events.Event;
    import starling.textures.Texture;
    
    public class GPUGIF extends Image
    {
        
        private var _currentFrame:int = -1;
        private var timer:Timer;
        private var renderer:GIFRenderer;
        private var cachedTextures:Vector.<Texture>;
        
        public function GPUGIF()
        {
            super(Texture.empty(1, 1));
        }
        
        public function decode(stream:ByteArray):void
        {
            function complete(event:flash.events.Event):void
            {
                _currentFrame = 0;
                timer = new Timer(0, 0);
                timer.addEventListener(TimerEvent.TIMER, timer_tickHandler);
                renderer = new GIFRenderer(decoder);
                cachedTextures = new Vector.<Texture>(totalFrames, true);
                draw();
                dispatchEventWith(starling.events.Event.COMPLETE);
                destroy();
            }
            
            function error(event:flash.events.Event):void
            {
                dispatchEventWith(starling.events.Event.IO_ERROR);
                destroy();
            }
            
            function destroy():void
            {
                decoder.removeEventListener(flash.events.Event.COMPLETE, complete);
                decoder.removeEventListener(ErrorEvent.ERROR, error);
                decoder.dispose();
                decoder = null;
            }
            
            var decoder:GIFDecoder = new GIFDecoder();
                decoder.addEventListener(flash.events.Event.COMPLETE, complete);
                decoder.addEventListener(ErrorEvent.ERROR, error);
                decoder.decode(stream);
        }
        
        public function get frames():Vector.<GIFFrame>
        {
            hasBeenLoaded();
            return renderer.frames;
        }
        
        public function get currentFrame():int
        {
            hasBeenLoaded();
            return _currentFrame;
        }
        
        public function get framesLoaded():int
        {
            hasBeenLoaded();
            return frames.length;
        }
        
        public function get totalFrames():int
        {
            hasBeenLoaded();
            return frames.length;
        }
        
        public function get isPlaying():Boolean
        {
            hasBeenLoaded();
            return timer.running;
        }
        
        public function gotoAndPlay(frame:Object, scene:String=null):void
        {
            hasBeenLoaded();
            _currentFrame = checkFrame(uint(frame));
            draw();
            play();
        }
        
        public function gotoAndStop(frame:Object, scene:String=null):void
        {
            hasBeenLoaded();
            _currentFrame = checkFrame(uint(frame));
            draw();
            stop();
        }
        
        public function nextFrame():void
        {
            hasBeenLoaded();
            _currentFrame = (_currentFrame + 1) % totalFrames;
            draw();
        }
        
        public function prevFrame():void
        {
            hasBeenLoaded();
            _currentFrame = (totalFrames + (_currentFrame - 1)) % totalFrames;
            draw();
        }
        
        public function play():void
        {
            hasBeenLoaded();
            
            if (!isPlaying) {
                timer.start();
            }
        }
        
        public function stop():void
        {
            hasBeenLoaded();
            
            if (isPlaying) {
                timer.stop();
            }
        }
        
        private function hasBeenLoaded():void
        {
            if (!timer) {
                throw new FunctionSequenceError();
            }
        }
        
        private function checkFrame(index:uint):uint
        {
            if (index < 1 || index > totalFrames) {
                throw new RangeError("Frame out of range, please specify a frame between 1 and " + totalFrames + ".");
            }
            
            return index - 1;
        }
        
        private function draw():void
        {
            var frame:GIFFrame = frames[currentFrame];
            timer.delay = frame.delay;
            
            if (!cachedTextures[currentFrame]) {
                cachedTextures[currentFrame] = Texture.fromBitmapData(frame.bitmapData);
            }
            
            texture = cachedTextures[currentFrame];
            readjustSize();
        }
        
        private function timer_tickHandler(event:TimerEvent):void
        {
            nextFrame();
        }
        
    }
}