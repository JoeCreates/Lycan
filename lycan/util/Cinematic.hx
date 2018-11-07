package lycan.util;

#if !macro
import flixel.FlxBasic;
import lycan.util.ConditionalEvent;
#end
import haxe.macro.Expr;


/*
	Originally authord by deepnight
	Adapted and extended by Joe Williamson (JoeCreates)

	BASIC USE: (see the static method "demo" for 2 examples)
		var cm = new Cinematic();
		cm.create({ INSTRUCTIONS; });
		flash.Lib.current.addEventListener( flash.events.Event.ENTER_FRAME, function(_) cm.update() );

	NOTE :
		The methods prefixed by "_" should not be called directly (internal use)

	EXAMPLE :
		var cm = new Cinematic();
		cm.create({
			player.move(5,5) > end;
			player.say("Je suis arrivé !");
			300;
			player.laugh() > 500;
			enemy.move(5,5) > end;
			player.die() > 500;
			ennemy.laugh();
			1000;
			gameOver();
		});
		add(cm);

	SYNTAX :
		// Immediate call :
		method();

		// call followed by a pause of 500ms:
		method() > 500;

		// Call followed by a stop of the reading, up to a signal call ("truc")
		method() > end("truc");

		// Call followed by a stop of the reading, until a call EACH with signal ()
		method() > end;

		// Pause for 500ms
		500;

		// Equivalent of a haxe.Timer.delay (method), with the support of the "skip" in addition.
		750 >> method();

		// Launches parallel cinematics after 500ms
		500 >> cm.create({
			method();
		});

	SIGNALS:
		The signals are global to all the cinematics. Parallel execution.
		IMPORTANT: The call to signal () is SNAPSHOT and therefore does not last. Clearly, if the cinematics is on an "end" at
		When signal is called, the "end" will unlock. But if signal is called before the finish at the end,
		It will block indefinitely on the "end" ...
		The persistentSignal () method is used to start a signal that will last until an end corresponding to the
		recovers. The signal is then DELETED as soon as it is picked up. Note that this signal will never disappear if no "end"
		Does not use it, station to the effects of edge ...

	USE OF SKIP:
		The skip () method allows to empty the list of commands in 1 frame. During its execution, the variable "turbo"
		True, to allow the methods of the game to know that they must be played in accelerated (complete resolution
		Of their effect in instantaneous)

*/

private typedef CinematicEvent = {
	f : Void->Void,
	t : Float,
	s : Null<String>,
}

#if macro
class Cinematic {
#end
#if !macro
class Cinematic extends FlxBasic {

	// Public
	public var conditionalEventManager:ConditionalEventManager;
	public var turbo(default,null)	: Bool; // vaut true pendant un skip()
	public var onAllComplete		: Null< Void->Void >; // appelé à chaque fois que toutes les cinématiques sont terminées

	#if (!CinematicDebug)
	/****************************************************/
	public static function demo():Cinematic {
		var cm = new Cinematic();

		var foo= 1;
		var a = 0;
		var t = function() {trace("uhoh... oh wait it's okay!"); };
		cm.create({
			trace("1") > 100; // wait 1000ms after the trace
			a = 2;
			trace(a); // trace without delay
			t();
			100; // wait 1000ms

			100 >> function() {
				trace("3");
				cm.signal("mySignal");
			}(); // do test() in parallel in 1000ms
			end("mySignal"); // attente d'un appel quelconque à signal()

			0 >> function() {
				trace("4");
				cm.signal();
			}(); // do test() in parallel in 1000ms
			end; // wait for any signal
			
			wait({trace("foo: " + foo); foo++; foo > 100; }, cm.signal());
			end;
			
			1000;

			if ( true ) {
				trace("5 true") > 500;
				trace("6 true") > 500;
			} else {
				trace("5 false") > 500;
				trace("6 false") > 500;
			}

			foo += 100;
			if (foo > 10) trace("foo is greater than 10");
			switch ( foo ) {
				case 0 : trace("switch 0 " + foo) > 500;
				case 1 : trace("switch 1 " + foo) > 500 ;
				case 2 : trace("switch 2 " + foo) > 500;
			};
			trace("after switch") > 500;

			for ( i in 0...3 )
				trace("loop "+i) > 500;
			trace("after loop") > 500;
		});
		return cm;
	}
	/****************************************************/
	#end

