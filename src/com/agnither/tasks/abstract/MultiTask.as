/**
 * Created by agnither on 28.04.16.
 */
package com.agnither.tasks.abstract
{
    import com.agnither.tasks.events.TaskEvent;
    import com.agnither.tasks.global.TaskSystem;

    public class MultiTask extends SimpleTask
    {
        private var _tasks: Vector.<SimpleTask>;
        private var _pointer: int = 0;
        
        private function get currentTask():SimpleTask
        {
            return _tasks.length > _pointer ? _tasks[_pointer] : null;
        }

        public function MultiTask(data: Object = null)
        {
            super(data);

            _tasks = new <SimpleTask>[];
        }

        public function addTask(task: SimpleTask, cost: Number = 1):void
        {
            task.costValue = cost;
            task.parent = this;
            _tasks.push(task);
        }

        private function nextTask():void
        {
            var task: SimpleTask = currentTask;
            if (task != null)
            {
                taskStart(task);
                task.addEventListener(TaskEvent.PROGRESS, localProgress);
                task.addEventListener(TaskEvent.COMPLETE, localCallback);
                task.addEventListener(TaskEvent.ERROR, localError);
                TaskSystem.getInstance().addTask(task);
            } else {
                complete();
            }
        }

        private function removeTask():void
        {
            var task: SimpleTask = currentTask;
            if (task != null)
            {
                task.removeEventListener(TaskEvent.PROGRESS, localProgress);
                task.removeEventListener(TaskEvent.COMPLETE, localCallback);
                task.removeEventListener(TaskEvent.ERROR, localError);
                taskComplete(task);
            }
        }

        override public function execute(token: Object):void
        {
            super.execute(token);
            
            nextTask();
        }

        protected function taskStart(task: SimpleTask):void
        {

        }

        protected function taskComplete(task: SimpleTask):void
        {
            dispatchEvent(new TaskEvent(TaskEvent.TASK_COMPLETE));
        }
        
        private function localProgress(event: TaskEvent):void
        {
            var value: Number = 0;
            var totalCost: Number = 0;
            for (var i:int = 0; i < _tasks.length; i++)
            {
                value += _tasks[i].progressValue * _tasks[i].costValue;
                totalCost += _tasks[i].costValue;
            }
            if (totalCost > 0)
            {
                value /= totalCost;
            }
            progress(value);
        }

        private function localCallback(event: TaskEvent):void
        {
            removeTask();
            _pointer++;
            nextTask();
        }

        private function localError(event: TaskEvent):void
        {
            error(event.data as String);
        }
        
        override protected function dispose():void
        {
            removeTask();
            _tasks.length = 0;
            _tasks = null;
            
            super.dispose();
        }
    }
}
