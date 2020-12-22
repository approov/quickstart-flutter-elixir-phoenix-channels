
part of approov_web_socket;


class _StreamSinkImpl<T> implements StreamSink<T> {
  final StreamConsumer<T> _target;
  final _doneCompleter = new Completer<void>();
  StreamController<T>/*?*/ _controllerInstance;
  Completer/*?*/ _controllerCompleter;
  bool _isClosed = false;
  bool _isBound = false;
  bool _hasError = false;

  _StreamSinkImpl(this._target);

  void add(T data) {
    if (_isClosed) {
      throw StateError("StreamSink is closed");
    }
    _controller.add(data);
  }

  void addError(Object error, [StackTrace/*?*/ stackTrace]) {
    if (_isClosed) {
      throw StateError("StreamSink is closed");
    }
    _controller.addError(error, stackTrace);
  }

  Future addStream(Stream<T> stream) {
    if (_isBound) {
      throw new StateError("StreamSink is already bound to a stream");
    }
    _isBound = true;
    if (_hasError) return done;
    // Wait for any sync operations to complete.
    Future targetAddStream() {
      return _target.addStream(stream).whenComplete(() {
        _isBound = false;
      });
    }

    var controller = _controllerInstance;
    if (controller == null) return targetAddStream();
    var future = _controllerCompleter/*!*/.future;
    controller.close();
    return future.then((_) => targetAddStream());
  }

  Future flush() {
    if (_isBound) {
      throw new StateError("StreamSink is bound to a stream");
    }
    var controller = _controllerInstance;
    if (controller == null) return new Future.value(this);
    // Adding an empty stream-controller will return a future that will complete
    // when all data is done.
    _isBound = true;
    var future = _controllerCompleter/*!*/.future;
    controller.close();
    return future.whenComplete(() {
      _isBound = false;
    });
  }

  Future close() {
    if (_isBound) {
      throw new StateError("StreamSink is bound to a stream");
    }
    if (!_isClosed) {
      _isClosed = true;
      var controller = _controllerInstance;
      if (controller != null) {
        controller.close();
      } else {
        _closeTarget();
      }
    }
    return done;
  }

  void _closeTarget() {
    _target.close().then(_completeDoneValue, onError: _completeDoneError);
  }

  Future get done => _doneCompleter.future;

  void _completeDoneValue(value) {
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete(value);
    }
  }

  void _completeDoneError(Object error, StackTrace stackTrace) {
    if (!_doneCompleter.isCompleted) {
      _hasError = true;
      _doneCompleter.completeError(error, stackTrace);
    }
  }

  StreamController<T> get _controller {
    if (_isBound) {
      throw new StateError("StreamSink is bound to a stream");
    }
    if (_isClosed) {
      throw new StateError("StreamSink is closed");
    }
    if (_controllerInstance == null) {
      _controllerInstance = new StreamController<T>(sync: true);
      _controllerCompleter = new Completer();
      _target.addStream(_controller.stream).then((_) {
        if (_isBound) {
          // A new stream takes over - forward values to that stream.
          _controllerCompleter/*!*/.complete(this);
          _controllerCompleter = null;
          _controllerInstance = null;
        } else {
          // No new stream, .close was called. Close _target.
          _closeTarget();
        }
      }, onError: (Object error, StackTrace stackTrace) {
        if (_isBound) {
          // A new stream takes over - forward errors to that stream.
          _controllerCompleter/*!*/.completeError(error, stackTrace);
          _controllerCompleter = null;
          _controllerInstance = null;
        } else {
          // No new stream. No need to close target, as it has already
          // failed.
          _completeDoneError(error, stackTrace);
        }
      });
    }
    return _controllerInstance/*!*/;
  }
}
