import Toybox.Lang;

module Util {
    class Observable {

        private var _subscribers as Array<Method> = [];

        function subscribe(callback as Method) {
            _subscribers.add(callback);
        }

        protected function notify(property as Symbol?) {
            for (var i = 0; i < _subscribers.size(); i++) {
                _subscribers[i].invoke(property);
            }
        }
    }
}