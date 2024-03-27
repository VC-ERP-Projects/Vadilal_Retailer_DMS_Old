using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

[Serializable]
public class AstConf
{
    public string AssetCode { get; set;}
    public string AssetName { get; set; }
    public int AssetID { get; set; }
    public int AssetTransferID { get; set; }
    public int AssetConditionID { get; set; }
    public int AssetStatusID { get; set; }
    public string AttachFileName { get; set; }
}