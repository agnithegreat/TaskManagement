/**
 * Created by agnither on 28.04.16.
 */
package com.agnither.tasks.abstract
{
    import com.agnither.tasks.events.TaskEvent;

    import flash.events.EventDispatcher;

    public class SimpleTask extends EventDispatcher
    {
        private var _retryLimit: int = 3;
        public function set retryLimit(value: int):void
        {
            _retryLimit = value;
        }
        private var _retryCount: int = 0;

        protected var _data: Object;
        public function get data():Object
        {
            return _data;
        }

        protected var _result: Object;
        public function get result():Object
        {
            return _result;
        }
        
        protected var _progress: Number = 0;
        public function get progressValue():Number
        {
            return _progress;
        }

        private var _completed: Boolean;
        private var _allowAutoComplete: Boolean = false;

        private var _cost: Number = 1;
        public function get costValue():Number
        {
            return _cost;
        }
        public function set costValue(value: Number):void
        {
            _cost = value;
        }
        
        public var parent: MultiTask;

        public function SimpleTask(data: Object = null, autoComplete: Boolean = false)
        {
            _data = data || {};
            _allowAutoComplete = autoComplete;
        }
        
        public function execute():void
        {
        }
        
        public function cancel():void
        {
            complete();
        }

        final public function retry():void
        {
            if (_retryLimit == 0 || _retryCount++ < _retryLimit)
            {
                dispose();
                execute();
            } else {
                error("retry limit reached");
            }
        }

        final protected function progress(value: Number):void
        {
            _progress = value;
            dispatchEvent(new TaskEvent(TaskEvent.PROGRESS, value));
            
            if (!_completed && _allowAutoComplete && value == 1)
            {
                complete();
            }
        }
        
        final protected function complete():void
        {
            _completed = true;
            processComplete();
            progress(1);
            dispatchEvent(new TaskEvent(TaskEvent.COMPLETE, result));
            destroy();
        }

        final protected function error(message: String):void
        {
            log(message);
            processError();
            dispatchEvent(new TaskEvent(TaskEvent.ERROR, text));
            destroy();
        }

        final protected function log(message: String):void
        {
            trace(this, message);
        }

        public function get progressText():String
        {
            return String(int(_progress*100)+"%");
        }

        public function get text():String
        {
            return progressText;
        }
        
        protected function processComplete():void
        {
            
        }

        protected function processError():void
        {

        }

        protected function dispose():void
        {
        }
        
        final public function destroy():void
        {
            dispose();

            _data = null;
            _result = null;
        }
    }
}
