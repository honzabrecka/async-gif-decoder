# Async GIF decoder [![Build Status](https://travis-ci.org/honzabrecka/async-gif-decoder.svg?branch=master)](https://travis-ci.org/honzabrecka/async-gif-decoder)

An asynchronous [GIF](http://www.w3.org/Graphics/GIF/spec-gif89a.txt) decoder written in ActionScript 3 that lets you play animated GIFs in flash without freezing the UI.

> Inspired by Lee Burrows' [Async-Image-Encoders](https://github.com/LeeBurrows/Async-Image-Encoders), based on Thibault Imbert's [as3gif](https://code.google.com/p/as3gif/).

```as3
var gif:GIF = new GIF();
    gif.addEventListener(Event.COMPLETE, function(event:Event):void
    {
        trace("done", gif.totalFrames);
        gif.play();
    });
    gif.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void
    {
	    trace(event);
    });
    gif.load(new URLRequest("smile.gif"));

addChild(gif);
```

If you want to play GIFs in your [starling](https://github.com/Gamua/Starling-Framework) based app, you can use `renderers/GPUGIF` class.