/**
 * Created by agnither on 28.04.16.
 */
package com.agnither.tasks.abstract
{
    import com.agnither.tasks.events.TaskEvent;

    public class MultiTask extends SimpleTask
    {
        private var _tasks: Vector.<SimpleTask>;
        private var _pointer: int = 0;

        public function MultiTask(data: Object = null)
        {
            super(data);

            _tasks = new <SimpleTask>[];
        }

        public function addTask(task: SimpleTask, cost: Number = 1):void
        {
            task.costValue = cost;
            _tasks.push(task);
        }

        override public function retry():void
        {
            // TODO: retry multitask
            super.retry();
        }

        private function nextTask():void
        {
            if (_tasks.length > _pointer)
            {
                var task: SimpleTask = _tasks[_pointer];
                taskStart(task);
                task.addEventListener(TaskEvent.PROGRESS, localProgress);
                task.addEventListener(TaskEvent.COMPLETE, localCallback);
                task.execute();
            } else {
                complete();
            }
        }

        override public function execute():void
        {
            super.execute();
            
            nextTask();
        }

        protected function taskStart(task: SimpleTask):void
        {

        }

        protected function taskComplete(task: SimpleTask):void
        {

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
            var task: SimpleTask = _tasks[_pointer++];
            task.removeEventListener(TaskEvent.PROGRESS, localProgress);
            task.removeEventListener(TaskEvent.COMPLETE, localCallback);
            taskComplete(task);

            nextTask();
        }
        
        override public function destroy():void
        {
            _tasks.length = 0;
            _tasks = null;
            
            super.destroy();
        }
    }
}
