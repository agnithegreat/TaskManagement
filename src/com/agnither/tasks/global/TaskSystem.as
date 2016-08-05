/**
 * Created by agnither on 05.08.16.
 */
package com.agnither.tasks.global
{
    import com.agnither.tasks.abstract.SimpleTask;
    import com.agnither.tasks.events.TaskEvent;

    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Dictionary;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    public class TaskSystem extends EventDispatcher
    {
        private static var _instance: TaskSystem;
        public static function getInstance():TaskSystem
        {
            if (_instance == null)
            {
                _instance = new TaskSystem(new SingletonToken());
            }
            return _instance;
        }
        
        private var _token: SingletonToken;
        
        private var _running: Vector.<SimpleTask>;
        private var _queue: Vector.<SimpleTask>;
        private var _callbacks: Dictionary;

        private var _timer: Timer;
        private var _lastTimer: int;

        public function TaskSystem(token: SingletonToken)
        {
            _token = token;
            if (_token == null)
            {
                throw new Error("You can not create TaskSystem using constructor. Use getInstance() method.");
            }

            _running = new <SimpleTask>[];
            _queue = new <SimpleTask>[];
            _callbacks = new Dictionary();

            _timer = new Timer(1);
            _timer.addEventListener(TimerEvent.TIMER, handleTimer);
            start();
        }

        public function addTask(task: SimpleTask, callback: Function = null, instant: Boolean = true):void
        {
            if (callback != null)
            {
                _callbacks[task] = callback;
            }
            
            if (instant)
            {
                runTask(task);
            } else {
                if (_queue.indexOf(task) >= 0)
                {
                    throw new Error(this + " is already in queue");
                }
                _queue.push(task);
                checkNextTask();
            }
        }

        public function start():void
        {
            _lastTimer = getTimer();
            _timer.start();
            
            checkNextTask();
        }

        public function stop():void
        {
            handleTimer(null);
            _timer.stop();
        }
        
        public function validateTaskExecution(task: SimpleTask, token: Object):void
        {
            if (token != _token)
            {
                throw new Error(task + " Task execution validation is failed");
            }
        }
        
        private function checkNextTask():void
        {
            if (_running.length == 0 && _queue.length > 0)
            {
                runTask(_queue.shift());
            }
        }

        private function runTask(task: SimpleTask):void
        {
            if (_running.indexOf(task) >= 0)
            {
                throw new Error(this + " is already running");
            }
            
            task.addEventListener(TaskEvent.COMPLETE, handleTaskComplete);
            task.addEventListener(TaskEvent.ERROR, handleTaskError);
            _running.push(task);
            task.execute(_token);
        }

        private function removeTask(task: SimpleTask):void
        {
            task.removeEventListener(TaskEvent.COMPLETE, handleTaskComplete);
            task.removeEventListener(TaskEvent.ERROR, handleTaskError);

            var runningIndex: int = _running.indexOf(task);
            if (runningIndex >= 0)
            {
                _running.splice(runningIndex, 1);
            }
            
            var queueIndex: int = _queue.indexOf(task);
            if (queueIndex >= 0)
            {
                _queue.splice(queueIndex, 1);
            }
            
            checkNextTask();
        }

        private function handleTimer(event:TimerEvent):void
        {
            var now: int = getTimer();
            var delta: Number = (now - _lastTimer) * 0.001;

            for (var i:int = 0; i < _running.length; i++)
            {
                var task: SimpleTask = _running[i];
                task.step(delta);
            }

            _lastTimer = now;
        }

        private function handleTaskComplete(event: TaskEvent):void
        {
            var task: SimpleTask = event.currentTarget as SimpleTask;

            var callback: Function = _callbacks[task];
            if (callback != null)
            {
                callback();
            }
            delete _callbacks[task];

            removeTask(task);
        }
        
        private function handleTaskError(event: TaskEvent):void
        {
            var task: SimpleTask = event.currentTarget as SimpleTask;
            delete _callbacks[task];
            removeTask(task);
        }
    }
}

class SingletonToken
{

}
