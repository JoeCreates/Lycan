package lycan.loading.tasks;

interface IDataProducer<T> {
    public var data(get, null):T;
}