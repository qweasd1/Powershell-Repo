using System;

namespace PSCore
{
    public class PSFunctionInfo
    {
        public Guid Guid { get; private set; }
        public string Name { get; set; }
        public bool IsShow { get; set; }

        //public string File { get; set; }
        public PSFunctionInfo(string name)
        {
            Name = name;
            Guid = Guid.NewGuid();
            IsShow = true;
        }
    }
}
