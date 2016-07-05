package lycan.core;

import Sys;
import sys.io.Process;

class Version {
	public static inline var VERSION_MAJOR:Int = 0;
	public static inline var VERSION_MINOR:Int = 1;

	public macro static function getGitSHA(path:String):String {
		var cwd = Sys.getCwd();
		var ret = new Process("git", ["rev-parse", "HEAD"]);
		return ret;
	}

	public macro static function getShortGitSHA(path:String):String {
		var cwd = Sys.getCwd();
		var ret = new Process("git", ["rev-parse", "--short", "HEAD"]);
		return ret;
	}
}