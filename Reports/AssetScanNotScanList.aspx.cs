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

public partial class Reports_AssetScanNotScanList : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;
    protected String Version;


    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            ctx = new DDMSEntities();
            int EGID = Convert.ToInt32(Session["GroupID"]);
            CustType = Convert.ToInt32(Session["Type"]);
            Version = Convert.ToString(ConfigurationManager.AppSettings["Version"]);

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
                        var unit = xml.Descendants("reports");
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
        else
        {
            Response.Redirect("~/Login.aspx");
        }
    }

    private void ClearAllInputs()
    {
        //if (CustType == 1)
        //{
        //    divDistributor.Visible = true;
        //    //acetxtName.ContextKey = (CustType + 1).ToString();
        //}
        //else
        //{
        //    divDistributor.Visible = false;
        //    divDistributor.Style.Add("Display", "none");
        //}
        //txtCode.Text = "21200420 - RASESH SHUKLA - 71";
        //txtDistCode.Text = "DABS9440 - SAGAR CORP. [I/C DIST] BAPUNAGAR - 2000010000100000";
        //txtSSCode.Text = "DOGCON25 - CONGEAL AIRCON   BARASAT - 4030240000100000";
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static ResponseData GetData(string Fromdate, string Todate, string ReportBy, string ReportType, string ReportScanFrom, string SearchFor, string DistCode, string SSDistCode, string DealerCode, string txtCode, string PlantID, string StoreLocID, string AssetDistCode, string AssetSSDistCode, string AssetDealerCode, string AssetPlantCode, string AssetStoreLocCode, string ReportOption, string IsAssetPresentlyAt)
    {
        ResponseData result = new ResponseData();
        try
        {
            int CustType = Convert.ToInt32(HttpContext.Current.Session["Type"]);

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"].ToString());
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"].ToString());
            int SUserID = int.TryParse(txtCode, out SUserID) ? SUserID : 0;
            int PlantId = int.TryParse(PlantID, out PlantId) ? PlantId : 0;
            int StoreLocId = int.TryParse(StoreLocID, out StoreLocId) ? StoreLocId : 0;
            decimal SSID = decimal.TryParse(SSDistCode, out SSID) ? SSID : 0;
            decimal DistID = decimal.TryParse(DistCode, out DistID) ? DistID : 0;
            decimal DealerID = decimal.TryParse(DealerCode, out DealerID) ? DealerID : 0;
            int AssetPlantID = int.TryParse(AssetPlantCode, out AssetPlantID) ? AssetPlantID : 0;
            int AssetStoreLocID = int.TryParse(AssetStoreLocCode, out AssetStoreLocID) ? AssetStoreLocID : 0;
            decimal AssetSSID = decimal.TryParse(AssetSSDistCode, out AssetSSID) ? AssetSSID : 0;
            decimal AssetDistID = decimal.TryParse(AssetDistCode, out AssetDistID) ? AssetDistID : 0;
            decimal AssetDealerID = decimal.TryParse(AssetDealerCode, out AssetDealerID) ? AssetDealerID : 0;
            if (CustType == 1)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if (SearchFor == "0" && SUserID == 0 && SSID == 0 && DistID == 0 && DealerID == 0 && ctx.OEMPs.FirstOrDefault(x => x.EmpID == UserID && x.ParentID == ParentID).IsAdmin)
                    {
                        result.Status = false;
                        result.Message = "Please select at least one parameter";
                        result.Data = null;
                        return result;
                    }
                }
            }
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = !string.IsNullOrEmpty(ReportOption) && ReportOption == "1" ? "ReportAssetScannedData" : "ReportNoAssetScannedData";
            Cm.Parameters.AddWithValue("@FromDate", Fromdate);
            Cm.Parameters.AddWithValue("@Todate", Todate);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ReportFor", SearchFor);
            Cm.Parameters.AddWithValue("@ReportType", ReportType);
            Cm.Parameters.AddWithValue("@ReportBy", ReportBy);
            Cm.Parameters.AddWithValue("@ReportScanFrom", ReportScanFrom);
            Cm.Parameters.AddWithValue("@DistributorID", DistID);
            Cm.Parameters.AddWithValue("@SSID", SSID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@PlantID", PlantId);
            Cm.Parameters.AddWithValue("@StoreLocID", StoreLocId);
            Cm.Parameters.AddWithValue("@IsAssetPresentlyAt", IsAssetPresentlyAt);
            Cm.Parameters.AddWithValue("@AssetAtDistID", AssetDistID);
            Cm.Parameters.AddWithValue("@AssetAtSSID", AssetSSID);
            Cm.Parameters.AddWithValue("@AssetAtDealerID", AssetDealerID);
            Cm.Parameters.AddWithValue("@AssetAtPlantID", AssetPlantID);
            Cm.Parameters.AddWithValue("@AssetAtStorLocID", AssetStoreLocID);
            DataSet Ds = objClass.CommonFunctionForSelect(Cm);
            if (Ds.Tables.Count > 0)
            {
                if (!string.IsNullOrEmpty(ReportOption) && ReportOption == "1")
                {
                    var RowData = Ds.Tables[0].AsEnumerable().Select(x => new
                    {
                        Sr = x.Field<dynamic>("Sr"),
                        AssetPresentlyAt = x.Field<dynamic>("AssetPresentlyAt"),
                        PresentCity = x.Field<dynamic>("PresentCity"),
                        Status = x.Field<dynamic>("Status"),
                        AssetSrNo = x.Field<dynamic>("AssetSrNo"),
                        SRNO = x.Field<dynamic>("SRNO"),
                        LGMDate = x.Field<dynamic>("LGMDate"),
                        ScanDateTime = x.Field<dynamic>("ScanDateTime"),
                        AssetPhysicalAt = x.Field<dynamic>("AssetPhysicalAt"),
                        City = x.Field<dynamic>("City"),
                        PhysicalStatus = x.Field<dynamic>("PhysicalStatus"),
                        AssetasperBook = x.Field<dynamic>("AssetasperBook"),
                        BookCity = x.Field<dynamic>("BookCity"),
                        BookStatus = x.Field<dynamic>("BookStatus"),
                        ScanBy = x.Field<dynamic>("ScanBy"),
                        ConflictStatus = x.Field<dynamic>("ConflictStatus"),
                        ScanningOption = x.Field<dynamic>("ScanningOption"),
                        ScanningThrough = x.Field<dynamic>("ScanningThrough"),
                        Remarks = x.Field<dynamic>("Remarks"),
                        Lat = x.Field<dynamic>("Lat"),
                        Long = x.Field<dynamic>("Long"),
                        Address = x.Field<dynamic>("Address"),
                        ParentCodeName = x.Field<dynamic>("ParentCodeName"),
                        ParentBeatEmp = x.Field<dynamic>("ParentBeatEmp")
                    }).ToList();
                    result.Data = RowData;
                }
                else
                {
                    var RowData = Ds.Tables[0].AsEnumerable().Select(x => new
                    {
                        Sr = x.Field<dynamic>("Sr"),
                        AssetPresentlyAt = x.Field<dynamic>("Asset presently At"),
                        AssetSrNo = x.Field<dynamic>("Asset Sr.No"),
                        LGMDate = x.Field<dynamic>("LGM Date"),
                        Status = x.Field<dynamic>("SAP Status"),
                        BeatEmployee = x.Field<dynamic>("Beat Employee"),
                        ParentCodeName = x.Field<dynamic>("ParentCodeName"),
                        ParentBeatEmp = x.Field<dynamic>("ParentBeatEmp")
                    }).ToList();

                    result.Data = RowData;
                }

            }
            result.Status = true;
            return result;
        }
        catch (Exception ex)
        {
            return result;
        }
    }
}