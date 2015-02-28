using System;
using System.Collections.Generic;
using System.Linq;

namespace PSCore
{
    public class PSFunctionInfoRepository
    {
        private Dictionary<string, PSFunctionInfo> _funcName_funcInfo;
        private Dictionary<Guid, HistoryRepository> _funcIdentifier_funcHistory;

        public PSFunctionInfoRepository()
        {
            _funcName_funcInfo = new Dictionary<string, PSFunctionInfo>();
            _funcIdentifier_funcHistory = new Dictionary<Guid, HistoryRepository>();
        }

        public void NewFunction(string funcName,string originalVersion)
        {
            if (_funcName_funcInfo.ContainsKey(funcName))
            {
                throw new InvalidOperationException("there is already a function called: " + funcName);
            }
            var newFuncInfo = new PSFunctionInfo(funcName);
            var historyRepo = new HistoryRepository();
            historyRepo.Add(originalVersion);
            _funcName_funcInfo.Add(funcName, newFuncInfo);
            _funcIdentifier_funcHistory.Add(newFuncInfo.Guid, historyRepo);
        }

        public void Record(string funcName, string newVersion)
        {
            if (!_funcName_funcInfo.ContainsKey(funcName))
            {
                throw new InvalidOperationException(string.Format("no this function: {0}. please first added it", funcName));            
            }

            _funcIdentifier_funcHistory[_funcName_funcInfo[funcName].Guid].Add(newVersion);
        }

        public void Hide(string funcName)
        {
            if (!_funcName_funcInfo.ContainsKey(funcName))
            {
                throw new InvalidOperationException(string.Format("no this function: {0}. please first added it", funcName));
            }
            var funcInfo = _funcName_funcInfo[funcName];
            
            funcInfo.IsShow = false;
        }

        public string Show(string funcName)
        {
            if (!_funcName_funcInfo.ContainsKey(funcName))
            {
                throw new InvalidOperationException(string.Format("no this function: {0}. please first added it", funcName));
            }
            var funcInfo = _funcName_funcInfo[funcName];
            funcInfo.IsShow = true;
            return _funcIdentifier_funcHistory[funcInfo.Guid].Current;
        }

        public bool IsHidden(string funcName)
        {
            if (!_funcName_funcInfo.ContainsKey(funcName))
            {
                throw new InvalidOperationException(string.Format("no this function: {0}. please first added it", funcName));
            }
            var funcInfo = _funcName_funcInfo[funcName];
            return funcInfo.IsShow;
        }

        public bool HasFunction(string funcName)
        {
            return _funcName_funcInfo.Keys.Select(x=>x.ToLower()).Contains(funcName.ToLower());
        }

        public string[] GetAllFunctions()
        {
            return _funcName_funcInfo.Keys.OrderBy(x=>x).ToArray();
        }
        public string[] GetHiddinFunctions()
        {
            return (from funcInfo in _funcName_funcInfo.Values
                    where funcInfo.IsShow == false
                    select funcInfo.Name).ToArray();
        }

        public void Delete(string funcName)
        {
            var funcInfo = _funcName_funcInfo[funcName];
            _funcIdentifier_funcHistory.Remove(funcInfo.Guid);
            _funcName_funcInfo.Remove(funcName); 
        }

        //TODO: think what will happened when you want to rename an function name.But you still want to hold the history of its previous version
        //Let's do it in next release
        private void Rename(string oldFuncName, string newFuncName)
        {
            var funcInfo = _funcName_funcInfo[oldFuncName];
            funcInfo.Name = newFuncName;
            _funcName_funcInfo.Remove(oldFuncName);
            _funcName_funcInfo.Add(newFuncName,funcInfo);            
        }

        public string Rollback(string funcName)
        {
            var historyRepo = getRepoByFuncName(funcName);
                historyRepo.Rollback();
            return historyRepo.Current;
        }

        public string Redo(string funcName)
        {
            var historyRep = getRepoByFuncName(funcName);
            historyRep.Redo();
            return historyRep.Current;
        }

        public string GetCurrentByFuncName(string funcName)
        {
            return getRepoByFuncName(funcName).Current;
        }

        private HistoryRepository getRepoByFuncName(string funcName)
        {
            var funInfo = _funcName_funcInfo[funcName];
            return _funcIdentifier_funcHistory[funInfo.Guid];
        }
    }
}
