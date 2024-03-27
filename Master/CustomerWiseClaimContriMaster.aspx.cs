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

public partial class Master_CustomerWiseClaimContriMaster : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType, Index;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;
    protected String LogoURL;
    public class ClaimContriDicData
    {
        public string Text { get; set; }
        public decimal Value { get; set; }
    }
    [Serializable]
    public class ClaimContriValidate
    {
        public int RateClaimID { get; set; }
        public int DivisionID { get; set; }
        public decimal CustomerID { get; set; }
        public int PriceListID { get; set; }
        public string CustDesc { get; set; }
        public string PriceDesc { get; set; }
        public string FromDate { get; set; }
        public string ToDate { get; set; }
        public decimal CompCont { get; set; }
        public decimal DistCont { get; set; }
        public bool IsActive { get; set; }
        public string ParentName { get; set; }
        public string UpdatedDate { get; set; }
        public string UpdatedBy { get; set; }
        public string IPAddress { get; set; }
        public String Remarks { get; set; }
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

    private void ClearAllInputs()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            ddlDivision.DataSource = Division;
            ddlDivision.DataBind();
            ddlDivision.ClearSelection();
        }
        txtFromDate.Text = txtToDate.Text = Common.DateTimeConvert(DateTime.Now);
        gvMissdata.DataSource = null;
        gvMissdata.DataBind();
        gvMissdata.Style.Add("display", "none");
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    #region AjaxMethods

    [WebMethod]
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<ClaimContriDicData> SearchCustomerByType(int DivisionID, string prefixText)
    {
        List<ClaimContriDicData> StrCust = new List<ClaimContriDicData>();

        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCRDs
                           join b in ctx.OGCRDs on c.CustomerID equals b.CustomerID
                           where (c.Type == 3 && !c.IsTemp && c.CustGroupID != 14) && b.DivisionlID == DivisionID && b.PriceListID != null && b.DivisionlID != null
                           orderby c.CustomerCode descending
                           select new ClaimContriDicData
                           {
                               Text = c.CustomerCode + " - " + c.CustomerName,
                               Value = c.CustomerID
                           }).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OCRDs
                           join b in ctx.OGCRDs on c.CustomerID equals b.CustomerID
                           where (c.Type == 3 && !c.IsTemp && c.CustGroupID != 14) && b.DivisionlID == DivisionID && b.PriceListID != null && b.DivisionlID != null
                           && ((c.CustomerCode).Contains(prefixText) || (c.CustomerName).Contains(prefixText))
                           orderby c.CreatedDate descending
                           select new ClaimContriDicData
                           {
                               Text = c.CustomerCode + " - " + c.CustomerName,
                               Value = c.CustomerID
                           }).Take(20).ToList();
            }
        }

        return StrCust;
    }

    //[WebMethod]
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    //public static List<DicData> LoadCustomerByType(int DivisionID, string prefixText)
    //{
    //    List<DicData> StrCust = new List<DicData>();

    //    using (DDMSEntities ctx = new DDMSEntities())
    //    {
    //        if (prefixText == "*")
    //        {
    //            StrCust = (from c in ctx.OCRDs
    //                       join b in ctx.OGCRDs on c.CustomerID equals b.CustomerID
    //                       where (c.Type == 3 && !c.IsTemp && c.CustGroupID != 14) && b.DivisionlID == DivisionID && b.PriceListID != null && b.DivisionlID != null
    //                       orderby c.CustomerCode descending
    //                       select new DicData
    //                       {
    //                           Text = c.CustomerCode + " - " + c.CustomerName,
    //                           Value = 0
    //                       }).Take(20).ToList();
    //        }
    //        else
    //        {
    //            StrCust = (from c in ctx.OCRDs
    //                       join b in ctx.OGCRDs on c.CustomerID equals b.CustomerID
    //                       where (c.Type == 3 && !c.IsTemp && c.CustGroupID != 14) && b.DivisionlID == DivisionID && b.PriceListID != null && b.DivisionlID != null
    //                       && ((c.CustomerCode).Contains(prefixText) || (c.CustomerName).Contains(prefixText))
    //                       orderby c.CreatedDate descending
    //                       select new DicData
    //                       {
    //                           Text = c.CustomerCode + " - " + c.CustomerName,
    //                           Value = 0
    //                       }).Take(20).ToList();
    //        }
    //    }

    //    return StrCust;
    //}

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetCustomerDetail(string CustCode, int DivisionID)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            if (!string.IsNullOrEmpty(CustCode))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == CustCode);
                    if (objOCRD != null)
                    {
                        ORCLM objORCLM = ctx.ORCLMs.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID && x.DivisionID == DivisionID);
                        int PriceID = ctx.OGCRDs.Where(x => x.CustomerID == objOCRD.CustomerID && x.DivisionlID == DivisionID && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();

                        var CustData = new
                        {
                            CustomerID = objORCLM != null ? objORCLM.CustomerID : objOCRD.CustomerID,
                            CustomerCode = objOCRD.CustomerCode + " - " + objOCRD.CustomerName,
                            PriceGroup = PriceID > 0 ? ctx.OIPLs.FirstOrDefault(x => x.PriceListID == PriceID).Name : "",
                            FromDate = objORCLM != null && objORCLM.FromDate != null ? objORCLM.FromDate.ToString("dd/MM/yyyy") : DateTime.Now.ToString("dd/MM/yyyy"),
                            ToDate = objORCLM != null && objORCLM.ToDate != null ? objORCLM.ToDate.ToString("dd/MM/yyyy") : DateTime.Now.ToString("dd/MM/yyyy"),
                            CompContri = objORCLM != null ? objORCLM.CompCont.ToString() : "",
                            DistContri = objORCLM != null ? objORCLM.DistCont.ToString() : "",
                            Active = objORCLM != null ? objORCLM.Active : true,
                            ParentName = ctx.OCRDs.Where(x => x.CustomerID == objOCRD.ParentID).Select(x => x.CustomerCode + " - " + x.CustomerName).DefaultIfEmpty().FirstOrDefault(),
                            UpdateBy = objORCLM != null ? ctx.OEMPs.Where(x => x.EmpID == objORCLM.UpdatedBy).Select(x => x.EmpCode + " - " + x.Name).DefaultIfEmpty().FirstOrDefault() : "",
                            UpdateDate = objORCLM != null ? objORCLM.UpdatedDate.ToString("dd/MM/yyyy HH:mm") : "",
                            IpAddress = objORCLM != null ? objORCLM.IPAddress : ""
                        };

                        result.Add(CustData);
                    }
                    else
                        result.Add("ERROR=" + "" + "Customer not found.");
                }
            }
            else
                result.Add("ERROR=" + "" + "Please select proper customer.");
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }

        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string LoadData(int DivisionID)
    {
        List<dynamic> result = new List<dynamic>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetClaimContriData";
        Cm.Parameters.AddWithValue("@DivisionID", DivisionID);
        string jsonstring = "";
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {

            jsonstring = JsonConvert.SerializeObject(ds.Tables[0]);

            //List<ClaimContriValidate> ClaimData = ds.Tables[0].AsEnumerable().Select
            // (x => new ClaimContriValidate
            // {
            //     RateClaimID = x.Field<int>("RateClaimID"),
            //     CustomerID = x.Field<decimal>("CustomerID"),
            //     DivisionID = x.Field<int>("DivisionID"),
            //     PriceListID = x.Field<int>("PriceListID"),
            //     CustDesc = x.Field<String>("CustDesc"),
            //     PriceDesc = x.Field<String>("PriceDesc"),
            //     FromDate = x.Field<String>("FromDate"),
            //     ToDate = x.Field<String>("ToDate"),
            //     CompCont = x.Field<decimal>("CompCont"),
            //     DistCont = x.Field<decimal>("DistCont"),
            //     IsActive = x.Field<bool>("Active"),
            //     ParentName = x.Field<String>("ParentName"),
            //     UpdatedDate = x.Field<String>("UpdatedDate"),
            //     UpdatedBy = x.Field<String>("UpdatedBy"),
            //     IPAddress = x.Field<String>("IPAddress"),
            //     Remarks = x.Field<String>("Remarks")
            // }).ToList();
            //result.Add(ClaimData);
        }
        //return result;
        return jsonstring;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DicData> LoadPriceByCustType(int DivisionID, int CustType, string prefixText)
    {
        List<DicData> result = new List<DicData>();

        using (DDMSEntities ctx = new DDMSEntities())
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetCustomerTypeWisePriceGroup";
            Cm.Parameters.AddWithValue("@DivisionID", DivisionID);
            Cm.Parameters.AddWithValue("@CustType", CustType);
            Cm.Parameters.AddWithValue("@Prefix", prefixText);

            DataSet DS = objClass.CommonFunctionForSelect(Cm);
            dynamic Data = "";
            if (DS.Tables[0] != null && DS.Tables[0].Rows.Count > 0)
            {
                result = DS.Tables[0].AsEnumerable()
                    .Select(r => new DicData { Text = r.Field<string>("Data"), Value = r.Field<int>("Id") })
                    .ToList();
            }
        }
        return result;
    }

    #endregion

    #region TransferCSVToTable

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

    #region Button Events

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadReport(string strFromDate, string strToDate, string strCustomer, string strIsHistory, int DivisionID)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                DateTime FromDate = Convert.ToDateTime(strFromDate);
                DateTime ToDate = Convert.ToDateTime(strToDate);
                var Cust = strCustomer.Split("-".ToArray()).First().Trim();
                decimal CustomerID = !String.IsNullOrEmpty(Cust) ? ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Cust).CustomerID : 0;

                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();

                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "GetCustWiseClaimHistory";
                Cm.Parameters.AddWithValue("@FromDate", FromDate);
                Cm.Parameters.AddWithValue("@ToDate", ToDate);
                Cm.Parameters.AddWithValue("@CustomerID", CustomerID);
                Cm.Parameters.AddWithValue("@DivisionID", DivisionID);
                Cm.Parameters.AddWithValue("@IsHistory", strIsHistory.ToLower() == "true" ? "1" : "0");

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

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputCustomer, int DivisionID)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var CustomerListData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputCustomer.ToString());
                if (DivisionID > 0)
                {
                    foreach (var item in CustomerListData)
                    {
                        int RateClaimID = int.TryParse(Convert.ToString(item["RateClaimID"]), out RateClaimID) ? RateClaimID : 0;
                        Decimal CustomerID = Decimal.TryParse(Convert.ToString(item["CustomerID"]), out CustomerID) ? CustomerID : 0;
                        int PriceListID = int.TryParse(Convert.ToString(item["PriceListID"]), out PriceListID) ? PriceListID : 0;
                        DateTime FromDate = Convert.ToDateTime(Convert.ToString(item["FromDate"]));
                        DateTime ToDate = Convert.ToDateTime(Convert.ToString(item["ToDate"]));
                        decimal CompContri = Decimal.TryParse(Convert.ToString(item["CompContri"]), out CompContri) ? CompContri : 0;
                        decimal DistContri = Decimal.TryParse(Convert.ToString(item["DistContri"]), out DistContri) ? DistContri : 0;
                        bool IsActive = Convert.ToBoolean(Convert.ToString(item["IsActive"]));
                        //string IPAddress = Convert.ToString(item["IPAddress"]);
                        string Remarks = Convert.ToString(item["Remarks"]);

                        if (CustomerID > 0)
                        {
                            ORCLM objORCLM = ctx.ORCLMs.FirstOrDefault(x => x.RateClaimID == RateClaimID && x.CustomerID == CustomerID && x.DivisionID == DivisionID);

                            var count = ctx.ORCLMs.Any(x => x.RateClaimID != RateClaimID && x.CustomerID == CustomerID && x.DivisionID == DivisionID &&
                                    ((EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(FromDate) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(ToDate))
                                 || (EntityFunctions.TruncateTime(FromDate) <= EntityFunctions.TruncateTime(x.FromDate) && EntityFunctions.TruncateTime(ToDate) >= EntityFunctions.TruncateTime(x.ToDate))
                                 || (EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(FromDate) && EntityFunctions.TruncateTime(FromDate) <= EntityFunctions.TruncateTime(x.ToDate))
                                 || (EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(ToDate) && EntityFunctions.TruncateTime(ToDate) <= EntityFunctions.TruncateTime(x.ToDate))));

                            if (count)
                            {
                                return "WARNING=From date and To date is already set for customer : " + ctx.OCRDs.Where(x => x.CustomerID == CustomerID).Select(x => x.CustomerCode + " - " + x.CustomerName).DefaultIfEmpty().FirstOrDefault();
                            }
                            if (objORCLM == null)
                            {
                                objORCLM = new ORCLM()
                                {
                                    CustomerID = CustomerID,
                                    CreatedBy = UserID,
                                    CreatedDate = DateTime.Now
                                };
                                ctx.ORCLMs.Add(objORCLM);
                            }
                            objORCLM.DivisionID = DivisionID;
                            objORCLM.PriceListID = PriceListID;
                            objORCLM.FromDate = FromDate;
                            objORCLM.ToDate = ToDate;
                            objORCLM.CompCont = CompContri;
                            objORCLM.DistCont = DistContri;
                            objORCLM.Active = IsActive;
                           // objORCLM.IPAddress = IPAddress;
                            objORCLM.Remarks = Remarks;
                            if (Convert.ToString(item["IsChange"]) == "1")
                            {
                                objORCLM.UpdatedBy = UserID;
                                objORCLM.UpdatedDate = DateTime.Now;
                            }
                        }
                        else
                        {
                            return "WARNING=Please select proper Customer";
                        }
                    }
                    ctx.SaveChanges();
                    return "SUCCESS=Customer Added Successfully";
                }
                else
                {
                    return "WARNING=Please select proper Division";
                }
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is wrong: " + Common.GetString(ex);
        }
    }

    protected void btnCLMUpload_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable missdata = new DataTable();
            missdata.Columns.Add("Division Code");
            missdata.Columns.Add("Customer Code");
            missdata.Columns.Add("PriceCode");
            missdata.Columns.Add("From Date");
            missdata.Columns.Add("To Date");
            missdata.Columns.Add("Comp Contri");
            missdata.Columns.Add("Dist Contri");
            missdata.Columns.Add("Active");
            missdata.Columns.Add("Remarks");
            missdata.Columns.Add("ErrorMsg");

            bool flag = true;

            if (ORCLMUpload.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(ORCLMUpload.PostedFile.FileName));
                ORCLMUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(ORCLMUpload.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtDATA = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtDATA);
                    }
                    catch (Exception ex)
                    {
                        ORCLMUpload.Dispose();
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                        return;
                    }
                    if (dtDATA != null && dtDATA.Rows != null && dtDATA.Rows.Count > 0)
                    {
                        var duplicates = dtDATA.AsEnumerable()
                                                        .Select(dr => new
                                                        {
                                                            CustomerCode = dr.Field<string>("Customer Code").Trim(),
                                                            DivisionCode = dr.Field<string>("Division Code"),
                                                            PriceCode = dr.Field<string>("PriceCode"),
                                                            FromDate = dr.Field<string>("From Date"),
                                                            ToDate = dr.Field<string>("To Date"),
                                                            Remarks = dr.Field<string>("Remarks")
                                                        })
                                                        .GroupBy(x => x)
                                                        .Where(g => g.Count() > 1)
                                                        .Select(g => g.Key)
                                                        .ToList();
                        foreach (var item in duplicates)
                        {
                            DataRow missdr = missdata.NewRow();
                            missdr["Division Code"] = item.DivisionCode.ToString();
                            missdr["Customer Code"] = item.CustomerCode.ToString();
                            missdr["PriceCode"] = item.PriceCode.ToString();
                            missdr["From Date"] = item.FromDate.ToString();
                            missdr["To Date"] = item.ToDate.ToString();
                            missdr["Remarks"] = item.Remarks.ToString();
                            missdr["ErrorMsg"] = "Duplicate Entry Found for Division Code:" + item.DivisionCode.ToString() + " and Customer Code: " + item.CustomerCode.ToString() + " and FromDate:" + item.FromDate.ToString() + " and ToDate:" + item.ToDate.ToString();
                            missdata.Rows.Add(missdr);
                            flag = false;
                        }

                        if (!flag)
                        {
                            gvMissdata.DataSource = missdata;
                            gvMissdata.DataBind();
                            divMissData.Visible = true;
                            divCustEntry.Style.Add("display", "none");
                            divClaimReport.Style.Add("display", "none");
                            return;
                        }
                    }

                    if (dtDATA != null && dtDATA.Rows != null && dtDATA.Rows.Count > 0)
                    {
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtDATA.Rows)
                            {
                                string DivisionCode = item["Division Code"].ToString();
                                string CustCode = item["Customer Code"].ToString();
                                string PriceCode = item["PriceCode"].ToString();
                                string FromDate = item["From Date"].ToString();
                                string ToDate = item["To Date"].ToString();
                                string CompContri = item["Comp Contri"].ToString();
                                string DistContri = item["Dist Contri"].ToString();
                                string Active = item["Active"].ToString();
                                string Remarks = item["Remarks"].ToString();
                                Decimal CompContrib = decimal.TryParse(CompContri, out CompContrib) ? CompContrib : 0;
                                Decimal DistContrib = decimal.TryParse(DistContri, out DistContrib) ? DistContrib : 0;

                                var objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == CustCode && x.Active);

                                if (CompContrib + DistContrib > 100 || CompContrib + DistContrib < 100)
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Division Code"] = DivisionCode;
                                    missdr["Customer Code"] = CustCode;
                                    missdr["PriceCode"] = PriceCode;
                                    missdr["From Date"] = FromDate;
                                    missdr["To Date"] = ToDate;
                                    missdr["Comp Contri"] = CompContri;
                                    missdr["Dist Contri"] = DistContri;
                                    missdr["Active"] = Active;
                                    missdr["Remarks"] = Remarks;
                                    missdr["ErrorMsg"] = "Comp Contri. and Dist Contri. must be 100 % for :'" + CustCode + "'";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                //if (!string.IsNullOrEmpty(Remarks))
                                //{
                                //    if (Remarks.Length > 100)
                                //    {
                                //        DataRow missdr = missdata.NewRow();
                                //        missdr["Division Code"] = DivisionCode;
                                //        missdr["Customer Code"] = CustCode;
                                //        missdr["PriceCode"] = PriceCode;
                                //        missdr["From Date"] = FromDate;
                                //        missdr["To Date"] = ToDate;
                                //        missdr["Comp Contri"] = CompContri;
                                //        missdr["Dist Contri"] = DistContri;
                                //        missdr["Active"] = Active;
                                //        missdr["Remarks"] = Remarks;
                                //        missdr["ErrorMsg"] = "Remarks length is more than 100 character";
                                //        missdata.Rows.Add(missdr);
                                //        flag = false;

                                //    }
                                //}
                                if (!string.IsNullOrEmpty(CustCode))
                                {
                                    if (objOCRD == null)
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Division Code"] = DivisionCode;
                                        missdr["Customer Code"] = CustCode;
                                        missdr["PriceCode"] = PriceCode;
                                        missdr["From Date"] = FromDate;
                                        missdr["To Date"] = ToDate;
                                        missdr["Comp Contri"] = CompContri;
                                        missdr["Dist Contri"] = DistContri;
                                        missdr["Active"] = Active;
                                        missdr["Remarks"] = Remarks;
                                        missdr["ErrorMsg"] = "Customer Code: '" + CustCode + "' does not exist or not active.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                    else
                                    {
                                        if (!string.IsNullOrEmpty(DivisionCode))
                                        {
                                            var objODIV = ctx.ODIVs.FirstOrDefault(x => x.DivisionCode == DivisionCode && x.Active);
                                            var objOIPL = ctx.OIPLs.FirstOrDefault(x => x.Name == PriceCode && x.Active);

                                            if (objODIV == null)
                                            {
                                                DataRow missdr = missdata.NewRow();
                                                missdr["Division Code"] = DivisionCode;
                                                missdr["Customer Code"] = CustCode;
                                                missdr["PriceCode"] = PriceCode;
                                                missdr["From Date"] = FromDate;
                                                missdr["To Date"] = ToDate;
                                                missdr["Comp Contri"] = CompContri;
                                                missdr["Dist Contri"] = DistContri;
                                                missdr["Active"] = Active;
                                                missdr["Remarks"] = Remarks;
                                                missdr["ErrorMsg"] = "Division Code: '" + DivisionCode + "' does not exist or not active.";
                                                missdata.Rows.Add(missdr);
                                                flag = false;
                                            }
                                            else if (objOIPL == null)
                                            {
                                                DataRow missdr = missdata.NewRow();
                                                missdr["Division Code"] = DivisionCode;
                                                missdr["Customer Code"] = CustCode;
                                                missdr["PriceCode"] = PriceCode;
                                                missdr["From Date"] = FromDate;
                                                missdr["To Date"] = ToDate;
                                                missdr["Comp Contri"] = CompContri;
                                                missdr["Dist Contri"] = DistContri;
                                                missdr["Active"] = Active;
                                                missdr["Remarks"] = Remarks;
                                                missdr["ErrorMsg"] = "Price Code: '" + PriceCode + "' does not exist or not active.";
                                                missdata.Rows.Add(missdr);
                                                flag = false;
                                            }
                                            else if (!ctx.OGCRDs.Any(x => x.CustomerID == objOCRD.CustomerID && x.DivisionlID == objODIV.DivisionlID && x.PriceListID == objOIPL.PriceListID))
                                            {
                                                DateTime EndDate = Convert.ToDateTime(ToDate);
                                                if (EndDate.Date >= DateTime.Now.Date)
                                                {
                                                    DataRow missdr = missdata.NewRow();
                                                    missdr["Division Code"] = DivisionCode;
                                                    missdr["Customer Code"] = CustCode;
                                                    missdr["PriceCode"] = PriceCode;
                                                    missdr["From Date"] = FromDate;
                                                    missdr["To Date"] = ToDate;
                                                    missdr["Comp Contri"] = CompContri;
                                                    missdr["Dist Contri"] = DistContri;
                                                    missdr["Active"] = Active;
                                                    missdr["Remarks"] = Remarks;
                                                    missdr["ErrorMsg"] = "Customer Code '" + CustCode + "' is not available in Division Code: '" + DivisionCode + "' or Pricelist not match";
                                                    missdata.Rows.Add(missdr);
                                                    flag = false;
                                                }
                                            }
                                            else
                                            {
                                                DateTime StartDate = Convert.ToDateTime(FromDate);
                                                DateTime EndDate = Convert.ToDateTime(ToDate);
                                                ORCLM objORCLM = ctx.ORCLMs.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID && x.DivisionID == objODIV.DivisionlID && EntityFunctions.TruncateTime(x.FromDate) == EntityFunctions.TruncateTime(StartDate) && EntityFunctions.TruncateTime(x.ToDate) == EntityFunctions.TruncateTime(EndDate));

                                                var count = ctx.ORCLMs.Any(x => x.CustomerID == objOCRD.CustomerID && x.DivisionID == objODIV.DivisionlID &&
                                                     ((EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(StartDate) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(EndDate))
                                                  || (EntityFunctions.TruncateTime(StartDate) <= EntityFunctions.TruncateTime(x.FromDate) && EntityFunctions.TruncateTime(EndDate) >= EntityFunctions.TruncateTime(x.ToDate))
                                                  || (EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(StartDate) && EntityFunctions.TruncateTime(StartDate) <= EntityFunctions.TruncateTime(x.ToDate))
                                                  || (EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(EndDate) && EntityFunctions.TruncateTime(EndDate) <= EntityFunctions.TruncateTime(x.ToDate))));

                                                if (count)
                                                {
                                                    DataRow missdr = missdata.NewRow();
                                                    missdr["Division Code"] = DivisionCode;
                                                    missdr["Customer Code"] = CustCode;
                                                    missdr["PriceCode"] = PriceCode;
                                                    missdr["From Date"] = FromDate;
                                                    missdr["To Date"] = ToDate;
                                                    missdr["Comp Contri"] = CompContri;
                                                    missdr["Dist Contri"] = DistContri;
                                                    missdr["Active"] = Active;
                                                    missdr["Remarks"] = Remarks;
                                                    missdr["ErrorMsg"] = "WARNING=From date and To date is already set for customer : " + ctx.OCRDs.Where(x => x.CustomerID == objOCRD.CustomerID).Select(x => x.CustomerCode + " - " + x.CustomerName).DefaultIfEmpty().FirstOrDefault();
                                                    missdata.Rows.Add(missdr);
                                                    flag = false;
                                                }
                                            }
                                        }
                                        else
                                        {
                                            DataRow missdr = missdata.NewRow();
                                            missdr["Division Code"] = DivisionCode;
                                            missdr["Customer Code"] = CustCode;
                                            missdr["PriceCode"] = PriceCode;
                                            missdr["From Date"] = FromDate;
                                            missdr["To Date"] = ToDate;
                                            missdr["Comp Contri"] = CompContri;
                                            missdr["Dist Contri"] = DistContri;
                                            missdr["Active"] = Active;
                                            missdr["Remarks"] = Remarks;
                                            missdr["ErrorMsg"] = "Please enter Division Code in Customer Code '" + CustCode + "'";
                                            missdata.Rows.Add(missdr);
                                            flag = false;
                                        }
                                        if (string.IsNullOrEmpty(PriceCode))
                                        {
                                            DataRow missdr = missdata.NewRow();
                                            missdr["Division Code"] = DivisionCode;
                                            missdr["Customer Code"] = CustCode;
                                            missdr["PriceCode"] = PriceCode;
                                            missdr["From Date"] = FromDate;
                                            missdr["To Date"] = ToDate;
                                            missdr["Comp Contri"] = CompContri;
                                            missdr["Dist Contri"] = DistContri;
                                            missdr["Active"] = Active;
                                            missdr["Remarks"] = Remarks;
                                            missdr["ErrorMsg"] = "Please enter Price Code in Customer Code '" + CustCode + "'";
                                            missdata.Rows.Add(missdr);
                                            flag = false;
                                        }

                                    }
                                }
                                else
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Division Code"] = DivisionCode;
                                    missdr["Customer Code"] = CustCode;
                                    missdr["PriceCode"] = PriceCode;
                                    missdr["From Date"] = FromDate;
                                    missdr["To Date"] = ToDate;
                                    missdr["Comp Contri"] = CompContri;
                                    missdr["Dist Contri"] = DistContri;
                                    missdr["Active"] = Active;
                                    missdr["Remarks"] = Remarks;
                                    missdr["ErrorMsg"] = "Data is not proper.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                            }
                        }
                    }

                    if (flag)
                    {
                        if (dtDATA != null && dtDATA.Rows != null && dtDATA.Rows.Count > 0)
                        {
                            using (DDMSEntities ctx = new DDMSEntities())
                            {
                                foreach (DataRow item in dtDATA.Rows)
                                {
                                    try
                                    {
                                        string DivisionCode = item["Division Code"].ToString();
                                        string CustCode = item["Customer Code"].ToString();
                                        string PriceCode = item["PriceCode"].ToString();
                                        string CompContri = item["Comp Contri"].ToString();
                                        string DistContri = item["Dist Contri"].ToString();
                                        string Active = item["Active"].ToString();
                                        string Remarks = item["Remarks"].ToString();
                                        var objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == CustCode && x.Active);
                                        var objODIV = ctx.ODIVs.FirstOrDefault(x => x.DivisionCode == DivisionCode && x.Active);
                                        var objOIPL = ctx.OIPLs.FirstOrDefault(x => x.Name == PriceCode && x.Active);

                                        if (objOCRD != null)
                                        {
                                            DateTime FromDate = Convert.ToDateTime(item["From Date"].ToString());
                                            DateTime ToDate = Convert.ToDateTime(item["To Date"].ToString());
                                            Decimal CompContrib = decimal.TryParse(CompContri, out CompContrib) ? CompContrib : 0;
                                            Decimal DistContrib = decimal.TryParse(DistContri, out DistContrib) ? DistContrib : 0;

                                            var objORCLM = ctx.ORCLMs.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID && x.DivisionID == objODIV.DivisionlID && EntityFunctions.TruncateTime(x.FromDate) == EntityFunctions.TruncateTime(FromDate) && EntityFunctions.TruncateTime(x.ToDate) == EntityFunctions.TruncateTime(ToDate));

                                            if (objORCLM == null)
                                            {
                                                var count = ctx.ORCLMs.Any(x => x.CustomerID == objOCRD.CustomerID && x.DivisionID == objODIV.DivisionlID &&
                                                    ((EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(FromDate) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(ToDate))
                                                 || (EntityFunctions.TruncateTime(FromDate) <= EntityFunctions.TruncateTime(x.FromDate) && EntityFunctions.TruncateTime(ToDate) >= EntityFunctions.TruncateTime(x.ToDate))
                                                 || (EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(FromDate) && EntityFunctions.TruncateTime(FromDate) <= EntityFunctions.TruncateTime(x.ToDate))
                                                 || (EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(ToDate) && EntityFunctions.TruncateTime(ToDate) <= EntityFunctions.TruncateTime(x.ToDate))));

                                                if (!count)
                                                {
                                                    objORCLM = new ORCLM()
                                                    {
                                                        CreatedBy = UserID,
                                                        CreatedDate = DateTime.Now
                                                    };
                                                    ctx.ORCLMs.Add(objORCLM);
                                                }
                                            }
                                            if (objORCLM != null)
                                            {
                                                if (objODIV != null)
                                                    objORCLM.DivisionID = objODIV.DivisionlID;
                                                else
                                                    objORCLM.DivisionID = null;

                                                if (objOIPL != null)
                                                    objORCLM.PriceListID = objOIPL.PriceListID;
                                                else
                                                    objORCLM.PriceListID = null;

                                                objORCLM.CustomerID = objOCRD.CustomerID;
                                                objORCLM.FromDate = FromDate;
                                                objORCLM.ToDate = ToDate;
                                                objORCLM.CompCont = decimal.TryParse(CompContri, out CompContrib) ? CompContrib : 0;
                                                objORCLM.DistCont = decimal.TryParse(DistContri, out DistContrib) ? DistContrib : 0;
                                                objORCLM.Active = Active == "Y" ? true : false;
                                                objORCLM.UpdatedBy = UserID;
                                                objORCLM.UpdatedDate = DateTime.Now;
                                                if (!string.IsNullOrEmpty(Remarks))
                                                {
                                                    if (Remarks.Trim().Length > 100)
                                                    {
                                                        objORCLM.Remarks = Remarks.Trim().Substring(0, 100);
                                                    }
                                                    else
                                                    {
                                                        objORCLM.Remarks = Remarks.Trim();
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    catch (DbEntityValidationException ex)
                                    {
                                        var error = ex.EntityValidationErrors.First().ValidationErrors.First();
                                        if (error != null)
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + error.ErrorMessage.Replace("'", "") + "',2);", true);
                                        else
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);

                                        ORCLMUpload.Dispose();
                                        return;
                                    }
                                }
                                ctx.SaveChanges();
                            }
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);
                            gvMissdata.DataSource = null;
                            gvMissdata.DataBind();
                            divMissData.Style.Add("display", "none");
                            divCustEntry.Style.Add("display", "block");
                            ORCLMUpload.Dispose();
                            //divClaimReport.Visible = false;
                        }
                    }
                    else
                    {
                        gvMissdata.DataSource = missdata;
                        gvMissdata.DataBind();
                        divMissData.Visible = true;
                        divCustEntry.Style.Add("display", "none");
                        divClaimReport.Style.Add("display", "none");
                        ORCLMUpload.Dispose();
                    }
                }
                else
                {
                    ORCLMUpload.Dispose();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                }
            }
            else
            {
                ORCLMUpload.Dispose();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion
}