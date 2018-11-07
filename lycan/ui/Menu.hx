package lycan.ui;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.FlxInput;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.ui.FlxButton;
import flixel.util.FlxSignal;

// DEMO TODO
// Simple rpg nested menus
// Cursor tweening
// Changing to different cursor
// Rctangle cursor
// Item highlighting
// Radial menu
// Static menu (shows only selected item)
// Menu scrolling
// Cursor persisting (changing vsibility on inactive menu)

class MenuCursor extends FlxSprite {
	public function new() {
		super();
	}
}

enum MenuDirection {
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

typedef SpriteMenu = Menu<FlxSprite>;
typedef ButtonMenu = Menu<FlxButton>;

/**
 * Does not do rendering of MenuItem sprites. Sprites must be added to the state elsewhere.
 */
class Menu<T:FlxSprite> extends FlxTypedGroup<MenuItem<T>> {
	public var hasFocus(default, set):Bool;
	
	public var defaultItem:MenuItem<T>;
	public var selectedItem:MenuItem<T>;
	public var lastItem:MenuItem<T>;
	
	public var enableKeyboard:Bool;
	public var enableGamepad:Bool;
	
	/** When menu cancelled */
	public var onCancel:FlxTypedSignal<Menu<T>->Void>;
	/** When item is activated */
	public var onAction:FlxTypedSignal<Menu<T>->Void>;
	/** On an attempted change of selection */
	public var onMove:FlxTypedSignal<Menu<T>->Void>;
	/** On a successful change of selection */
	public var onItemChanged:FlxTypedSignal<Menu<T>->Void>;
	/** On focus gained */
	public var onFocusGained:FlxTypedSignal<Menu<T>->Void>;
	/** On focus lost */
	public var onFocusLost:FlxTypedSignal<Menu<T>->Void>;
	
	public var upKeys:Array<FlxKey>;
	public var downKeys:Array<FlxKey>;
	public var leftKeys:Array<FlxKey>;
	public var rightKeys:Array<FlxKey>;
	public var actionKeys:Array<FlxKey>;
	public var cancelKeys:Array<FlxKey>;
	
	public var gamePads:Array<FlxGamepad>;
	public var upButtons:Array<FlxGamepadInputID>;
	public var downButtons:Array<FlxGamepadInputID>;
	public var leftButtons:Array<FlxGamepadInputID>;
	public var rightButtons:Array<FlxGamepadInputID>;
	public var actionButtons:Array<FlxGamepadInputID>;
	public var cancelButtons:Array<FlxGamepadInputID>;
	
	public function new(enableKeyboard:Bool = true, enableGamepad:Bool = true) {
		super();
		
		hasFocus = false;
		defaultItem = null;
		selectedItem = null;
		
		this.enableKeyboard = enableKeyboard;
		this.enableGamepad = enableGamepad;
		
		onCancel = new FlxTypedSignal<Menu<T>->Void>();
		onAction = new FlxTypedSignal<Menu<T>->Void>();
		onMove = new FlxTypedSignal<Menu<T>->Void>();
		onItemChanged = new FlxTypedSignal<Menu<T>->Void>();
		onFocusGained = new FlxTypedSignal<Menu<T>->Void>();
		onFocusLost = new FlxTypedSignal<Menu<T>->Void>();
		
		gamePads = null; // Use first gamepad by default
		upButtons = [FlxGamepadInputID.DPAD_UP, FlxGamepadInputID.LEFT_STICK_DIGITAL_UP];
		downButtons = [FlxGamepadInputID.DPAD_DOWN, FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN];
		leftButtons = [FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT];
		rightButtons = [FlxGamepadInputID.DPAD_RIGHT, FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT];
		actionButtons = [FlxGamepadInputID.A];
		cancelButtons = [FlxGamepadInputID.B];
		
		upKeys = [FlxKey.UP];
		downKeys = [FlxKey.DOWN];
		leftKeys = [FlxKey.LEFT];
		rightKeys = [FlxKey.RIGHT];
		actionKeys = [FlxKey.ENTER];
		cancelKeys = [FlxKey.BACKSPACE];
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (hasFocus) {
			if (enableGamepad) {
				if (gamePads == null) {
					checkGamepad(FlxG.gamepads.getFirstActiveGamepad());
				} else {
					for (g in gamePads) checkGamepad(g);
				}
			}
			if (enableKeyboard) {
				checkKeyboard();
			}
		}
	}
	
	public function updateSelection():Void {
		
	}
	
	public function move(direction:MenuDirection):Bool {
		if (selectedItem == null) return false;
		
		onMove.dispatch(this);
		
		switch (direction) {
			case UP: 
				if (selectedItem.upAction != null) selectedItem.upAction(selectedItem);
				return select(selectedItem.upItem);
			case DOWN: 
				if (selectedItem.downAction != null) selectedItem.downAction(selectedItem);
				return select(selectedItem.downItem);
			case LEFT:
				if (selectedItem.leftAction != null) selectedItem.leftAction(selectedItem);
				return select(selectedItem.leftItem);
			case RIGHT: 
				if (selectedItem.rightAction != null) selectedItem.rightAction(selectedItem);
				return select(selectedItem.rightItem);
			default:
		};
		return false;
	}
	
