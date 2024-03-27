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

public partial class Master_EmpReasonCode : System.Web.UI.Page
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
    public class EmpReasonCodeRegion
    {
        public string Text { get; set; }
        public Int16 Value { get; set; }
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
    public static List<EmpReasonCodeRegion> SearchRegion(string prefixText)
    {
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        decimal ParentID = 1000010000000000;
        Int32 UserID = 1;
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetIndianState";
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", 1);
        Cm.Parameters.AddWithValue("@CountryId", 1);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        List<EmpReasonCodeRegion> ObjList = new List<EmpReasonCodeRegion>();
        if (ds.Tables[0].Rows.Count > 0)
        {
            for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                EmpReasonCodeRegion Obj = new EmpReasonCodeRegion();
                Obj.Text = ds.Tables[0].Rows[i]["Data"].ToString();
                Obj.Value = Convert.ToInt16(ds.Tables[0].Rows[i]["StateID"].ToString());
                ObjList.Add(Obj);
            }
        }
        return ObjList;
    }

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
    public static List<dynamic> SearchReason(string prefixText)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            List<string> items = new List<string>();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (prefixText == "*")
                {
                    items = (from c in ctx.ORSNs
                             where c.Active && c.Type == "S"
                             select c.ReasonName + " # " +  SqlFunctions.StringConvert((double)c.ReasonID).Trim()).Distinct().ToList();
                }
                else
                {
                    items = (from c in ctx.ORSNs
                             where c.Active && c.Type == "S" && (c.ReasonName.Contains(prefixText) || c.ReasonDesc.Contains(prefixText))
                             select c.ReasonName + " # " + SqlFunctions.StringConvert((double)c.ReasonID).Trim()).Distinct().ToList();
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
    public static String LoadData(int ddlOptionId)
    {
        string jsonstring = "";
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetEmployeeReasonData";
        Cm.Parameters.AddWithValue("@OptionId", ddlOptionId);
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            jsonstring = JsonConvert.SerializeObject(ds.Tables[0]);
        }
        return jsonstring;
    }


    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputScanningType, int IsAnyRowDeleted, string DeletedIDs,int OptionId)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var EmpReasonData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputScanningType.ToString());

                if (!string.IsNullOrEmpty(DeletedIDs))
                {
                    List<string> isDeletedIds = DeletedIDs.Trim().Split(",".ToArray()).ToList();
                    List<int> IDs = new List<int>();
                    foreach (var item in isDeletedIds)
                    {
                        int Id = Int32.TryParse(item, out Id) ? Id : 0;
                        IDs.Add(Id);
                    }
                    ctx.OERMs.Where(x => IDs.Any(y => y == x.OERMId)).ToList().ForEach(x => { x.IsDeleted = true; x.UpdatedBy = UserID; x.Active = false; x.UpdatedDate = DateTime.Now; });
                    ctx.SaveChanges();
                }

                foreach (var item in EmpReasonData)
                {
                    OERM ObjScanType = new OERM();
                    int OERMId = int.TryParse(Convert.ToString(item["OERMId"]), out OERMId) ? OERMId : 0;
                    int ReasonId = int.TryParse(Convert.ToString(item["ReasonId"]), out ReasonId) ? ReasonId : 0;
                    int EmpId = int.TryParse(Convert.ToString(item["EmpId"]), out EmpId) ? EmpId : 0;
                    int SubEmpId = int.TryParse(Convert.ToString(item["SubEmpId"]), out SubEmpId) ? SubEmpId : 0;
                    int FwdEmpId = int.TryParse(Convert.ToString(item["FwdEmpId"]), out FwdEmpId) ? FwdEmpId : 0;
                    int RegionId = int.TryParse(Convert.ToString(item["RegionId"]), out RegionId) ? RegionId : 0;
                    bool IsActive = Convert.ToBoolean(Convert.ToString(item["Active"]));

                    if (OERMId > 0 && Convert.ToString(item["IsChange"]) == "1")
                    {
                        var ObjOERM = ctx.OERMs.Where(x => x.OERMId == OERMId).First();
                        ObjOERM.ReasonId = ReasonId;
                        ObjOERM.OptionId = OptionId;
                        ObjOERM.EmpId = EmpId;
                        ObjOERM.SubEmpId = SubEmpId;
                        ObjOERM.FwdToEmpId = FwdEmpId;
                        ObjOERM.RegionId = RegionId;
                        ObjOERM.Active = IsActive;
                        ObjScanType.IsDeleted = false;                        
                        ObjOERM.UpdatedBy = UserID;
                        ObjOERM.UpdatedDate = DateTime.Now;
                        ctx.SaveChanges();
                    }
                    else if (OERMId > 0 && Convert.ToString(item["IsChange"]) == "0")
                    {
                    }
                    else
                    {
                        ObjScanType.ReasonId = ReasonId;
                        ObjScanType.OptionId = OptionId;
                        ObjScanType.EmpId = EmpId;
                        ObjScanType.SubEmpId = SubEmpId;
                        ObjScanType.FwdToEmpId = FwdEmpId;
                        ObjScanType.RegionId = RegionId;
                        ObjScanType.Active = IsActive;
                        ObjScanType.IsDeleted = false;
                        ObjScanType.UpdatedBy = UserID;
                        ObjScanType.UpdatedDate = DateTime.Now;
                        ObjScanType.CreatedBy = UserID;
                        ObjScanType.CreatedDate = DateTime.Now;
                        ctx.OERMs.Add(ObjScanType);
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

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadReport(string strIsHistory,int ddlOptionId)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetSEmployeeReasonReport";
            Cm.Parameters.AddWithValue("@IsHistory", strIsHistory.ToLower() == "true" ? "1" : "0");
            Cm.Parameters.AddWithValue("@OptionId", ddlOptionId);

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