	// Private
	var queues			: Array<Array<CinematicEvent>>;
	var curQueue		: Null<Array<CinematicEvent>>;
	var persistSignals	: Map<String,Bool>;
	#end

	public function new() {
		#if !macro
		super();
		turbo = false;
		queues = new Array();
		persistSignals = new Map();
		conditionalEventManager = new ConditionalEventManager();
		#end
	}

	#if !macro
	override public function destroy() {
		super.destroy();
		queues = null;
		curQueue = null;
		onAllComplete = null;
		conditionalEventManager.destroy();
	}
	#end

	static function error( ?msg="", p : Position ) {
		#if macro
		haxe.macro.Context.error("Macro error: "+msg,p);
		#end
	}

	static function funName(e:Expr) {
		switch (e.expr) {
			case EConst(c) :
				switch (c) {
					case CIdent(v) : return v;
					default :
				}
			default :
		}
		return null;
	}

	macro public function create(ethis:Expr, block:Expr) : Expr {
		var r = __rchain(ethis, block);
		r = macro {
			$ethis.__beginNewQueue();
			$r;
		}
		#if CinematicDebug
		trace( tink.macro.tools.Printer.print(r) );
		#end
		return r;
	}

	macro public function chainToLast(ethis:Expr, block:Expr) : Expr {
		var r = __rchain(ethis, block);
		r = macro {
			if ( $ethis.isEmpty() )
				$ethis.__beginNewQueue();
			$r;
		}
		return r;
	}

	static function __rchain(ethis:Expr, block:Expr) {
		switch ( block.expr ) {
			case EBlock(el):
				var exprs = [];

				for ( e in el ) {
					var preDelay = null;
					var postDelay = macro 0;
					var signal = null;

					var topLevel = false;

					function parseSpecialExpr(de:Expr, strict:Bool) {
						switch (de.expr) {
							case ECall(f,params) : // END with signal name
								if ( funName(f)=="end" ) {
									signal = params[0];
									return macro null;
								} if ( funName(f)=="wait" ) {
									return macro $ethis.conditionalEventManager.wait(
										function() {
											return ${params[0]};
										}, function(c:ConditionalEvent) {
											${params[1]};
										}
									);
								} else if ( strict )
									error("unsupported expression", de.pos);
							case EConst(c) :
								switch (c) {
									case CIdent(v) : // END general
										if ( v=="end" ) {
											signal = macro "";
											return macro null;
										} else
											error("unexpected CIdent "+v, de.pos);

									case CInt(v) : // Time limit
										postDelay = de;

									default :
										error("unexpected EConst "+c, de.pos);
								}
							default :
								if ( strict )
									error("unsupported expression", de.pos);
						}
						return de;
					}

					function parseChainedMethod(ce:Expr, ?level=0) {
						switch (ce.expr) {
							case ECall(_), EConst(_) :

							case EBlock(list) :
								ce = __rchain(ethis, ce);

							case EWhile(cond, b, classic) :
								topLevel = true;
								var mb = __rchain(ethis, b);
								if ( classic )
									return macro while ($cond) $mb;
								else
									return macro do {$mb;} while ($cond);

							case EVars(_) :
								error("forbidden variable assignation (using new variable declaration WITHIN a cinematic will lead to unexpected results)", ce.pos);
							//case EVars(_), EUnop(_), EThrow(_) :
							case EUnop(_), EThrow(_) :
								topLevel = true;

							case EFunction(name, f) :
								topLevel = true;
								f.expr = __rchain(ethis, f.expr);

							case EFor(it, b) :
								topLevel = true;
								b = __rchain(ethis, b);
								return macro for ($it) $b;

							case ESwitch(es, cases, d) :
								topLevel = true;
								for ( c in cases )
									c.expr = __rchain(ethis, c.expr);
								if ( d!=null )
									d = __rchain(ethis, d);
								ce.expr = ESwitch(es, cases, d);

							case EIf(econd, eif, eelse) : // condition
								topLevel = true;
								var mif = __rchain(ethis, eif);
								if ( eelse==null ) {
									return macro if ($econd) {$mif;}
								} else {
									var melse = __rchain(ethis, eelse);
									return macro if ($econd) {$mif;} else {$melse;}
								}

							case EBinop(op,e1,e2):
								//trace(op);
								//if( op==OpAssign )
								//error("assignation is not supported here", e.pos);
								if ( level>0 )
									error("cannot combine multiple operators > or >>", e2.pos);
								if ( op == OpGt ) { // opérateur ">"
									topLevel = true;
									return __rchain( ethis,  macro {$e1; $e2;} );
								}
								if ( op == OpShr ) { // opérateur ">>"
									preDelay = e1;
									switch (e2.expr) {
										case ECall(_) :
										default : error("Only function calls are supported here", e2.pos);
									}
									return parseChainedMethod(e2);
								}

							default:
								error(Std.string(ce.expr).split("(")[0]+" is not supported in chain", ce.pos);
						}
						return ce;
					}

					e = parseSpecialExpr(e, false);
					e = parseChainedMethod(e);
					if ( topLevel )
						exprs.push(e);
					else if ( preDelay!=null )
						exprs.push( macro {
						$ethis.__add( function() {
							$ethis.__addParallel( function() { $e; }, $preDelay);
						}, 0);
					});
					else if ( signal!=null )
						exprs.push(macro $ethis.__add( function() { $e; }, $postDelay, $signal ));
					else
						exprs.push(macro $ethis.__add( function() { $e; }, $postDelay ));

				}
				return {pos:block.pos, expr:EBlock(exprs)};
			//return macro $a{exprs};
			//return macro {$[exprs];};
			default:
				return __rchain(ethis, macro {$block;});
		}
	}

