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


public partial class Master_CompanyInvRemark : System.Web.UI.Page
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
    //[WebMethod]
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    //public static List<DicData> SearchSuperStockiest(string prefixText, string strEmpId, string strRegionId)
    //{
    //    List<DicData> dicData = new List<DicData>();
    //    //List<DiscountTypeSearch> StrCust = new List<DiscountTypeSearch>();
    //    using (var ctx = new DDMSEntities())
    //    {
    //        //decimal ParentID = 1000010000000000;
    //        //Int32 UserID = 1;
    //        Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
    //        //int Type = Convert.ToInt32(contextKey);
    //        decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
    //        //int EmpGroupId = Int32.TryParse(strEmpGroupId, out EmpGroupId) && EmpGroupId > 0 ? EmpGroupId : 0;
    //        int SUserID = Int32.TryParse(strEmpId, out SUserID) && SUserID > 0 ? SUserID : 0;
    //        int RegionId = Int32.TryParse(strRegionId, out RegionId) && RegionId > 0 ? RegionId : 0;
    //        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
    //        SqlCommand Cm = new SqlCommand();

    //        Cm.Parameters.Clear();
    //        Cm.CommandType = CommandType.StoredProcedure;
    //        Cm.CommandText = "GetSuperStockiestData";
    //        Cm.Parameters.AddWithValue("@SUserID", SUserID);
    //        Cm.Parameters.AddWithValue("@ParentID", ParentID);
    //        Cm.Parameters.AddWithValue("@Prefix", prefixText);
    //        Cm.Parameters.AddWithValue("@Count", 0);
    //        Cm.Parameters.AddWithValue("@EmpId", UserID);
    //        Cm.Parameters.AddWithValue("@RegionId", RegionId);
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
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DiscountTypeSearch> SearchEmployeeGroup(string prefixText)
    {
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            List<DiscountTypeSearch> StrCust = new List<DiscountTypeSearch>();
            if (prefixText == "*")
            {
                // StrCust = ctx.OGRPs.Where(x => x.ParentID == ParentID).OrderBy(x => x.EmpGroupName).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc).Take(20).ToList();
                StrCust = (from c in ctx.OGRPs.Where(x => x.ParentID == ParentID).OrderBy(x => x.EmpGroupName)
                           select new DiscountTypeSearch
                           {
                               Text = (c.EmpGroupName + " # " + c.EmpGroupDesc + " # " + SqlFunctions.StringConvert((double)c.EmpGroupID).Trim()),
                               Value = c.EmpGroupID
                           }).Take(20).ToList();
            }
            else
            {
                //StrCust = ctx.OGRPs.Where(x => x.EmpGroupName.Contains(prefixText) && x.ParentID == ParentID).OrderBy(x => x.EmpGroupName).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc).Take(20).ToList();
                StrCust = (from c in ctx.OGRPs.Where(x => x.EmpGroupName.Contains(prefixText) && x.ParentID == ParentID).OrderBy(x => x.EmpGroupName)
                           select new DiscountTypeSearch
                           {
                               Text = (c.EmpGroupName + " # " + c.EmpGroupDesc + " # " + SqlFunctions.StringConvert((double)c.EmpGroupID).Trim()),
                               Value = c.EmpGroupID
                           }).Take(20).ToList();
            }

            return StrCust;
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
    public static String LoadItemData(int OptionId)
    {
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        //JsonConvert.SerializeObject(ds.Tables[0]);
        string jsonstring = "";
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetEmpRemarksData";
        Cm.Parameters.AddWithValue("@OptionId", OptionId);
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            jsonstring = JsonConvert.SerializeObject(ds.Tables[0]);
        }
        return jsonstring;
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static String LoadEmployeeData(int OptionId)
    {
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        //JsonConvert.SerializeObject(ds.Tables[0]);
        string jsonstring = "";
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetEmployeeInvoiceRemarksData";
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
    public static string SaveItemData(string hidJsonInputClaim, int OptionId, int IsAnyRowDeleted, string DeletedIDs)
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
                    ctx.OEREMs.Where(x => IDs.Any(y => y == x.OERId)).ToList().ForEach(x => { x.Deleted = true; x.UpdatedBy = UserID; x.Active = false; x.UpdatedDate = DateTime.Now; });
                    ctx.SaveChanges();
                }

                foreach (var item in ClaimListData)
                {
                   // int itmRef = int.TryParse(Convert.ToString(item["RefNo"]), out itmRef) ? itmRef : 0;
                    //  string itmRef = Convert.ToString(item["RefNo"]);
                    //OEREM ODTIE = ctx.OEREMs.Where(x => x.Refid == itmRef).FirstOrDefault();
                    //if (ODTIE == null)
                    //{
                    //    return "ERROR= Please enter valid ref no. ";
                    //}

                    OEREM ObjClaim = new OEREM();
                    int DiscountExcId = int.TryParse(Convert.ToString(item["DiscountExcId"]), out DiscountExcId) ? DiscountExcId : 0;
                    int RefNo = int.TryParse(Convert.ToString(item["RefNo"]), out RefNo) ? RefNo : 0;
                    bool IsActive = Convert.ToBoolean(Convert.ToString(item["IsActive"]));
                    bool IsInclude = Convert.ToBoolean(Convert.ToString(item["IsInclude"]));
                    string Remarks1 = Convert.ToString(item["Remark1"]);
                    string Remarks2 = Convert.ToString(item["Remark2"]);
                    string Remarks3 = Convert.ToString(item["Remark3"]);
                    DateTime FromDate = Convert.ToDateTime(Convert.ToString(item["FromDate"]));
                    DateTime ToDate = Convert.ToDateTime(Convert.ToString(item["ToDate"]));
                    //  int EmployeeGroupId = int.TryParse(Convert.ToString(item["EmployeeGroupId"]), out EmployeeGroupId) ? EmployeeGroupId : 0;
                    string IPAddress = Convert.ToString(item["IPAddress"]);
                    if (DiscountExcId > 0 && Convert.ToString(item["IsChange"]) == "1")
                    {
                        var ObjOCLPM = ctx.OEREMs.Where(x => x.OERId == DiscountExcId).First();

                        ObjOCLPM.Refid = RefNo;
                        ObjOCLPM.Remarks1 = Remarks1;
                        ObjOCLPM.Remarks2 = Remarks2;
                        ObjOCLPM.Remarks3 = Remarks3;
                        ObjOCLPM.FromDate = FromDate;
                        ObjOCLPM.ToDate = ToDate;
                        ObjOCLPM.Active = IsActive;
                        ObjOCLPM.UpdatedBy = UserID;
                        ObjOCLPM.UpdatedDate = DateTime.Now;
                        ObjOCLPM.Deleted = false;

                        ctx.SaveChanges();
                    }
                    else if (DiscountExcId > 0 && Convert.ToString(item["IsChange"]) == "0")
                    {
                    }
                    else
                    {
                        ObjClaim.Refid = RefNo;

                        ObjClaim.Remarks1 = Remarks1;
                        ObjClaim.Remarks2 = Remarks2;
                        ObjClaim.Remarks3 = Remarks3;
                        ObjClaim.FromDate = FromDate;
                        ObjClaim.ToDate = ToDate;
                        ObjClaim.Active = IsActive;
                        ObjClaim.UpdatedBy = UserID;
                        ObjClaim.UpdatedDate = DateTime.Now;
                        ObjClaim.CreatedBy = UserID;
                        ObjClaim.CreatedDate = DateTime.Now;
                        ObjClaim.Deleted = false;
                        ctx.OEREMs.Add(ObjClaim);
                    }
                }

                ctx.SaveChanges();
                return "SUCCESS=Remarks Added Successfully";
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is wrong: " + Common.GetString(ex);
        }
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveEmpData(string hidJsonInputClaim, int OptionId, int IsAnyRowDeleted, string DeletedIDs)
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
                    ctx.OEIRMs.Where(x => IDs.Any(y => y == x.OEIRMId)).ToList().ForEach(x => { x.Deleted = true; x.UpdatedBy = UserID; x.Active = false; x.UpdatedDate = DateTime.Now; });
                    ctx.SaveChanges();
                }

                foreach (var item in ClaimListData)
                {
                    int itmRef = int.TryParse(Convert.ToString(item["RefNo"]), out itmRef) ? itmRef : 0;
                    //  string itmRef = Convert.ToString(item["RefNo"]);
                    OEREM ODTIE = ctx.OEREMs.Where(x => x.Refid == itmRef).FirstOrDefault();
                    if (ODTIE == null)
                    {
                        return "ERROR= Please enter valid ref no. ";
                    }

                    OEIRM ObjClaim = new OEIRM();
                    int DiscountExcId = int.TryParse(Convert.ToString(item["DiscountExcId"]), out DiscountExcId) ? DiscountExcId : 0;
                    int EmpId = int.TryParse(Convert.ToString(item["EmpId"]), out EmpId) ? EmpId : 0;
                    int RgnId = int.TryParse(Convert.ToString(item["RegionId"]), out RgnId) ? RgnId : 0;
                    Decimal DistId = Decimal.TryParse(Convert.ToString(item["DistId"]), out DistId) ? DistId : 0;
                   // Decimal SSId = Decimal.TryParse(Convert.ToString(item["SSId"]), out SSId) ? SSId : 0;
                    int CustGroupId = int.TryParse(Convert.ToString(item["CustGroupId"]), out CustGroupId) ? CustGroupId : 0;
                    //String RefNo = Convert.ToString(item["RefNo"]);
                    int RefNo = int.TryParse(Convert.ToString(item["RefNo"]), out RefNo) ? RefNo : 0;
                    Decimal CustId = Decimal.TryParse(Convert.ToString(item["CustId"]), out CustId) ? CustId : 0;
                    
                    bool IsActive = Convert.ToBoolean(Convert.ToString(item["IsActive"]));
                    bool IsInclude = Convert.ToBoolean(Convert.ToString(item["IsInclude"]));
                    DateTime FromDate = Convert.ToDateTime(Convert.ToString(item["FromDate"]));
                    DateTime ToDate = Convert.ToDateTime(Convert.ToString(item["ToDate"]));
                    int EmployeeGroupId = int.TryParse(Convert.ToString(item["EmployeeGroupId"]), out EmployeeGroupId) ? EmployeeGroupId : 0;
                    string IPAddress = Convert.ToString(item["IPAddress"]);
                    if (DiscountExcId > 0 && Convert.ToString(item["IsChange"]) == "1")
                    {
                        var ObjOCLPM = ctx.OEIRMs.Where(x => x.OEIRMId == DiscountExcId).First();
                        ObjOCLPM.OptionId = OptionId;
                        ObjOCLPM.RefNo = RefNo;
                        ObjOCLPM.RegionId = RgnId;
                        ObjOCLPM.EmpId = EmpId;
                        ObjOCLPM.DistributorId = DistId;
                        ObjOCLPM.SSID = 0;
                        ObjOCLPM.CustGroupId = CustGroupId;
                        ObjOCLPM.CustomerId = CustId;
                        ObjOCLPM.Active = IsActive;
                        ObjOCLPM.IncExc = IsInclude;
                        ObjOCLPM.FromDate = FromDate;
                        ObjOCLPM.ToDate = ToDate;
                        ObjOCLPM.UpdatedBy = UserID;
                        ObjOCLPM.UpdatedDate = DateTime.Now;
                        ObjOCLPM.Deleted = false;
                        ObjOCLPM.EmpGroupId = EmployeeGroupId;
                        ctx.SaveChanges();
                    }
                    else if (DiscountExcId > 0 && Convert.ToString(item["IsChange"]) == "0")
                    {
                    }
                    else
                    {
                        ObjClaim.OptionId = OptionId;
                        ObjClaim.RefNo = RefNo;
                        ObjClaim.RegionId = RgnId;
                        ObjClaim.EmpId = EmpId;
                        ObjClaim.DistributorId = DistId;
                        ObjClaim.SSID = 0;
                        ObjClaim.CustGroupId = CustGroupId;
                        ObjClaim.CustomerId = CustId;
                        ObjClaim.Active = IsActive;
                        ObjClaim.IncExc = IsInclude;
                        ObjClaim.FromDate = FromDate;
                        ObjClaim.ToDate = ToDate;
                        ObjClaim.UpdatedBy = UserID;
                        ObjClaim.UpdatedDate = DateTime.Now;
                        ObjClaim.CreatedBy = UserID;
                        ObjClaim.CreatedDate = DateTime.Now;
                        ObjClaim.Deleted = false;
                        ObjClaim.EmpGroupId = EmployeeGroupId;
                        ctx.OEIRMs.Add(ObjClaim);
                    }
                }

                ctx.SaveChanges();
                return "SUCCESS=Remarks Employee Data Added Successfully";
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is wrong: " + Common.GetString(ex);
        }
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string RefNoValidate(string RefNo, int OptionId)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int GRefNo = int.TryParse(Convert.ToString(RefNo), out GRefNo) ? GRefNo : 0;
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                ODTIE ODTIE = ctx.ODTIEs.Where(x => x.RefNo == GRefNo && x.OptionId == OptionId).FirstOrDefault();
                if (ODTIE == null)
                {
                    return "SUCCESS=0";
                }
                return "SUCCESS=1";
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is wrong: " + Common.GetString(ex);
        }
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DicData> SearchGroupRefNo(string prefixText)
    {

        List<DicData> dicData = new List<DicData>();
        using (var ctx = new DDMSEntities())
        {
            Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetGroupRefNo";
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
    #endregion
}