using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity.Validation;
using System.Data.Objects;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;
public partial class Master_ItemWiseCategoryMaster : System.Web.UI.Page
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
    private List<OICM> SCM1s
    {
        get { return this.ViewState["SCM1"] as List<OICM>; }
        set { this.ViewState["SCM1"] = value; }
    }

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
    public static List<DicData> GetItem(string prefixText, Int16 DivisionId)
    {
        List<DicData> dicData = new List<DicData>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        decimal ParentID = 1000010000000000;
        Int32 UserID = 1;
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetItemForCategoryMaster";
        Cm.Parameters.AddWithValue("@DivisionId", DivisionId);
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


    [WebMethod]
    public static string GetItemDetails(string ItemCode)
    {
        string jsonstring = "";
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetItemCategoryDetails";
        Cm.Parameters.AddWithValue("@ItemCode", ItemCode);
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            jsonstring = JsonConvert.SerializeObject(ds.Tables[0]);
        }
        return jsonstring;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static String LoadData(int optionId, int DivisionId)
    {
        string jsonstring = "";
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetItemCategoryMasterData";
        Cm.Parameters.AddWithValue("@OptionId", optionId);
        Cm.Parameters.AddWithValue("@DivisionId", DivisionId);
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            jsonstring = JsonConvert.SerializeObject(ds.Tables[0]);
        }
        return jsonstring;
    }


    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputUnitMapping, int IsAnyRowDeleted, string DeletedIDs, int OptionId, int DivisionId)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var ClaimLevelEntry = JsonConvert.DeserializeObject<dynamic>(hidJsonInputUnitMapping.ToString());

                if (!string.IsNullOrEmpty(DeletedIDs))
                {
                    List<string> isDeletedIds = DeletedIDs.Trim().Split(",".ToArray()).ToList();
                    List<int> IDs = new List<int>();
                    foreach (var item in isDeletedIds)
                    {
                        int Id = Int32.TryParse(item, out Id) ? Id : 0;
                        IDs.Add(Id);
                    }
                    ctx.OICMs.Where(x => IDs.Any(y => y == x.OICMID)).ToList().ForEach(x => { x.IsDeleted = true; x.UpdatedBy = UserID; x.Active = false; x.UpdatedDate = DateTime.Now; });
                    ctx.SaveChanges();
                }

                foreach (var item in ClaimLevelEntry)
                {
                    OICM ObjScanType = new OICM();
                    int OICMID = int.TryParse(Convert.ToString(item["OICMID"]), out OICMID) ? OICMID : 0;
                    Decimal MRPOrCatId = Decimal.TryParse(Convert.ToString(item["MRPOrCatId"]), out MRPOrCatId) ? MRPOrCatId : 0;
                    string ItemCode = Convert.ToString(item["ItemCode"]);

                    var ObjItm = ctx.OITMs.Where(x => x.ItemCode == ItemCode).FirstOrDefault();
                    DateTime FromDate = Convert.ToDateTime(Convert.ToString(item["FromDate"]));
                    DateTime ToDate = Convert.ToDateTime(Convert.ToString(item["ToDate"]));
                    bool IsActive = Convert.ToBoolean(Convert.ToString(item["Active"]));
                    if (OICMID > 0 && Convert.ToString(item["IsChange"]) == "1")
                    {
                        var ObjOERM = ctx.OICMs.Where(x => x.OICMID == OICMID).First();
                        ObjOERM.OptionId = OptionId;
                        ObjOERM.DivisionId = DivisionId;
                        ObjOERM.ItemId = ObjItm.ItemID;
                        ObjOERM.FromDate = FromDate;
                        ObjOERM.ToDate = ToDate;
                        ObjOERM.Active = IsActive;
                        ObjOERM.MRPORCate = MRPOrCatId.ToString();
                        ObjScanType.IsDeleted = false;
                        ObjOERM.UpdatedBy = UserID;
                        ObjOERM.UpdatedDate = DateTime.Now;
                        ctx.SaveChanges();
                    }
                    else if (OICMID > 0 && Convert.ToString(item["IsChange"]) == "0")
                    {
                    }
                    else
                    {
                        ObjScanType.OptionId = OptionId;
                        ObjScanType.DivisionId = DivisionId;
                        ObjScanType.ItemId = ObjItm.ItemID;
                        ObjScanType.FromDate = FromDate;
                        ObjScanType.ToDate = ToDate;
                        ObjScanType.Active = IsActive;
                        ObjScanType.MRPORCate = MRPOrCatId.ToString();
                        ObjScanType.IsDeleted = false;
                        ObjScanType.UpdatedBy = UserID;
                        ObjScanType.UpdatedDate = DateTime.Now;
                        ObjScanType.CreatedBy = UserID;
                        ObjScanType.CreatedDate = DateTime.Now;
                        ctx.OICMs.Add(ObjScanType);
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
    public static List<dynamic> LoadReport(string strIsHistory, int optionId, int DivisionId)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetItemWiseCategoryReport";
            Cm.Parameters.AddWithValue("@OptionId", optionId);
            Cm.Parameters.AddWithValue("@DivisionId", DivisionId);
            Cm.Parameters.AddWithValue("@IsHistory", strIsHistory.ToLower() == "true" ? "1" : "0");

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
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DicData> GetCategoryMaster(string prefixText)
    {

        List<DicData> dicData = new List<DicData>();
        using (var ctx = new DDMSEntities())
        {
            Int32 UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetCategoryMaster";
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



    protected void btnUploadItemMRP_Click(object sender, EventArgs e)
    {

        try
        {
            DataTable missdata = new DataTable();
            missdata.Columns.Add("ItemCode");
            missdata.Columns.Add("FromDate");
            missdata.Columns.Add("ToDate");
            missdata.Columns.Add("MRP");
            missdata.Columns.Add("ErrorMsg");

            int OptionId = Convert.ToInt32(ddlOption.SelectedValue);
            int DivisionId = Convert.ToInt32(ddlDivision.SelectedValue);
            bool flag = true;

            if (flpLineItemExcInc.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flpLineItemExcInc.PostedFile.FileName));
                flpLineItemExcInc.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flpLineItemExcInc.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtPOH = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtPOH);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                        return;
                    }

                    if (dtPOH != null && dtPOH.Rows != null && dtPOH.Rows.Count > 0)
                    {
                        gvProductMappingMissData.DataSource = null;
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtPOH.Rows)
                            {
                                String ItemCode = item["ItemCode"].ToString().Trim();
                                String FromDate = item["FromDate"].ToString().Trim();
                                String ToDate = item["ToDate"].ToString().Trim();
                                String MRP = item["MRP"].ToString().Trim();




                                if (string.IsNullOrEmpty(ItemCode) && string.IsNullOrEmpty(FromDate) && string.IsNullOrEmpty(ToDate) && string.IsNullOrEmpty(MRP))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["FromDate"] = FromDate;
                                    missdr["ToDate"] = ToDate;
                                    missdr["MRP"] = MRP;
                                    missdr["ErrorMsg"] = "Blank row found please remove blank row.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }

                                else if (string.IsNullOrEmpty(ItemCode) || string.IsNullOrEmpty(FromDate) || string.IsNullOrEmpty(ToDate))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["FromDate"] = FromDate;
                                    missdr["ToDate"] = ToDate;
                                    missdr["MRP"] = MRP;
                                    missdr["ErrorMsg"] = "Plesase Enter Item Code, From Date and ToDate.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (!string.IsNullOrEmpty(ItemCode))
                                {
                                    var ObjItm = ctx.OITMs.Where(x => x.ItemCode == ItemCode).FirstOrDefault();
                                    if (ObjItm == null)
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["ItemCode"] = ItemCode;
                                        missdr["FromDate"] = FromDate;
                                        missdr["ToDate"] = ToDate;
                                        missdr["MRP"] = MRP;
                                        missdr["ErrorMsg"] = "Plesase Enter valid item code.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else if (string.IsNullOrEmpty(MRP))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["FromDate"] = FromDate;
                                    missdr["ToDate"] = ToDate;
                                    missdr["MRP"] = MRP;
                                    missdr["ErrorMsg"] = "Plesase Enter MRP.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (!string.IsNullOrEmpty(MRP) && Convert.ToInt32(MRP) == 0)
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["FromDate"] = FromDate;
                                    missdr["ToDate"] = ToDate;
                                    missdr["MRP"] = MRP;
                                    missdr["ErrorMsg"] = "Please Enter valid MRP";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (Convert.ToDateTime(FromDate) > Convert.ToDateTime(ToDate))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["FromDate"] = FromDate;
                                    missdr["ToDate"] = ToDate;
                                    missdr["MRP"] = MRP;
                                    missdr["ErrorMsg"] = "In Valid From Date TO Date";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                var ObjItem = ctx.OITMs.Where(x => x.ItemCode == ItemCode).FirstOrDefault();
                                DateTime FrmDate = Convert.ToDateTime(FromDate);
                                DateTime TDate = Convert.ToDateTime(ToDate);
                                OICM objSCM2 = ctx.OICMs.FirstOrDefault(x => x.ItemId == ObjItem.ItemID && x.OptionId == OptionId && x.DivisionId == DivisionId && x.MRPORCate == MRP && (x.FromDate == FrmDate && x.ToDate == TDate && x.Active == true));
                                if (objSCM2 != null)
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["FromDate"] = FromDate;
                                    missdr["ToDate"] = ToDate;
                                    missdr["MRP"] = MRP;
                                    missdr["ErrorMsg"] = "Record Already exists";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                            }
                            if (flag)
                            {
                                try
                                {
                                    if (SCM1s == null)
                                        SCM1s = new List<OICM>();

                                    foreach (DataRow item in dtPOH.Rows)
                                    {
                                        string ItmCode = item["ItemCode"].ToString().Trim();
                                        var ObjItm = ctx.OITMs.Where(x => x.ItemCode == ItmCode).FirstOrDefault();
                                        //Int32 SchemeNo = Int32.TryParse(item["SchemeNo"].ToString().Trim(), out SchemeNo) ? SchemeNo : 0;
                                        DateTime FromDate = Convert.ToDateTime(item["FromDate"].ToString().Trim());
                                        DateTime ToDate = Convert.ToDateTime(item["ToDate"].ToString().Trim());
                                        String MRP = item["MRP"].ToString().Trim();

                                        if (ObjItm.ItemID > 0)
                                        {

                                            var objSCM1 = ctx.OICMs.Where(x => x.ItemId == ObjItm.ItemID && x.OptionId == OptionId && x.DivisionId == DivisionId && (DateTime.Compare(x.FromDate.Value, FromDate) < 0 && DateTime.Compare(x.ToDate.Value, FromDate) > 0)).OrderByDescending(x => x.ToDate).FirstOrDefault();
                                            if (objSCM1 != null)
                                            {
                                                objSCM1.ToDate = FromDate.AddDays(-1);
                                                objSCM1.UpdatedBy = UserID;
                                                objSCM1.MRPORCate = MRP;
                                                objSCM1.Active = true;
                                                objSCM1.IsDeleted = false;
                                                objSCM1.UpdatedDate = DateTime.Now;
                                                ctx.SaveChanges();
                                            }
                                            var objSCM4 = ctx.OICMs.Where(x => x.ItemId == ObjItm.ItemID && x.OptionId == OptionId && x.DivisionId == DivisionId && (DateTime.Compare(x.FromDate.Value, ToDate) < 0 && DateTime.Compare(x.ToDate.Value, ToDate) > 0)).OrderByDescending(x => x.ToDate).FirstOrDefault();
                                            if (objSCM4 != null)
                                            {
                                                objSCM4.FromDate = ToDate.AddDays(1);
                                                objSCM4.UpdatedBy = UserID;
                                                objSCM4.MRPORCate = MRP;
                                                objSCM4.Active = true;
                                                objSCM4.IsDeleted = false;
                                                objSCM4.UpdatedDate = DateTime.Now;
                                                ctx.SaveChanges();
                                            }
                                            var objSCM3 = ctx.OICMs.Where(x => x.ItemId == ObjItm.ItemID && x.OptionId == OptionId && x.DivisionId == DivisionId && x.FromDate == FromDate && x.ToDate == ToDate).OrderByDescending(x => x.ToDate).FirstOrDefault();
                                            if (objSCM3 != null)
                                            {
                                                objSCM3.MRPORCate = MRP;
                                                objSCM3.UpdatedBy = UserID;
                                                objSCM3.UpdatedDate = DateTime.Now;
                                                ctx.SaveChanges();
                                            }
                                            OICM objSCM2 = ctx.OICMs.FirstOrDefault(x => x.ItemId == ObjItm.ItemID && x.OptionId == OptionId && x.DivisionId == DivisionId && (x.FromDate == FromDate && x.ToDate == ToDate && x.Active == true));
                                            if (objSCM2 == null)
                                            {
                                                OICM ObjOcm = new OICM();
                                                ObjOcm.OptionId = OptionId;
                                                ObjOcm.DivisionId = DivisionId;
                                                ObjOcm.ItemId = ObjItm.ItemID;
                                                ObjOcm.FromDate = FromDate;
                                                ObjOcm.ToDate = ToDate;
                                                ObjOcm.MRPORCate = MRP;
                                                ObjOcm.Active = true;
                                                ObjOcm.IsDeleted = false;
                                                ObjOcm.CreatedBy = UserID;
                                                ObjOcm.CreatedDate = DateTime.Now;
                                                ObjOcm.UpdatedBy = UserID;
                                                ObjOcm.UpdatedDate = DateTime.Now;
                                                ctx.OICMs.Add(ObjOcm);
                                            }
                                        }
                                    }
                                    ctx.SaveChanges();
                                    gvProductMappingMissData.DataSource = null;
                                    gvProductMappingMissData.DataBind();
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('file uploaded successfully!',1);", true);
                                    gvProductMappingMissData.Visible = false;
                                    divEmpClaimLevel.Visible = true;

                                }
                                catch (DbEntityValidationException ex)
                                {
                                    var error = ex.EntityValidationErrors.First().ValidationErrors.First();
                                    if (error != null)
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + error.ErrorMessage.Replace("'", "") + "',2);", true);
                                    else
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                                    return;
                                }

                            }
                            else
                            {
                                divEmpClaimLevel.Visible = false;
                                gvProductMappingMissData.Visible = true;
                                gvProductMappingMissData.DataSource = missdata;
                                gvProductMappingMissData.DataBind();
                            }
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }


    public static void TransferCSVToTable(string filePath, DataTable dt)
    {

        string[] csvRows = System.IO.File.ReadAllLines(filePath);
        string[] fields = null;
        bool head = true;
        foreach (string csvRow in csvRows)
        {
            if (head)
            {
                if (dt.Columns.Count == 0)
                {
                    fields = csvRow.Split(',');
                    foreach (string column in fields)
                    {
                        DataColumn datecolumn = new DataColumn(column);
                        datecolumn.AllowDBNull = true;
                        dt.Columns.Add(datecolumn);
                    }
                }
                head = false;
            }
            else
            {
                fields = csvRow.Split(',');
                DataRow row = dt.NewRow();
                row.ItemArray = new object[fields.Length];
                row.ItemArray = fields;
                dt.Rows.Add(row);
            }
        }

    }
    #endregion
}