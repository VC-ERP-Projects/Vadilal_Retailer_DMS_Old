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

public partial class Master_SchemeEligibility : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType, Index;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;
    protected String LogoURL;
    [Serializable]
    public class SchemeElgValidate
    {
        public int ScmELID { get; set; }
        public int? RegionId { get; set; }
        public decimal? DistID { get; set; }
        public decimal? DealerID { get; set; }
        public String RegionDesc { get; set; }
        public String DistDesc { get; set; }
        public String DealerDesc { get; set; }
        public int EligibleCnt { get; set; }
        public Boolean IsInclude { get; set; }
        public Boolean IsActive { get; set; }
        public Boolean IsDeleted { get; set; }
        public String CreatedDate { get; set; }
        public string CreatedBy { get; set; }
        public String UpdatedDate { get; set; }
        public string UpdatedBy { get; set; }
        public int QPSQty { get; set; }
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
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.OMNU.PageName == pagename && x.EmpGroupID == EGID && x.ParentID == ParentID);
                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(CustType == 1 ? Auth.OMNU.Company : CustType == 2 ? Auth.OMNU.CMS : CustType == 3 ? Auth.OMNU.DMS : CustType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
                    AuthType = Auth.AuthorizationType;

                    var UserType = Session["UserType"].ToString();
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
            //LoadData();
            //ClearAllInputs();

        }
    }

    #endregion

    #region AjaxMethods

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadData(int SchemeID, int OptionId)
    {
        List<dynamic> result = new List<dynamic>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetSchemeEligibilityData";
        Cm.Parameters.AddWithValue("@SchemeID", SchemeID);
        Cm.Parameters.AddWithValue("@OptionId", OptionId);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            List<SchemeElgValidate> CallData = ds.Tables[0].AsEnumerable().Select
             (x => new SchemeElgValidate
             {
                 ScmELID = x.Field<int>("SchemeEligibleID"),
                 RegionId = x.Field<int>("RegionID"),
                 DistID = x.Field<decimal>("DistID"),
                 DealerID = x.Field<decimal>("DealerID"),
                 RegionDesc = x.Field<String>("RegionDesc"),
                 DistDesc = x.Field<String>("DistDesc"),
                 DealerDesc = x.Field<String>("DealerDesc"),
                 EligibleCnt = x.Field<int>("EligibleCnt"),
                 IsInclude = x.Field<Boolean>("IsInclude"),
                 IsActive = x.Field<Boolean>("Active"),
                 IsDeleted = x.Field<Boolean>("IsDeleted"),
                 CreatedDate = x.Field<String>("CreatedDate"),
                 CreatedBy = x.Field<String>("CreatedBy"),
                 UpdatedDate = x.Field<String>("UpdatedDate"),
                 UpdatedBy = x.Field<String>("UpdatedBy"),
                 QPSQty = x.Field<int>("QPSQty")
             }).ToList();
            result.Add(CallData);
        }
        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DicData> GetDistRegionCurrHierarchy(string prefixText)
    {
        List<DicData> result = new List<DicData>();

        try
        {
            List<string> items = new List<string>();
            prefixText = !string.IsNullOrEmpty(prefixText) ? prefixText : "*";
            int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetDistributorRegionCurrHierarchy";

            Cm.Parameters.AddWithValue("@UserID", UserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
            Cm.Parameters.AddWithValue("@Count", 0);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            return ds.Tables[0].AsEnumerable()
                        .Select(r => new DicData { Text = r.Field<string>("Data"), Value = 0 })
                        .ToList();
        }
        catch (Exception ex)
        {

        }

        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DicData> GetDistributorCurrHierarchy(string prefixText, string StateID)
    {
        List<DicData> result = new List<DicData>();

        try
        {
            List<string> items = new List<string>();
            prefixText = !string.IsNullOrEmpty(prefixText) ? prefixText : "*";

            int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetMasterDataForCurrHierarchyReports";

            Cm.Parameters.AddWithValue("@Type", "Distributor");
            Cm.Parameters.AddWithValue("@UserID", UserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
            Cm.Parameters.AddWithValue("@Count", 0);
            Cm.Parameters.AddWithValue("@StateID", StateID);
            Cm.Parameters.AddWithValue("@CityID", 0);
            Cm.Parameters.AddWithValue("@PlantID", 0);
            Cm.Parameters.AddWithValue("@SSID", 0);
            Cm.Parameters.AddWithValue("@DistID", 0);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            return ds.Tables[0].AsEnumerable()
                        .Select(r => new DicData { Text = r.Field<string>("Data"), Value = 0 })
                        .ToList();
        }
        catch (Exception ex)
        {

        }

        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DicData> GetDealerCurrHierarchy(string prefixText, string StateID, string DistID)
    {
        List<DicData> result = new List<DicData>();

        try
        {
            List<string> items = new List<string>();
            prefixText = !string.IsNullOrEmpty(prefixText) ? prefixText : "*";
            int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetMasterDataForCurrHierarchyReports";

            Cm.Parameters.AddWithValue("@Type", "Dealer");
            Cm.Parameters.AddWithValue("@UserID", UserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
            Cm.Parameters.AddWithValue("@Count", 0);
            Cm.Parameters.AddWithValue("@StateID", StateID);
            Cm.Parameters.AddWithValue("@CityID", 0);
            Cm.Parameters.AddWithValue("@PlantID", 0);
            Cm.Parameters.AddWithValue("@SSID", 0);
            Cm.Parameters.AddWithValue("@DistID", DistID);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            return ds.Tables[0].AsEnumerable()
                        .Select(r => new DicData { Text = r.Field<string>("Data"), Value = 0 })
                        .ToList();
        }
        catch (Exception ex)
        {

        }

        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DicData> LoadScheme(string prefixText, int OptionId)
    {
        List<DicData> result = new List<DicData>();
        try
        {
            prefixText = string.IsNullOrEmpty(prefixText) ? "*" : prefixText;
            //if (OptionId == 1)
            //{
            //    OptionId = 2;
            //}
            //else
            //{
            //    OptionId = 1;
            //}
            using (var ctx = new DDMSEntities())
            {
                if (prefixText == "*")
                {

                    result = (from c in ctx.OSCMs
                              where c.ApplicableMode == "S"
                              orderby c.SchemeID descending
                              select new DicData
                              {
                                  Value = c.SchemeID,
                                  Text = SqlFunctions.StringConvert((double)c.SchemeID).Trim() + " - " + c.SchemeCode + " - " + c.SchemeName
                              //(c.ApplicableMode == "M" ? "Master" : c.ApplicableMode == "S" ? "QPS" : c.ApplicableMode == "D" ? "Machine Discount" : c.ApplicableMode == "P" ? "Parlour Discount" : c.ApplicableMode == "A" ? "S to D " : "") + " - " + SqlFunctions.StringConvert((double)c.SchemeID).Trim()
                              }).Take(40).ToList();

                    //result = (from c in ctx.OSCMs
                    //          join e in ctx.SCM4 on c.SchemeID equals e.SchemeID
                    //          where c.ApplicableMode == "S" && c.Active == true && e.BasedOn == OptionId
                    //          orderby c.SchemeID descending
                    //          select new DicData
                    //          {
                    //              Value = c.SchemeID,
                    //              Text = c.SchemeCode + " - " + c.SchemeName + " - " +
                    //          (c.ApplicableMode == "M" ? "Master" : c.ApplicableMode == "S" ? "QPS" : c.ApplicableMode == "D" ? "Machine Discount" : c.ApplicableMode == "P" ? "Parlour Discount" : c.ApplicableMode == "A" ? "S to D " : "") + " - " + SqlFunctions.StringConvert((double)c.SchemeID).Trim()
                    //          }).Take(40).ToList();
                    //result = result.GroupBy(x => x.Value).Select(y => y.First()).Distinct().ToList();
                }
                else
                {
                    result = (from c in ctx.OSCMs
                              where ((c.SchemeName.Contains(prefixText) || c.SchemeCode.Contains(prefixText) || (SqlFunctions.StringConvert((decimal)c.SchemeID).Contains(prefixText))) && c.ApplicableMode == "S")
                              orderby c.SchemeID descending
                              select new DicData
                              {
                                  Value = c.SchemeID,
                                  Text = SqlFunctions.StringConvert((double)c.SchemeID).Trim() +" - "+c.SchemeCode + " - " + c.SchemeName
                              // (c.ApplicableMode == "M" ? "Master" : c.ApplicableMode == "S" ? "QPS" : c.ApplicableMode == "D" ? "Machine Discount" : c.ApplicableMode == "P" ? "Parlour Discount" : c.ApplicableMode == "A" ? "S to D " : "") + " - " + SqlFunctions.StringConvert((double)c.SchemeID).Trim()
                              }).Take(40).ToList();

                    //result = (from c in ctx.OSCMs
                    //          join e in ctx.SCM4 on c.SchemeID equals e.SchemeID
                    //          where c.ApplicableMode == "S" && c.Active == true && e.BasedOn == OptionId
                    //          orderby c.SchemeID descending
                    //          select new DicData
                    //          {
                    //              Value = c.SchemeID,
                    //              Text = c.SchemeCode + " - " + c.SchemeName + " - " +
                    //          (c.ApplicableMode == "M" ? "Master" : c.ApplicableMode == "S" ? "QPS" : c.ApplicableMode == "D" ? "Machine Discount" : c.ApplicableMode == "P" ? "Parlour Discount" : c.ApplicableMode == "A" ? "S to D " : "") + " - " + SqlFunctions.StringConvert((double)c.SchemeID).Trim()
                    //          }).Take(40).ToList();
                    //result = result.GroupBy(x => x.Value).Select(y => y.First()).Distinct().ToList();

                }
            }
        }
        catch (Exception ex)
        {

        }
        return result;
    }

    #endregion

    #region Button Events

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadReport(string strIsHistory, string SchemeID, string OptionId)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            int QPSSchemeID = int.TryParse(SchemeID, out QPSSchemeID) ? QPSSchemeID : 0;
            int ScmOptionId = int.TryParse(OptionId, out ScmOptionId) ? ScmOptionId : 0;
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetSchemeEligibility";
            Cm.Parameters.AddWithValue("@IsHistory", strIsHistory.ToLower() == "true" ? "1" : "0");
            Cm.Parameters.AddWithValue("@SchemeID", QPSSchemeID);
            Cm.Parameters.AddWithValue("@OptionId", ScmOptionId);

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
    public static string SaveData(string hidJsonInputCustomer, int SchemeID, int IsAnyRowDeleted, int OptionId)
    {
        //List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int count = 0;
                if (SchemeID > 0)
                {
                    int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                    var CustomerListData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputCustomer.ToString());

                    ctx.OSCMELGs.Where(x => x.SchemeID == SchemeID && x.OptionId == OptionId).ToList().ForEach(x => { x.Active = false; x.IsDeleted = true; });

                    foreach (var item in CustomerListData)
                    {
                        int ScmELGID = int.TryParse(Convert.ToString(item["ScmELGID"]), out ScmELGID) ? ScmELGID : 0;
                        int DistRegionID = int.TryParse(Convert.ToString(item["DistRegionID"]), out DistRegionID) ? DistRegionID : 0;
                        Decimal DistID = Decimal.TryParse(Convert.ToString(item["DistID"]), out DistID) ? DistID : 0;
                        Decimal DealerID = Decimal.TryParse(Convert.ToString(item["DealerID"]), out DealerID) ? DealerID : 0;
                        bool IsActive = Convert.ToBoolean(Convert.ToString(item["IsActive"]));
                        int EligibleCnt = int.TryParse(Convert.ToString(item["EligibleCount"]), out EligibleCnt) ? EligibleCnt : 0;
                        int QPSQty = int.TryParse(Convert.ToString(item["QPSQty"]), out QPSQty) ? QPSQty : 0;
                        bool IsInclude = Convert.ToBoolean(Convert.ToString(item["IsInclExcl"]));
                        bool IsDeleted = Convert.ToBoolean(Convert.ToString(item["IsDeleted"]));
                        OCRD ObjCust;
                        if (DistRegionID > 0 || DistID > 0 || DealerID > 0)
                        {
                            if (DistRegionID > 0)
                            {
                                var Result = ctx.OSCMELGs.FirstOrDefault(x =>   x.SchemeID == SchemeID && x.OptionId != OptionId && x.IsInclude == IsInclude && x.RegionID == DistRegionID && x.Active);
                                if (Result != null)
                                {
                                    OCST ObjState = ctx.OCSTs.Where(x => x.StateID == DistRegionID).FirstOrDefault();
                                    return "WARNING=" + ObjState.GSTStateCode + " - " + ObjState.StateName + " Region already exists in another option";
                                }
                            }
                            if (DistID > 0)
                            {
                                var Result = ctx.OSCMELGs.FirstOrDefault(x =>  x.SchemeID == SchemeID && x.OptionId != OptionId && x.IsInclude == IsInclude  && x.DistID == DistID && x.Active);
                                if (Result != null)
                                {
                                    ObjCust = ctx.OCRDs.Where(x => x.CustomerID == DistID && x.Type == 2).FirstOrDefault();
                                    return "WARNING=" + ObjCust.CustomerCode + " - " + ObjCust.CustomerName + " - Distributor already exists in another option";
                                }
                            }
                            if (DealerID > 0)
                            {
                                var Result = ctx.OSCMELGs.FirstOrDefault(x =>  x.SchemeID == SchemeID && x.OptionId != OptionId && x.IsInclude == IsInclude && x.DealerID == DealerID && x.Active);
                                if (Result != null)
                                {
                                    ObjCust = ctx.OCRDs.Where(x => x.CustomerID == DealerID && x.Type == 3).FirstOrDefault();
                                    return "WARNING=" + ObjCust.CustomerCode + " - " + ObjCust.CustomerName + " - Dealer already exists in another option";
                                }
                            }
                            count++;
                            OSCMELG objOSCMELG = ctx.OSCMELGs.FirstOrDefault(x => x.SchemeEligibleID == ScmELGID && x.OptionId == OptionId);

                            if (objOSCMELG == null && Convert.ToString(item["IsChange"]) == "1")
                            {
                                objOSCMELG = new OSCMELG()
                                {
                                    CreatedBy = UserID,
                                    CreatedDate = DateTime.Now
                                };
                                ctx.OSCMELGs.Add(objOSCMELG);
                            }

                            if (DistRegionID > 0)
                            {
                                objOSCMELG.RegionID = DistRegionID;
                            }
                            else
                                objOSCMELG.RegionID = null;

                            if (DistID > 0)
                            {
                                objOSCMELG.DistID = DistID;
                            }
                            else
                                objOSCMELG.DistID = null;

                            if (DealerID > 0)
                            {
                                objOSCMELG.DealerID = DealerID;
                            }
                            else
                                objOSCMELG.DealerID = null;

                            objOSCMELG.SchemeID = SchemeID;
                            objOSCMELG.Active = IsActive;
                            objOSCMELG.IsInclude = IsInclude;
                            objOSCMELG.IsDeleted = IsDeleted;
                            objOSCMELG.EligibleCnt = EligibleCnt;
                            objOSCMELG.OptionId = OptionId;
                            objOSCMELG.QPSQty = QPSQty;
                            if (Convert.ToString(item["IsChange"]) == "1")
                            {
                                objOSCMELG.UpdatedBy = UserID;
                                objOSCMELG.UpdatedDate = DateTime.Now;
                            }
                        }
                    }
                    if (count == 0 && IsAnyRowDeleted == 0)
                    {
                        return "WARNING=Please enter atleast one record";
                    }
                    ctx.SaveChanges();
                    return "SUCCESS=Scheme eligibility Added Successfully";
                }
                else
                {
                    return "ERROR=Please select proper scheme";
                }
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is wrong: " + Common.GetString(ex);
        }
    }
    #endregion
}