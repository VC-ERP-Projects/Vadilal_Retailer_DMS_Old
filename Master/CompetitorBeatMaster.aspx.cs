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
using System.Data.SqlClient;

[Serializable]
public class OCRUTCUST
{
    public int OCOMPID { get; set; }
    public string Code { get; set; }
    public string CompetitorName { get; set; }
    public string City { get; set; }
    public string Mobile { get; set; }
    public string CreatedDateTime { get; set; }
    public string CreatedBy { get; set; }
    public string TemporaryCode { get; set; }
    public string DistributorCode { get; set; }
    public string UpdatedDateTime { get; set; }
    public string UpdatedBy { get; set; }
    public string Active { get; set; }
    public int IsChange { get; set; }
}

public partial class Master_CompetitorBeatMaster : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType, Index;
    protected decimal ParentID;
    protected String AuthType;

    private List<OCRUTCUST> RutCustomers
    {
        get { return this.ViewState["OCRUTCUST"] as List<OCRUTCUST>; }
        set { this.ViewState["OCRUTCUST"] = value; }
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
        if (chkMode.Checked)
        {

            chckCopyBeat.Visible = false;
            lblCopyBeat.Visible = false;
            acettxtCBCode.Enabled = false;
            txtCBCode.Text = "Auto Generated";
            txtCBCode.Enabled = false;
            txtName.Focus();
            txtCBCode.Style.Remove("background-color");
        }
        else
        {

            chckCopyBeat.Visible = true;
            chckCopyBeat.Checked = false;
            txtCopyPrefSP.Text = "";
            lblCopyBeat.Visible = true;
            acettxtCBCode.Enabled = true;
            txtCBCode.Text = "";
            txtCBCode.Enabled = true;
            txtCBCode.Focus();
            txtCBCode.Style.Add("background-color", "rgb(250, 255, 189);");
        }

        acettxtCBCode.ContextKey = acettxtMoveRouteCode.ContextKey = ParentID.ToString();

        RutCustomers = new List<OCRUTCUST>();
        OCRUTCUST objRut = new OCRUTCUST();
        RutCustomers.Add(objRut);

        gvCustomer.DataSource = RutCustomers;
        gvCustomer.DataBind();

        ViewState["CompRouteID"] = null;
        chkAcitve.Checked = true;
        txtNotes.Text = txtCode.Text = txtMoveRouteCode.Text = txtName.Text = txtCreatedBy.Text = txtCreatedTime.Text = txtUpdatedBy.Text = txtUpdatedTime.Text = "";
        ddlActivity.SelectedValue = "0";


        gvMissdataEmployee.DataSource = null;
        gvMissdataEmployee.DataBind();
        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "$.cookie('Route',0);", true);
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnImportEmployee);
        ValidateUser();
        if (!IsPostBack)
        {
            acettxtCBCode.ServiceMethod = "GetCompetitorRoute";
            ClearAllInputs();
        }
    }

    #endregion

    #region TransferCreateCSV
    public static void TransferCreateCSV(string filePath, DataTable dt, DataRow[] drs)
    {
        StreamWriter sw = null;
        int iColCount = dt.Columns.Count;
        if (!File.Exists(filePath))
        {
            sw = new StreamWriter(filePath, false);

            for (int i = 0; i < iColCount; i++)
            {
                sw.Write(dt.Columns[i]);
                if (i < iColCount - 1)
                {
                    sw.Write(",");
                }
            }
            sw.Write(sw.NewLine);
        }
        else
            sw = new StreamWriter(filePath, true);

        foreach (DataRow dr in drs)
        {
            for (int i = 0; i < iColCount; i++)
            {
                if (!Convert.IsDBNull(dr[i]))
                {
                    sw.Write(dr[i].ToString());
                }
                if (i < iColCount - 1)
                {
                    sw.Write(",");
                }
            }
            sw.Write(sw.NewLine);
        }
        sw.Close();
    }
    #endregion

    #region TransferCSVToTable
    public static void TransferCSVToTable(string filePath, DataTable dt)
    {
        try
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
        catch (Exception)
        {

        }
    }
    #endregion

    #region Button Click

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string CheckDuplicateCust(string ID, string Route, int SPID)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (ID != "" && ID.Split(",".ToArray()).Length > 0)
                {
                    int RID = ctx.OCRUTs.Where(x => x.RouteCode == Route).Select(x => x.CompRouteID).DefaultIfEmpty(0).FirstOrDefault();
                    List<string> resultID = ID.Split(",".ToArray()).ToList();
                    foreach (string CustID in resultID)
                    {
                        Decimal custid = Decimal.TryParse(CustID, out custid) ? custid : 0;

                        if (custid > 0 && ctx.CRUT1.Any(x => x.OCOMPID == custid && x.CompRouteID != RID && x.OCRUT.PrefSalesPersonID != SPID && x.Active && !x.IsDeleted))
                        {
                            var str = "";
                            ctx.CRUT1.Where(x => x.OCOMPID == custid && x.CompRouteID != RID && x.OCRUT.PrefSalesPersonID != SPID && x.Active && !x.IsDeleted).Select(x => x.OCRUT.RouteCode + " # " + x.OCRUT.OEMP.EmpCode).ToList().ForEach(x => str += x + ", ");
                            str = str.TrimEnd(", ".ToArray());
                            return "2|Customer : " + ctx.OCOMPs.FirstOrDefault(x => x.OCOMPID == custid).Code + " already assign to Route Code and Employee : " + str;
                        }
                    }

                }
                return "1|";
            }
        }
        catch (Exception ex)
        {
            return "2|" + Common.GetString(ex);
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    string IPAdd = hdnIPAdd.Value;
                    if (IPAdd == "undefined")
                        IPAdd = "";
                    if (IPAdd.Length > 15)
                        IPAdd = IPAdd = IPAdd.Substring(0, 15);
                    int CompRouteID = 0;
                    OCRUT objRoute = null;

                    if (ViewState["CompRouteID"] != null && Int32.TryParse(ViewState["CompRouteID"].ToString(), out CompRouteID))
                    {
                        if (ctx.OCRUTs.Any(x => x.ParentID == ParentID && x.RouteName == txtName.Text && x.CompRouteID != CompRouteID))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Beat Name is not allowed.',3);", true);
                            return;
                        }
                        objRoute = ctx.OCRUTs.Include("CRUT1").FirstOrDefault(x => x.CompRouteID == CompRouteID && x.ParentID == ParentID);
                    }
                    else
                    {
                        if (ctx.OCRUTs.Any(x => x.ParentID == ParentID && x.RouteName == txtName.Text))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Beat Name is not allowed.',3);", true);
                            return;
                        }
                        objRoute = new OCRUT();
                        objRoute.CompRouteID = ctx.GetKey("OCRUT", "CompRouteID", "", ParentID, 0).FirstOrDefault().Value;
                        objRoute.ParentID = ParentID;
                        objRoute.CreatedDate = DateTime.Now;
                        objRoute.CreatedBy = UserID;
                        objRoute.RouteCode = "CB" + objRoute.CompRouteID.ToString("D5");
                        objRoute.CreatedIpAddress = IPAdd;
                        ctx.OCRUTs.Add(objRoute);
                    }
                    objRoute.RouteName = txtName.Text;

                    int EmpID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : 0;

                    if (EmpID == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Proper Sales Person.',3);", true);
                        return;
                    }
                    else
                        objRoute.PrefSalesPersonID = EmpID;

                    objRoute.Notes = txtNotes.Text;
                    objRoute.UpdatedDate = DateTime.Now;
                    objRoute.UpdatedBy = UserID;
                    objRoute.UpdatedIpAddress = IPAdd;
                    objRoute.Active = chkAcitve.Checked;

                    int Count = ctx.GetKey("CRUT1", "CRUT1ID", "", ParentID, 0).FirstOrDefault().Value;
                    int CustID = 0;
                    int MoveRouteID = 0;
                    if (!string.IsNullOrEmpty(txtMoveRouteCode.Text) && txtMoveRouteCode.Text.Split("-".ToArray()).Length > 0)
                        MoveRouteID = Int32.TryParse(txtMoveRouteCode.Text.Split("-".ToArray()).LastOrDefault(), out MoveRouteID) ? MoveRouteID : 0;

                    objRoute.CRUT1.ToList().ForEach(x => x.IsDeleted = true);
                    foreach (GridViewRow item in gvCustomer.Rows)
                    {
                        Label lblCustID = (Label)item.FindControl("lblCustID");
                        TextBox txtCustCode = (TextBox)item.FindControl("txtCustCode");
                        HtmlInputHidden lblIsChange = (HtmlInputHidden)item.FindControl("lblIsChange");
                        int IsDataChange = lblIsChange != null && int.TryParse(lblIsChange.Value, out IsDataChange) ? IsDataChange : 0;
                        if (int.TryParse(lblCustID.Text, out CustID) && CustID > 0)
                        {
                            if (ctx.OCOMPs.Any(x => x.OCOMPID == CustID))
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                CRUT1 objCRUT1 = objRoute.CRUT1.FirstOrDefault(x => x.OCOMPID == CustID);
                                if (objCRUT1 == null)
                                {
                                    objCRUT1 = new CRUT1();
                                    objCRUT1.CRUT1ID = Count++;
                                    objCRUT1.OCOMPID = CustID;
                                    objCRUT1.Active = true;
                                    objCRUT1.CreatedBy = UserID;
                                    objCRUT1.CreatedDate = DateTime.Now;
                                    objRoute.CRUT1.Add(objCRUT1);
                                }
                                objCRUT1.IsDeleted = false;
                                if (IsDataChange > 0)
                                {
                                    objCRUT1.UpdatedBy = UserID;
                                    objCRUT1.UpdatedDate = DateTime.Now;
                                }
                                if (chkCheck.Checked)
                                {
                                    if (ddlActivity.SelectedValue == "1")
                                    {
                                        var str = CheckDuplicateCust(CustID.ToString(), objRoute.RouteCode, objRoute.PrefSalesPersonID.Value);
                                        if (str.Contains("1|"))
                                        {
                                            objCRUT1.Active = true;
                                        }
                                        else
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + str.Split("|".ToArray()).Last() + "',3);", true);
                                            return;
                                        }

                                    }
                                    else if (ddlActivity.SelectedValue == "2")
                                    {
                                        //NO NEED TO CHECK FOR DUBLICATE
                                        objCRUT1.Active = false;
                                    }
                                    else if (ddlActivity.SelectedValue == "3")
                                    {
                                        if (MoveRouteID > 0)
                                        {
                                            if (!ctx.CRUT1.Any(x => x.CompRouteID == MoveRouteID && x.ParentID == ParentID && x.OCOMPID == CustID))
                                            {
                                                objCRUT1.CompRouteID = MoveRouteID;
                                                objCRUT1.IsDeleted = false;
                                                objCRUT1.Active = true;
                                                var RouteData = ctx.OCRUTs.Where(x => x.CompRouteID == MoveRouteID).Select(x => new { x.RouteCode, PrefSalesPersonID = x.PrefSalesPersonID.Value }).FirstOrDefault();
                                                var str = CheckDuplicateCust(CustID.ToString(), RouteData.RouteCode, RouteData.PrefSalesPersonID);
                                                if (str.Contains("1|"))
                                                {

                                                }
                                                else
                                                {
                                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + str.Split("|".ToArray()).Last() + "',3);", true);
                                                    return;
                                                }
                                            }
                                            else
                                            {
                                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + txtCustCode.Text.Trim() + " customer is already exists in selected move beat',3);", true);
                                                return;
                                            }
                                        }
                                        else
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Move beat is not select proper',3);", true);
                                            return;
                                        }
                                    }
                                }
                                else
                                {
                                    if (objCRUT1.Active)
                                    {
                                        var str = CheckDuplicateCust(CustID.ToString(), objRoute.RouteCode, objRoute.PrefSalesPersonID.Value);
                                        if (str.Contains("1|"))
                                        {
                                            //NOTHING
                                        }
                                        else
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + str.Split("|".ToArray()).Last() + "',3);", true);
                                            return;
                                        }
                                    }
                                }
                            }
                            else
                            {

                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Customer " + txtCustCode.Text + " does not belong to this beat type.',3);", true);
                                return;
                            }
                        }
                    }
                    ctx.SaveChanges();
                    ClearAllInputs();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record Submitted Successfully : " + objRoute.RouteName + "',1);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Page is invalid!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Master.aspx");
    }

    protected void btnImportEmployee_Click(object sender, EventArgs e)
    {
        DataTable missdata = new DataTable();
        missdata.Columns.Add("Sr");
        missdata.Columns.Add("EmpCode");
        missdata.Columns.Add("AverageCallMinutes");
        missdata.Columns.Add("ProductiveCall");
        missdata.Columns.Add("NonProductiveCall");
        missdata.Columns.Add("ErrorMsg");
        missdata.Columns.Add("LoginEmpID");

        int rowcount = 0;
        try
        {
            bool flag = true;
            using (DDMSEntities ctx = new DDMSEntities())
            {

                if (flEUpload.HasFile)
                {
                    if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                        System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                    string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flEUpload.PostedFile.FileName));
                    flEUpload.PostedFile.SaveAs(fileName);
                    string ext = Path.GetExtension(flEUpload.PostedFile.FileName);
                    if (ext.ToLower() == ".csv")
                    {
                        DataTable dt = new DataTable();

                        TransferCSVToTable(fileName, dt);

                        if (dt != null && dt.Rows != null && dt.Rows.Count > 0)
                        {
                            foreach (DataRow item in dt.Rows)
                            {
                                rowcount++;
                                flag = true;
                                String EmpCode = item["EmployeeCode"].ToString().Trim();
                                int AverageCallMinutes = Int32.TryParse(item["AverageCallMinutes"].ToString().Trim(), out AverageCallMinutes) ? AverageCallMinutes : 0;
                                int ProductiveCall = Int32.TryParse(item["ProductiveCall"].ToString().Trim(), out ProductiveCall) ? ProductiveCall : 0;
                                int NonProductiveCall = Int32.TryParse(item["NonProductiveCall"].ToString().Trim(), out NonProductiveCall) ? NonProductiveCall : 0;

                                if (string.IsNullOrEmpty(EmpCode))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Sr"] = rowcount;
                                    missdr["LoginEmpID"] = UserID;
                                    missdr["EmpCode"] = EmpCode;
                                    missdr["AverageCallMinutes"] = item["AverageCallMinutes"].ToString();
                                    missdr["ProductiveCall"] = item["ProductiveCall"].ToString();
                                    missdr["NonProductiveCall"] = item["NonProductiveCall"].ToString();
                                    missdr["ErrorMsg"] = "Blank row found please remove blank row.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (!ctx.OEMPs.Any(x => x.EmpCode == EmpCode && x.ParentID == ParentID && x.Active))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Sr"] = rowcount;
                                    missdr["LoginEmpID"] = UserID;
                                    missdr["EmpCode"] = EmpCode;
                                    missdr["AverageCallMinutes"] = item["AverageCallMinutes"].ToString();
                                    missdr["ProductiveCall"] = item["ProductiveCall"].ToString();
                                    missdr["NonProductiveCall"] = item["NonProductiveCall"].ToString();
                                    missdr["ErrorMsg"] = "Employee Code: " + EmpCode + " does not exist or is In-Active.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (AverageCallMinutes <= 0 || ProductiveCall <= 0 || NonProductiveCall <= 0)
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Sr"] = rowcount;
                                    missdr["LoginEmpID"] = UserID;
                                    missdr["EmpCode"] = EmpCode;
                                    missdr["AverageCallMinutes"] = item["AverageCallMinutes"].ToString();
                                    missdr["ProductiveCall"] = item["ProductiveCall"].ToString();
                                    missdr["NonProductiveCall"] = item["NonProductiveCall"].ToString();
                                    missdr["ErrorMsg"] = "Minus or ZERO Value is not allow.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Sr"] = rowcount;
                                    missdr["EmpCode"] = EmpCode;
                                    missdr["AverageCallMinutes"] = AverageCallMinutes;
                                    missdr["ProductiveCall"] = ProductiveCall;
                                    missdr["NonProductiveCall"] = NonProductiveCall;
                                    missdr["ErrorMsg"] = "Success";
                                    missdr["LoginEmpID"] = UserID;
                                    missdata.Rows.Add(missdr);
                                }
                                if (flag)
                                {
                                    Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                                    SqlCommand Cm = new SqlCommand();

                                    Cm.Parameters.Clear();
                                    Cm.CommandType = CommandType.StoredProcedure;
                                    Cm.CommandText = "spUpdateEmployeeRouteDetail";
                                    Cm.Parameters.Add("@EmployeeRouteChange", missdata);
                                    objClass.CommonFunctionForInsertUpdateDelete(Cm);
                                }
                            }
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);
                        }
                        else
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('No Record Found!',3);", true);
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                }

                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please select atleast one file!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        finally
        {
            gvMissdataEmployee.DataSource = missdata;
            gvMissdataEmployee.DataBind();

        }
    }

    protected void btnCopyBeat_Click(object sender, EventArgs e)
    {
        Int32 BeatID = Int32.TryParse(txtCBCode.Text.Split("-".ToArray()).First().Trim(), out BeatID) ? BeatID : 0;
        string IPAdd = hdnIPAdd.Value;
        if (IPAdd == "undefined")
            IPAdd = "";
        if (IPAdd.Length > 15)
            IPAdd = IPAdd = IPAdd.Substring(0, 15);
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int CompRouteID = 0;
                if (ViewState["CompRouteID"] != null && Int32.TryParse(ViewState["CompRouteID"].ToString(), out CompRouteID))
                {
                    Int32 CopySP = 0;
                    if (txtCopyPrefSP.Text.Split("-".ToArray()).Length >= 3)
                        CopySP = Int32.TryParse(txtCopyPrefSP.Text.Split("-".ToArray()).Last().Trim(), out CopySP) ? CopySP : 0;
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select Copy Sales Person',2);", true);
                        return;
                    }

                    OCRUT objOCRUTFrom = ctx.OCRUTs.Include("CRUT1").FirstOrDefault(x => x.CompRouteID == CompRouteID);
                    OCRUT objOCRUTTo = new OCRUT();

                    var properties = CollectionExtensions.GetProperty(typeof(OCRUT).GetProperties());
                    foreach (string item in properties)
                        objOCRUTTo.GetType().GetProperty(item).SetValue(objOCRUTTo, objOCRUTFrom.GetType().GetProperty(item).GetValue(objOCRUTFrom, null), null);

                    objOCRUTTo.CompRouteID = ctx.GetKey("OCRUT", "CompRouteID", "", 0, 0).FirstOrDefault().Value;
                    objOCRUTTo.ParentID = objOCRUTFrom.ParentID;
                    objOCRUTTo.RouteCode = "CB" + objOCRUTTo.CompRouteID.ToString("D5"); ;
                    if (objOCRUTFrom.RouteName.Split("_".ToArray()).Length > 1)
                        objOCRUTTo.RouteName = objOCRUTFrom.RouteName.Substring(0, objOCRUTFrom.RouteName.LastIndexOf("_")).Trim();
                    else
                        objOCRUTTo.RouteName = objOCRUTFrom.RouteName + "_COPY";
                    objOCRUTTo.PrefSalesPersonID = CopySP;
                    objOCRUTTo.Notes = txtNotes.Text;
                    objOCRUTTo.CreatedDate = DateTime.Now;
                    objOCRUTTo.CreatedBy = UserID;
                    objOCRUTTo.UpdatedDate = DateTime.Now;
                    objOCRUTTo.UpdatedBy = UserID;
                    objOCRUTTo.Active = objOCRUTFrom.Active;
                    objOCRUTTo.CreatedIpAddress = IPAdd;
                    ctx.OCRUTs.Add(objOCRUTTo);

                    objOCRUTFrom.Active = false;
                    objOCRUTFrom.UpdatedBy = UserID;
                    objOCRUTFrom.UpdatedDate = DateTime.Now;

                    int CRUT1Count = ctx.GetKey("CRUT1", "CRUT1ID", "", 0, 0).FirstOrDefault().Value;
                    var List = objOCRUTFrom.CRUT1.Where(x => x.Active).OrderBy(x => x.CRUT1ID).ToList();
                    foreach (CRUT1 objCRUT1From in List)
                    {
                        if (objCRUT1From.OCOMP.Active)
                        {
                            CRUT1 objCRUT1To = new CRUT1();
                            properties = CollectionExtensions.GetProperty(typeof(CRUT1).GetProperties());
                            foreach (string item in properties)
                                objCRUT1To.GetType().GetProperty(item).SetValue(objCRUT1To, objCRUT1From.GetType().GetProperty(item).GetValue(objCRUT1From, null), null);

                            objCRUT1To.CRUT1ID = CRUT1Count++;
                            objCRUT1To.ParentID = objCRUT1From.ParentID;
                            objCRUT1To.CompRouteID = objOCRUTTo.CompRouteID;
                            objCRUT1To.OCOMPID = objCRUT1From.OCOMPID;
                            objCRUT1To.Active = objCRUT1From.Active;
                            objCRUT1To.IsDeleted = objCRUT1From.IsDeleted;
                            objOCRUTTo.CRUT1.Add(objCRUT1To);
                        }
                        objCRUT1From.Active = false;
                    }
                    ctx.SaveChanges();

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully : " + objOCRUTTo.RouteCode + " # " + objOCRUTTo.RouteName + "',1);", true);
                    ClearAllInputs();
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select Proper Beat.',3);", true);
                    return;
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void gvMissdataEmployee_PreRender(object sender, EventArgs e)
    {
        if (gvMissdataEmployee.Rows.Count > 0)
        {
            gvMissdataEmployee.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvMissdataEmployee.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    #region Change Events

    protected void txtCustCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            TextBox txtCustCode = (TextBox)sender;
            GridViewRow Currentgvr = (GridViewRow)txtCustCode.NamingContainer;
            if (txtCustCode != null && !String.IsNullOrEmpty(txtCustCode.Text))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    string Code = txtCustCode.Text.Split("-".ToArray()).FirstOrDefault().Trim();
                    if (ctx.OCOMPs.Any(x => x.Code == Code && x.Active))
                    {
                        OCOMP Cust = ctx.OCOMPs.FirstOrDefault(x => x.Code == Code && x.Active);
                        if (Cust != null)
                        {
                            var CustInDMS = ctx.AOCRDs.Where(x => x.CustomerID == Cust.OCOMPID).FirstOrDefault();
                            if (CustInDMS != null && !CustInDMS.Active)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('DMS status is in-active.',3);", true);
                                txtCustCode.Text = "";
                                txtCustCode.Focus();
                                return;
                            }
                        }

                        bool BeatStatus;
                        string beatstatus;

                        if (ctx.CRUT1.Any(x => x.OCOMPID == Cust.OCOMPID))
                        {
                            var beatlist = ctx.CRUT1.Where(x => x.OCOMPID == Cust.OCOMPID && x.Active);    // which routeid will be consider in this?
                            BeatStatus = beatlist.Count() >= 0 ? true : false;//If another route contains the same customer with in-active status then in another route that customer add this customer then it must shown as active bu default.
                            beatstatus = BeatStatus == true ? "True" : "False";
                        }
                        else
                        {
                            BeatStatus = true;//As it is exist in any beat Bydeafult True.
                            beatstatus = BeatStatus == true ? "True" : "False";
                        }

                        if (!RutCustomers.Any(x => x.OCOMPID == Cust.OCOMPID))
                        {
                            if (!ctx.OCOMPs.Any(x => x.OCOMPID == Cust.OCOMPID))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Customer #" + txtCustCode.Text + " does not belong to this beat type.',3);", true);
                                txtCustCode.Text = "";
                                txtCustCode.Focus();

                                RutCustomers[Currentgvr.RowIndex].OCOMPID = 0;
                                RutCustomers[Currentgvr.RowIndex].Code = null;
                                RutCustomers[Currentgvr.RowIndex].CompetitorName = null;
                                RutCustomers[Currentgvr.RowIndex].City = null;
                                RutCustomers[Currentgvr.RowIndex].Mobile = null;
                                RutCustomers[Currentgvr.RowIndex].CreatedDateTime = null;
                                RutCustomers[Currentgvr.RowIndex].CreatedBy = null;
                                RutCustomers[Currentgvr.RowIndex].TemporaryCode = null;
                                RutCustomers[Currentgvr.RowIndex].DistributorCode = null;
                                RutCustomers[Currentgvr.RowIndex].UpdatedDateTime = null;
                                RutCustomers[Currentgvr.RowIndex].UpdatedBy = null;
                                RutCustomers[Currentgvr.RowIndex].Active = null;
                                RutCustomers[Currentgvr.RowIndex].IsChange = 0;

                                gvCustomer.DataSource = RutCustomers;
                                gvCustomer.DataBind();
                            }
                            else
                            {
                                var CityName = "";
                                CityName = ctx.OCTies.Where(x => x.CityID == Cust.CityID).Select(x => x.CityName).FirstOrDefault();
                                var CreatedBy = ctx.OEMPs.Where(x => x.EmpID == Cust.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " - " + x.Name).FirstOrDefault();
                                var objTempCode = ctx.OCRDs.Where(x => x.CompetitorID == Cust.OCOMPID && x.IsTemp && x.Type == 3).FirstOrDefault();
                                var TempCode = objTempCode != null ? objTempCode.CustomerCode : "";
                                var DistCode = objTempCode != null ? ctx.OCRDs.Where(x => x.CustomerID == objTempCode.ParentID).Select(x => x.CustomerCode + " - " + x.CustomerName).FirstOrDefault() : "";
                                var UpdatedBy = ctx.OEMPs.Where(x => x.EmpID == Cust.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " - " + x.Name).FirstOrDefault();

                                RutCustomers[Currentgvr.RowIndex].OCOMPID = Cust.OCOMPID;
                                RutCustomers[Currentgvr.RowIndex].Code = Cust.Code;
                                RutCustomers[Currentgvr.RowIndex].CompetitorName = Cust.CustomerName;
                                RutCustomers[Currentgvr.RowIndex].Mobile = Cust.Phone;
                                RutCustomers[Currentgvr.RowIndex].City = CityName;
                                RutCustomers[Currentgvr.RowIndex].TemporaryCode = TempCode;
                                RutCustomers[Currentgvr.RowIndex].DistributorCode = DistCode;
                                RutCustomers[Currentgvr.RowIndex].Active = Cust.Active ? "Y" : "N";
                                RutCustomers[Currentgvr.RowIndex].IsChange = 1;

                                if ((Currentgvr.RowIndex + 1) == RutCustomers.Count)
                                {
                                    RutCustomers.Add(new OCRUTCUST());
                                }
                                gvCustomer.DataSource = RutCustomers;
                                gvCustomer.DataBind();
                            }
                        }

                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same customer already exist.',3);", true);
                            txtCustCode.Text = "";
                            txtCustCode.Focus();

                            RutCustomers[Currentgvr.RowIndex].OCOMPID = 0;
                            RutCustomers[Currentgvr.RowIndex].Code = null;
                            RutCustomers[Currentgvr.RowIndex].CompetitorName = null;
                            RutCustomers[Currentgvr.RowIndex].City = null;
                            RutCustomers[Currentgvr.RowIndex].Mobile = null;
                            RutCustomers[Currentgvr.RowIndex].CreatedDateTime = null;
                            RutCustomers[Currentgvr.RowIndex].CreatedBy = null;
                            RutCustomers[Currentgvr.RowIndex].TemporaryCode = null;
                            RutCustomers[Currentgvr.RowIndex].DistributorCode = null;
                            RutCustomers[Currentgvr.RowIndex].UpdatedDateTime = null;
                            RutCustomers[Currentgvr.RowIndex].UpdatedBy = null;
                            RutCustomers[Currentgvr.RowIndex].Active = null;
                            RutCustomers[Currentgvr.RowIndex].IsChange = 0;

                            gvCustomer.DataSource = RutCustomers;
                            gvCustomer.DataBind();
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper competitor.',3);", true);
                        txtCustCode.Text = "";
                        txtCustCode.Focus();

                        RutCustomers[Currentgvr.RowIndex].OCOMPID = 0;
                        RutCustomers[Currentgvr.RowIndex].Code = null;
                        RutCustomers[Currentgvr.RowIndex].CompetitorName = null;
                        RutCustomers[Currentgvr.RowIndex].City = null;
                        RutCustomers[Currentgvr.RowIndex].Mobile = null;
                        RutCustomers[Currentgvr.RowIndex].CreatedDateTime = null;
                        RutCustomers[Currentgvr.RowIndex].CreatedBy = null;
                        RutCustomers[Currentgvr.RowIndex].TemporaryCode = null;
                        RutCustomers[Currentgvr.RowIndex].DistributorCode = null;
                        RutCustomers[Currentgvr.RowIndex].UpdatedDateTime = null;
                        RutCustomers[Currentgvr.RowIndex].UpdatedBy = null;
                        RutCustomers[Currentgvr.RowIndex].Active = null;
                        RutCustomers[Currentgvr.RowIndex].IsChange = 0;

                        gvCustomer.DataSource = RutCustomers;
                        gvCustomer.DataBind();
                    }
                }
            }
            else
            {
                RutCustomers.RemoveAt(Currentgvr.RowIndex);
                gvCustomer.DataSource = RutCustomers;
                gvCustomer.DataBind();
            }

            gvMissdataEmployee.DataSource = null;
            gvMissdataEmployee.DataBind();
        }
        catch (Exception ex)
        {
            try
            {
                var FileName = Server.MapPath("~/Document/Log/RouteMaster.txt");
                TraceService(FileName, Common.GetString(ex));
                TraceService(FileName, ex.Source);
                TraceService(FileName, ex.StackTrace);
                TraceService(FileName, ex.Message);
            }
            catch (Exception)
            {
            }
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    private void TraceService(string path, string content)
    {
        FileStream fs = new FileStream(path, FileMode.OpenOrCreate, FileAccess.Write);
        StreamWriter sw = new StreamWriter(fs);
        sw.BaseStream.Seek(0, SeekOrigin.End);
        sw.WriteLine(content);
        sw.Close();
    }

    protected void txtCBCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && txtCBCode != null && !String.IsNullOrEmpty(txtCBCode.Text))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var word = txtCBCode.Text.Split("-".ToArray()).First().Trim();
                    var objCustRoute = ctx.OCRUTs.Include("CRUT1").Include("CRUT1.OCOMP").FirstOrDefault(x => x.RouteCode == word && x.ParentID == ParentID);

                    if (objCustRoute != null)
                    {
                        ClearAllInputs();
                        ViewState["CompRouteID"] = objCustRoute.CompRouteID;
                        txtCBCode.Text = objCustRoute.RouteCode;
                        txtName.Text = objCustRoute.RouteName;

                        txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objCustRoute.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                        txtCreatedTime.Text = objCustRoute.CreatedDate.ToString("dd-MMM-yy HH:mm");
                        txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objCustRoute.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                        txtUpdatedTime.Text = objCustRoute.UpdatedDate.ToString("dd-MMM-yy HH:mm");
                        txtCreatedIP.Text = objCustRoute.CreatedIpAddress == null ? "" : objCustRoute.CreatedIpAddress;
                        txtUpdatedIP.Text = objCustRoute.UpdatedIpAddress == null ? "" : objCustRoute.UpdatedIpAddress;


                        int EmpID = objCustRoute.PrefSalesPersonID.GetValueOrDefault(0);

                        txtCode.Text = objCustRoute.OEMP.EmpCode + " - " + objCustRoute.OEMP.Name + " - " + objCustRoute.OEMP.EmpID.ToString();


                        txtNotes.Text = objCustRoute.Notes;
                        chkAcitve.Checked = objCustRoute.Active;

                        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                        SqlCommand Cm = new SqlCommand();

                        Cm.Parameters.Clear();
                        Cm.CommandType = CommandType.StoredProcedure;
                        Cm.CommandText = "GetCompetitorBeat";
                        Cm.Parameters.AddWithValue("@CompRouteID", objCustRoute.CompRouteID);
                        DataSet ds = objClass.CommonFunctionForSelect(Cm);
                        if (ds.Tables.Count > 0)
                        {
                            RutCustomers = ds.Tables[0].AsEnumerable().Select
                           (x => new OCRUTCUST
                           {
                               OCOMPID = x.Field<int>("OCOMPID"),
                               Code = x.Field<String>("Code"),
                               CompetitorName = x.Field<String>("CompetitorName"),
                               Mobile = x.Field<String>("Phone"),
                               City = x.Field<String>("CityName"),
                               CreatedDateTime = x.Field<String>("CreatedDateTime"),
                               CreatedBy = x.Field<String>("CreatedBy"),
                               TemporaryCode = x.Field<String>("TemporaryCode"),
                               DistributorCode = x.Field<String>("DistributorCode"),
                               UpdatedDateTime = x.Field<String>("UpdatedDateTime"),
                               UpdatedBy = x.Field<String>("UpdatedBy"),
                               Active = x.Field<String>("Active"),
                               IsChange = 0
                           }).ToList();
                        }

                        if (RutCustomers == null)
                            RutCustomers = new List<OCRUTCUST>();

                        var crut1 = new OCRUTCUST();
                        //crut1.Active = true;
                        RutCustomers.Add(crut1);

                        gvCustomer.DataSource = RutCustomers;
                        gvCustomer.DataBind();
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Search proper beat!',3);", true);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtCBCode.Focus();
    }

    #endregion

    #region CheckBox Change Event

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        chckCopyBeat.Checked = false;
        ClearAllInputs();
    }

    #endregion

    #region GridView

    protected void gvCustomer_PreRender(object sender, EventArgs e)
    {
        if (gvCustomer.Rows.Count > 0)
        {
            gvCustomer.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvCustomer.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

}