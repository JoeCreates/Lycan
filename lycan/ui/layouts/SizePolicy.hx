package lycan.ui.layouts;

enum Policy {
	Fixed; // The widget can never grow or shrink
}

class SizePolicy {
	private var policy:Policy;
	
	public function new(policy:Policy) {
		this.policy = policy;
	}
}