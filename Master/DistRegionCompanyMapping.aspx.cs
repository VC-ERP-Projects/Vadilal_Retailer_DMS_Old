using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;
public partial class Master_DistRegionCompanyMapping : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType, Index;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;
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
    public static List<ClaimLevelEntrySearch> SearchRegion(string prefixText)
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
        List<ClaimLevelEntrySearch> ObjList = new List<ClaimLevelEntrySearch>();
        if (ds.Tables[0].Rows.Count > 0)
        {
            for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                ClaimLevelEntrySearch Obj = new ClaimLevelEntrySearch();
                Obj.Text = ds.Tables[0].Rows[i]["Data"].ToString();
                Obj.Value = 0;
                ObjList.Add(Obj);
            }
        }
        return ObjList;
    }

    [WebMethod]
    public static List<ClaimLevelEntrySearch> SearchSalesOrg(string prefixText)
    {
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetSalesOrganization";
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        List<ClaimLevelEntrySearch> ObjList = new List<ClaimLevelEntrySearch>();
        if (ds.Tables[0].Rows.Count > 0)
        {
            for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                ClaimLevelEntrySearch Obj = new ClaimLevelEntrySearch();
                Obj.Text = ds.Tables[0].Rows[i]["Data"].ToString();
                Obj.Value = 0;
                ObjList.Add(Obj);
            }
        }
        return ObjList;
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
        Cm.CommandText = "GetDistRegionCompanyMappingData";
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
    public static string SaveData(string hidJsonInputUnitMapping,  int OptionId)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var ClaimLevelEntry = JsonConvert.DeserializeObject<dynamic>(hidJsonInputUnitMapping.ToString());
                string directoryPath = HttpContext.Current.Server.MapPath("~/Images/CompanyLogo");
                try
                {
                    if (!Directory.Exists(directoryPath))
                    {
                        Directory.CreateDirectory(directoryPath);
                    }
                }
                catch (Exception ex)
                {
                    return ex.Message.ToString();
                }
                foreach (var item in ClaimLevelEntry)
                {
                    ODCM ObjScanType = new ODCM();
                    int CompanyMappingId = int.TryParse(Convert.ToString(item["CompanyMappingId"]), out CompanyMappingId) ? CompanyMappingId : 0;
                  
                    int RegionId = int.TryParse(Convert.ToString(item["RegionId"]), out RegionId) ? RegionId : 0;
                    int CompanyId = int.TryParse(Convert.ToString(item["CompanyId"]), out CompanyId) ? CompanyId : 0;
                    String CompanyLogo = Convert.ToString(item["CompanyLogo"]);
                    string imageName = RegionId.ToString() + "_" + OptionId + ".jpg";

                    //set the image path
                    string imgPath = Path.Combine(directoryPath, imageName);
                    if (CompanyMappingId > 0 && Convert.ToString(item["IsChange"]) == "1")
                    {
                        var ObjOERM = ctx.ODCMs.Where(x => x.CompanyMappingId == CompanyMappingId).First();
                        ObjOERM.OptionId = OptionId;
                        ObjOERM.RegionId = RegionId;
                        ObjOERM.SalesOrgId = CompanyId;
                        ObjOERM.Logo = imageName;
                        ObjOERM.ImageBase64 = CompanyLogo;
                        ObjOERM.UpdateBy = UserID;
                        ObjOERM.UpdateDatetime = DateTime.Now;
                        byte[] imageBytes = Convert.FromBase64String(CompanyLogo.Split(',')[1].ToString());
                        File.WriteAllBytes(imgPath, imageBytes);
                        ctx.SaveChanges();
                    }
                    else if (CompanyMappingId > 0 && Convert.ToString(item["IsChange"]) == "0")
                    {
                    }
                    else
                    {
                        byte[] imageBytes = Convert.FromBase64String(CompanyLogo.Split(',')[1].ToString());

                        File.WriteAllBytes(imgPath, imageBytes);

                        ObjScanType.OptionId = OptionId;
                        ObjScanType.RegionId = RegionId;
                        ObjScanType.SalesOrgId = CompanyId;
                        ObjScanType.Logo = imageName;
                        ObjScanType.ImageBase64 = CompanyLogo;
                        ObjScanType.UpdateBy = UserID;
                        ObjScanType.UpdateDatetime = DateTime.Now;
                        ctx.ODCMs.Add(ObjScanType);
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
        //try
        //{

        //    Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        //    SqlCommand Cm = new SqlCommand();

        //    Cm.Parameters.Clear();
        //    Cm.CommandType = CommandType.StoredProcedure;
        //    Cm.CommandText = "GetClaimLevelEntryReport";
        //    Cm.Parameters.AddWithValue("@OptionId", optionId);
        //    Cm.Parameters.AddWithValue("@IsHistory", strIsHistory.ToLower() == "true" ? "1" : "0");

        //    DataSet DS = objClass.CommonFunctionForSelect(Cm);

        //    DataTable dt;
        //    if (DS.Tables[0] != null && DS.Tables[0].Rows.Count > 0)
        //    {
        //        dt = DS.Tables[0];
        //        result.Add(JsonConvert.SerializeObject(dt));
        //    }
        //}
        //catch (Exception ex)
        //{
        //    result.Add("ERROR=" + "" + Common.GetString(ex));
        //}
        return result;
    }
    #endregion
}