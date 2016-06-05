package lycan.tween.ease;

/**
 * Linear easing equations.
 */
class EaseLinear {
	/**
	 * Easing equation for a linear function.
	 * @param	t	The value to ease.
	 * @return	The eased value.
	 */
    public inline static function none(t:Float):Float {
        return t;
    }
}