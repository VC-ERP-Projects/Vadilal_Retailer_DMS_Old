using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_ItemGroupImageMaster : System.Web.UI.Page
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
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

   
    public static List<ClaimLevelEntrySearch> SearchRegion(string prefixText)
     {
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        decimal ParentID = 1000010000000000;
        Int32 UserID = 1;
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetItemGroupMaster";
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
    public static String LoadData()
    {
        string jsonstring = "";
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetDistItemGroupCompanyMappingData";

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            jsonstring = JsonConvert.SerializeObject(ds.Tables[0]);
        }
        return jsonstring;
    }


    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputUnitMapping)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var ClaimLevelEntry = JsonConvert.DeserializeObject<dynamic>(hidJsonInputUnitMapping.ToString());
                string directoryPath = HttpContext.Current.Server.MapPath("~/Images/ItemGroupImage");
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
                    IGIMG ObjScanType = new IGIMG();
                    int CompanyMappingId = int.TryParse(Convert.ToString(item["CompanyMappingId"]), out CompanyMappingId) ? CompanyMappingId : 0;

                    int RegionId = int.TryParse(Convert.ToString(item["RegionId"]), out RegionId) ? RegionId : 0;       
                    String CompanyLogo = Convert.ToString(item["CompanyLogo"]);
                    String FileName = Convert.ToString(item["ImgName"]);
                    string FinalFileName = FileName.Split('.')[0].ToString();
                    //string imageName = RegionId.ToString() + "_"+ ".jpg";
                    string imageName = FinalFileName+".jpg";

                    //set the image path
                    string imgPath = Path.Combine(directoryPath, imageName);
                    if (CompanyMappingId > 0 && Convert.ToString(item["IsChange"]) == "1")
                    {
                        var ObjOERM = ctx.IGIMGs.Where(x => x.ItemGroupMappingID == CompanyMappingId).First();                        
                        ObjOERM.ItemGroupID = RegionId;
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


                        ObjScanType.ItemGroupID = RegionId;
                        
                        ObjScanType.Logo = imageName;
                        ObjScanType.ImageBase64 = CompanyLogo;
                        ObjScanType.UpdateBy = UserID;
                        ObjScanType.UpdateDatetime = DateTime.Now;
                        ctx.IGIMGs.Add(ObjScanType);
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
}