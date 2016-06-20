/**
 * Created by agnither on 05.05.16.
 */
package com.agnither.tasks.events
{
    import flash.events.Event;

    public class TaskEvent extends Event
    {
        public static const PROGRESS: String = "progress_TaskEvent";
        public static const COMPLETE: String = "complete_TaskEvent";
        
        private var _data: Object;
        public function get data():Object
        {
            return _data;
        }
        
        public function TaskEvent(type:String, data: Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
        {
            _data = data;
            super(type, bubbles, cancelable);
        }
        
        override public function clone():Event
        {
            return new TaskEvent(type, data, bubbles, cancelable);
        }
    }
}
