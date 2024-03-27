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

public partial class Master_ClaimLockingMaster : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType, Index;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;
    protected String LogoURL;
    [Serializable]
    public class ClaimLockingValidate
    {
        public int OCLPMID { get; set; }
        public int OptionId { get; set; }
        public int RegionId { get; set; }
        public string Region { get; set; }
        public Decimal EmpId { get; set; }
        public string EmpName { get; set; }
        public Decimal DistributorId { get; set; }
        public string DistName { get; set; }
        public Decimal SSID { get; set; }
        public string SSName { get; set; }
        public int Days { get; set; }
        public bool IsActive { get; set; }
        public string CreatedDate { get; set; }
        public string CreatedBy { get; set; }
        public string UpdatedDate { get; set; }
        public string UpdatedBy { get; set; }
    }
    #endregion
    #region HelperMethod
    public class ClaimLocking
    {
        public string Text { get; set; }
        public decimal Value { get; set; }
    }
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
        if (!IsPostBack)
        {
            //ClearAllInputs();
        }
    }
    #endregion

    #region AjaxMethods
    [WebMethod]
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<ClaimLocking> SearchRegion(string prefixText)
    {
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        //  decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
        //Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
        decimal ParentID = 1000010000000000;
        Int32 UserID = 1;
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForCurrHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "State");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", 1);
        Cm.Parameters.AddWithValue("@StateID", 0);
        Cm.Parameters.AddWithValue("@CityID", 0);
        Cm.Parameters.AddWithValue("@PlantID", 0);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        //StrCust = ds.Tables[0].AsEnumerable()
        //               .Select(r => r.Field<string>("Data"))
        //               .ToList();
        List<ClaimLocking> ObjList = new List<ClaimLocking>();
        if (ds.Tables[0].Rows.Count > 0)
        {

            for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                ClaimLocking Obj = new ClaimLocking();
                Obj.Text = ds.Tables[0].Rows[i]["Data"].ToString();
                Obj.Value = 0;
                ObjList.Add(Obj);
            }
        }
        return ObjList;
    }

    [WebMethod]
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]  
    public static List<dynamic> SearchEmployee(string prefixText)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            List<string> items = new List<string>();

            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (prefixText == "*")
                {
                    items = (from c in ctx.OEMPs
                             where c.ParentID == 1000010000000000
                             select c.EmpCode + " - " + c.Name + " - " + SqlFunctions.StringConvert((double)c.EmpID).Trim()).Distinct().ToList();
                }
                else
                {
                    items = (from c in ctx.OEMPs
                             where c.ParentID == 1000010000000000 && (c.EmpCode.Contains(prefixText) || c.Name.Contains(prefixText))
                             select c.EmpCode + " - " + c.Name + " - " + SqlFunctions.StringConvert((double)c.EmpID).Trim()).Distinct().ToList();
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
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public static List<DicData> SearchDistributor(string prefixText, string strEmpId, string strRegionId)
    {
        List<DicData> dicData = new List<DicData>();
        List<ClaimLocking> StrCust = new List<ClaimLocking>();
        using (var ctx = new DDMSEntities())
        {
            //decimal ParentID = 1000010000000000;
            //Int32 UserID = 1;
            Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            //int Type = Convert.ToInt32(contextKey);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            //int EmpGroupId = Int32.TryParse(strEmpGroupId, out EmpGroupId) && EmpGroupId > 0 ? EmpGroupId : 0;
            int SUserID = Int32.TryParse(strEmpId, out SUserID) && SUserID > 0 ? SUserID : 0;
            int RegionId = Int32.TryParse(strRegionId, out RegionId) && RegionId > 0 ? RegionId : 0;
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetDistributorData";
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
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DicData> SearchSuperStockiest(string prefixText, string strEmpId, string strRegionId)
    {
        List<DicData> dicData = new List<DicData>();
        List<ClaimLocking> StrCust = new List<ClaimLocking>();
        using (var ctx = new DDMSEntities())
        {
            //decimal ParentID = 1000010000000000;
            //Int32 UserID = 1;
            Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            //int Type = Convert.ToInt32(contextKey);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            //int EmpGroupId = Int32.TryParse(strEmpGroupId, out EmpGroupId) && EmpGroupId > 0 ? EmpGroupId : 0;
            int SUserID = Int32.TryParse(strEmpId, out SUserID) && SUserID > 0 ? SUserID : 0;
            int RegionId = Int32.TryParse(strRegionId, out RegionId) && RegionId > 0 ? RegionId : 0;
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetSuperStockiestData";
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


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadData(int OptionId)
    {
        List<dynamic> result = new List<dynamic>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetClaimLockingPeriodData";
        Cm.Parameters.AddWithValue("@OptionId", OptionId);
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            List<ClaimLockingValidate> CliamData = ds.Tables[0].AsEnumerable().Select
             (x => new ClaimLockingValidate
             {
                 OCLPMID = x.Field<int>("OCLPMID"),
                 OptionId = x.Field<int>("OptionId"),
                 RegionId = x.Field<int>("RegionID"),
                 Region = x.Field<string>("Region"),
                 EmpId = x.Field<Decimal>("EmpId"),
                 EmpName = x.Field<String>("EmpName"),
                 DistributorId = x.Field<Decimal>("DistributorId"),
                 DistName = x.Field<String>("Distributor"),
                 SSID = x.Field<Decimal>("SSID"),
                 SSName = x.Field<String>("SSName"),
                 IsActive = x.Field<bool>("Active"),
                 Days = x.Field<int>("Days"),
                 CreatedDate = x.Field<string>("CreatedDate"),
                 CreatedBy = x.Field<string>("CreatedBy"),
                 UpdatedDate = x.Field<string>("UpdatedDate"),
                 UpdatedBy = x.Field<string>("UpdatedBy")
             }).ToList();
            result.Add(CliamData);
        }
        return result;
    }
    #endregion

    #region Button event
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadReport(string strIsHistory, int OptionId)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetClaimLoackingPeriodReport";
            Cm.Parameters.AddWithValue("@IsHistory", strIsHistory.ToLower() == "true" ? "1" : "0");
            Cm.Parameters.AddWithValue("@OptionId", OptionId);

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

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputClaim, int OptionId, int IsAnyRowDeleted, string DeletedIDs)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var ClaimListData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputClaim.ToString());

                if (!string.IsNullOrEmpty(DeletedIDs))
                {
                    List<string> isDeletedIds = DeletedIDs.Trim().Split(",".ToArray()).ToList();
                    List<int> IDs = new List<int>();
                    foreach (var item in isDeletedIds)
                    {
                        int Id = Int32.TryParse(item, out Id) ? Id : 0;
                        IDs.Add(Id);//OCLPM
                    }
                    ctx.OCLPMs.Where(x => IDs.Any(y => y == x.OCLPMID)).ToList().ForEach(x => { x.Deleted = true; x.UpdatedBy = UserID; x.Active = false; x.UpdatedDate = DateTime.Now; });
                    ctx.SaveChanges();
                }

                foreach (var item in ClaimListData)
                {
                    OCLPM ObjClaim = new OCLPM();
                    int CliamId = int.TryParse(Convert.ToString(item["CliamLockingId"]), out CliamId) ? CliamId : 0;
                    int EmpId = int.TryParse(Convert.ToString(item["EmpId"]), out EmpId) ? EmpId : 0;
                    int RgnId = int.TryParse(Convert.ToString(item["RegionId"]), out RgnId) ? RgnId : 0;
                    Decimal DistId = Decimal.TryParse(Convert.ToString(item["DistId"]), out DistId) ? DistId : 0;
                    Decimal SSId = Decimal.TryParse(Convert.ToString(item["SSId"]), out SSId) ? SSId : 0;
                    int DaysId = int.TryParse(Convert.ToString(item["DaysId"]), out DaysId) ? DaysId : 0;
                    bool IsActive = Convert.ToBoolean(Convert.ToString(item["IsActive"]));
                    string IPAddress = Convert.ToString(item["IPAddress"]);
                    Decimal CustomerId = Decimal.TryParse(Convert.ToString(item["CustomerId"]), out CustomerId) ? CustomerId : 0;
                    if (CliamId > 0 && Convert.ToString(item["IsChange"]) == "1")
                    {
                        var ObjOCLPM = ctx.OCLPMs.Where(x => x.OCLPMID == CliamId).First();

                        ObjOCLPM.RegionID = RgnId;
                        ObjOCLPM.EmpId = EmpId;
                        ObjOCLPM.DistributorId = DistId;
                        ObjOCLPM.SSID = SSId;
                        ObjOCLPM.Days = DaysId;
                        ObjOCLPM.Active = IsActive;
                        ObjOCLPM.OptionId = OptionId;
                        //ObjOCLPM.ModuleId = ModuleId;
                        //ObjOCLPM.ScanningATID = ScanningId;
                        //ObjOCLPM.CustomerId = CustomerId;
                        ObjOCLPM.UpdatedBy = UserID;
                        ObjOCLPM.UpdatedDate = DateTime.Now;
                        ObjOCLPM.Deleted = false;
                        ctx.SaveChanges();
                    }
                    else if (CliamId > 0 && Convert.ToString(item["IsChange"]) == "0")
                    {
                    }
                    else
                    {
                        ObjClaim.OptionId = OptionId;
                        ObjClaim.RegionID = RgnId;
                        ObjClaim.EmpId = EmpId;
                        ObjClaim.DistributorId = DistId;
                        ObjClaim.SSID = SSId;
                        ObjClaim.Days = DaysId;
                        ObjClaim.Active = IsActive;
                        //ObjOCLPM.ModuleId = ModuleId;
                        //ObjOCLPM.ScanningATID = ScanningId;
                        ObjClaim.UpdatedBy = UserID;
                        ObjClaim.UpdatedDate = DateTime.Now;
                        ObjClaim.CreatedBy = UserID;
                        ObjClaim.CreatedDate = DateTime.Now;
                        ObjClaim.Deleted = false;
                        ctx.OCLPMs.Add(ObjClaim);
                    }
                }

                ctx.SaveChanges();
                return "SUCCESS=Claim Data Added Successfully";
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is wrong: " + Common.GetString(ex);
        }
    }
    #endregion     

}