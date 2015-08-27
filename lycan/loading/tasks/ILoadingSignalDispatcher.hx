package lycan.loading.tasks;

import msignal.Signal.Signal1;
import msignal.Signal.Signal2;

interface ILoadingSignalDispatcher {
	var signal_started:Signal1<Dynamic>;
	var signal_progressed:Signal2<Dynamic, Float>;
	var signal_completed:Signal1<Dynamic>;
	var signal_failed:Signal2<Dynamic, String>;
}