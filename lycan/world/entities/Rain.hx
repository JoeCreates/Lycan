package lycan.world.entities;

import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.system.FlxSound;
import lycan.util.ImageLoader;

enum RainType {
	FRONT;
	MIDDLE;
	BACK;
}

class Rain extends FlxEmitter {
	private var maxY:Float;
	private var sfx:FlxSound;
	
	public function new(maxParticles:Int, rainType:RainType, maxY:Float) {
		super(0, -130, maxParticles);
		
		this.maxY = maxY;
		
		setSize(FlxG.width * 1.3, 10); // Extended a bit to account for angle/velocity of particles
		launchMode = FlxEmitterMode.SQUARE;
		
		var velocityFactor:Float;
		
		switch(rainType) {
			case RainType.BACK:
				velocityFactor = 0.6;
				alpha.set(0.4, 0.5);
			case RainType.MIDDLE:
				velocityFactor = 0.8;
				alpha.set(0.5, 0.65);
			case RainType.FRONT:
				velocityFactor = 1;
				alpha.set(0.6, 0.75);
		}
		
		velocityFactor *= 1.3;
		
		velocity.set(-250 * velocityFactor, 550 * velocityFactor, -150 * velocityFactor, 650 * velocityFactor);
		
		for (i in 0...maxParticles) {
			var rainParticle:RainParticle = new RainParticle(rainType);
			add(rainParticle);
		}
		
		sfx = FlxG.sound.load("rain", 1, true);
		#if html5
		sfx.pan = 0.0001; // Hacky workaround for Chrome 44 sound panning bug
		#end
	}
	
	public function startRain():Void {
		start(false, 0.08);
		if (!sfx.playing || sfx.volume < 1) {
			sfx.play(true); // Note force-restarted as a possible fix for Android audio related crash after resuming from Chartboost video ad
			sfx.fadeIn(1, sfx.volume, 0.6);
		}
	}
	
	public function stopRain():Void {
		this.emitting = false;
		sfx.fadeOut(0.5);
	}
	
	override public function update(dt : Float):Void {
		super.update(dt);
		
		for (particle in members) {
			if (particle.y > maxY) {
				particle.kill();
			}
		}
	}
}

private class RainParticle extends FlxParticle {
	public var rainType(default, set):RainType;
	
	public function new(rainType:RainType) {
		super();
		
		//loadGraphic(ImageLoader.getGraphicAsset("rain.png"), true, 30, 30);
		//animation.add("front", [0], 0, false);
		//animation.add("middle", [1], 0, false);
		//animation.add("back", [2], 0, false);
		lifespan = 0;
		
		this.rainType = rainType;
	}
	
	private function set_rainType(rainType:RainType):RainType {
		switch(rainType) {
			case RainType.BACK:
				scrollFactor.set(0.5, 0.5);
				//animation.play("back");
			case RainType.MIDDLE:
				scrollFactor.set(0.75, 0.75);
				//animation.play("middle");
			case RainType.FRONT:
				scrollFactor.set(0.1, 0.1);
				//animation.play("front");
		}
		return this.rainType = rainType;
	}
}