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

public partial class Master_DistRemarkMaster : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType, Index;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;
    protected String LogoURL;
    public class ClaimLevelEntrySearch
    {
        public string Text { get; set; }
        public decimal Value { get; set; }
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
    public static List<DicData> SearchDistributor(string prefixText, string strEmpId, string strRegionId)
    {
        List<DicData> dicData = new List<DicData>();
        using (var ctx = new DDMSEntities())
        {
            //decimal ParentID = 1000010000000000;
            //Int32 UserID = 1;
            Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            //int Type = Convert.ToInt32(contextKey);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            int SUserID = Int32.TryParse(strEmpId, out SUserID) && SUserID > 0 ? SUserID : 0;
            int RegionId = Int32.TryParse(strRegionId, out RegionId) && RegionId > 0 ? RegionId : 0;

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetDealerForRemark";
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
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
    public static String LoadData()
    {
        string jsonstring = "";
        decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetDistRemarkEntryData";
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            jsonstring = JsonConvert.SerializeObject(ds.Tables[0]);
        }
        return jsonstring;
    }


    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputUnitMapping, int IsAnyRowDeleted, string DeletedIDs)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
               // int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var ClaimLevelEntry = JsonConvert.DeserializeObject<dynamic>(hidJsonInputUnitMapping.ToString());
                decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
                if (!string.IsNullOrEmpty(DeletedIDs))
                {
                    List<string> isDeletedIds = DeletedIDs.Trim().Split(",".ToArray()).ToList();
                    List<int> IDs = new List<int>();
                    foreach (var item in isDeletedIds)
                    {
                        int Id = Int32.TryParse(item, out Id) ? Id : 0;
                        IDs.Add(Id);
                    }
                    ctx.ODRMs.Where(x => IDs.Any(y => y == x.RemarksId)).ToList().ForEach(x => { x.Deleted = true; x.UpdatedBy = ParentID; x.Active = false; x.UpdatedDate = DateTime.Now; });
                    ctx.SaveChanges();
                }
                
                foreach (var item in ClaimLevelEntry)
                {
                    ODRM ObjScanType = new ODRM();
                    int OCLEID = int.TryParse(Convert.ToString(item["OCLEID"]), out OCLEID) ? OCLEID : 0;
                    Decimal CustomerId = Decimal.TryParse(Convert.ToString(item["DistId"]), out CustomerId) ? CustomerId : 0;
                    string Remarks1 = Convert.ToString(item["Remarks1"]);
                    string Remarks2 = Convert.ToString(item["Remarks2"]);
                    DateTime FromDate = Convert.ToDateTime(Convert.ToString(item["FromDate"]));
                    DateTime ToDate = Convert.ToDateTime(Convert.ToString(item["ToDate"]));
                    bool IsActive = true; //Convert.ToBoolean(Convert.ToString(item["Active"]));
                    bool IsHeirachy = true; //Convert.ToBoolean(Convert.ToString(item["IsHeirachy"]));

                    if (OCLEID > 0 && Convert.ToString(item["IsChange"]) == "1")
                    {
                        var ObjOERM = ctx.ODRMs.Where(x => x.RemarksId == OCLEID).First();
                        //if (ObjOERM.FromDate != FromDate)
                        //{
                        //    return "ERROR=you can't change from date";
                        //}
                        if (ObjOERM.ToDate != ToDate)
                        {
                            if (ObjOERM.ToDate < ToDate)
                            {
                                return "ERROR=you can't select to date grater than previous date";
                            }
                            if (ToDate <= DateTime.Now)
                            {
                                return "ERROR=you can't select to date less or equal to today date";
                            }
                        }

                        ObjOERM.Remarks1 = Remarks1;
                        ObjOERM.Remarks2 = Remarks2;
                        ObjOERM.DealerId = CustomerId;
                        ObjOERM.FromDate = FromDate;
                        ObjOERM.ToDate = ToDate;
                        ObjOERM.Active = IsActive;
                        ObjOERM.Include = IsHeirachy;
                        ObjScanType.Deleted = false;
                        ObjOERM.UpdatedBy = ParentID;
                        ObjOERM.UpdatedDate = DateTime.Now;
                        ctx.SaveChanges();
                    }
                    else if (OCLEID > 0 && Convert.ToString(item["IsChange"]) == "0")
                    {
                    }
                    else
                    {
                        ObjScanType.Remarks1 = Remarks1;
                        ObjScanType.Remarks2 = Remarks2;
                        ObjScanType.DealerId= CustomerId;
                        ObjScanType.FromDate = FromDate;
                        ObjScanType.ToDate = ToDate;
                        ObjScanType.Active = IsActive;
                        ObjScanType.Include = IsHeirachy;
                        ObjScanType.Deleted = false;
                        ObjScanType.UpdatedBy = ParentID;
                        ObjScanType.UpdatedDate = DateTime.Now;
                        ObjScanType.CreatedBy = ParentID;
                        ObjScanType.CreatedDate = DateTime.Now;
                        ctx.ODRMs.Add(ObjScanType);
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
    public static List<dynamic> LoadReport(string strIsHistory)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetDistRemarksEntryReport";
            Cm.Parameters.AddWithValue("@IsHistory", strIsHistory.ToLower() == "true" ? "1" : "0");
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
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