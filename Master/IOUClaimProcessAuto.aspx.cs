using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

[Serializable]
public class IOUClaimProcess
{
    public int OIOUID { get; set; }
    public int? StateID { get; set; }
    public decimal? DistID { get; set; }
    public string DistDesc { get; set; }
    public string StateDesc { get; set; }
    public decimal? PerClaimAmt { get; set; }
    public decimal? PerPurchaseAmt { get; set; }
    public Boolean Active { get; set; }
    public Boolean IsDeleted { get; set; }
    public String CreatedDate { get; set; }
    public string CreatedBy { get; set; }
    public String UpdatedDate { get; set; }
    public string UpdatedBy { get; set; }
}

public partial class Master_IOUClaimProcessAuto : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType, Index;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;
    protected String LogoURL;
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

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            Load();
        }
    }

    #region Ajex Event
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
    #endregion

    #region Button Click Event

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadReport()
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();

                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "GetIOUClaimProcessAuto";
                DataSet DS = objClass.CommonFunctionForSelect(Cm);

                DataTable dt;
                if (DS.Tables[0] != null && DS.Tables[0].Rows.Count > 0)
                {
                    dt = DS.Tables[0];
                    result.Add(JsonConvert.SerializeObject(dt));
                }
                else
                {
                    result.Add("ERROR=No Data Found.");
                }
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
    public static List<dynamic> Load()
    {
        List<dynamic> result = new List<dynamic>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetIOUClaimProcessAutoLoadData";
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            List<IOUClaimProcess> CallData = ds.Tables[0].AsEnumerable().Select
             (x => new IOUClaimProcess
             {
                 OIOUID = x.Field<int>("OIOUID"),
                 StateID = x.Field<int>("StateID"),
                 DistID = x.Field<decimal>("CustomerID"),
                 DistDesc = x.Field<String>("DistDesc"),
                 StateDesc = x.Field<String>("StateDesc"),
                 PerClaimAmt = x.Field<decimal>("PerClaimAmt"),
                 PerPurchaseAmt = x.Field<decimal>("PerPurchaseAmt"),
                 Active = x.Field<Boolean>("Active"),
                 IsDeleted = x.Field<Boolean>("IsDeleted"),
                 CreatedDate = x.Field<String>("CreatedDate"),
                 CreatedBy = x.Field<String>("CreatedBy"),
                 UpdatedDate = x.Field<String>("UpdatedDate"),
                 UpdatedBy = x.Field<String>("UpdatedBy")
             }).ToList();

            result.Add(CallData);
        }
        return result;
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputCustomer, int IsAnyRowDeleted)
    {
        //List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int count = 0;

                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var CustomerListData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputCustomer.ToString());
                ctx.OIOUs.ToList().ForEach(x => { x.Active = false; x.IsDeleted = true; });

                foreach (var item in CustomerListData)
                {
                    int OIOUID = int.TryParse(Convert.ToString(item["OIOUID"]), out OIOUID) ? OIOUID : 0;
                    string Region = Convert.ToString(item["Region"]);
                    string Distributor = Convert.ToString(item["DistCode"]);
                    decimal ClaimAmount = Decimal.TryParse(Convert.ToString(item["ClaimAmount"]), out ClaimAmount) ? ClaimAmount : 0;
                    decimal ClaimPurchase = Decimal.TryParse(Convert.ToString(item["PurchaseAmount"]), out ClaimPurchase) ? ClaimPurchase : 0;
                    int RegionID = 0;
                    decimal DistID = 0;

                    if (!string.IsNullOrEmpty(Region.Split("-".ToArray()).Last().Trim()))
                        RegionID = Convert.ToInt32(Region.Split("-".ToArray()).Last().Trim());
                    if (!string.IsNullOrEmpty(Distributor.Split("-".ToArray()).Last().Trim()))
                        DistID = Convert.ToDecimal(Distributor.Split("-".ToArray()).Last().Trim());

                    if (RegionID > 0 || DistID > 0)
                    {
                        count++;

                        bool IsActive = Convert.ToBoolean(Convert.ToString(item["IsActive"]));
                        bool IsDeleted = Convert.ToBoolean(Convert.ToString(item["IsDeleted"]));


                        OIOU objOIOU = ctx.OIOUs.FirstOrDefault(x => x.OIOUID == OIOUID);
                        if (objOIOU == null && Convert.ToString(item["IsChange"]) == "1")
                        {
                            objOIOU = new OIOU()
                            {
                                CreatedBy = UserID,
                                CreatedDate = DateTime.Now
                            };
                            ctx.OIOUs.Add(objOIOU);
                        }
                        if (RegionID > 0)
                            objOIOU.StateID = RegionID;
                        else
                            objOIOU.StateID = null;

                        if (DistID > 0)
                            objOIOU.ParentID = DistID;
                        else
                            objOIOU.ParentID = null;

                        objOIOU.Active = IsActive;
                        objOIOU.IsDeleted = IsDeleted;
                        objOIOU.PerClaimAmt = ClaimAmount;
                        objOIOU.PerPurchaseAmt = ClaimPurchase;
                        if (Convert.ToString(item["IsChange"]) == "1")
                        {
                            objOIOU.UpdatedBy = UserID;
                            objOIOU.UpdatedDate = DateTime.Now;
                        }
                    }
                }
                if (count == 0 && IsAnyRowDeleted == 0)
                {
                    return "WARNING=Please enter atleast one record";
                }

                ctx.SaveChanges();

                return "SUCCESS=IOU Claim Process Added Successfully";
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is wrong: " + Common.GetString(ex);
        }
    }
    #endregion
}