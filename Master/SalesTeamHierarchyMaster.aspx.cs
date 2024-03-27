using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Text;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using System.Data.Objects.SqlClient;
using System.Threading;
using System.Data.SqlClient;
using Newtonsoft.Json;
using System.Configuration;
using System.Data.Entity.Validation;
using System.Data.Objects;

public partial class Master_SalesTeamHierarchyMaster : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType, Index;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;
    protected String LogoURL;
    public class ScanningTypeEmpGroup
    {
        public string Text { get; set; }
        public decimal Value { get; set; }
    }
    [Serializable]
    public class SalesTeamHierarchyValidate
    {
        public int OSTHMID { get; set; }
        public int EmpGroupId { get; set; }
        public int EmpId { get; set; }
        public string Region { get; set; }
        public int RegionId { get; set; }
        public Boolean Mobile { get; set; }
        public Boolean Email { get; set; }
        public Boolean Both { get; set; }
        public bool IsActive { get; set; }
        public string CreatedDate { get; set; }
        public string CreatedBy { get; set; }
        public string UpdatedDate { get; set; }
        public string UpdatedBy { get; set; }
        public string EmpName { get; set; }
        public string EmpGroupName { get; set; }
        public string CustomerName { get; set; }
        public Decimal CustomerId { get; set; }
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

    //private void ClearAllInputs()
    //{
    //    gvMissdata.DataSource = null;
    //    gvMissdata.DataBind();
    //    gvMissdata.Style.Add("display", "none");
    //}

    #endregion
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            // ClearAllInputs();
        }
    }

    #region AjaxMethods

    [WebMethod]
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<ScanningTypeEmpGroup> SearchEmployeeGroup(string prefixText)
    {
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            List<ScanningTypeEmpGroup> StrCust = new List<ScanningTypeEmpGroup>();
            if (prefixText == "*")
            {
                // StrCust = ctx.OGRPs.Where(x => x.ParentID == ParentID).OrderBy(x => x.EmpGroupName).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc).Take(20).ToList();
                StrCust = (from c in ctx.OGRPs.Where(x => x.ParentID == ParentID).OrderBy(x => x.EmpGroupName)
                           select new ScanningTypeEmpGroup
                           {
                               Text = (c.EmpGroupName + " # " + c.EmpGroupDesc + " # " + SqlFunctions.StringConvert((double)c.EmpGroupID).Trim()),
                               Value = c.EmpGroupID
                           }).Take(20).ToList();
            }
            else
            {
                //StrCust = ctx.OGRPs.Where(x => x.EmpGroupName.Contains(prefixText) && x.ParentID == ParentID).OrderBy(x => x.EmpGroupName).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc).Take(20).ToList();
                StrCust = (from c in ctx.OGRPs.Where(x => x.EmpGroupName.Contains(prefixText) && x.ParentID == ParentID).OrderBy(x => x.EmpGroupName)
                           select new ScanningTypeEmpGroup
                           {
                               Text = (c.EmpGroupName + " # " + c.EmpGroupDesc + " # " + SqlFunctions.StringConvert((double)c.EmpGroupID).Trim()),
                               Value = c.EmpGroupID
                           }).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod]
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<ScanningTypeEmpGroup> SearchEmployee(string prefixText, string strEmpGroupId)
    {
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            Int32 EmpId = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            OEMP ObjEmp = ctx.OEMPs.Where(x => x.EmpID == EmpId).FirstOrDefault();
            int EmpGroupId = Int32.TryParse(strEmpGroupId, out EmpGroupId) && EmpGroupId > 0 ? EmpGroupId : 0;
            List<ScanningTypeEmpGroup> StrCust = new List<ScanningTypeEmpGroup>();
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OEMPs.Where(x => x.ParentID == ParentID && (EmpGroupId == 0 || x.EmpGroupID == EmpGroupId)).OrderBy(x => x.Name)
                           select new ScanningTypeEmpGroup
                           {
                               Text = (c.EmpCode + " - " + c.Name + " - " + SqlFunctions.StringConvert((double)c.EmpID).Trim()),
                               Value = c.EmpID
                           }).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OEMPs.Where(x => (x.UserName.Contains(prefixText) || x.EmpCode.Contains(prefixText) || x.Name.Contains(prefixText)) && x.ParentID == ParentID && (EmpGroupId == 0 || x.EmpGroupID == EmpGroupId)).OrderBy(x => x.Name)
                           select new ScanningTypeEmpGroup
                           {
                               Text = (c.EmpCode + " - " + c.Name + " - " + SqlFunctions.StringConvert((double)c.EmpID).Trim()).Trim(),
                               Value = c.EmpID
                           }).Take(20).ToList();
            }

            return StrCust;
        }
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadData()
    {
        List<dynamic> result = new List<dynamic>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetSalesTeamHierarchyMasterData";
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            List<SalesTeamHierarchyValidate> ScanningTypeData = ds.Tables[0].AsEnumerable().Select
             (x => new SalesTeamHierarchyValidate
             {
                 OSTHMID = x.Field<int>("OSTHMID"),
                 EmpGroupId = x.Field<int>("EmpGroupId"),
                 EmpId = x.Field<int>("EmpId"),
                 Mobile = x.Field<bool>("Mobile"),
                 Email = x.Field<bool>("Email"),
                 Both = x.Field<bool>("Both"),
                 IsActive = x.Field<bool>("IsActive"),
                 CreatedDate = x.Field<string>("CreatedDate"),
                 CreatedBy = x.Field<string>("CreatedBy"),
                 UpdatedDate = x.Field<string>("UpdatedDate"),
                 UpdatedBy = x.Field<string>("UpdatedBy"),
                 EmpName = x.Field<String>("EmpName"),
                 RegionId = x.Field<int>("RegionId"),
                 Region = x.Field<string>("Region"),
                 EmpGroupName = x.Field<String>("EmpGroupName"),
                 CustomerName = x.Field<String>("CustomerName"),
                 CustomerId = x.Field<Decimal>("CustomerId")

             }).ToList();
            result.Add(ScanningTypeData);
        }
        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public static List<DicData> SearchCustomer(string prefixText, string strEmpGroupId, string strEmpId)
    {
        List<DicData> dicData = new List<DicData>();
        List<ScanningTypeEmpGroup> StrCust = new List<ScanningTypeEmpGroup>();
        using (var ctx = new DDMSEntities())
        {
            Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            //int Type = Convert.ToInt32(contextKey);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            int EmpGroupId = Int32.TryParse(strEmpGroupId, out EmpGroupId) && EmpGroupId > 0 ? EmpGroupId : 0;
            int SUserID = Int32.TryParse(strEmpId, out SUserID) && SUserID > 0 ? SUserID : 0;

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetCustomerDataForCurrHierarchy";

            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
            Cm.Parameters.AddWithValue("@Count", 0);
            Cm.Parameters.AddWithValue("@EmpGroupId", EmpGroupId);
            Cm.Parameters.AddWithValue("@EmpId", UserID);


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


    #region Button Events
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadReport(string strIsHistory, int ModuleId, int ScanningAtId)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetScanningTypeReport";
            Cm.Parameters.AddWithValue("@IsHistory", strIsHistory.ToLower() == "true" ? "1" : "0");
            Cm.Parameters.AddWithValue("@ModuleId", ModuleId);
            Cm.Parameters.AddWithValue("@ScanningAtId", ScanningAtId);

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

    [WebMethod]
    public static List<ScanningTypeEmpGroup> SearchRegion(string prefixText)
    {
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
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
        List<ScanningTypeEmpGroup> ObjList = new List<ScanningTypeEmpGroup>();
        if (ds.Tables[0].Rows.Count > 0)
        {
            for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                ScanningTypeEmpGroup Obj = new ScanningTypeEmpGroup();
                Obj.Text = ds.Tables[0].Rows[i]["Data"].ToString();
                Obj.Value = 0;
                ObjList.Add(Obj);
            }
        }
        return ObjList;
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputScanningType, int IsAnyRowDeleted, string DeletedIDs)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var CustomerListData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputScanningType.ToString());
               


                if (!string.IsNullOrEmpty(DeletedIDs))
                {
                    List<string> isDeletedIds = DeletedIDs.Trim().Split(",".ToArray()).ToList();
                    List<int> IDs = new List<int>();
                    foreach (var item in isDeletedIds)
                    {
                        int Id = Int32.TryParse(item, out Id) ? Id : 0;
                        IDs.Add(Id);
                    }
                    ctx.OSTHMs.Where(x => IDs.Any(y => y == x.OSTHMID)).ToList().ForEach(x => { x.IsDeleted = true; x.UpdatedBy = UserID; x.IsActive = false; x.UpdatedDate = DateTime.Now; });
                    ctx.SaveChanges();
                }

                foreach (var item in CustomerListData)
                {
                    OSTHM ObjScanType = new OSTHM();
                    int SalesTeamHierarchyTypeId = int.TryParse(Convert.ToString(item["SalesTeamHierarchyTypeId"]), out SalesTeamHierarchyTypeId) ? SalesTeamHierarchyTypeId : 0;
                    //int ScanModuleId = int.TryParse(Convert.ToString(item["ModuleId"]), out ModuleId) ? ModuleId : 0;
                    //int ScanningatId = int.TryParse(Convert.ToString(item["ScanningId"]), out ScanningId) ? ScanningId : 0;
                    int RegionId = int.TryParse(Convert.ToString(item["RegionId"]), out RegionId) ? RegionId : 0;
                    int EmpGroupId = int.TryParse(Convert.ToString(item["EmpGroupId"]), out EmpGroupId) ? EmpGroupId : 0;
                    int EmpId = int.TryParse(Convert.ToString(item["EmpId"]), out EmpId) ? EmpId : 0;
                    bool IsMobile = Convert.ToBoolean(Convert.ToString(item["IschkMobile"]));

                    //if (IsMobile == false)
                    //{
                    //    return "ERROR=Something is wrong: ";
                    //}
                    bool IsEmail = Convert.ToBoolean(Convert.ToString(item["IschkEmail"]));
                    bool IschkBoth = Convert.ToBoolean(Convert.ToString(item["IschkBoth"]));
                    bool IsActive = Convert.ToBoolean(Convert.ToString(item["IsActive"]));
                    string IPAddress = Convert.ToString(item["IPAddress"]);
                    Decimal CustomerId = Decimal.TryParse(Convert.ToString(item["CustomerId"]), out CustomerId) ? CustomerId : 0;

                   
                    if (SalesTeamHierarchyTypeId > 0 && Convert.ToString(item["IsChange"]) == "1")
                    {
                        var ObjOSTHM = ctx.OSTHMs.Where(x => x.OSTHMID == SalesTeamHierarchyTypeId).First();
                        ObjOSTHM.EmpGroupId = EmpGroupId;
                        ObjOSTHM.EmpId = EmpId;
                        ObjOSTHM.RegionId = RegionId;

                        ObjOSTHM.Both = IschkBoth;
                        if (ObjOSTHM.Both == true)
                        {
                            ObjOSTHM.Mobile = true;
                            ObjOSTHM.Email = true;
                        }
                        else
                        {
                            ObjOSTHM.Mobile = IsMobile;
                            ObjOSTHM.Email = IsEmail;
                        }
                        ObjOSTHM.IsActive = IsActive;
                        ObjOSTHM.CustomerId = CustomerId;
                        ObjOSTHM.UpdatedBy = UserID;
                        ObjOSTHM.UpdatedDate = DateTime.Now;
                        ctx.SaveChanges();
                    }
                    else if (SalesTeamHierarchyTypeId > 0 && Convert.ToString(item["IsChange"]) == "0")
                    {
                    }
                    else
                    {
                        ObjScanType.EmpGroupId = EmpGroupId;
                        ObjScanType.EmpId = EmpId;
                        ObjScanType.RegionId = RegionId;
                        ObjScanType.CustomerId = CustomerId;
                        ObjScanType.Both = IschkBoth;
                        if (ObjScanType.Both == true)
                        {
                            ObjScanType.Mobile = true;
                            ObjScanType.Email = true;
                        }
                        else
                        {
                            ObjScanType.Mobile = IsMobile;
                            ObjScanType.Email = IsEmail;
                        }
                        ObjScanType.IsActive = IsActive;
                        ObjScanType.UpdatedBy = UserID;
                        ObjScanType.UpdatedDate = DateTime.Now;
                        ObjScanType.CreatedBy = UserID;
                        ObjScanType.CreatedDate = DateTime.Now;
                        ctx.OSTHMs.Add(ObjScanType);
                    }
                }

                ctx.SaveChanges();
                return "SUCCESS=SalesTeam Hierarchy Added Successfully";
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is wrong: " + Common.GetString(ex);
        }
    }


    #endregion
}