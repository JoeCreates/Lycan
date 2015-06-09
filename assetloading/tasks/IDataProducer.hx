package lycan.assetloading.tasks ;

interface IDataProducer<T> {
	public var data(get, null):T;
}