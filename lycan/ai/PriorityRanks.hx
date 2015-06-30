package lycan.ai;

// Some levels to base AI behavioural priorities off of
@:enum abstract PriorityRank(Float) {
	var NONE = 0.0;
	var VERY_LOW = 0.2;
	var LOW = 0.4;
	var MEDIUM = 0.6;
	var HIGH = 0.8;
	var VERY_HIGH = 1.0;
	var OVERRIDE = 10000.0;
}