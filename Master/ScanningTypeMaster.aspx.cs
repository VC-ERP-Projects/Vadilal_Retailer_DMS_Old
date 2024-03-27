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

public partial class Master_ScanningTypeMaster : System.Web.UI.Page
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
    public class ScanningTypeValidate
    {
        public int OSTMID { get; set; }

        public int ModuleId { get; set; }
        public int ScanningAtId { get; set; }

        public int EmpGroupId { get; set; }
        public int EmpId { get; set; }
        public Boolean ManualKeypadEntry { get; set; }
        public Boolean CameraScanning { get; set; }
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

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            // ClearAllInputs();
        }
    }

    #endregion

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
    public static List<dynamic> LoadData(int ModuleId, int ScanningId)
    {
        List<dynamic> result = new List<dynamic>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetScanningTypeData";
        Cm.Parameters.AddWithValue("@ModuleId", ModuleId);
        Cm.Parameters.AddWithValue("@ScanningATId", ScanningId);
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            List<ScanningTypeValidate> ScanningTypeData = ds.Tables[0].AsEnumerable().Select
             (x => new ScanningTypeValidate
             {
                 OSTMID = x.Field<int>("OSTMID"),
                 EmpGroupId = x.Field<int>("EmpGroupId"),
                 EmpId = x.Field<int>("EmpId"),
                 ManualKeypadEntry = x.Field<bool>("ManualKeyPadEntry"),
                 CameraScanning = x.Field<bool>("CameraScanning"),
                 Both = x.Field<bool>("Both"),
                 IsActive = x.Field<bool>("IsActive"),
                 CreatedDate = x.Field<string>("CreatedDate"),
                 CreatedBy = x.Field<string>("CreatedBy"),
                 UpdatedDate = x.Field<string>("UpdatedDate"),
                 UpdatedBy = x.Field<string>("UpdatedBy"),
                 EmpName = x.Field<String>("EmpName"),
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


    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputScanningType, int ModuleId, int ScanningId, int IsAnyRowDeleted, string DeletedIDs)
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
                    ctx.OSTMs.Where(x => IDs.Any(y => y == x.OSTMID)).ToList().ForEach(x => { x.IsDeleted = true; x.UpdatedBy = UserID; x.IsActive = false; x.UpdatedDate = DateTime.Now; });
                    ctx.SaveChanges();
                }

                foreach (var item in CustomerListData)
                {
                    OSTM ObjScanType = new OSTM();
                    int ScanningTypeId = int.TryParse(Convert.ToString(item["ScanningTypeId"]), out ScanningTypeId) ? ScanningTypeId : 0;
                    //int ScanModuleId = int.TryParse(Convert.ToString(item["ModuleId"]), out ModuleId) ? ModuleId : 0;
                    //int ScanningatId = int.TryParse(Convert.ToString(item["ScanningId"]), out ScanningId) ? ScanningId : 0;
                    int EmpGroupId = int.TryParse(Convert.ToString(item["EmpGroupId"]), out EmpGroupId) ? EmpGroupId : 0;
                    int EmpId = int.TryParse(Convert.ToString(item["EmpId"]), out EmpId) ? EmpId : 0;
                    bool Ischkmanual = Convert.ToBoolean(Convert.ToString(item["Ischkmanual"]));
                    bool IschkCamscanning = Convert.ToBoolean(Convert.ToString(item["IschkCamscanning"]));
                    bool IschkBoth = Convert.ToBoolean(Convert.ToString(item["IschkBoth"]));
                    bool IsActive = Convert.ToBoolean(Convert.ToString(item["IsActive"]));
                    string IPAddress = Convert.ToString(item["IPAddress"]);
                    Decimal CustomerId = Decimal.TryParse(Convert.ToString(item["CustomerId"]), out CustomerId) ? CustomerId : 0;
                    if (ScanningTypeId > 0 && Convert.ToString(item["IsChange"]) == "1")
                    {
                        var ObjOSTM = ctx.OSTMs.Where(x => x.OSTMID == ScanningTypeId).First();
                        ObjOSTM.EmpGroupId = EmpGroupId;
                        ObjOSTM.EmpId = EmpId;

                        ObjOSTM.Both = IschkBoth;
                        if (ObjOSTM.Both == true)
                        {
                            ObjOSTM.ManualKeyPadEntry = true;
                            ObjOSTM.CameraScanning = true;
                        }
                        else
                        {
                            ObjOSTM.ManualKeyPadEntry = Ischkmanual;
                            ObjOSTM.CameraScanning = IschkCamscanning;
                        }
                        ObjOSTM.IsActive = IsActive;
                        ObjOSTM.ModuleId = ModuleId;
                        ObjOSTM.ScanningATID = ScanningId;
                        ObjOSTM.CustomerId = CustomerId;
                        ObjOSTM.UpdatedBy = UserID;
                        ObjOSTM.UpdatedDate = DateTime.Now;
                        ctx.SaveChanges();
                    }
                    else if (ScanningTypeId > 0 && Convert.ToString(item["IsChange"]) == "0")
                    {
                    }
                    else
                    {
                        ObjScanType.EmpGroupId = EmpGroupId;
                        ObjScanType.EmpId = EmpId;
                        ObjScanType.CustomerId = CustomerId;
                        ObjScanType.Both = IschkBoth;
                        if (ObjScanType.Both == true)
                        {
                            ObjScanType.ManualKeyPadEntry = true;
                            ObjScanType.CameraScanning = true;
                        }
                        else
                        {
                            ObjScanType.ManualKeyPadEntry = Ischkmanual;
                            ObjScanType.CameraScanning = IschkCamscanning;
                        }
                        ObjScanType.IsActive = IsActive;
                        ObjScanType.ModuleId = ModuleId;
                        ObjScanType.ScanningATID = ScanningId;
                        ObjScanType.UpdatedBy = UserID;
                        ObjScanType.UpdatedDate = DateTime.Now;
                        ObjScanType.CreatedBy = UserID;
                        ObjScanType.CreatedDate = DateTime.Now;
                        ctx.OSTMs.Add(ObjScanType);
                    }
                }

                ctx.SaveChanges();
                return "SUCCESS=Scanning Type Added Successfully";
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is wrong: " + Common.GetString(ex);
        }
    }


    #endregion
}