using System;
using System.Collections.Generic;

namespace PSCore
{
    public class HistoryRepository
    {
        
        public Stack<string> HistoryStack { get; private set; }
        public Stack<string> RedoStack { get; private set; }
        public string Current { get; private set; }


        public HistoryRepository()
        {
            HistoryStack = new Stack<string>();
            RedoStack = new Stack<string>();
        }

        public void Rollback()
        {
            if (HistoryStack.Count == 0)
            {
                throw new InvalidOperationException("This is the first Version");
            }

            RedoStack.Push(Current);
            Current = HistoryStack.Pop();
        }

        public void Add(string newText)
        {
            //first time you add a record
            if (Current == null)
            {
                Current = newText;
                return;
            }

            
            if (Current!= newText)
            {
                if (RedoStack.Count > 0)
                {
                    RedoStack.Clear();
                }

                HistoryStack.Push(Current);
                Current = newText;
            }
            
        }

        public void Redo()
        {
            if (RedoStack.Count == 0)
            {

                throw new InvalidOperationException("This is the lastest Version ");
            }

            HistoryStack.Push(Current);
            Current = RedoStack.Pop();
        }

        public void Reset()
        {
            HistoryStack.Clear();
            RedoStack.Clear();
            Current = null;
        }
    }
}
