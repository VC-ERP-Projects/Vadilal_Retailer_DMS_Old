using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_UserUnitMappingMaster : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType, Index;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;
    protected String LogoURL;

    [Serializable]
    public class ScanningTypeValidate
    {
        public int EmpReasonID { get; set; }
        public int EmpId { get; set; }
        public int ReasonId { get; set; }
        public bool IsActive { get; set; }
        public string CreatedDate { get; set; }
        public string CreatedBy { get; set; }
        public string UpdatedDate { get; set; }
        public string UpdatedBy { get; set; }
        public string EmpName { get; set; }
        public string ReasonCode { get; set; }
    }
    #endregion

    #region HelperMethod

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int EGID = Convert.ToInt32(Session["GroupID"]);
                CustType = Convert.ToInt32(Session["Type"]);
                Version = Convert.ToString(ConfigurationManager.AppSettings["Version"]);
                LogoURL = Common.GetLogo(ParentID);
                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
                var UserType = Session["UserType"].ToString();
                int menuid = ctx.OMNUs.FirstOrDefault(x => x.PageName == pagename && (UserType == "b" ? true : x.MenuType == UserType)).MenuID;
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.MenuID == menuid && x.EmpGroupID == EGID && x.ParentID == ParentID);
                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(CustType == 1 ? Auth.OMNU.Company : CustType == 2 ? Auth.OMNU.CMS : CustType == 3 ? Auth.OMNU.DMS : CustType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
                    AuthType = Auth.AuthorizationType;

                    //var UserType = Session["UserType"].ToString();
                    if (Auth.OMNU.MenuType.ToUpper() == "B" || UserType.ToUpper() == "B" || UserType.ToUpper() == Auth.OMNU.MenuType.ToUpper()) { }
                    else
                        Response.Redirect("~/AccessError.aspx");

                    hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();

                    if (Session["Lang"] != null && Session["Lang"].ToString() == "gujarati")
                    {
                        try
                        {
                            var xml = XDocument.Load(Server.MapPath("../Document/forlanguage.xml"));
                            var unit = xml.Descendants("Inward");
                            if (unit != null)
                            {
                                var ctrls = Common.GetAll(this, typeof(Label));
                                foreach (Label item in ctrls)
                                {
                                    if (unit.Elements().Any(x => x.Name == item.ID))
                                        item.Text = unit.Elements().FirstOrDefault(x => x.Name == item.ID).Value;
                                }
                            }
                        }
                        catch (Exception)
                        { }
                    }
                }
            }
        }
        else
        {
            Response.Redirect("~/Login.aspx");
        }
    }
    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
         ValidateUser();
    }

    #endregion

    #region AjaxMethods


    [WebMethod]
    public static List<dynamic> SearchEmployee(string prefixText, string strRegionId)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            List<string> items = new List<string>();
            Int32 RegionId = Int32.TryParse(strRegionId, out RegionId) ? RegionId : 0;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (prefixText == "*")
                {
                    items = (from c in ctx.OEMPs
                             join aa in ctx.EMP1 on c.EmpID equals aa.EmpID
                             where c.ParentID == 1000010000000000 && (RegionId == 0 || aa.StateID == RegionId)
                             select c.EmpCode + " # " + c.Name + " # " + SqlFunctions.StringConvert((double)c.EmpID).Trim()).Distinct().ToList();
                }
                else
                {
                    items = (from c in ctx.OEMPs
                             join aa in ctx.EMP1 on c.EmpID equals aa.EmpID
                             where c.ParentID == 1000010000000000 && (c.EmpCode.Contains(prefixText) || c.Name.Contains(prefixText))
                             && (RegionId == 0 || aa.StateID == RegionId)
                             select c.EmpCode + " # " + c.Name + " # " + SqlFunctions.StringConvert((double)c.EmpID).Trim()).Distinct().ToList();
                }
                result.Add(items);
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }
        return result;
    }

    [WebMethod]
    public static List<DicData> SearchDistributor(string prefixText)
    {
        List<DicData> dicData = new List<DicData>();
        using (var ctx = new DDMSEntities())
        {
            //decimal ParentID = 1000010000000000;
            //Int32 UserID = 1;
            Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            //int Type = Convert.ToInt32(contextKey);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            //int EmpGroupId = Int32.TryParse(strEmpGroupId, out EmpGroupId) && EmpGroupId > 0 ? EmpGroupId : 0;

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetDistributorUnitMapData";
            Cm.Parameters.AddWithValue("@SUserID", 0);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
            Cm.Parameters.AddWithValue("@Count", 0);
            Cm.Parameters.AddWithValue("@EmpId", UserID);
            Cm.Parameters.AddWithValue("@RegionId", 0);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    return ds.Tables[0].AsEnumerable()
                                .Select(r => new DicData { Text = r.Field<string>("Data"), Value = 0 })
                                .ToList();
                }
            }
            return dicData;
        }
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DicData> SearchSuperStockiest(string prefixText)
    {
        List<DicData> dicData = new List<DicData>();
        using (var ctx = new DDMSEntities())
        {
            //decimal ParentID = 1000010000000000;
            //Int32 UserID = 1;
            Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            //int Type = Convert.ToInt32(contextKey);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            //int EmpGroupId = Int32.TryParse(strEmpGroupId, out EmpGroupId) && EmpGroupId > 0 ? EmpGroupId : 0;
            int SUserID = 0;
            int RegionId = 0;
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetSuperStockiestUnitMappingData";
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
            Cm.Parameters.AddWithValue("@Count", 0);
            Cm.Parameters.AddWithValue("@EmpId", UserID);
            Cm.Parameters.AddWithValue("@RegionId", RegionId);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    return ds.Tables[0].AsEnumerable()
                                .Select(r => new DicData { Text = r.Field<string>("Data"), Value = 0 })
                                .ToList();
                }
            }
            return dicData;
        }
    }



    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string GetCustomerEmpDetails(string CustomerId, int optionId)
    {
        string jsonstring = "";
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetCustomerEmpDetails";
        Cm.Parameters.AddWithValue("@CustomerId", CustomerId);
        Cm.Parameters.AddWithValue("@OptionId", optionId);
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            jsonstring = JsonConvert.SerializeObject(ds.Tables[0]);
        }
        return jsonstring;
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static String LoadData(int optionId)
    {
        string jsonstring = "";
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetUserUnitMappingData";
        Cm.Parameters.AddWithValue("@OptionId", optionId);
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            jsonstring = JsonConvert.SerializeObject(ds.Tables[0]);
        }
        return jsonstring;
    }


    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputUnitMapping, int IsAnyRowDeleted, string DeletedIDs, int OptionId)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var UnitMappingData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputUnitMapping.ToString());

                if (!string.IsNullOrEmpty(DeletedIDs))
                {
                    List<string> isDeletedIds = DeletedIDs.Trim().Split(",".ToArray()).ToList();
                    List<int> IDs = new List<int>();
                    foreach (var item in isDeletedIds)
                    {
                        int Id = Int32.TryParse(item, out Id) ? Id : 0;
                        IDs.Add(Id);
                    }
                    ctx.OCUMs.Where(x => IDs.Any(y => y == x.OCUMID)).ToList().ForEach(x => { x.IsDeleted = true; x.UpdatedBy = UserID; x.Active = false; x.UpdatedDate = DateTime.Now; });
                    ctx.SaveChanges();
                }

                foreach (var item in UnitMappingData)
                {
                    OCUM ObjScanType = new OCUM();
                    int OCUMID = int.TryParse(Convert.ToString(item["OCUMID"]), out OCUMID) ? OCUMID : 0;
                    Decimal CustomerId = Decimal.TryParse(Convert.ToString(item["CustId"]), out CustomerId) ? CustomerId : 0;
                    int Unit = int.TryParse(Convert.ToString(item["Unit"]), out Unit) ? Unit : 0;
                    bool IsActive = Convert.ToBoolean(Convert.ToString(item["Active"]));

                    if (OCUMID > 0 && Convert.ToString(item["IsChange"]) == "1")
                    {
                        var ObjOERM = ctx.OCUMs.Where(x => x.OCUMID == OCUMID).First();
                        ObjOERM.OptionId = OptionId;
                        ObjOERM.CustID = CustomerId;
                        ObjOERM.Unit = Unit;
                        ObjOERM.Active = IsActive;
                        ObjScanType.IsDeleted = false;
                        ObjOERM.UpdatedBy = UserID;
                        ObjOERM.UpdatedDate = DateTime.Now;
                        ctx.SaveChanges();
                    }
                    else if (OCUMID > 0 && Convert.ToString(item["IsChange"]) == "0")
                    {
                    }
                    else
                    {
                        ObjScanType.OptionId = OptionId;
                        ObjScanType.CustID = CustomerId;
                        ObjScanType.Unit = Unit;
                        ObjScanType.Active = IsActive;
                        ObjScanType.IsDeleted = false;
                        ObjScanType.UpdatedBy = UserID;
                        ObjScanType.UpdatedDate = DateTime.Now;
                        ObjScanType.CreatedBy = UserID;
                        ObjScanType.CreatedDate = DateTime.Now;
                        ctx.OCUMs.Add(ObjScanType);
                    }
                }

                ctx.SaveChanges();
                return "SUCCESS=Data Saved Successfully";
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is wrong: " + Common.GetString(ex);
        }
    }



    #endregion


    #region Button Events
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadReport(string strIsHistory, int optionId)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetUserUnitMappingReport";
            Cm.Parameters.AddWithValue("@OptionId", optionId);
            Cm.Parameters.AddWithValue("@IsHistory", strIsHistory.ToLower() == "true" ? "1" : "0");

            DataSet DS = objClass.CommonFunctionForSelect(Cm);

            DataTable dt;
            if (DS.Tables[0] != null && DS.Tables[0].Rows.Count > 0)
            {
                dt = DS.Tables[0];
                result.Add(JsonConvert.SerializeObject(dt));
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }

        return result;

    }


    #endregion
}