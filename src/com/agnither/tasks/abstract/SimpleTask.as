/**
 * Created by agnither on 28.04.16.
 */
package com.agnither.tasks.abstract
{
    import com.agnither.tasks.events.TaskEvent;

    import flash.events.EventDispatcher;
    import flash.utils.setTimeout;

    public class SimpleTask extends EventDispatcher
    {
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

        public function SimpleTask(data: Object = null, autoComplete: Boolean = false)
        {
            _data = data;
            _allowAutoComplete = autoComplete;
        }
        
        public function execute():void
        {
        }

        protected function progress(value: Number):void
        {
            _progress = value;
            dispatchEvent(new TaskEvent(TaskEvent.PROGRESS, value));
            
            if (_allowAutoComplete && value == 1)
            {
                complete();
            }
        }
        
        protected function complete():void
        {
            if (!_allowAutoComplete)
            {
                progress(1);
            }
            dispatchEvent(new TaskEvent(TaskEvent.COMPLETE, result));
            destroy();
        }
        
        public function get progressText():String
        {
            return String(int(_progress*100)+"%");
        }
        
        public function get text():String
        {
            return progressText;
        }
        
        public function destroy():void
        {
            _data = null;
            _result = null;
        }
    }
}
