using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity.Validation;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_DiscountTypeIncExcMaster : System.Web.UI.Page
{
    protected int UserID, CustType, Index;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;
    #region HelperMethod
    public class DiscountTypeSearch
    {
        public string Text { get; set; }
        public decimal Value { get; set; }
    }
    private List<ODTIE> ODTIEs
    {
        get { return this.ViewState["ODTIE"] as List<ODTIE>; }
        set { this.ViewState["ODTIE"] = value; }
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


    public static void TransferCSVToTable(string filePath, DataTable dt)
    {
        string[] csvRows = System.IO.File.ReadAllLines(filePath);
        string[] fields = null;
        bool head = true;
        foreach (string csvRow in csvRows)
        {
            if (head)
            {
                if (dt.Columns.Count == 0)
                {
                    fields = csvRow.Split(',');
                    foreach (string column in fields)
                    {
                        DataColumn datecolumn = new DataColumn(column);
                        datecolumn.AllowDBNull = true;
                        dt.Columns.Add(datecolumn);
                    }
                }
                head = false;
            }
            else
            {
                fields = csvRow.Split(',');
                DataRow row = dt.NewRow();
                row.ItemArray = new object[fields.Length];
                row.ItemArray = fields;
                dt.Rows.Add(row);
            }
        }

    }
    #endregion
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
    #region PageLoad
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            //ClearAllInputs();
        }
        //ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        //  scriptManager.RegisterPostBackControl(btnMappingUpload);
    }
    #endregion

    #region AjaxMethods
    [WebMethod]
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DiscountTypeSearch> SearchRegion(string prefixText)
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
        List<DiscountTypeSearch> ObjList = new List<DiscountTypeSearch>();
        if (ds.Tables[0].Rows.Count > 0)
        {

            for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                DiscountTypeSearch Obj = new DiscountTypeSearch();
                Obj.Text = ds.Tables[0].Rows[i]["Data"].ToString();
                Obj.Value = 0;
                ObjList.Add(Obj);
            }
        }
        return ObjList;
    }

    [WebMethod]
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]  
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
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public static List<DicData> SearchDistributor(string prefixText, string strEmpId, string strRegionId, string strSSID)
    {
        List<DicData> dicData = new List<DicData>();
        List<DiscountTypeSearch> StrCust = new List<DiscountTypeSearch>();
        using (var ctx = new DDMSEntities())
        {
            //decimal ParentID = 1000010000000000;
            //Int32 UserID = 1;
            Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            //int Type = Convert.ToInt32(contextKey);

            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);


            decimal SSID = Decimal.TryParse(strSSID, out SSID) && SSID > 0 ? SSID : 0;

            //int EmpGroupId = Int32.TryParse(strEmpGroupId, out EmpGroupId) && EmpGroupId > 0 ? EmpGroupId : 0;
            int SUserID = Int32.TryParse(strEmpId, out SUserID) && SUserID > 0 ? SUserID : 0;
            int RegionId = Int32.TryParse(strRegionId, out RegionId) && RegionId > 0 ? RegionId : 0;
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetDistributorDataForDiscountType";
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
            Cm.Parameters.AddWithValue("@Count", 0);
            Cm.Parameters.AddWithValue("@EmpId", UserID);
            Cm.Parameters.AddWithValue("@RegionId", RegionId);
            Cm.Parameters.AddWithValue("@SSID", SSID);

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
        //List<DiscountTypeSearch> StrCust = new List<DiscountTypeSearch>();
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
    public static List<DicData> SearchCustomerGroup(string prefixText)
    {

        List<DicData> dicData = new List<DicData>();
        using (var ctx = new DDMSEntities())
        {
            //decimal ParentID = 1000010000000000;
            //Int32 UserID = 1;
            Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetCustomerGroup";
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
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
    public static List<DicData> SearchCustomerData(string prefixText, string strEmpId, string strRegionId, string strDistId)
    {
        List<DicData> dicData = new List<DicData>();
        //List<DiscountTypeSearch> StrCust = new List<DiscountTypeSearch>();
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
            decimal DistributorId = Decimal.TryParse(strDistId, out DistributorId) && DistributorId > 0 ? DistributorId : 0;
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetCustomerData";
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
            Cm.Parameters.AddWithValue("@Count", 0);
            Cm.Parameters.AddWithValue("@EmpId", UserID);
            Cm.Parameters.AddWithValue("@RegionId", RegionId);
            Cm.Parameters.AddWithValue("@DistributorId", DistributorId);
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
    public static List<DicData> SearchDivision(string prefixText)
    {

        List<DicData> dicData = new List<DicData>();
        using (var ctx = new DDMSEntities())
        {
            //decimal ParentID = 1000010000000000;
            //Int32 UserID = 1;
            Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetDivsion";
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
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
    public static List<DicData> SearchProductGroup(string prefixText)
    {

        List<DicData> dicData = new List<DicData>();
        using (var ctx = new DDMSEntities())
        {
            //decimal ParentID = 1000010000000000;
            //Int32 UserID = 1;
            Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetProductGroup";
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
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
    public static List<DicData> SearchProductSubGroup(string prefixText, String strProdGroupId)
    {

        List<DicData> dicData = new List<DicData>();
        using (var ctx = new DDMSEntities())
        {
            //decimal ParentID = 1000010000000000;
            //Int32 UserID = 1;
            Int32 ProdGroupId = Int32.TryParse(strProdGroupId, out ProdGroupId) ? ProdGroupId : 0;
            Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetProductSubGroup";
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
            Cm.Parameters.AddWithValue("@ProductGroupId", ProdGroupId);
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
    public static List<DicData> SearchItemCode(string prefixText, String strProdGroupId, String strProdSubGroupId)
    {

        List<DicData> dicData = new List<DicData>();
        using (var ctx = new DDMSEntities())
        {
            //decimal ParentID = 1000010000000000;
            //Int32 UserID = 1;
            Int32 ProdGroupId = Int32.TryParse(strProdGroupId, out ProdGroupId) ? ProdGroupId : 0;
            Int32 ProdSubGroupId = Int32.TryParse(strProdSubGroupId, out ProdSubGroupId) ? ProdSubGroupId : 0;
            Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetItem";
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
            Cm.Parameters.AddWithValue("@ProductGroupId", ProdGroupId);
            Cm.Parameters.AddWithValue("@ProductSubGroupId", ProdSubGroupId);
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

    //[WebMethod]
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    //public static List<DicData> SearchItem(string prefixText)
    //{

    //    List<DicData> dicData = new List<DicData>();
    //    using (var ctx = new DDMSEntities())
    //    {
    //        //decimal ParentID = 1000010000000000;
    //        //Int32 UserID = 1;
    //        Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
    //        decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
    //        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
    //        SqlCommand Cm = new SqlCommand();
    //        Cm.Parameters.Clear();
    //        Cm.CommandType = CommandType.StoredProcedure;
    //        Cm.CommandText = "GetProductSubGroup";
    //        Cm.Parameters.AddWithValue("@Prefix", prefixText);
    //        DataSet ds = objClass.CommonFunctionForSelect(Cm);
    //        if (ds.Tables.Count > 0)
    //        {
    //            if (ds.Tables[0].Rows.Count > 0)
    //            {
    //                return ds.Tables[0].AsEnumerable()
    //                            .Select(r => new DicData { Text = r.Field<string>("Data"), Value = 0 })
    //                            .ToList();
    //            }
    //        }
    //        return dicData;
    //    }
    //}

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static String LoadData(int OptionId)
    {
        List<dynamic> result = new List<dynamic>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        //JsonConvert.SerializeObject(ds.Tables[0]);
        string jsonstring = "";
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetDiscountTypeIncExlData";
        Cm.Parameters.AddWithValue("@OptionId", OptionId);
        // Cm.Parameters.AddWithValue("@DiscountType", DiscountType);
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            jsonstring = JsonConvert.SerializeObject(ds.Tables[0]);
        }
        return jsonstring;
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
            Cm.CommandText = "GetDiscountTypeExclReport";
            Cm.Parameters.AddWithValue("@IsHistory", strIsHistory.ToLower() == "true" ? "1" : "0");
            Cm.Parameters.AddWithValue("@OptionId", OptionId);
            //  Cm.Parameters.AddWithValue("@DiscountType", DiscountType);
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
                    ctx.ODTIEs.Where(x => IDs.Any(y => y == x.DiscountExcId)).ToList().ForEach(x => { x.Deleted = true; x.UpdateBy = UserID; x.Active = false; x.UpdatedDate = DateTime.Now; });
                    ctx.SaveChanges();
                }

                foreach (var item in ClaimListData)
                {
                    ODTIE ObjClaim = new ODTIE();
                    int DiscountExcId = int.TryParse(Convert.ToString(item["DiscountExcId"]), out DiscountExcId) ? DiscountExcId : 0;
                    int EmpId = int.TryParse(Convert.ToString(item["EmpId"]), out EmpId) ? EmpId : 0;
                    int RgnId = int.TryParse(Convert.ToString(item["RegionId"]), out RgnId) ? RgnId : 0;
                    Decimal DistId = Decimal.TryParse(Convert.ToString(item["DistId"]), out DistId) ? DistId : 0;
                    Decimal SSId = Decimal.TryParse(Convert.ToString(item["SSId"]), out SSId) ? SSId : 0;
                    int CustGroupId = int.TryParse(Convert.ToString(item["CustGroupId"]), out CustGroupId) ? CustGroupId : 0;

                    Decimal CustId = Decimal.TryParse(Convert.ToString(item["CustId"]), out CustId) ? CustId : 0;
                    int DivisionId = int.TryParse(Convert.ToString(item["DivisionId"]), out DivisionId) ? DivisionId : 0;
                    int ProdGrpId = int.TryParse(Convert.ToString(item["ProdGrpId"]), out ProdGrpId) ? ProdGrpId : 0;
                    int ProdSubGrpId = int.TryParse(Convert.ToString(item["ProdSubGrpId"]), out ProdSubGrpId) ? ProdSubGrpId : 0;
                    String ItemCode = Convert.ToString(item["ItemCode"]);
                    OITM ObjItemId = ctx.OITMs.Where(x => x.ItemCode == ItemCode).FirstOrDefault();
                    //int ItemId = ObjItm.ItemID;
                    int ItemId = 0;
                    if (ObjItemId != null)
                    {
                        ItemId = int.TryParse(Convert.ToString(ObjItemId.ItemID), out ItemId) ? ItemId : 0;
                    }
                    bool IsMater = Convert.ToBoolean(Convert.ToString(item["Master"]));
                    bool IsQPS = Convert.ToBoolean(Convert.ToString(item["QPS"]));
                    bool IsMachine = Convert.ToBoolean(Convert.ToString(item["Machine"]));
                    bool IsParlour = Convert.ToBoolean(Convert.ToString(item["Parlour"]));
                    bool IsFOW = Convert.ToBoolean(Convert.ToString(item["FOW"]));
                    bool IsSecFri = Convert.ToBoolean(Convert.ToString(item["SecFright"]));
                    bool IsVRS = Convert.ToBoolean(Convert.ToString(item["VRS"]));
                    bool IsRateDiff = Convert.ToBoolean(Convert.ToString(item["RateDiff"]));
                    bool IsIOU = Convert.ToBoolean(Convert.ToString(item["IOU"]));
                    bool IsSTD = Convert.ToBoolean(Convert.ToString(item["SToD"]));



                    bool IsActive = Convert.ToBoolean(Convert.ToString(item["IsActive"]));
                    bool IsInclude = Convert.ToBoolean(Convert.ToString(item["IsInclude"]));
                    DateTime FromDate = Convert.ToDateTime(Convert.ToString(item["FromDate"]));
                    DateTime ToDate = Convert.ToDateTime(Convert.ToString(item["ToDate"]));

                    string IPAddress = Convert.ToString(item["IPAddress"]);
                    if (DiscountExcId > 0 && Convert.ToString(item["IsChange"]) == "1")
                    {
                        var ObjOCLPM = ctx.ODTIEs.Where(x => x.DiscountExcId == DiscountExcId).First();
                        ObjOCLPM.OptionId = OptionId;
                        //  ObjOCLPM.DiscountType = DiscountType;
                        //ObjOCLPM.RegionId = RgnId;
                        //ObjOCLPM.EmpId = EmpId;
                        //ObjOCLPM.DistributorId = DistId;
                        //ObjOCLPM.SSId = SSId;
                        //ObjOCLPM.CustGroupId = CustGroupId;
                        //ObjOCLPM.CustomerId = CustId;
                        //ObjOCLPM.Division = DivisionId;
                        //ObjOCLPM.ProductGroupId = ProdGrpId;
                        //ObjOCLPM.ProductSubGroupId = ProdSubGrpId;
                        //ObjOCLPM.ItemId = ItemId;
                        //ObjOCLPM.Active = IsActive;
                        //ObjOCLPM.IsInclude = IsInclude;
                        //ObjOCLPM.FromDate = FromDate;
                        //ObjOCLPM.ToDate = ToDate;
                        //ObjOCLPM.UpdateBy = UserID;
                        //ObjOCLPM.UpdatedDate = DateTime.Now;
                        //ObjOCLPM.Deleted = false;
                        //ObjOCLPM.MasterSchm = IsMater;
                        //ObjOCLPM.QPS = IsQPS;
                        //ObjOCLPM.Machine = IsMachine;
                        //ObjOCLPM.Parlour = IsParlour;
                        //ObjOCLPM.FOW = IsFOW;
                        //ObjOCLPM.SecFright = IsSecFri;
                        //ObjOCLPM.VRS = IsVRS;
                        //ObjOCLPM.RateDiff = IsRateDiff;
                        //ObjOCLPM.IOU = IsIOU;
                        //ObjOCLPM.STOD = IsSTD;
                        ctx.SaveChanges();
                    }
                    else if (DiscountExcId > 0 && Convert.ToString(item["IsChange"]) == "0")
                    {
                    }
                    else
                    {
                        ObjClaim.OptionId = OptionId;
                        // ObjClaim.DiscountType = DiscountType.ToString();
                        //ObjClaim.RegionId = RgnId;
                        //ObjClaim.EmpId = EmpId;
                        //ObjClaim.DistributorId = DistId;
                        //ObjClaim.SSId = SSId;

                        //ObjClaim.CustGroupId = CustGroupId;
                        //ObjClaim.CustomerId = CustId;
                        //ObjClaim.Division = DivisionId;
                        //ObjClaim.ProductGroupId = ProdGrpId;
                        //ObjClaim.ProductSubGroupId = ProdSubGrpId;
                        //ObjClaim.ItemId = ItemId;
                        //ObjClaim.Active = IsActive;
                        //ObjClaim.IsInclude = IsInclude;
                        //ObjClaim.FromDate = FromDate;
                        //ObjClaim.ToDate = ToDate;
                        //ObjClaim.UpdateBy = UserID;
                        //ObjClaim.UpdatedDate = DateTime.Now;
                        //ObjClaim.CreatedBy = UserID;
                        //ObjClaim.CreatedDate = DateTime.Now;
                        //ObjClaim.Deleted = false;
                        //ObjClaim.MasterSchm = IsMater;
                        //ObjClaim.QPS = IsQPS;
                        //ObjClaim.Machine = IsMachine;
                        //ObjClaim.Parlour = IsParlour;
                        //ObjClaim.FOW = IsFOW;
                        //ObjClaim.SecFright = IsSecFri;
                        //ObjClaim.VRS = IsVRS;
                        //ObjClaim.RateDiff = IsRateDiff;
                        //ObjClaim.IOU = IsIOU;
                        //ObjClaim.STOD = IsSTD;
                        ctx.ODTIEs.Add(ObjClaim);
                    }
                }

                ctx.SaveChanges();
                return "SUCCESS=Discount Type Data Added Successfully";
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is wrong: " + Common.GetString(ex);
        }
    }

    protected void btnMappingUpload_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable missdata = new DataTable();
            missdata.Columns.Add("Employee");
            missdata.Columns.Add("Region");
            missdata.Columns.Add("Distritutor");
            missdata.Columns.Add("SuperStockist");
            missdata.Columns.Add("CustomerGroup");
            missdata.Columns.Add("Customer");
            missdata.Columns.Add("Division");
            missdata.Columns.Add("ProductGroup");
            missdata.Columns.Add("ProductSubGroup");
            missdata.Columns.Add("ItemCode");
            missdata.Columns.Add("Master");
            missdata.Columns.Add("QPS");
            missdata.Columns.Add("Machine");
            missdata.Columns.Add("Parlour");
            //missdata.Columns.Add("FOW");
            //missdata.Columns.Add("SecFreight");
            //missdata.Columns.Add("VRS");
            //missdata.Columns.Add("RateDif");
            //missdata.Columns.Add("IOU");
            missdata.Columns.Add("STOD");
            missdata.Columns.Add("FromDate");
            missdata.Columns.Add("ToDate");
            missdata.Columns.Add("IncExc");
            missdata.Columns.Add("Active");
            missdata.Columns.Add("ErrorMsg");
            bool flag = true;
            if (flpLineItemExcInc.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flpLineItemExcInc.PostedFile.FileName));
                flpLineItemExcInc.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flpLineItemExcInc.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtPOH = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtPOH);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                        return;
                    }

                    if (dtPOH != null && dtPOH.Rows != null && dtPOH.Rows.Count > 0)
                    {
                        //gvProductMappingMissData.DataSource = null;
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtPOH.Rows)
                            {
                                String Employee = item["Employee"].ToString().Trim();
                                String Region = item["Region"].ToString().Trim();
                                String Distritutor = item["Distritutor"].ToString().Trim();
                                String SuperStockist = item["SuperStockist"].ToString().Trim();
                                String CustomerGroup = item["CustomerGroup"].ToString().Trim();
                                String Customer = item["Customer"].ToString().Trim();
                                String Division = item["Division"].ToString().Trim();
                                String ProductGroup = item["ProductGroup"].ToString().Trim();
                                String ProductSubGroup = item["ProductSubGroup"].ToString().Trim();
                                String ItemCode = item["ItemCode"].ToString().Trim();
                                String Master = item["Master"].ToString().Trim();
                                String QPS = item["QPS"].ToString().Trim();
                                String Machine = item["Machine"].ToString().Trim();
                                String Parlour = item["Parlour"].ToString().Trim();
                                //String FOW = item["FOW"].ToString().Trim();
                                //String SecFreight = item["SecFreight"].ToString().Trim();
                                //String VRS = item["VRS"].ToString().Trim();
                                //String RateDif = item["RateDif"].ToString().Trim();
                                //String IOU = item["IOU"].ToString().Trim();
                                String STOD = item["STOD"].ToString().Trim();
                                String FromDate = item["FromDate"].ToString().Trim();
                                String ToDate = item["ToDate"].ToString().Trim();
                                String IncExc = item["IncExc"].ToString().Trim();
                                String Active = item["Active"].ToString().Trim();


                                if (string.IsNullOrEmpty(Region) && string.IsNullOrEmpty(Employee) && string.IsNullOrEmpty(SuperStockist) && string.IsNullOrEmpty(Distritutor) && string.IsNullOrEmpty(CustomerGroup) && string.IsNullOrEmpty(Customer) && string.IsNullOrEmpty(Division)
                                    && string.IsNullOrEmpty(ProductGroup) && string.IsNullOrEmpty(ProductSubGroup) && string.IsNullOrEmpty(ItemCode) && string.IsNullOrEmpty(Master) && string.IsNullOrEmpty(QPS) && string.IsNullOrEmpty(Machine) && string.IsNullOrEmpty(Parlour)
                                    // && string.IsNullOrEmpty(FOW) && string.IsNullOrEmpty(SecFreight) && string.IsNullOrEmpty(VRS) && string.IsNullOrEmpty(RateDif) && string.IsNullOrEmpty(IOU) 
                                    && string.IsNullOrEmpty(STOD) && string.IsNullOrEmpty(FromDate) && string.IsNullOrEmpty(ToDate) && string.IsNullOrEmpty(IncExc) && string.IsNullOrEmpty(Active))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Employee"] = Employee;
                                    missdr["Region"] = Region;
                                    missdr["Distritutor"] = Distritutor;
                                    missdr["SuperStockist"] = SuperStockist;
                                    missdr["CustomerGroup"] = CustomerGroup;
                                    missdr["Customer"] = Customer;
                                    missdr["Division"] = Division;
                                    missdr["ProductGroup"] = ProductGroup;
                                    missdr["ProductSubGroup"] = ProductSubGroup;
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["Master"] = Master;
                                    missdr["QPS"] = QPS;
                                    missdr["Machine"] = Machine;
                                    missdr["Parlour"] = Parlour;
                                    //missdr["FOW"] = FOW;
                                    //missdr["SecFreight"] = SecFreight;
                                    //missdr["VRS"] = VRS;
                                    //missdr["RateDif"] = RateDif;
                                    //missdr["IOU"] = IOU;
                                    missdr["STOD"] = STOD;
                                    missdr["FromDate"] = FromDate;
                                    missdr["ToDate"] = ToDate;
                                    missdr["IncExc"] = IncExc;
                                    missdr["Active"] = Active;
                                    missdr["ErrorMsg"] = "Blank row found please remove blank row.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (!string.IsNullOrEmpty(Region))
                                {
                                    int RegionId = int.TryParse(item["Region"].ToString().Trim().Split('-').Last(), out RegionId) ? RegionId : 0;
                                    OCST ObjRegion = ctx.OCSTs.FirstOrDefault(x => x.StateID == RegionId);
                                    if (ObjRegion == null)
                                    {
                                        DataRow missdr = missdata.NewRow();

                                        missdr["Employee"] = Employee;
                                        missdr["Region"] = Region;
                                        missdr["Distritutor"] = Distritutor;
                                        missdr["SuperStockist"] = SuperStockist;
                                        missdr["CustomerGroup"] = CustomerGroup;
                                        missdr["Customer"] = Customer;
                                        missdr["Division"] = Division;
                                        missdr["ProductGroup"] = ProductGroup;
                                        missdr["ProductSubGroup"] = ProductSubGroup;
                                        missdr["ItemCode"] = ItemCode;
                                        missdr["Master"] = Master;
                                        missdr["QPS"] = QPS;
                                        missdr["Machine"] = Machine;
                                        missdr["Parlour"] = Parlour;
                                        //missdr["FOW"] = FOW;
                                        //missdr["SecFreight"] = SecFreight;
                                        //missdr["VRS"] = VRS;
                                        //missdr["RateDif"] = RateDif;
                                        //missdr["IOU"] = IOU;
                                        missdr["STOD"] = STOD;
                                        missdr["FromDate"] = FromDate;
                                        missdr["ToDate"] = ToDate;
                                        missdr["IncExc"] = IncExc;
                                        missdr["Active"] = Active;
                                        missdr["ErrorMsg"] = "Invalid Region.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else if (!string.IsNullOrEmpty(Employee))
                                {
                                    int EmployeeId = int.TryParse(item["Employee"].ToString().Trim().Split('#').Last(), out EmployeeId) ? EmployeeId : 0;
                                    OEMP objOEMP = ctx.OEMPs.FirstOrDefault(x => x.EmpID == EmployeeId);
                                    if (objOEMP == null)
                                    {
                                        DataRow missdr = missdata.NewRow();

                                        missdr["Employee"] = Employee;
                                        missdr["Region"] = Region;
                                        missdr["Distritutor"] = Distritutor;
                                        missdr["SuperStockist"] = SuperStockist;
                                        missdr["CustomerGroup"] = CustomerGroup;
                                        missdr["Customer"] = Customer;
                                        missdr["Division"] = Division;
                                        missdr["ProductGroup"] = ProductGroup;
                                        missdr["ProductSubGroup"] = ProductSubGroup;
                                        missdr["ItemCode"] = ItemCode;
                                        missdr["Master"] = Master;
                                        missdr["QPS"] = QPS;
                                        missdr["Machine"] = Machine;
                                        missdr["Parlour"] = Parlour;
                                        //missdr["FOW"] = FOW;
                                        //missdr["SecFreight"] = SecFreight;
                                        //missdr["VRS"] = VRS;
                                        //missdr["RateDif"] = RateDif;
                                        //missdr["IOU"] = IOU;
                                        missdr["STOD"] = STOD;
                                        missdr["FromDate"] = FromDate;
                                        missdr["ToDate"] = ToDate;
                                        missdr["IncExc"] = IncExc;
                                        missdr["Active"] = Active;
                                        missdr["ErrorMsg"] = "Invalid Employee.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }

                                }
                                else if (!string.IsNullOrEmpty(Distritutor))
                                {
                                    OCRD objDistId = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Distritutor && x.Type == 2);
                                    if (objDistId == null)
                                    {
                                        DataRow missdr = missdata.NewRow();

                                        missdr["Employee"] = Employee;
                                        missdr["Region"] = Region;
                                        missdr["Distritutor"] = Distritutor;
                                        missdr["SuperStockist"] = SuperStockist;
                                        missdr["CustomerGroup"] = CustomerGroup;
                                        missdr["Customer"] = Customer;
                                        missdr["Division"] = Division;
                                        missdr["ProductGroup"] = ProductGroup;
                                        missdr["ProductSubGroup"] = ProductSubGroup;
                                        missdr["ItemCode"] = ItemCode;
                                        missdr["Master"] = Master;
                                        missdr["QPS"] = QPS;
                                        missdr["Machine"] = Machine;
                                        missdr["Parlour"] = Parlour;
                                        //missdr["FOW"] = FOW;
                                        //missdr["SecFreight"] = SecFreight;
                                        //missdr["VRS"] = VRS;
                                        //missdr["RateDif"] = RateDif;
                                        //missdr["IOU"] = IOU;
                                        missdr["STOD"] = STOD;
                                        missdr["FromDate"] = FromDate;
                                        missdr["ToDate"] = ToDate;
                                        missdr["IncExc"] = IncExc;
                                        missdr["Active"] = Active;
                                        missdr["ErrorMsg"] = "Invalid Distributor.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else if (!string.IsNullOrEmpty(SuperStockist))
                                {
                                    OCRD objSSID = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == SuperStockist && x.Type == 4);
                                    if (objSSID == null)
                                    {
                                        DataRow missdr = missdata.NewRow();

                                        missdr["Employee"] = Employee;
                                        missdr["Region"] = Region;
                                        missdr["Distritutor"] = Distritutor;
                                        missdr["SuperStockist"] = SuperStockist;
                                        missdr["CustomerGroup"] = CustomerGroup;
                                        missdr["Customer"] = Customer;
                                        missdr["Division"] = Division;
                                        missdr["ProductGroup"] = ProductGroup;
                                        missdr["ProductSubGroup"] = ProductSubGroup;
                                        missdr["ItemCode"] = ItemCode;
                                        missdr["Master"] = Master;
                                        missdr["QPS"] = QPS;
                                        missdr["Machine"] = Machine;
                                        missdr["Parlour"] = Parlour;
                                        //missdr["FOW"] = FOW;
                                        //missdr["SecFreight"] = SecFreight;
                                        //missdr["VRS"] = VRS;
                                        //missdr["RateDif"] = RateDif;
                                        //missdr["IOU"] = IOU;
                                        missdr["STOD"] = STOD;
                                        missdr["FromDate"] = FromDate;
                                        missdr["ToDate"] = ToDate;
                                        missdr["IncExc"] = IncExc;
                                        missdr["Active"] = Active;
                                        missdr["ErrorMsg"] = "Invalid Super Stockist.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else if (!string.IsNullOrEmpty(CustomerGroup))
                                {
                                    int CustomerGroupId = int.TryParse(item["CustomerGroup"].ToString().Trim().Split('#').Last(), out CustomerGroupId) ? CustomerGroupId : 0;
                                    CGRP objCustGrp = ctx.CGRPs.FirstOrDefault(x => x.CustGroupID == CustomerGroupId);
                                    if (objCustGrp == null)
                                    {
                                        DataRow missdr = missdata.NewRow();

                                        missdr["Employee"] = Employee;
                                        missdr["Region"] = Region;
                                        missdr["Distritutor"] = Distritutor;
                                        missdr["SuperStockist"] = SuperStockist;
                                        missdr["CustomerGroup"] = CustomerGroup;
                                        missdr["Customer"] = Customer;
                                        missdr["Division"] = Division;
                                        missdr["ProductGroup"] = ProductGroup;
                                        missdr["ProductSubGroup"] = ProductSubGroup;
                                        missdr["ItemCode"] = ItemCode;
                                        missdr["Master"] = Master;
                                        missdr["QPS"] = QPS;
                                        missdr["Machine"] = Machine;
                                        missdr["Parlour"] = Parlour;
                                        //missdr["FOW"] = FOW;
                                        //missdr["SecFreight"] = SecFreight;
                                        //missdr["VRS"] = VRS;
                                        //missdr["RateDif"] = RateDif;
                                        //missdr["IOU"] = IOU;
                                        missdr["STOD"] = STOD;
                                        missdr["FromDate"] = FromDate;
                                        missdr["ToDate"] = ToDate;
                                        missdr["IncExc"] = IncExc;
                                        missdr["Active"] = Active;
                                        missdr["ErrorMsg"] = "Invalid Customer Group.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else if (!string.IsNullOrEmpty(Customer))
                                {
                                    OCRD ObjCust = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Customer && x.Type == 3);
                                    if (ObjCust == null)
                                    {
                                        DataRow missdr = missdata.NewRow();

                                        missdr["Employee"] = Employee;
                                        missdr["Region"] = Region;
                                        missdr["Distritutor"] = Distritutor;
                                        missdr["SuperStockist"] = SuperStockist;
                                        missdr["CustomerGroup"] = CustomerGroup;
                                        missdr["Customer"] = Customer;
                                        missdr["Division"] = Division;
                                        missdr["ProductGroup"] = ProductGroup;
                                        missdr["ProductSubGroup"] = ProductSubGroup;
                                        missdr["ItemCode"] = ItemCode;
                                        missdr["Master"] = Master;
                                        missdr["QPS"] = QPS;
                                        missdr["Machine"] = Machine;
                                        missdr["Parlour"] = Parlour;
                                        //missdr["FOW"] = FOW;
                                        //missdr["SecFreight"] = SecFreight;
                                        //missdr["VRS"] = VRS;
                                        //missdr["RateDif"] = RateDif;
                                        //missdr["IOU"] = IOU;
                                        missdr["STOD"] = STOD;
                                        missdr["FromDate"] = FromDate;
                                        missdr["ToDate"] = ToDate;
                                        missdr["IncExc"] = IncExc;
                                        missdr["Active"] = Active;
                                        missdr["ErrorMsg"] = "Invalid Customer.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else if (!string.IsNullOrEmpty(Division))
                                {
                                    int DivisionId = int.TryParse(item["Division"].ToString().Trim().Split('#').Last(), out DivisionId) ? DivisionId : 0;
                                    ODIV objDivisionId = ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == DivisionId);
                                    if (objDivisionId == null)
                                    {
                                        DataRow missdr = missdata.NewRow();

                                        missdr["Employee"] = Employee;
                                        missdr["Region"] = Region;
                                        missdr["Distritutor"] = Distritutor;
                                        missdr["SuperStockist"] = SuperStockist;
                                        missdr["CustomerGroup"] = CustomerGroup;
                                        missdr["Customer"] = Customer;
                                        missdr["Division"] = Division;
                                        missdr["ProductGroup"] = ProductGroup;
                                        missdr["ProductSubGroup"] = ProductSubGroup;
                                        missdr["ItemCode"] = ItemCode;
                                        missdr["Master"] = Master;
                                        missdr["QPS"] = QPS;
                                        missdr["Machine"] = Machine;
                                        missdr["Parlour"] = Parlour;
                                        //missdr["FOW"] = FOW;
                                        //missdr["SecFreight"] = SecFreight;
                                        //missdr["VRS"] = VRS;
                                        //missdr["RateDif"] = RateDif;
                                        //missdr["IOU"] = IOU;
                                        missdr["STOD"] = STOD;
                                        missdr["FromDate"] = FromDate;
                                        missdr["ToDate"] = ToDate;
                                        missdr["IncExc"] = IncExc;
                                        missdr["Active"] = Active;
                                        missdr["ErrorMsg"] = "Invalid Customer.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else if (!string.IsNullOrEmpty(ProductGroup))
                                {
                                    int ProductGroupId = int.TryParse(item["ProductGroup"].ToString().Trim().Split('#').Last(), out ProductGroupId) ? ProductGroupId : 0;
                                    OITB objProductGroupId = ctx.OITBs.FirstOrDefault(x => x.ItemGroupID == ProductGroupId);
                                    if (objProductGroupId == null)
                                    {
                                        DataRow missdr = missdata.NewRow();

                                        missdr["Employee"] = Employee;
                                        missdr["Region"] = Region;
                                        missdr["Distritutor"] = Distritutor;
                                        missdr["SuperStockist"] = SuperStockist;
                                        missdr["CustomerGroup"] = CustomerGroup;
                                        missdr["Customer"] = Customer;
                                        missdr["Division"] = Division;
                                        missdr["ProductGroup"] = ProductGroup;
                                        missdr["ProductSubGroup"] = ProductSubGroup;
                                        missdr["ItemCode"] = ItemCode;
                                        missdr["Master"] = Master;
                                        missdr["QPS"] = QPS;
                                        missdr["Machine"] = Machine;
                                        missdr["Parlour"] = Parlour;
                                        //missdr["FOW"] = FOW;
                                        //missdr["SecFreight"] = SecFreight;
                                        //missdr["VRS"] = VRS;
                                        //missdr["RateDif"] = RateDif;
                                        //missdr["IOU"] = IOU;
                                        missdr["STOD"] = STOD;
                                        missdr["FromDate"] = FromDate;
                                        missdr["ToDate"] = ToDate;
                                        missdr["IncExc"] = IncExc;
                                        missdr["Active"] = Active;
                                        missdr["ErrorMsg"] = "Invalid Product Group.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else if (!string.IsNullOrEmpty(ProductSubGroup))
                                {
                                    int ProdSubGroupId = int.TryParse(item["ProductSubGroup"].ToString().Trim().Split('#').Last(), out ProdSubGroupId) ? ProdSubGroupId : 0;
                                    OITG objProdSubGroupId = ctx.OITGs.FirstOrDefault(x => x.ItemSubGroupID == ProdSubGroupId);
                                    if (objProdSubGroupId == null)
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Employee"] = Employee;
                                        missdr["Region"] = Region;
                                        missdr["Distritutor"] = Distritutor;
                                        missdr["SuperStockist"] = SuperStockist;
                                        missdr["CustomerGroup"] = CustomerGroup;
                                        missdr["Customer"] = Customer;
                                        missdr["Division"] = Division;
                                        missdr["ProductGroup"] = ProductGroup;
                                        missdr["ProductSubGroup"] = ProductSubGroup;
                                        missdr["ItemCode"] = ItemCode;
                                        missdr["Master"] = Master;
                                        missdr["QPS"] = QPS;
                                        missdr["Machine"] = Machine;
                                        missdr["Parlour"] = Parlour;
                                        //missdr["FOW"] = FOW;
                                        //missdr["SecFreight"] = SecFreight;
                                        //missdr["VRS"] = VRS;
                                        //missdr["RateDif"] = RateDif;
                                        //missdr["IOU"] = IOU;
                                        missdr["STOD"] = STOD;
                                        missdr["FromDate"] = FromDate;
                                        missdr["ToDate"] = ToDate;
                                        missdr["IncExc"] = IncExc;
                                        missdr["Active"] = Active;
                                        missdr["ErrorMsg"] = "Invalid Product Sub-Group.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;

                                    }
                                }
                                else if (!string.IsNullOrEmpty(ItemCode))
                                {
                                    OITM ObjItm = ctx.OITMs.FirstOrDefault(x => x.ItemCode == ItemCode);
                                    if (ObjItm == null)
                                    {
                                        DataRow missdr = missdata.NewRow();

                                        missdr["Employee"] = Employee;
                                        missdr["Region"] = Region;
                                        missdr["Distritutor"] = Distritutor;
                                        missdr["SuperStockist"] = SuperStockist;
                                        missdr["CustomerGroup"] = CustomerGroup;
                                        missdr["Customer"] = Customer;
                                        missdr["Division"] = Division;
                                        missdr["ProductGroup"] = ProductGroup;
                                        missdr["ProductSubGroup"] = ProductSubGroup;
                                        missdr["ItemCode"] = ItemCode;
                                        missdr["Master"] = Master;
                                        missdr["QPS"] = QPS;
                                        missdr["Machine"] = Machine;
                                        missdr["Parlour"] = Parlour;
                                        //missdr["FOW"] = FOW;
                                        //missdr["SecFreight"] = SecFreight;
                                        //missdr["VRS"] = VRS;
                                        //missdr["RateDif"] = RateDif;
                                        //missdr["IOU"] = IOU;
                                        missdr["STOD"] = STOD;
                                        missdr["FromDate"] = FromDate;
                                        missdr["ToDate"] = ToDate;
                                        missdr["IncExc"] = IncExc;
                                        missdr["Active"] = Active;
                                        missdr["ErrorMsg"] = "Invalid Product-Code.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                            }
                            if (flag)
                            {
                                try
                                {
                                    if (ODTIEs == null)
                                        ODTIEs = new List<ODTIE>();

                                    foreach (DataRow item in dtPOH.Rows)
                                    {

                                        int RegionId = int.TryParse(item["Region"].ToString().Trim().Split('-').Last(), out RegionId) ? RegionId : 0;
                                        int EmployeeId = int.TryParse(item["Employee"].ToString().Trim().Split('#').Last(), out EmployeeId) ? EmployeeId : 0;
                                        String SuperStockist = item["SuperStockist"].ToString().Trim();
                                        String Distritutor = item["Distritutor"].ToString().Trim();
                                        int CustomerGroupId = int.TryParse(item["CustomerGroup"].ToString().Trim().Split('#').Last(), out CustomerGroupId) ? CustomerGroupId : 0;
                                        String Customer = item["Customer"].ToString().Trim();
                                        int DivisionId = int.TryParse(item["Division"].ToString().Trim().Split('#').Last(), out DivisionId) ? DivisionId : 0;
                                        int ProductGroupId = int.TryParse(item["ProductGroup"].ToString().Trim().Split('#').Last(), out ProductGroupId) ? ProductGroupId : 0;
                                        int ProdSubGroupId = int.TryParse(item["ProductSubGroup"].ToString().Trim().Split('#').Last(), out ProdSubGroupId) ? ProdSubGroupId : 0;
                                        String ItemCode = item["ItemCode"].ToString().Trim();
                                        bool Master = Boolean.TryParse(item["Master"].ToString().Trim(), out Master) ? Master : false;
                                        bool QPS = Boolean.TryParse(item["QPS"].ToString().Trim(), out QPS) ? QPS : false;
                                        bool Machine = Boolean.TryParse(item["Machine"].ToString().Trim(), out Machine) ? Machine : false;
                                        bool Parlour = Boolean.TryParse(item["Parlour"].ToString().Trim(), out Parlour) ? Parlour : false;

                                        // Temp Hide This is use for Cliam process
                                        // bool FOW = Boolean.TryParse(item["FOW"].ToString().Trim(), out FOW) ? FOW : false;
                                        //   bool SecFreight = Boolean.TryParse(item["SecFreight"].ToString().Trim(), out SecFreight) ? SecFreight : false;
                                        //   bool VRS = Boolean.TryParse(item["VRS"].ToString().Trim(), out VRS) ? VRS : false;
                                        //   bool RateDif = Boolean.TryParse(item["RateDif"].ToString().Trim(), out RateDif) ? RateDif : false;
                                        //   bool IOU = Boolean.TryParse(item["IOU"].ToString().Trim(), out IOU) ? IOU : false;
                                        bool STOD = Boolean.TryParse(item["STOD"].ToString().Trim(), out STOD) ? STOD : false;
                                        String FromDate = item["FromDate"].ToString().Trim();
                                        String ToDate = item["ToDate"].ToString().Trim();
                                        bool IncExc = Boolean.TryParse(item["IncExc"].ToString().Trim(), out IncExc) ? IncExc : false;
                                        bool Active = Boolean.TryParse(item["Active"].ToString().Trim(), out Active) ? Active : false;
                                        int EmpId = 0, CustGroupId = 0, DivId = 0, ProdGrpId = 0, ItemId = 0, ProdSubGrp = 0;
                                        // int CustGroupId = 0;
                                        Decimal DistId = 0, SSID = 0, CustId = 0;
                                        if (RegionId != 0)
                                        {
                                            OCST ObjRegion = ctx.OCSTs.FirstOrDefault(x => x.StateID == RegionId);
                                            if (ObjRegion != null)
                                                RegionId = ObjRegion.StateID;
                                        }
                                        if (EmployeeId != 0)
                                        {
                                            OEMP objOEMP = ctx.OEMPs.FirstOrDefault(x => x.EmpID == EmployeeId);
                                            if (objOEMP != null)
                                                EmployeeId = objOEMP.EmpID;
                                        }
                                        if (!string.IsNullOrEmpty(Distritutor))
                                        {
                                            OCRD objDistId = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Distritutor && x.Type == 2);
                                            if (objDistId != null)
                                                DistId = objDistId.CustomerID;
                                        }
                                        if (!string.IsNullOrEmpty(SuperStockist))
                                        {
                                            OCRD objSSID = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == SuperStockist && x.Type == 4);
                                            if (objSSID != null)
                                                SSID = objSSID.CustomerID;
                                        }
                                        if (CustomerGroupId != 0)
                                        {
                                            CGRP objCustGrp = ctx.CGRPs.FirstOrDefault(x => x.CustGroupID == CustomerGroupId);
                                            if (objCustGrp != null)
                                                CustGroupId = objCustGrp.CustGroupID;
                                        }
                                        if (!string.IsNullOrEmpty(Customer))
                                        {
                                            OCRD ObjCust = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Customer && x.Type == 3);
                                            if (ObjCust != null)
                                                CustId = ObjCust.CustomerID;
                                        }
                                        if (DivisionId != 0)
                                        {
                                            ODIV objDivisionId = ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == DivisionId);
                                            if (objDivisionId != null)
                                                DivId = objDivisionId.DivisionlID;
                                        }
                                        if (ProductGroupId != 0)
                                        {
                                            OITB objProductGroupId = ctx.OITBs.FirstOrDefault(x => x.ItemGroupID == ProductGroupId);
                                            if (objProductGroupId != null)
                                                ProdGrpId = objProductGroupId.ItemGroupID;
                                        }
                                        if (ProdSubGroupId != 0)
                                        {
                                            OITG objProdSubGroupId = ctx.OITGs.FirstOrDefault(x => x.ItemSubGroupID == ProdSubGroupId);
                                            if (objProdSubGroupId != null)
                                                ProdSubGrp = objProdSubGroupId.ItemSubGroupID;
                                        }
                                        if (!string.IsNullOrEmpty(ItemCode))
                                        {
                                            OITM ObjItm = ctx.OITMs.FirstOrDefault(x => x.ItemCode == ItemCode);
                                            if (ObjItm != null)
                                                ItemId = ObjItm.ItemID;
                                        }
                                        int UserID = Convert.ToInt32(Session["UserID"]);
                                        ODTIE objODTIE = new ODTIE();
                                        objODTIE.OptionId = Convert.ToInt16(ddlOption.SelectedValue);
                                        //objODTIE.EmpId = EmployeeId;
                                        //objODTIE.RegionId = RegionId;
                                        //objODTIE.DistributorId = DistId;
                                        //if (objODTIE.OptionId == 1)
                                        //{
                                        //    objODTIE.SSId = 0;
                                        //    objODTIE.CustomerId = CustId;
                                        //}
                                        //else
                                        //{
                                        //    objODTIE.SSId = SSID;
                                        //    objODTIE.CustomerId = 0;
                                        //}
                                        //objODTIE.CustGroupId = CustGroupId;
                                        //objODTIE.Division = DivId;
                                        //objODTIE.ProductGroupId = ProdGrpId;
                                        //objODTIE.ProductSubGroupId = ProdSubGrp;
                                        //objODTIE.ItemId = ItemId;
                                        //objODTIE.MasterSchm = Master;
                                        //objODTIE.QPS = QPS;
                                        //objODTIE.Machine = Machine;
                                        //objODTIE.Parlour = Parlour;
                                        ////objODTIE.FOW = FOW;
                                        ////objODTIE.SecFright = SecFreight;
                                        ////objODTIE.VRS = VRS;
                                        ////objODTIE.RateDiff = RateDif;
                                        ////objODTIE.IOU = IOU;
                                        //objODTIE.STOD = STOD;
                                        //objODTIE.FromDate = Convert.ToDateTime(FromDate);
                                        //objODTIE.ToDate = Convert.ToDateTime(ToDate);
                                        //objODTIE.IsInclude = IncExc;
                                        objODTIE.Active = Active;
                                        objODTIE.CreatedBy = UserID;
                                        objODTIE.CreatedDate = DateTime.Now;
                                        objODTIE.UpdateBy = UserID;
                                        objODTIE.UpdatedDate = DateTime.Now;
                                        objODTIE.Deleted = false;
                                        ctx.ODTIEs.Add(objODTIE);
                                    }
                                    ctx.SaveChanges();
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('file uploaded successfully!',1);", true);
                                    //   gvProductMappingMissData.Visible = false;
                                }
                                catch (DbEntityValidationException ex)
                                {
                                    var error = ex.EntityValidationErrors.First().ValidationErrors.First();
                                    if (error != null)
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + error.ErrorMessage.Replace("'", "") + "',2);", true);
                                    else
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                                    return;
                                }
                            }
                            else
                            {
                                if (missdata.Rows.Count > 0)
                                {
                                    Response.Clear();
                                    Response.Buffer = true;
                                    Response.ClearContent();
                                    IDataReader reader = missdata.CreateDataReader();
                                    StringWriter writer = new StringWriter();
                                    writer.WriteLine("Created On ," + "'" + DateTime.Now);

                                    do
                                    {
                                        writer.WriteLine(string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetName).ToList()));
                                        int count = 0;
                                        while (reader.Read())
                                        {
                                            writer.WriteLine(string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetValue).ToList()));
                                            if (++count % 100 == 0)
                                            {
                                                writer.Flush();
                                            }
                                        }
                                    }
                                    while (reader.NextResult());

                                    Response.AddHeader("content-disposition", "attachment; filename=DistributorExcludeFileUploadStatus_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
                                    Response.ContentType = "application/txt";
                                    Response.Write(writer.ToString());
                                    Response.Flush();
                                    Response.End();
                                    // ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('file uploaded successfully!',1);", true);
                                }
                                // gvProductMappingMissData.Visible = true;
                                // gvProductMappingMissData.DataSource = missdata;
                                // gvProductMappingMissData.DataBind();
                            }
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }
    #endregion


}