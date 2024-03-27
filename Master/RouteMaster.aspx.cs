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
public class RUTCUST
{
    public Decimal CustomerID { get; set; }
    public string Customer { get; set; }
    public string Phone { get; set; }
    public string Location { get; set; }
    public string Parent { get; set; }
    public string CityName { get; set; }
    public string CustGroupDesc { get; set; }
    public Boolean BActive { get; set; }
    public Boolean CActive { get; set; }
    public string PricingGroup { get; set; }
    public string Status { get; set; }
}

public partial class Marketing_RouteMaster_aspx : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType, Index;
    protected decimal ParentID;
    protected String AuthType;

    private List<RUTCUST> RutCustomers
    {
        get { return this.ViewState["RUTCUST"] as List<RUTCUST>; }
        set { this.ViewState["RUTCUST"] = value; }
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
            chkSrchByParent.Visible = false;
            lblSrchByParent.Visible = false;
            chckCopyBeat.Visible = false;
            lblCopyBeat.Visible = false;
            acettxtRouteCode.Enabled = false;
            txtRouteCode.Text = "Auto Generated";
            txtRouteCode.Enabled = false;
            txtName.Focus();
            txtRouteCode.Style.Remove("background-color");
        }
        else
        {
            chkSrchByParent.Visible = true;
            lblSrchByParent.Visible = true;
            chckCopyBeat.Visible = true;
            chckCopyBeat.Checked = false;
            txtCopyPrefSP.Text = "";
            lblCopyBeat.Visible = true;
            acettxtRouteCode.Enabled = true;
            txtRouteCode.Text = "";
            txtRouteCode.Enabled = true;
            txtRouteCode.Focus();
            txtRouteCode.Style.Add("background-color", "rgb(250, 255, 189);");
        }

        acetxtName.ContextKey = (CustType + 1).ToString();
        acettxtRouteCode.ContextKey = acettxtMoveRouteCode.ContextKey = ParentID.ToString();

        RutCustomers = new List<RUTCUST>();
        RUTCUST objRut = new RUTCUST();
        RutCustomers.Add(objRut);

        gvCustomer.DataSource = RutCustomers;
        gvCustomer.DataBind();

        ViewState["RouteID"] = null;
        chkAcitve.Checked = true;
        txtNotes.Text = txtCode.Text = txtOwnCustomer.Text = txtCompCustomer.Text = txtAvgBusiness.Text = txtAvgExpense.Text = txtDistance.Text =
                      txtMoveRouteCode.Text = txtTotal.Text = txtDesc.Text = txtName.Text = txtCreatedBy.Text = txtCreatedTime.Text = txtUpdatedBy.Text = txtUpdatedTime.Text = "";
        chkMonday.Checked = chkTuesday.Checked = chkWednesday.Checked = chkThursday.Checked = chkFriday.Checked = chkSaturday.Checked = chkSunday.Checked = true;
        ddlActivity.SelectedValue = "0";

        gvMissdata.DataSource = null;
        gvMissdata.DataBind();
        gvMissdataEmployee.DataSource = null;
        gvMissdataEmployee.DataBind();
        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "$.cookie('Route',0);", true);
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnExport);
        scriptManager.RegisterPostBackControl(this.btnImport);
        scriptManager.RegisterPostBackControl(this.btnImportEmployee);
        ValidateUser();
        if (!IsPostBack)
        {
            acettxtRouteCode.ServiceMethod = "GetRoute";
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
                    int RID = ctx.ORUTs.Where(x => x.RouteCode == Route).Select(x => x.RouteID).DefaultIfEmpty(0).FirstOrDefault();
                    List<string> resultID = ID.Split(",".ToArray()).ToList();
                    foreach (string CustID in resultID)
                    {
                        Decimal custid = Decimal.TryParse(CustID, out custid) ? custid : 0;

                        if (custid > 0 && ctx.RUT1.Any(x => x.CustomerID == custid && x.RouteID != RID && x.ORUT.PrefSalesPersonID != SPID && x.Active && !x.IsDeleted))
                        {
                            var str = "";
                            ctx.RUT1.Where(x => x.CustomerID == custid && x.RouteID != RID && x.ORUT.PrefSalesPersonID != SPID && x.Active && !x.IsDeleted).Select(x => x.ORUT.RouteCode + " # " + x.ORUT.OEMP1.EmpCode).ToList().ForEach(x => str += x + ", ");
                            str = str.TrimEnd(", ".ToArray());
                            return "2|Customer : " + ctx.OCRDs.FirstOrDefault(x => x.CustomerID == custid).CustomerCode + " already assign to Route Code and Employee : " + str;
                        }
                    }

                }
                return "1|";
                //else
                //{
                //    return "2|Select Proper Route";
                //}
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
                    int RouteID = 0;
                    ORUT objRoute = null;
                    Int32 RouteType = Int32.TryParse(ddlRouteType.SelectedValue, out RouteType) ? RouteType : 0;

                    if (ViewState["RouteID"] != null && Int32.TryParse(ViewState["RouteID"].ToString(), out RouteID))
                    {
                        if (ctx.ORUTs.Any(x => x.ParentID == ParentID && x.RouteName == txtName.Text && x.RouteID != RouteID))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Beat Name is not allowed.',3);", true);
                            return;
                        }
                        objRoute = ctx.ORUTs.Include("RUT1").FirstOrDefault(x => x.RouteID == RouteID && x.ParentID == ParentID);
                    }
                    else
                    {
                        if (ctx.ORUTs.Any(x => x.ParentID == ParentID && x.RouteName == txtName.Text))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Beat Name is not allowed.',3);", true);
                            return;
                        }
                        objRoute = new ORUT();
                        objRoute.RouteID = ctx.GetKey("ORUT", "RouteID", "", ParentID, 0).FirstOrDefault().Value;
                        objRoute.ParentID = ParentID;
                        objRoute.CreatedDate = DateTime.Now;
                        objRoute.CreatedBy = UserID;
                        objRoute.RouteCode = "R" + objRoute.RouteID.ToString("D5");
                        objRoute.CreatedIpAddress = IPAdd;
                        ctx.ORUTs.Add(objRoute);
                    }
                    objRoute.RouteName = txtName.Text;
                    objRoute.Description = txtDesc.Text;
                    objRoute.Monday = chkMonday.Checked;
                    objRoute.Tuesday = chkTuesday.Checked;
                    objRoute.Wednesday = chkWednesday.Checked;
                    objRoute.Thursday = chkThursday.Checked;
                    objRoute.Friday = chkFriday.Checked;
                    objRoute.Saturday = chkSaturday.Checked;
                    objRoute.Sunday = chkSunday.Checked;
                    objRoute.RouteType = RouteType;

                    int EmpID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : 0;

                    if (EmpID == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Proper Sales Person.',3);", true);
                        return;
                    }
                    else
                        objRoute.PrefSalesPersonID = EmpID;

                    if (!String.IsNullOrEmpty(txtDistance.Text))
                        objRoute.DistanceKms = Convert.ToDecimal(txtDistance.Text);
                    if (!String.IsNullOrEmpty(txtAvgBusiness.Text))
                        objRoute.ExpectedBusiness = Convert.ToDecimal(txtAvgBusiness.Text);
                    if (!String.IsNullOrEmpty(txtAvgExpense.Text))
                        objRoute.ExpectedExpense = Convert.ToDecimal(txtAvgExpense.Text);

                    if (!String.IsNullOrEmpty(txtOwnCustomer.Text))
                        objRoute.OwnCustomer = Convert.ToInt32(txtOwnCustomer.Text);
                    if (!String.IsNullOrEmpty(txtCompCustomer.Text))
                        objRoute.CompCustomer = Convert.ToInt32(txtCompCustomer.Text);

                    if (!String.IsNullOrEmpty(txtTotal.Text))
                        objRoute.Total = Convert.ToDecimal(txtTotal.Text);
                    //if (!String.IsNullOrEmpty(txtNotes.Text))
                    objRoute.Notes = txtNotes.Text;
                    objRoute.Currency = Constant.Currency;
                    objRoute.UpdatedDate = DateTime.Now;
                    objRoute.UpdatedBy = UserID;
                    objRoute.UpdatedIpAddress = IPAdd;
                    objRoute.Active = chkAcitve.Checked;

                    int Count = ctx.GetKey("RUT1", "RUT1ID", "", ParentID, 0).FirstOrDefault().Value;
                    Decimal CustID = 0;
                    int MoveRouteID = 0;
                    if (!string.IsNullOrEmpty(txtMoveRouteCode.Text) && txtMoveRouteCode.Text.Split("-".ToArray()).Length > 0)
                        MoveRouteID = Int32.TryParse(txtMoveRouteCode.Text.Split("-".ToArray()).LastOrDefault(), out MoveRouteID) ? MoveRouteID : 0;

                    objRoute.RUT1.ToList().ForEach(x => x.IsDeleted = true);
                    foreach (GridViewRow item in gvCustomer.Rows)
                    {
                        Label lblCustID = (Label)item.FindControl("lblCustID");
                        TextBox txtCustCode = (TextBox)item.FindControl("txtCustCode");

                        if (Decimal.TryParse(lblCustID.Text, out CustID) && CustID > 0)
                        {
                            if (ctx.OCRDs.Any(x => x.CustomerID == CustID && x.Type == RouteType))
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                RUT1 objRUT1 = objRoute.RUT1.FirstOrDefault(x => x.CustomerID == CustID);
                                if (objRUT1 == null)
                                {
                                    objRUT1 = new RUT1();
                                    objRUT1.RUT1ID = Count++;
                                    objRUT1.CustomerID = CustID;
                                    objRUT1.BranchID = 1;
                                    objRUT1.Active = true;
                                    objRoute.RUT1.Add(objRUT1);
                                }
                                objRUT1.IsDeleted = false;
                                if (chkCheck.Checked)
                                {
                                    if (ddlActivity.SelectedValue == "1")
                                    {
                                        var str = CheckDuplicateCust(CustID.ToString(), objRoute.RouteCode, objRoute.PrefSalesPersonID.Value);
                                        if (str.Contains("1|"))
                                        {
                                            objRUT1.Active = true;
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
                                        objRUT1.Active = false;
                                    }
                                    else if (ddlActivity.SelectedValue == "3")
                                    {
                                        if (MoveRouteID > 0)
                                        {
                                            if (Convert.ToInt16(ddlRouteType.SelectedValue) == ctx.ORUTs.FirstOrDefault(x => x.RouteID == MoveRouteID).RouteType)
                                            {
                                                if (!ctx.RUT1.Any(x => x.RouteID == MoveRouteID && x.ParentID == ParentID && x.CustomerID == CustID))
                                                {
                                                    objRUT1.RouteID = MoveRouteID;
                                                    objRUT1.IsDeleted = false;
                                                    objRUT1.Active = true;
                                                    var RouteData = ctx.ORUTs.Where(x => x.RouteID == MoveRouteID).Select(x => new { x.RouteCode, PrefSalesPersonID = x.PrefSalesPersonID.Value }).FirstOrDefault();
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
                                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You cannot move customers to selected beat',3);", true);
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
                                    if (objRUT1.Active)
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

    protected void btnImport_Click(object sender, EventArgs e)
    {
        DataTable missdata = new DataTable();
        //missdata.Columns.Add("Beat Code");
        missdata.Columns.Add("Sr");
        missdata.Columns.Add("Customer Code");
        missdata.Columns.Add("Customer Name");
        missdata.Columns.Add("Error Msg");

        try
        {
            bool flag = true;

            using (DDMSEntities ctx = new DDMSEntities())
            {
                int EmpID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : 0;
                if (EmpID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Proper Sales Person.',3);", true);
                    return;
                }
                int RouteType = Convert.ToInt32(ddlRouteType.SelectedValue);

                int RouteID = 0;
                string IPAdd = hdnIPAdd.Value;
                if (IPAdd == "undefined")
                    IPAdd = "";
                if (IPAdd.Length > 15)
                    IPAdd = IPAdd = IPAdd.Substring(0, 15);
                if (ViewState["RouteID"] != null && Int32.TryParse(ViewState["RouteID"].ToString(), out RouteID))
                {
                    if (ctx.ORUTs.Any(x => x.RouteID == RouteID && x.Active))
                    {
                        ORUT objORUT = ctx.ORUTs.FirstOrDefault(x => x.RouteID == RouteID);
                        objORUT.RouteType = RouteType;
                        objORUT.PrefSalesPersonID = EmpID;
                        objORUT.UpdatedDate = DateTime.Now;
                        objORUT.UpdatedBy = UserID;
                        objORUT.UpdatedIpAddress = IPAdd;
                        if (flCUpload.HasFile)
                        {
                            if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                                System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                            string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flCUpload.PostedFile.FileName));
                            flCUpload.PostedFile.SaveAs(fileName);
                            string ext = Path.GetExtension(flCUpload.PostedFile.FileName);
                            if (ext.ToLower() == ".csv")
                            {
                                DataTable dt = new DataTable();

                                TransferCSVToTable(fileName, dt);

                                if (dt != null && dt.Rows != null && dt.Rows.Count > 0)
                                {
                                    var duplicates = (from row in dt.AsEnumerable()
                                                      select new
                                                      {
                                                          CustomerCode = row.Field<string>("CustomerCode").Trim(),
                                                          CustomerName = row.Field<string>("CustomerName").Trim()
                                                      })
                                        //.Select(dr => dr.Field<string>("CustomerCode").Trim())
                                                            .GroupBy(x => x)
                                                            .Where(g => g.Count() > 1)
                                                            .Select(g => g.Key)
                                                            .ToList();

                                    int count = 1;
                                    foreach (var item in duplicates)
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Sr"] = count.ToString();
                                        missdr["Customer Code"] = item.CustomerCode.ToString();
                                        missdr["Customer Name"] = item.CustomerName.ToString();
                                        missdr["Error Msg"] = "Duplicate Entry Found for Customer Code : " + item.CustomerCode.ToString() + "";
                                        missdata.Rows.Add(missdr);
                                        count = count + 1;
                                        flag = false;
                                    }

                                    if (!flag)
                                    {
                                        gvMissdata.DataSource = missdata;
                                        gvMissdata.DataBind();
                                        return;
                                    }

                                    foreach (DataRow item in dt.Rows)
                                    {
                                        try
                                        {
                                            string CustomerCode = item["CustomerCode"].ToString().Trim();
                                            if (!string.IsNullOrEmpty(item["CustomerCode"].ToString().Trim()))
                                            {
                                                var CustData = ctx.OCRDs.Where(x => x.CustomerCode == CustomerCode && x.Active).Select(x => new { x.Type, x.CustomerID }).FirstOrDefault();


                                                var CustInDMS = CustData != null ? ctx.AOCRDs.Where(x => x.CustomerID == CustData.CustomerID).FirstOrDefault() : null;
                                                if (CustInDMS != null && !CustInDMS.Active)
                                                {
                                                    DataRow missdr = missdata.NewRow();
                                                    missdr["Sr"] = count.ToString();
                                                    //missdr["Beat Code"] = objORUT.RouteCode;
                                                    missdr["Customer Code"] = CustomerCode;
                                                    missdr["Customer Name"] = item["CustomerName"].ToString().Trim();
                                                    missdr["Error Msg"] = "Customer Code : " + CustomerCode + " - DMS status is in-active";
                                                    missdata.Rows.Add(missdr);
                                                    count = count + 1;
                                                    flag = false;
                                                }
                                                else if (ctx.OCRDs.Any(x => x.CustomerCode == CustomerCode && x.Active))
                                                {
                                                    // Check pricing group 

                                                    if (!ctx.OGCRDs.Any(x => x.CustomerID == CustData.CustomerID && x.PriceListID.HasValue))
                                                    {
                                                        DataRow missdr = missdata.NewRow();
                                                        missdr["Sr"] = count.ToString();
                                                        //missdr["Beat Code"] = objORUT.RouteCode;
                                                        missdr["Customer Code"] = CustomerCode;
                                                        missdr["Customer Name"] = item["CustomerName"].ToString().Trim();
                                                        missdr["Error Msg"] = "Customer Pricing Group not assign to #" + CustomerCode + ".";
                                                        missdata.Rows.Add(missdr);
                                                        count = count + 1;
                                                        flag = false;
                                                    }

                                                    if (ddlRouteType.SelectedValue == "3")
                                                    {
                                                        int SalesPrefID = int.TryParse(txtCode.Text.Split('-').ToArray().Last(), out SalesPrefID) ? SalesPrefID : 0;
                                                        string Message = ctx.CheckDealerDistManagerHirarchy(SalesPrefID, CustData.CustomerID).FirstOrDefault();
                                                        if (!string.IsNullOrEmpty(Message))
                                                        {
                                                            DataRow missdr = missdata.NewRow();
                                                            missdr["Sr"] = count.ToString();
                                                            missdr["Customer Code"] = CustomerCode;
                                                            missdr["Customer Name"] = item["CustomerName"].ToString().Trim();
                                                            missdr["Error Msg"] = Message;
                                                            missdata.Rows.Add(missdr);
                                                            count = count + 1;
                                                            flag = false;
                                                        }
                                                    }


                                                    if (CustData.Type == objORUT.RouteType)
                                                    {
                                                        var str = CheckDuplicateCust(CustData.CustomerID.ToString(), objORUT.RouteCode, EmpID);
                                                        if (str.Contains("1|"))
                                                        {

                                                        }
                                                        else
                                                        {
                                                            DataRow missdr = missdata.NewRow();
                                                            missdr["Sr"] = count.ToString();
                                                            //missdr["Beat Code"] = objORUT.RouteCode;
                                                            missdr["Customer Code"] = CustomerCode;
                                                            missdr["Customer Name"] = item["CustomerName"].ToString().Trim();
                                                            missdr["Error Msg"] = str.Split("|".ToArray()).Last();
                                                            missdata.Rows.Add(missdr);
                                                            count = count + 1;
                                                            flag = false;
                                                        }
                                                    }
                                                    else
                                                    {
                                                        DataRow missdr = missdata.NewRow();
                                                        missdr["Sr"] = count.ToString();
                                                        //missdr["Beat Code"] = objORUT.RouteCode;
                                                        missdr["Customer Code"] = CustomerCode;
                                                        missdr["Customer Name"] = item["CustomerName"].ToString().Trim();
                                                        missdr["Error Msg"] = "Customer Code : " + CustomerCode + " does not belong to beat's type.";
                                                        missdata.Rows.Add(missdr);
                                                        count = count + 1;
                                                        flag = false;
                                                    }
                                                }
                                                else
                                                {
                                                    DataRow missdr = missdata.NewRow();
                                                    missdr["Sr"] = count.ToString();
                                                    //missdr["Beat Code"] = objORUT.RouteCode;
                                                    missdr["Customer Code"] = CustomerCode;
                                                    missdr["Customer Name"] = item["CustomerName"].ToString().Trim();
                                                    missdr["Error Msg"] = "Customer Code : " + CustomerCode + " Not Available.";
                                                    missdata.Rows.Add(missdr);
                                                    count = count + 1;
                                                    flag = false;
                                                }
                                            }
                                            else
                                            {
                                                DataRow missdr = missdata.NewRow();
                                                missdr["Sr"] = count.ToString();
                                                //missdr["Beat Code"] = "";
                                                missdr["Customer Code"] = CustomerCode;
                                                missdr["Customer Name"] = item["CustomerName"].ToString().Trim();
                                                missdr["Error Msg"] = "Customer Code is not proper.";
                                                missdata.Rows.Add(missdr);
                                                count = count + 1;
                                                flag = false;
                                            }
                                        }
                                        catch (Exception ex)
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
                                        }
                                    }

                                    if (flag)
                                    {
                                        Boolean firsttime = false;
                                        int RUT1Count = ctx.GetKey("RUT1", "RUT1ID", "", 0, 0).FirstOrDefault().Value;
                                        foreach (DataRow item in dt.Rows)
                                        {
                                            try
                                            {
                                                if (!string.IsNullOrEmpty(item["CustomerCode"].ToString().Trim()))
                                                {
                                                    string CustomerCode = item["CustomerCode"].ToString().Trim();
                                                    decimal CustomerID = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == CustomerCode).CustomerID;

                                                    if (firsttime == false)
                                                    {
                                                        List<RUT1> objRUT1s = ctx.RUT1.Where(x => x.RouteID == objORUT.RouteID).ToList();
                                                        objRUT1s.ForEach(x => x.Active = false);
                                                        objRUT1s.ForEach(x => x.IsDeleted = true);
                                                        firsttime = true;
                                                    }

                                                    RUT1 objRoute = ctx.RUT1.FirstOrDefault(x => x.CustomerID == CustomerID && x.RouteID == objORUT.RouteID);
                                                    if (objRoute == null)
                                                    {
                                                        objRoute = new RUT1();
                                                        objRoute.RUT1ID = RUT1Count++;
                                                        objRoute.CustomerID = CustomerID;
                                                        objRoute.ParentID = ParentID;
                                                        ctx.RUT1.Add(objRoute);
                                                    }
                                                    objRoute.RouteID = objORUT.RouteID;
                                                    objRoute.Active = true;
                                                    objRoute.BranchID = 1;
                                                    objRoute.IsDeleted = false;
                                                }
                                            }
                                            catch (Exception ex)
                                            {
                                                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
                                            }
                                        }
                                        ctx.SaveChanges();
                                        gvMissdata.DataSource = null;
                                        gvMissdata.DataBind();
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "alert('Process completed.',1); window.location.href=window.location.href;", true);

                                    }
                                    else
                                    {
                                        gvMissdata.DataSource = missdata;
                                        gvMissdata.DataBind();
                                    }
                                }
                                else

                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('No Record Found!',3);", true);
                            }
                            else
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                        }
                        else
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please select proper beat',3);", true);
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please select proper beat',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                string Date = DateTime.Now.ToString("dd/MM/yyyy");
                string RouteCode = txtRouteCode.Text;
                if (!string.IsNullOrEmpty(RouteCode))
                {

                    var qry = (from a in ctx.RUT1
                               join b in ctx.ORUTs on a.RouteID equals b.RouteID
                               join c in ctx.OCRDs on a.CustomerID equals c.CustomerID
                               where b.RouteCode == RouteCode && a.Active && !a.IsDeleted
                               select new { CustomerCode = c.CustomerCode, CustomerName = c.CustomerName, BeatCode = b.RouteCode, BeatName = b.RouteName }).ToList();

                    Response.Clear();
                    Response.Buffer = true;
                    GridView grd = new GridView();
                    grd.DataSource = qry;
                    grd.DataBind();
                    string FileName = "RouteMaster_" + Date + ".csv";
                    Response.AddHeader("content-disposition", "attachment;filename=" + FileName);
                    Response.Charset = "";
                    Response.ContentType = "application/text";
                    StringBuilder sBuilder = new System.Text.StringBuilder();
                    sBuilder.Append("CustomerCode");
                    sBuilder.Append(",");
                    sBuilder.Append("CustomerName");
                    sBuilder.Append(",");
                    sBuilder.Append("BeatCode");
                    sBuilder.Append(",");
                    sBuilder.Append("BeatName");

                    sBuilder.Append("\r\n");
                    for (int i = 0; i < grd.Rows.Count; i++)
                    {
                        for (int k = 0; k < grd.HeaderRow.Cells.Count; k++)
                        {
                            sBuilder.Append(grd.Rows[i].Cells[k].Text.Replace(",", "") + ",");
                        }
                        sBuilder.Append("\r\n");
                    }
                    Response.Output.Write(sBuilder.ToString());
                    Response.Flush();
                    Response.End();

                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select proper Beat Code!',3);", true);
                    return;

                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);

        }
    }

    protected void btnCopyBeat_Click(object sender, EventArgs e)
    {
        Int32 BeatID = Int32.TryParse(txtRouteCode.Text.Split("-".ToArray()).First().Trim(), out BeatID) ? BeatID : 0;
        string IPAdd = hdnIPAdd.Value;
        if (IPAdd == "undefined")
            IPAdd = "";
        if (IPAdd.Length > 15)
            IPAdd = IPAdd = IPAdd.Substring(0, 15);
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int RouteID = 0;
                if (ViewState["RouteID"] != null && Int32.TryParse(ViewState["RouteID"].ToString(), out RouteID))
                {
                    Int32 CopySP = 0;
                    if (txtCopyPrefSP.Text.Split("-".ToArray()).Length >= 3)
                        CopySP = Int32.TryParse(txtCopyPrefSP.Text.Split("-".ToArray()).Last().Trim(), out CopySP) ? CopySP : 0;
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select Copy Sales Person',2);", true);
                        return;
                    }

                    ORUT objORUTFrom = ctx.ORUTs.Include("RUT1").FirstOrDefault(x => x.RouteID == RouteID);
                    ORUT objORUTTo = new ORUT();

                    var properties = CollectionExtensions.GetProperty(typeof(ORUT).GetProperties());
                    foreach (string item in properties)
                        objORUTTo.GetType().GetProperty(item).SetValue(objORUTTo, objORUTFrom.GetType().GetProperty(item).GetValue(objORUTFrom, null), null);

                    objORUTTo.RouteID = ctx.GetKey("ORUT", "RouteID", "", 0, 0).FirstOrDefault().Value;
                    objORUTTo.ParentID = objORUTFrom.ParentID;
                    objORUTTo.RouteCode = "R" + objORUTTo.RouteID.ToString("D5"); ;
                    if (objORUTFrom.RouteName.Split("_".ToArray()).Length > 1)
                        objORUTTo.RouteName = objORUTFrom.RouteName.Substring(0, objORUTFrom.RouteName.LastIndexOf("_")).Trim();
                    else
                        objORUTTo.RouteName = objORUTFrom.RouteName;
                    objORUTTo.Description = objORUTFrom.Description;
                    objORUTTo.Monday = objORUTFrom.Monday;
                    objORUTTo.Tuesday = objORUTFrom.Tuesday;
                    objORUTTo.Wednesday = objORUTFrom.Wednesday;
                    objORUTTo.Thursday = objORUTFrom.Thursday;
                    objORUTTo.Friday = objORUTFrom.Friday;
                    objORUTTo.Saturday = objORUTFrom.Saturday;
                    objORUTTo.Sunday = objORUTFrom.Sunday;
                    objORUTTo.PrefSalesPersonID = CopySP;
                    objORUTTo.DistanceKms = objORUTFrom.DistanceKms;
                    objORUTTo.ExpectedBusiness = objORUTFrom.ExpectedBusiness;
                    objORUTTo.ExpectedExpense = objORUTFrom.ExpectedExpense;
                    objORUTTo.Total = objORUTFrom.Total;
                    objORUTTo.Notes = txtNotes.Text;
                    objORUTTo.Currency = "#C";
                    objORUTTo.CreatedDate = DateTime.Now;
                    objORUTTo.CreatedBy = UserID;
                    objORUTTo.UpdatedDate = DateTime.Now;
                    objORUTTo.UpdatedBy = UserID;
                    objORUTTo.Active = objORUTFrom.Active;
                    objORUTTo.OwnCustomer = objORUTFrom.OwnCustomer;
                    objORUTTo.CompCustomer = objORUTFrom.CompCustomer;
                    objORUTTo.RouteType = objORUTFrom.RouteType;
                    objORUTTo.CreatedIpAddress = IPAdd;
                    ctx.ORUTs.Add(objORUTTo);

                    objORUTFrom.Active = false;
                    objORUTFrom.UpdatedBy = UserID;
                    objORUTFrom.UpdatedDate = DateTime.Now;

                    int RUT1Count = ctx.GetKey("RUT1", "RUT1ID", "", 0, 0).FirstOrDefault().Value;
                    var List = objORUTFrom.RUT1.Where(x => x.Active).OrderBy(x => x.RUT1ID).ToList();
                    foreach (RUT1 objRUT1From in List)
                    {
                        if ((!objRUT1From.OCRD.IsTemp) && objRUT1From.OCRD.Active)
                        {
                            RUT1 objRUT1To = new RUT1();
                            properties = CollectionExtensions.GetProperty(typeof(RUT1).GetProperties());
                            foreach (string item in properties)
                                objRUT1To.GetType().GetProperty(item).SetValue(objRUT1To, objRUT1From.GetType().GetProperty(item).GetValue(objRUT1From, null), null);

                            objRUT1To.RUT1ID = RUT1Count++;
                            objRUT1To.ParentID = objRUT1From.ParentID;
                            objRUT1To.RouteID = objORUTTo.RouteID;
                            objRUT1To.CustomerID = objRUT1From.CustomerID;
                            objRUT1To.BranchID = objRUT1From.BranchID;
                            objRUT1To.Active = objRUT1From.Active;
                            objRUT1To.IsDeleted = objRUT1From.IsDeleted;
                            objORUTTo.RUT1.Add(objRUT1To);
                        }
                        objRUT1From.Active = false;
                    }
                    ctx.SaveChanges();

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully : " + objORUTTo.RouteCode + " # " + objORUTTo.RouteName + "',1);", true);
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
                    if (ctx.OCRDs.Any(x => x.CustomerCode == Code && x.Active == (x.IsTemp == false ? x.Active == true : x.Active)))// x.Active))
                    {
                        OCRD Cust = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Code && x.Active == (x.IsTemp == false ? x.Active == true : x.Active));
                        if (Cust != null)
                        {
                            var CustInDMS = ctx.AOCRDs.Where(x => x.CustomerID == Cust.CustomerID).FirstOrDefault();
                            if (CustInDMS != null && !CustInDMS.Active)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('DMS status is in-active.',3);", true);
                                txtCustCode.Text = "";
                                txtCustCode.Focus();
                                return;
                            }
                        }
                        if (ddlRouteType.SelectedValue == "3")
                        {
                            int SalesPrefID = int.TryParse(txtCode.Text.Split('-').ToArray().Last(), out SalesPrefID) ? SalesPrefID : 0;
                            string Message = ctx.CheckDealerDistManagerHirarchy(SalesPrefID, Cust.CustomerID).FirstOrDefault();
                            if (!string.IsNullOrEmpty(Message))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Message + "',3);", true);
                                txtCustCode.Text = "";
                                txtCustCode.Focus();
                                return;
                            }
                        }

                        bool BeatStatus;
                        string beatstatus;

                        if (ctx.RUT1.Any(x => x.CustomerID == Cust.CustomerID))
                        {
                            var beatlist = ctx.RUT1.Where(x => x.CustomerID == Cust.CustomerID && x.Active);    // which routeid will be consider in this?
                            //BeatStatus = beatlist.Count() > 0 ? beatlist.FirstOrDefault().Active : false;
                            BeatStatus = beatlist.Count() >= 0 ? true : false;//If another route contains the same customer with in-active status then in another route that customer add this customer then it must shown as active bu default.
                            beatstatus = BeatStatus == true ? "True" : "False";
                        }
                        else
                        {
                            BeatStatus = true;//As it is exist in any beat Bydeafult True.
                            beatstatus = BeatStatus == true ? "True" : "False";
                        }

                        var RouteType = Convert.ToInt32(ddlRouteType.SelectedValue);
                        if (!RutCustomers.Any(x => x.CustomerID == Cust.CustomerID))
                        {
                            if (!ctx.OCRDs.Any(x => x.CustomerID == Cust.CustomerID && x.Type == RouteType))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Customer #" + txtCustCode.Text + " does not belong to this beat type.',3);", true);
                                txtCustCode.Text = "";
                                txtCustCode.Focus();

                                RutCustomers[Currentgvr.RowIndex].CustomerID = 0;
                                RutCustomers[Currentgvr.RowIndex].Customer = null;
                                RutCustomers[Currentgvr.RowIndex].Location = null;
                                RutCustomers[Currentgvr.RowIndex].Parent = null;
                                RutCustomers[Currentgvr.RowIndex].Phone = null;
                                RutCustomers[Currentgvr.RowIndex].CityName = null;
                                RutCustomers[Currentgvr.RowIndex].BActive = true;
                                RutCustomers[Currentgvr.RowIndex].CActive = true;
                                RutCustomers[Currentgvr.RowIndex].CustGroupDesc = null;
                                RutCustomers[Currentgvr.RowIndex].PricingGroup = null;
                                RutCustomers[Currentgvr.RowIndex].Status = null;

                                gvCustomer.DataSource = RutCustomers;
                                gvCustomer.DataBind();
                            }
                            else
                            {
                                var parentname = "";
                                var CustGroupDesc = "";
                                if (Cust.ParentID != 1000010000000000)
                                    parentname = ctx.OCRDs.Where(x => x.CustomerID == Cust.ParentID).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault();
                                else if (Cust.OGCRDs.Any(x => x.PlantID.HasValue))
                                    parentname = Cust.OGCRDs.Where(x => x.PlantID.HasValue).Select(x => x.OPLT.PlantCode + " # " + x.OPLT.PlantName).FirstOrDefault();

                                if (Cust.CGRP != null)  // && Cust.Type == 3
                                    CustGroupDesc = Cust.CGRP.CustGroupName.ToString() + " # " + Cust.CGRP.CustGroupDesc.ToString();
                                if (!Cust.IsTemp)
                                {
                                    if (Cust.OGCRDs.Any(x => x.PriceListID.HasValue))
                                    {
                                        CRD1 objCRD1 = Cust.CRD1.FirstOrDefault();

                                        string prices = string.Join(", ", Cust.OGCRDs.Where(x => x.PriceListID.HasValue).Select(x => x.OIPL.Name.ToString()));

                                        RutCustomers[Currentgvr.RowIndex].CustomerID = Cust.CustomerID;
                                        RutCustomers[Currentgvr.RowIndex].Customer = Cust.CustomerCode + " # " + Cust.CustomerName;
                                        RutCustomers[Currentgvr.RowIndex].Location = objCRD1.Location;
                                        RutCustomers[Currentgvr.RowIndex].Parent = parentname;
                                        RutCustomers[Currentgvr.RowIndex].Phone = Cust.Phone;
                                        RutCustomers[Currentgvr.RowIndex].CityName = objCRD1.OCTY.CityName;
                                        RutCustomers[Currentgvr.RowIndex].BActive = true;
                                        RutCustomers[Currentgvr.RowIndex].CActive = Cust.Active;
                                        RutCustomers[Currentgvr.RowIndex].CustGroupDesc = CustGroupDesc;
                                        RutCustomers[Currentgvr.RowIndex].PricingGroup = prices.Trim(',');
                                        RutCustomers[Currentgvr.RowIndex].Status = beatstatus + " / True / True";

                                        if ((Currentgvr.RowIndex + 1) == RutCustomers.Count)
                                        {
                                            RutCustomers.Add(new RUTCUST());
                                        }
                                        gvCustomer.DataSource = RutCustomers;
                                        gvCustomer.DataBind();
                                    }
                                    else
                                    {
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Customer Pricing Group not assign to #" + (!string.IsNullOrEmpty(txtCustCode.Text) ? txtCustCode.Text.Replace("'", "") : "") + ".',3);", true);
                                        txtCustCode.Text = "";
                                        txtCustCode.Focus();

                                        RutCustomers[Currentgvr.RowIndex].CustomerID = 0;
                                        RutCustomers[Currentgvr.RowIndex].Customer = null;
                                        RutCustomers[Currentgvr.RowIndex].Location = null;
                                        RutCustomers[Currentgvr.RowIndex].Parent = null;
                                        RutCustomers[Currentgvr.RowIndex].Phone = null;
                                        RutCustomers[Currentgvr.RowIndex].CityName = null;
                                        RutCustomers[Currentgvr.RowIndex].BActive = true;
                                        RutCustomers[Currentgvr.RowIndex].CActive = true;
                                        RutCustomers[Currentgvr.RowIndex].CustGroupDesc = null;
                                        RutCustomers[Currentgvr.RowIndex].PricingGroup = null;
                                        RutCustomers[Currentgvr.RowIndex].Status = null;

                                        gvCustomer.DataSource = RutCustomers;
                                        gvCustomer.DataBind();
                                    }
                                }
                                else
                                {
                                    CRD1 objCRD1 = Cust.CRD1.FirstOrDefault();
                                    RutCustomers[Currentgvr.RowIndex].CustomerID = Cust.CustomerID;
                                    RutCustomers[Currentgvr.RowIndex].Customer = Cust.CustomerCode + " # " + Cust.CustomerName;
                                    RutCustomers[Currentgvr.RowIndex].Location = objCRD1.Location;
                                    RutCustomers[Currentgvr.RowIndex].Parent = parentname;
                                    RutCustomers[Currentgvr.RowIndex].Phone = Cust.Phone;
                                    RutCustomers[Currentgvr.RowIndex].CityName = objCRD1.OCTY.CityName;
                                    RutCustomers[Currentgvr.RowIndex].BActive = true;
                                    RutCustomers[Currentgvr.RowIndex].CActive = Cust.Active;
                                    RutCustomers[Currentgvr.RowIndex].CustGroupDesc = CustGroupDesc;
                                    RutCustomers[Currentgvr.RowIndex].PricingGroup = "";
                                    RutCustomers[Currentgvr.RowIndex].Status = beatstatus + " / True / True";

                                    if ((Currentgvr.RowIndex + 1) == RutCustomers.Count)
                                    {
                                        RutCustomers.Add(new RUTCUST());
                                    }
                                    gvCustomer.DataSource = RutCustomers;
                                    gvCustomer.DataBind();
                                }
                            }
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same customer already exist.',3);", true);
                            txtCustCode.Text = "";
                            txtCustCode.Focus();

                            RutCustomers[Currentgvr.RowIndex].CustomerID = 0;
                            RutCustomers[Currentgvr.RowIndex].Customer = null;
                            RutCustomers[Currentgvr.RowIndex].Location = null;
                            RutCustomers[Currentgvr.RowIndex].Parent = null;
                            RutCustomers[Currentgvr.RowIndex].Phone = null;
                            RutCustomers[Currentgvr.RowIndex].CityName = null;
                            RutCustomers[Currentgvr.RowIndex].BActive = true;
                            RutCustomers[Currentgvr.RowIndex].CActive = true;
                            RutCustomers[Currentgvr.RowIndex].CustGroupDesc = null;
                            RutCustomers[Currentgvr.RowIndex].PricingGroup = null;
                            RutCustomers[Currentgvr.RowIndex].Status = null;

                            gvCustomer.DataSource = RutCustomers;
                            gvCustomer.DataBind();
                        }

                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper customer.',3);", true);
                        txtCustCode.Text = "";
                        txtCustCode.Focus();

                        RutCustomers[Currentgvr.RowIndex].CustomerID = 0;
                        RutCustomers[Currentgvr.RowIndex].Customer = null;
                        RutCustomers[Currentgvr.RowIndex].Location = null;
                        RutCustomers[Currentgvr.RowIndex].Parent = null;
                        RutCustomers[Currentgvr.RowIndex].Phone = null;
                        RutCustomers[Currentgvr.RowIndex].CityName = null;
                        RutCustomers[Currentgvr.RowIndex].BActive = true;
                        RutCustomers[Currentgvr.RowIndex].CActive = true;
                        RutCustomers[Currentgvr.RowIndex].CustGroupDesc = null;
                        RutCustomers[Currentgvr.RowIndex].PricingGroup = null;
                        RutCustomers[Currentgvr.RowIndex].Status = null;

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
            gvMissdata.DataSource = null;
            gvMissdata.DataBind();
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

    protected void txtRouteCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && txtRouteCode != null && !String.IsNullOrEmpty(txtRouteCode.Text))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var word = txtRouteCode.Text.Split("-".ToArray()).First().Trim();
                    var objRoute = ctx.ORUTs.Include("RUT1").Include("RUT1.OCRD").FirstOrDefault(x => x.RouteCode == word && x.ParentID == ParentID);
                    if (objRoute != null)
                    {
                        ClearAllInputs();
                        ViewState["RouteID"] = objRoute.RouteID;
                        txtRouteCode.Text = objRoute.RouteCode;
                        txtName.Text = objRoute.RouteName;
                        txtDesc.Text = objRoute.Description;

                        txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objRoute.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                        txtCreatedTime.Text = objRoute.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                        txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objRoute.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                        txtUpdatedTime.Text = objRoute.UpdatedDate.ToString("dd/MM/yyyy HH:mm");
                        txtCreatedIP.Text = objRoute.CreatedIpAddress == null ? "" : objRoute.CreatedIpAddress;
                        txtUpdatedIP.Text = objRoute.UpdatedIpAddress == null ? "" : objRoute.UpdatedIpAddress;

                        chkMonday.Checked = objRoute.Monday;
                        chkTuesday.Checked = objRoute.Tuesday;
                        chkWednesday.Checked = objRoute.Wednesday;
                        chkThursday.Checked = objRoute.Thursday;
                        chkFriday.Checked = objRoute.Friday;
                        chkSaturday.Checked = objRoute.Saturday;
                        chkSunday.Checked = objRoute.Sunday;

                        int EmpID = objRoute.PrefSalesPersonID.GetValueOrDefault(0);

                        txtCode.Text = objRoute.OEMP1.EmpCode + " - " + objRoute.OEMP1.Name + " - " + objRoute.OEMP1.EmpID.ToString();

                        txtDistance.Text = objRoute.DistanceKms.GetValueOrDefault(0).ToString("0");
                        txtAvgBusiness.Text = objRoute.ExpectedBusiness.GetValueOrDefault(0).ToString("0");
                        txtAvgExpense.Text = objRoute.ExpectedExpense.GetValueOrDefault(0).ToString("0");
                        txtTotal.Text = objRoute.Total.ToString();
                        txtNotes.Text = objRoute.Notes;
                        chkAcitve.Checked = objRoute.Active;
                        ddlRouteType.SelectedValue = objRoute.RouteType.ToString();

                        //foreach (var item in objRoute.RUT1.Where(x => x.IsDeleted == false))
                        //{
                        //    RUTCUST objRutCust = new RUTCUST();
                        //    OCRD objCustOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == item.CustomerID);
                        //    OCRD objParentOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == objCustOCRD.ParentID);
                        //    objRutCust.CustomerID = item.CustomerID;
                        //    objRutCust.Customer = objCustOCRD.CustomerCode + " # " + objCustOCRD.CustomerName;
                        //    objRutCust.Phone = objCustOCRD.Phone;
                        //    objRutCust.Location = item.CRD1.Location;
                        //    objRutCust.Parent = objCustOCRD.ParentID == 1000010000000000 ? objCustOCRD.OGCRDs.FirstOrDefault().OPLT.PlantCode + " # " + objCustOCRD.OGCRDs.FirstOrDefault().OPLT.PlantName : objParentOCRD.CustomerCode + "#" + objParentOCRD.CustomerName;
                        //    objRutCust.City = item.CRD1.OCTY.CityName;
                        //    objRutCust.BActive = objCustOCRD.Active;
                        //    objRutCust.CActive = item.OCRD.Active;
                        //    RutCustomers.Add(objRutCust);
                        //}
                        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                        SqlCommand Cm = new SqlCommand();

                        Cm.Parameters.Clear();
                        Cm.CommandType = CommandType.StoredProcedure;
                        Cm.CommandText = "GetRutCustomers";
                        Cm.Parameters.AddWithValue("@RouteID", objRoute.RouteID);
                        DataSet ds = objClass.CommonFunctionForSelect(Cm);
                        if (ds.Tables.Count > 0)
                        {

 
                             RutCustomers = ds.Tables[0].AsEnumerable().Select
                            (x => new RUTCUST
                            {
                                CustomerID = x.Field<Decimal>("CustomerID"),
                                Customer = x.Field<String>("Customer"),
                                Phone = x.Field<String>("Phone"),
                                Location = x.Field<String>("Location"),
                                CityName = x.Field<String>("CityName"),
                                CustGroupDesc = x.Field<String>("CustGroupDesc"),
                                BActive = x.Field<Boolean>("BActive"),
                                CActive = x.Field<Boolean>("CActive"),
                                Parent = x.Field<String>("Parent"),
                                PricingGroup = x.Field<String>("PricingGroup"),
                                Status = x.Field<String>("Status"),
                            }).ToList();
                            
                        }

                        //RutCustomers = objRoute.RUT1.Where(x => x.IsDeleted == false).
                        //    Select(x => new
                        //    {
                        //        CustomerID = x.CustomerID,
                        //        Customer = x.OCRD.CustomerCode + " # " + x.OCRD.CustomerName,
                        //        Phone = x.OCRD.Phone,
                        //        Location = x.CRD1.Location,
                        //        Parent = ctx.OCRDs.FirstOrDefault(y => y.CustomerID == x.OCRD.ParentID).CustomerID,
                        //        City = x.CRD1.OCTY.CityName,
                        //        BActive = x.Active,
                        //        CActive = x.OCRD.Active
                        //    }).ToList().OrderByDescending(x => x.BActive).ThenBy(x => x.Customer).Select(x => new RUTCUST
                        //    {
                        //        CustomerID = x.CustomerID,
                        //        Customer = x.Customer,
                        //        Phone = x.Phone,
                        //        Location = x.Location,
                        //        City = x.City,
                        //        BActive = x.BActive,
                        //        CActive = x.CActive,
                        //        Parent = x.Parent != 1000010000000000 ? (ctx.OCRDs.Where(y => y.CustomerID == x.Parent).Select(y => y.CustomerCode + " # " + y.CustomerName).FirstOrDefault()) : (ctx.OGCRDs.Where(y => y.CustomerID == x.CustomerID).Select(y => y.OPLT.PlantCode + " # " + y.OPLT.PlantName).FirstOrDefault())
                        //    }).ToList();


                      
                        if (RutCustomers == null)
                            RutCustomers = new List<RUTCUST>();

                        var rut1 = new RUTCUST();
                        rut1.BActive = true;
                        RutCustomers.Add(rut1);

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
        txtRouteCode.Focus();
    }

    protected void ddlRouteType_SelectedIndexChanged(object sender, EventArgs e)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            Int32 RouteType = Int32.TryParse(ddlRouteType.SelectedValue, out RouteType) ? RouteType : 0;

            RutCustomers = new List<RUTCUST>();
            var word = txtRouteCode.Text.Split("-".ToArray()).First().Trim();
            var objRoute = ctx.ORUTs.Include("RUT1").Include("RUT1.OCRD").FirstOrDefault(x => x.RouteCode == word && x.ParentID == ParentID && x.RouteType == RouteType);
            if (objRoute != null)
            {
                //RutCustomers = objRoute.RUT1.Where(x => x.IsDeleted == false).
                //            Select(x => new RUTCUST
                //            {
                //                CustomerID = x.CustomerID,
                //                Customer = x.OCRD.CustomerCode + " # " + x.OCRD.CustomerName,
                //                Phone = x.OCRD.Phone,
                //                Location = x.CRD1.Location,
                //                City = x.CRD1.OCTY.CityName,
                //                Active = x.Active
                //            }).OrderByDescending(x => x.Active).ThenBy(x => x.Customer).ToList();

                if (RutCustomers == null)
                    RutCustomers = new List<RUTCUST>();
                gvCustomer.DataSource = RutCustomers;
                gvCustomer.DataBind();
            }
            else
            {
                gvCustomer.DataSource = RutCustomers;
                gvCustomer.DataBind();
            }
            var rut1 = new RUTCUST();
            rut1.BActive = true;
            RutCustomers.Add(rut1);
            gvCustomer.DataSource = RutCustomers;
            gvCustomer.DataBind();
        }
    }

    #endregion

    #region CheckBox Change Event

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        chkSrchByParent.Checked = false;
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

    protected void gvMissdata_PreRender(object sender, EventArgs e)
    {

        if (gvMissdata.Rows.Count > 0)
        {
            gvMissdata.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvMissdata.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
}