	#if !macro

	public function signal(?s:String) {
		for ( q in queues )
			if ( q.length>0 && (q[0].s==s || q[0].s=="") )
				runEvent( q.splice(0,1)[0] );
	}

	public function persistantSignal(s:String) {
		persistSignals.set(s, true);
		signal(s);
	}

	@:noCompletion public function __addParallel(cb:Void->Void, t:Int, ?signal:String) {
		queues.push( [ {f:cb, t: t, s:null }] );
	}

	@:noCompletion public function __add(cb:Void->Void, t:Int, ?signal:String) {
		curQueue.push({f:cb, t: t, s:signal});
	}

	@:noCompletion public function __beginNewQueue() {
		curQueue = [];
		queues.push(curQueue);
		//queues.push( new Array() );
		//curQueue = queues[queues.length-1];
	}

	public inline function isEmpty() {
		return queues.length==0;
	}

	function runEvent(e:CinematicEvent) {
		if ( e.s!=null )
			persistSignals.remove(e.s);
		e.f();
	}

	public function skip() {
		turbo = true;
		while ( queues.length>0 )
			update(0);
		turbo = false;
	}

	public function cancelEverything() {
		queues = [];
		curQueue = null;
		persistSignals = new Map();
	}

	override public function update(dt:Float):Void {
		super.update(dt);
		conditionalEventManager.update(dt);
		
		var i = 0;
		
		while ( i<queues.length ) {
			var q = queues[i];
			if ( q.length>0 ) {
				q[0].t -= dt * 1000;
				while ( q.length>0 && q[0].t<=0 && ( turbo || q[0].s==null || persistSignals.get(q[0].s) ) )
					runEvent( q.splice(0,1)[0] );
			}
			if ( q.length==0 ) {
				queues.splice(i,1);
				if ( isEmpty() && onAllComplete!=null )
					onAllComplete();
			} else
				i++;
		}
		if ( curQueue!=null && curQueue.length==0 )
			curQueue = null;
	}

	#end
}