	public function select(item:MenuItem<T>):Bool {
		if (item == selectedItem || item == null) return false;
		if (item.menu != this) throw("Cannot select item which is not in menu");
		
		lastItem = selectedItem;
		selectedItem = item;
		
		if (lastItem != null && lastItem.onDeselect != null) lastItem.onDeselect(lastItem);
		if (selectedItem.onSelect != null) selectedItem.onSelect(selectedItem);
		
		onItemChanged.dispatch(this);
		
		return true;
	}
	
	public function doAction():Void {
		onAction.dispatch(this);
		if (selectedItem != null && selectedItem.action != null) {
			selectedItem.action(selectedItem);
		}
	}
	
	public function doCancel():Void {
		onCancel.dispatch(this);
	}
	
	private function checkKeyboard():Void {
		if (FlxG.keys.anyJustPressed(upKeys)) move(UP);
		if (FlxG.keys.anyJustPressed(downKeys)) move(DOWN);
		if (FlxG.keys.anyJustPressed(leftKeys)) move(LEFT);
		if (FlxG.keys.anyJustPressed(rightKeys)) move(RIGHT);
		if (FlxG.keys.anyJustPressed(actionKeys)) doAction();
		if (FlxG.keys.anyJustPressed(cancelKeys)) doCancel();
	}
	
	private function checkGamepad(gamepad:FlxGamepad):Void {
		if (gamepad == null) return;
		if (gamepad.anyJustPressed(upButtons)) move(UP);
		if (gamepad.anyJustPressed(downButtons)) move(DOWN);
		if (gamepad.anyJustPressed(leftButtons)) move(LEFT);
		if (gamepad.anyJustPressed(rightButtons)) move(RIGHT);
		if (gamepad.anyJustPressed(actionButtons)) doAction();
		if (gamepad.anyJustPressed(cancelButtons)) doCancel();
	}
	
	private function set_hasFocus(focus:Bool):Bool {
		if (this.hasFocus == focus) return focus;
		this.hasFocus = focus;
		if (focus) {
			if (defaultItem != null) select(defaultItem);
			onFocusGained.dispatch(this);
		} else {
			onFocusLost.dispatch(this);
		}
		return focus;
	}
	
}

@:tink
class MenuItem<T:FlxSprite> extends FlxBasic {
	public var sprite:T;
	
	public var cursorOffset:FlxPoint;
	public var cursorAngle:Float;
	public var cursorFlip:Bool;
	
	public var downItem:MenuItem<T>;
	public var leftItem:MenuItem<T>;
	public var rightItem:MenuItem<T>;
	public var upItem:MenuItem<T>;
	
	public var downAction:MenuItem<T>->Void;
	public var leftAction:MenuItem<T>->Void;
	public var rightAction:MenuItem<T>->Void;
	public var upAction:MenuItem<T>->Void;
	public var action:MenuItem<T>->Void;
	
	public var onSelect:MenuItem<T>->Void;
	public var onDeselect:MenuItem<T>->Void;
	
	public var menu:Menu<T>;
	
	@:calc public var isSelected:Bool = menu.selectedItem == this;
	
	public function new(menu:Menu<T>, sprite:T) {
		super();
		this.sprite = sprite;
		this.menu = menu;
	}
	
	override public function draw():Void {
		super.draw();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
	}
	
	override public function destroy():Void {
		// TODO important!
		super.destroy();
	}
}

class MenuFactory {
	public static function fromGroup<T:FlxSprite>(group:FlxTypedGroup<T>):Menu<T> {
		var menu:Menu<T> = new Menu<T>();
		group.forEachExists((s:T)->{
			menu.add(new MenuItem<T>(menu, s));
		});
		
		menu.select(menu.getFirstExisting());
		//TODO menu onfocus moves to default
		return menu;
	}
	
	//TODO makeSelectionTweens
	
	public static function makeButtonMenu<T:FlxButton>(menu:Menu<T>):Menu<T> {
		//TODO 
		menu.onItemChanged.add((m:Menu<T>)->{
			var newButton:FlxButton = m.selectedItem.sprite;
			var lastButton:FlxButton = m.lastItem.sprite;
			lastButton.scale.set(1, 1);
			newButton.scale.set(1.1, 1.1);
			lastButton.onOut.fire();
			newButton.onOver.fire();
		});
		
		menu.onAction.add((m:Menu<T>)->{
			if (m.selectedItem.sprite.active) m.selectedItem.sprite.onUp.fire();
		});
		
		return menu;
	}
	
	public static function makeVerticalMenu<T:FlxSprite>(menu:Menu<T>):Menu<T> {
		var last:MenuItem<T>;
		menu.forEachExists((mi:MenuItem<T>)->{
			if (last != null) {
				last.downItem = mi;
			}
			mi.upItem = last;
			last = mi;
		});
		return menu;
	}
	
	public static function makeHorizontalMenu<T:FlxSprite>(menu:Menu<T>):Menu<T> {
		var last:MenuItem<T>;
		menu.forEachExists((mi:MenuItem<T>)->{
			if (last != null) {
				last.leftItem = mi;
			}
			mi.rightItem = last;
			last = mi;
		});
		return menu;
	}
}