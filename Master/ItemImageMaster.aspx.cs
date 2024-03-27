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
        public string Value { get; set; }
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
        if (!IsPostBack)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Division = ctx.ODIVs.Where(x => x.Active).ToList();
                ddlDivision.DataSource = Division;
                ddlDivision.DataBind();
                //   ddlDivision.Items.Insert(0, new ListItem("---Select---", "0"));
            }
        }

    }

    #endregion

    #region AjaxMethods
    [WebMethod]
    public static List<ClaimLevelEntrySearch> SearchRegion(string prefixText , int DivisionId)
    {
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        //decimal ParentID = 1000010000000000;
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetItemMaster";
        //Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@DivisionId", DivisionId);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        List<ClaimLevelEntrySearch> ObjList = new List<ClaimLevelEntrySearch>();
        if (ds.Tables[0].Rows.Count > 0)
        {
            for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                ClaimLevelEntrySearch Obj = new ClaimLevelEntrySearch();
                Obj.Text = ds.Tables[0].Rows[i]["Data"].ToString();
                Obj.Value = ds.Tables[0].Rows[i]["Value"].ToString();
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
                Obj.Value = "0";
                ObjList.Add(Obj);
            }
        }
        return ObjList;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static String LoadData(int optionId , int Division)
    {
        string jsonstring = "";
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetItemMappingData";
        Cm.Parameters.AddWithValue("@DivisionId", Division);
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            jsonstring = JsonConvert.SerializeObject(ds.Tables[0]);
        }
        return jsonstring;
    }


    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputUnitMapping, int OptionId)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var ClaimLevelEntry = JsonConvert.DeserializeObject<dynamic>(hidJsonInputUnitMapping.ToString());
                string directoryPath = HttpContext.Current.Server.MapPath("~/Images/ItemIamges");
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
                    OITMIMG ObjScanType = new OITMIMG();
                    int CompanyMappingId = int.TryParse(Convert.ToString(item["CompanyMappingId"]), out CompanyMappingId) ? CompanyMappingId : 0;

                    int RegionId = int.TryParse(Convert.ToString(item["RegionId"]), out RegionId) ? RegionId : 0;
                    int CompanyId = int.TryParse(Convert.ToString(item["CompanyId"]), out CompanyId) ? CompanyId : 0;
                    String CompanyLogo = Convert.ToString(item["CompanyLogo"]);
                    //string imageName = RegionId.ToString() + "_" + ".jpg";
                    String FileName = Convert.ToString(item["ImgName"]);
                    string FinalFileName = FileName.Split('.')[0].ToString();
                    //string imageName = RegionId.ToString() + "_"+ ".jpg";
                    string imageName = FinalFileName + ".jpg";

                    //set the image path
                    string imgPath = Path.Combine(directoryPath, imageName);
                    if (CompanyMappingId > 0 && Convert.ToString(item["IsChange"]) == "1")
                    {
                        var ObjOERM = ctx.OITMIMGs.Where(x => x.ItemMappingID == CompanyMappingId).First();
                        ObjOERM.ItemID = RegionId;
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
                        ObjScanType.ItemMappingID = ctx.GetKey("OITMIMG", "ItemMappingID", "", 0, 0).FirstOrDefault().Value;
                        ObjScanType.ItemID = RegionId;
                        ObjScanType.Logo = imageName;
                        ObjScanType.ImageBase64 = CompanyLogo;
                        ObjScanType.UpdateBy = UserID;
                        ObjScanType.UpdateDatetime = DateTime.Now;
                        ctx.OITMIMGs.Add(ObjScanType);
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