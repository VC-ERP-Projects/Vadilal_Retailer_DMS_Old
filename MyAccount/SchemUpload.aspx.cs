using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.OleDb;
using System.IO;
using System.Configuration;
using System.Data.SqlClient;
using System.Transactions;
using System.Collections.Specialized;
using System.Net;
using System.Data.Entity.Validation;
using System.Xml.Linq;
using System.Data.Objects;

public partial class MyAccount_SchemUpload : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int EGID = Convert.ToInt32(Session["GroupID"]);
                int CustType = Convert.ToInt32(Session["Type"]);

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
                            var unit = xml.Descendants("change_password");
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

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        gvMissdata.DataSource = null;
        gvMissdata.DataBind();

        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(btnCUpload);
        scriptManager.RegisterPostBackControl(btnMachineUpload);
        scriptManager.RegisterPostBackControl(btnParlourUpload);
        scriptManager.RegisterPostBackControl(btnVRSUpload);
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

    #region Button Click

    protected void btnCUpload_Click(object sender, EventArgs e)
    {
        try
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. You can not upload Master Scheme.',3);", true);
            return;

            DataTable missdata = new DataTable();
            missdata.Columns.Add("Dealer Code");
            missdata.Columns.Add("From");
            missdata.Columns.Add("Up To");
            missdata.Columns.Add("Comp. Cont. In %");
            missdata.Columns.Add("Dist. Cont. In %");
            missdata.Columns.Add("Expected Sale");
            missdata.Columns.Add("Division Code");
            missdata.Columns.Add("ErrorMsg");

            bool flag = true;

            if (flCUpload.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flCUpload.PostedFile.FileName));
                flCUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flCUpload.PostedFile.FileName);
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
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtPOH.Rows)
                            {
                                String DealerCode = item["Dealer Code"].ToString();
                                string DivisionCode = item["Division Code"].ToString();

                                if (ctx.OCRDs.Any(x => x.CustomerCode == DealerCode && x.Type == 3 && x.Active))
                                {
                                    if (ctx.ODIVs.Any(x => x.DivisionCode == DivisionCode && x.Active))
                                    {
                                        if (!string.IsNullOrEmpty(item["From"].ToString()) && !string.IsNullOrEmpty(item["Up To"].ToString()) &&
                                            !string.IsNullOrEmpty(item["Comp. Cont. In %"].ToString()) && !string.IsNullOrEmpty(item["Dist. Cont. In %"].ToString())
                                            && !string.IsNullOrEmpty(item["Expected Sale"].ToString()))
                                        {
                                            Decimal DecNum = 0;
                                            DateTime dt;


                                            if (Decimal.TryParse(item["Comp. Cont. In %"].ToString(), out DecNum) &&
                                               Decimal.TryParse(item["Dist. Cont. In %"].ToString(), out DecNum) &&
                                               Decimal.TryParse(item["Expected Sale"].ToString(), out DecNum) &&
                                               DateTime.TryParse(item["From"].ToString(), out dt) &&
                                               DateTime.TryParse(item["Up To"].ToString(), out dt))
                                            {

                                            }
                                            else
                                            {
                                                DataRow missdr = missdata.NewRow();
                                                missdr["Dealer Code"] = DealerCode;
                                                missdr["From"] = item["From"].ToString();
                                                missdr["Up To"] = item["Up To"].ToString();
                                                missdr["Comp. Cont. In %"] = item["Comp. Cont. In %"].ToString();
                                                missdr["Dist. Cont. In %"] = item["Dist. Cont. In %"].ToString();
                                                missdr["Expected Sale"] = item["Expected Sale"].ToString();
                                                missdr["Division Code"] = DivisionCode;
                                                missdr["ErrorMsg"] = "Data is not proper.";
                                                missdata.Rows.Add(missdr);
                                                flag = false;
                                            }
                                        }
                                        else
                                        {
                                            DataRow missdr = missdata.NewRow();
                                            missdr["Dealer Code"] = DealerCode;
                                            missdr["From"] = item["From"].ToString();
                                            missdr["Up To"] = item["Up To"].ToString();
                                            missdr["Comp. Cont. In %"] = item["Comp. Cont. In %"].ToString();
                                            missdr["Dist. Cont. In %"] = item["Dist. Cont. In %"].ToString();
                                            missdr["Expected Sale"] = item["Expected Sale"].ToString();
                                            missdr["Division Code"] = DivisionCode;
                                            missdr["ErrorMsg"] = "Data is not proper.";
                                            missdata.Rows.Add(missdr);
                                            flag = false;
                                        }
                                    }
                                    else
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Dealer Code"] = DealerCode;
                                        missdr["From"] = "";
                                        missdr["Up To"] = "";
                                        missdr["Comp. Cont. In %"] = "";
                                        missdr["Dist. Cont. In %"] = "";
                                        missdr["Expected Sale"] = "";
                                        missdr["Division Code"] = DivisionCode;
                                        missdr["ErrorMsg"] = "'" + DivisionCode + "' does not exist or not active.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Dealer Code"] = DealerCode;
                                    missdr["From"] = "";
                                    missdr["Up To"] = "";
                                    missdr["Comp. Cont. In %"] = "";
                                    missdr["Dist. Cont. In %"] = "";
                                    missdr["Expected Sale"] = "";
                                    missdr["Division Code"] = "";
                                    missdr["ErrorMsg"] = "Dealer Code: '" + DealerCode + "' does not exist or not active.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                            }
                        }
                    }

                    if (flag)
                    {

                        if (dtPOH != null && dtPOH.Rows != null && dtPOH.Rows.Count > 0)
                        {
                            using (DDMSEntities ctx = new DDMSEntities())
                            {
                                int SchemeID = ctx.GetKey("OSCM", "SchemeID", "", 0, 0).FirstOrDefault().Value;
                                int SCM1Count = ctx.GetKey("SCM1", "SCM1ID", "", 0, 0).FirstOrDefault().Value;
                                int SCM3Count = ctx.GetKey("SCM3", "SCM3ID", "", 0, 0).FirstOrDefault().Value;
                                int SchemeCount = ctx.GetKey("SCM4", "SCM4ID", "", 0, 0).FirstOrDefault().Value;

                                foreach (DataRow item in dtPOH.Rows)
                                {
                                    try
                                    {
                                        String DealerCode = item["Dealer Code"].ToString();

                                        var objDealer = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DealerCode && x.Type == 3);
                                        if (objDealer != null)
                                        {
                                            ctx.SCM1.Where(x => x.OSCM.ApplicableMode == "M" && x.CustomerID == objDealer.CustomerID).ToList().ForEach(x => x.Active = false);

                                            DateTime Startdate = Convert.ToDateTime(item["From"].ToString());
                                            DateTime EndDate = Convert.ToDateTime(item["Up To"].ToString());

                                            Decimal ComPercentage = Convert.ToDecimal(item["Comp. Cont. In %"].ToString());
                                            Decimal DistPercenatage = Convert.ToDecimal(item["Dist. Cont. In %"].ToString());
                                            Decimal ExpectedSale = Convert.ToDecimal(item["Expected Sale"].ToString());

                                            OSCM objOSCM = null;
                                            SCM4 objSCM4 = ctx.SCM4.Include("OSCM").FirstOrDefault(x => x.OSCM.ApplicableMode == "M" && x.HigherLimit == ExpectedSale && x.CompanyDisc == ComPercentage && x.DistributorDisc == DistPercenatage
                                                && EntityFunctions.TruncateTime(x.OSCM.StartDate) == EntityFunctions.TruncateTime(Startdate) && EntityFunctions.TruncateTime(x.OSCM.EndDate) == EntityFunctions.TruncateTime(EndDate));
                                            if (objSCM4 == null)
                                            {
                                                objOSCM = new OSCM();
                                                objOSCM.SchemeID = SchemeID++;
                                                objOSCM.StartDate = Startdate;
                                                objOSCM.EndDate = EndDate;
                                                objOSCM.ReasonID = null;
                                                objOSCM.SchemeCode = "SC" + objOSCM.SchemeID.ToString();
                                                objOSCM.SchemeName = "Scheme" + objOSCM.SchemeID.ToString();
                                                objOSCM.Active = true;
                                                objOSCM.ApplicableMode = "M";
                                                objOSCM.ReasonID = null;
                                                if (ctx.ORSNs.Any(x => x.ReasonDesc == "M" && x.Active))
                                                {
                                                    objOSCM.ReasonID = ctx.ORSNs.FirstOrDefault(x => x.ReasonDesc == "M" && x.Active).ReasonID;
                                                }

                                                objOSCM.ApplicableOn = 3;
                                                objOSCM.BirthDay = true;
                                                objOSCM.Anniversary = true;
                                                objOSCM.SpecialDay = true;
                                                objOSCM.Monday = true;
                                                objOSCM.Tuesday = true;
                                                objOSCM.Wednesday = true;
                                                objOSCM.Thursday = true;
                                                objOSCM.Friday = true;
                                                objOSCM.Saturday = true;
                                                objOSCM.Sunday = true;
                                                objOSCM.IsTaxApplicable = false;
                                                objOSCM.Remarks = null;

                                                objOSCM.CreatedDate = DateTime.Now;
                                                objOSCM.CreatedBy = UserID;

                                                objOSCM.UpdatedDate = DateTime.Now;
                                                objOSCM.UpdatedBy = UserID;

                                                ctx.OSCMs.Add(objOSCM);

                                                //SCM4     
                                                objSCM4 = new SCM4();

                                                objSCM4.SCM4ID = SchemeCount++;
                                                objSCM4.CompanyDisc = ComPercentage;
                                                objSCM4.DistributorDisc = DistPercenatage;
                                                objSCM4.SchemeID = objOSCM.SchemeID;
                                                objSCM4.Discount = (ComPercentage + DistPercenatage);
                                                objSCM4.LowerLimit = 0;
                                                objSCM4.HigherLimit = ExpectedSale;
                                                objSCM4.ItemGroupID = null;
                                                objSCM4.ItemSubGroupID = null;
                                                objSCM4.ItemID = null;
                                                objSCM4.Occurrence = 0;
                                                objSCM4.Quantity = 0;
                                                objSCM4.BasedOn = 1;
                                                objSCM4.DiscountType = "P";
                                                objOSCM.SCM4.Add(objSCM4);
                                            }
                                            else
                                            {
                                                objSCM4.OSCM.UpdatedDate = DateTime.Now;
                                                objSCM4.OSCM.UpdatedBy = UserID;
                                            }
                                            string DivisionCode = item["Division Code"].ToString();
                                            ODIV objODIV = ctx.ODIVs.FirstOrDefault(x => x.DivisionCode == DivisionCode);
                                            if (objODIV != null)
                                            {
                                                SCM3 objSCM3 = ctx.SCM3.FirstOrDefault(x => x.SchemeID == objSCM4.SchemeID && x.DivisionID == objODIV.DivisionlID);
                                                if (objSCM3 == null)
                                                {
                                                    objSCM3 = new SCM3();
                                                    objSCM3.SCM3ID = SCM3Count++;
                                                    objSCM3.SchemeID = objSCM4.SchemeID;
                                                    objSCM3.IsInclude = true;
                                                    objSCM3.DivisionID = objODIV.DivisionlID;
                                                    ctx.SCM3.Add(objSCM3);
                                                }
                                            }

                                            SCM1 objSCM11 = ctx.SCM1.FirstOrDefault(x => x.CustomerID == objDealer.CustomerID && x.SchemeID == objSCM4.SchemeID);
                                            if (objSCM11 == null)
                                            {
                                                objSCM11 = new SCM1();
                                                objSCM11.SCM1ID = SCM1Count++;
                                                objSCM11.CustomerID = objDealer.CustomerID;
                                                objSCM11.SchemeID = objSCM4.SchemeID;
                                                objSCM11.Type = 3;
                                                ctx.SCM1.Add(objSCM11);
                                            }
                                            objSCM11.Active = true;
                                            objSCM11.CreatedDate = DateTime.Now;

                                            ctx.SaveChanges();
                                        }
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
                            }
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);
                        }
                    }
                    else
                    {
                        gvMissdata.DataSource = missdata;
                        gvMissdata.DataBind();
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

    protected void btnMachineUpload_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable missdata = new DataTable();
            missdata.Columns.Add("Dealer Code");
            missdata.Columns.Add("From");
            missdata.Columns.Add("Up To");
            missdata.Columns.Add("Comp. Cont. In %");
            missdata.Columns.Add("Dist. Cont. In %");
            missdata.Columns.Add("Expected Sale");
            missdata.Columns.Add("Division Code");
            missdata.Columns.Add("Coupon Amount");
            missdata.Columns.Add("Assest Code");
            missdata.Columns.Add("ErrorMsg");

            bool flag = true;

            if (flMachineUpload.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flMachineUpload.PostedFile.FileName));
                flMachineUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flMachineUpload.PostedFile.FileName);
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
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtPOH.Rows)
                            {
                                string DealerCode = item["Dealer Code"].ToString();
                                if (ctx.OCRDs.Any(x => x.CustomerCode == DealerCode && x.Type == 3 && x.Active))
                                {
                                    string AssetCode = item["Assest Code"].ToString();
                                    if (!string.IsNullOrEmpty(AssetCode))
                                    {
                                        Decimal CustomerID = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DealerCode && x.Type == 3 && x.Active).CustomerID;

                                        OAST objOAST = ctx.OASTs.FirstOrDefault(x => x.AssetCode == AssetCode);
                                        if (objOAST == null || (!ctx.SCM1.Any(x => x.AssetID == objOAST.AssetID && x.Active && x.CustomerID != CustomerID)))
                                        {
                                            Decimal DistID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == CustomerID).ParentID;
                                            if (ctx.OGCRDs.Any(x => x.CustomerID == DistID && x.PlantID.HasValue))
                                            {
                                                string DivisionCode = item["Division Code"].ToString();
                                                if (ctx.ODIVs.Any(x => x.DivisionCode == DivisionCode && x.Active))
                                                {
                                                    if (!string.IsNullOrEmpty(item["From"].ToString()) && !string.IsNullOrEmpty(item["Up To"].ToString()) &&
                                                        !string.IsNullOrEmpty(item["Comp. Cont. In %"].ToString()) && !string.IsNullOrEmpty(item["Dist. Cont. In %"].ToString())
                                                        && !string.IsNullOrEmpty(item["Expected Sale"].ToString()) && !string.IsNullOrEmpty(item["Coupon Amount"].ToString()))
                                                    {
                                                        Decimal DecNum = 0;
                                                        DateTime dt;

                                                        if (Decimal.TryParse(item["Comp. Cont. In %"].ToString(), out DecNum) &&
                                                           Decimal.TryParse(item["Dist. Cont. In %"].ToString(), out DecNum) &&
                                                           Decimal.TryParse(item["Expected Sale"].ToString(), out DecNum) &&
                                                           Decimal.TryParse(item["Coupon Amount"].ToString(), out DecNum) && DecNum > 0 &&
                                                           DateTime.TryParse(item["From"].ToString(), out dt) &&
                                                           DateTime.TryParse(item["Up To"].ToString(), out dt))
                                                        {

                                                        }
                                                        else
                                                        {
                                                            DataRow missdr = missdata.NewRow();
                                                            missdr["Dealer Code"] = DealerCode;
                                                            missdr["From"] = item["From"].ToString();
                                                            missdr["Up To"] = item["Up To"].ToString();
                                                            missdr["Comp. Cont. In %"] = item["Comp. Cont. In %"].ToString();
                                                            missdr["Dist. Cont. In %"] = item["Dist. Cont. In %"].ToString();
                                                            missdr["Expected Sale"] = item["Expected Sale"].ToString();
                                                            missdr["Division Code"] = DivisionCode;
                                                            missdr["Coupon Amount"] = item["Coupon Amount"].ToString();
                                                            missdr["Assest Code"] = AssetCode;
                                                            missdr["ErrorMsg"] = "Data is not proper.";
                                                            missdata.Rows.Add(missdr);
                                                            flag = false;
                                                        }
                                                    }
                                                    else
                                                    {
                                                        DataRow missdr = missdata.NewRow();
                                                        missdr["Dealer Code"] = DealerCode;
                                                        missdr["From"] = item["From"].ToString();
                                                        missdr["Up To"] = item["Up To"].ToString();
                                                        missdr["Comp. Cont. In %"] = item["Comp. Cont. In %"].ToString();
                                                        missdr["Dist. Cont. In %"] = item["Dist. Cont. In %"].ToString();
                                                        missdr["Expected Sale"] = item["Expected Sale"].ToString();
                                                        missdr["Division Code"] = DivisionCode;
                                                        missdr["Coupon Amount"] = item["Coupon Amount"].ToString();
                                                        missdr["Assest Code"] = AssetCode;
                                                        missdr["ErrorMsg"] = "Data is not proper.";
                                                        missdata.Rows.Add(missdr);
                                                        flag = false;
                                                    }
                                                }
                                                else
                                                {
                                                    DataRow missdr = missdata.NewRow();
                                                    missdr["Dealer Code"] = DealerCode;
                                                    missdr["From"] = "";
                                                    missdr["Up To"] = "";
                                                    missdr["Comp. Cont. In %"] = "";
                                                    missdr["Dist. Cont. In %"] = "";
                                                    missdr["Expected Sale"] = "";
                                                    missdr["Division Code"] = DivisionCode;
                                                    missdr["Coupon Amount"] = "";
                                                    missdr["Assest Code"] = AssetCode;
                                                    missdr["ErrorMsg"] = "'" + DivisionCode + "' does not exist or not active.";
                                                    missdata.Rows.Add(missdr);
                                                    flag = false;
                                                }
                                            }
                                            else
                                            {
                                                DataRow missdr = missdata.NewRow();
                                                missdr["Dealer Code"] = DealerCode;
                                                missdr["From"] = "";
                                                missdr["Up To"] = "";
                                                missdr["Comp. Cont. In %"] = "";
                                                missdr["Dist. Cont. In %"] = "";
                                                missdr["Expected Sale"] = "";
                                                missdr["Division Code"] = "";
                                                missdr["Coupon Amount"] = "";
                                                missdr["Assest Code"] = AssetCode;
                                                missdr["ErrorMsg"] = "Plant code does not exist";
                                                missdata.Rows.Add(missdr);
                                                flag = false;
                                            }
                                        }
                                        else
                                        {
                                            DataRow missdr = missdata.NewRow();
                                            missdr["Dealer Code"] = DealerCode;
                                            missdr["From"] = "";
                                            missdr["Up To"] = "";
                                            missdr["Comp. Cont. In %"] = "";
                                            missdr["Dist. Cont. In %"] = "";
                                            missdr["Expected Sale"] = "";
                                            missdr["Division Code"] = "";
                                            missdr["Coupon Amount"] = "";
                                            missdr["Assest Code"] = AssetCode;
                                            missdr["ErrorMsg"] = "Same Asset : " + AssetCode + " is already mapped with customer.";
                                            missdata.Rows.Add(missdr);
                                            flag = false;
                                        }
                                    }
                                    else
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Dealer Code"] = DealerCode;
                                        missdr["From"] = "";
                                        missdr["Up To"] = "";
                                        missdr["Comp. Cont. In %"] = "";
                                        missdr["Dist. Cont. In %"] = "";
                                        missdr["Expected Sale"] = "";
                                        missdr["Division Code"] = "";
                                        missdr["Coupon Amount"] = "";
                                        missdr["Assest Code"] = AssetCode;
                                        missdr["ErrorMsg"] = "'" + AssetCode + "' Assest Code is compulsory.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Dealer Code"] = DealerCode;
                                    missdr["From"] = "";
                                    missdr["Up To"] = "";
                                    missdr["Comp. Cont. In %"] = "";
                                    missdr["Dist. Cont. In %"] = "";
                                    missdr["Expected Sale"] = "";
                                    missdr["Division Code"] = "";
                                    missdr["Coupon Amount"] = "";
                                    missdr["Assest Code"] = "";
                                    missdr["ErrorMsg"] = "Dealer Code: '" + DealerCode + "' does not exist or not active.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                            }
                        }
                    }

                    if (flag)
                    {

                        if (dtPOH != null && dtPOH.Rows != null && dtPOH.Rows.Count > 0)
                        {
                            using (DDMSEntities ctx = new DDMSEntities())
                            {
                                int SchemeID = ctx.GetKey("OSCM", "SchemeID", "", 0, 0).FirstOrDefault().Value;
                                int SCM1Count = ctx.GetKey("SCM1", "SCM1ID", "", 0, 0).FirstOrDefault().Value;
                                int SCM3Count = ctx.GetKey("SCM3", "SCM3ID", "", 0, 0).FirstOrDefault().Value;
                                int SchemeCount = ctx.GetKey("SCM4", "SCM4ID", "", 0, 0).FirstOrDefault().Value;
                                int AssetCount = ctx.GetKey("OAST", "AssetID", "", 0, 0).FirstOrDefault().Value;
                                foreach (DataRow item in dtPOH.Rows)
                                {
                                    try
                                    {
                                        string DealerCode = item["Dealer Code"].ToString();
                                        Decimal CustomerID = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DealerCode && x.Type == 3).CustomerID;
                                        if (CustomerID > 0)
                                        {
                                            Decimal DistID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == CustomerID).ParentID;

                                            string DivisionCode = item["Division Code"].ToString();
                                            int DivisionlID = ctx.ODIVs.FirstOrDefault(x => x.DivisionCode == DivisionCode).DivisionlID;
                                            if (DivisionlID > 0)
                                            {
                                                string AssetCode = item["Assest Code"].ToString().Trim();
                                                OAST objOAST = ctx.OASTs.FirstOrDefault(x => x.AssetCode == AssetCode);
                                                if (objOAST == null)
                                                {
                                                    objOAST = new OAST();
                                                    objOAST.AssetID = AssetCount++;
                                                    objOAST.AssetCode = AssetCode;
                                                    objOAST.AssetName = AssetCode;
                                                    objOAST.AssetTypeID = 4;
                                                    objOAST.ModelNumber = AssetCode;
                                                    objOAST.SerialNumber = AssetCode;
                                                    objOAST.AdditionalIdentifier = "99999";
                                                    objOAST.HoldByCustomerID = CustomerID;
                                                    objOAST.CreatedDate = DateTime.Now;
                                                    objOAST.CreatedBy = UserID;
                                                    objOAST.UpdatedDate = DateTime.Now;
                                                    objOAST.UpdatedBy = UserID;
                                                    objOAST.Active = true;
                                                    objOAST.AssetSubnumber = "0001";
                                                    objOAST.Location = ctx.CRD1.FirstOrDefault(x => x.CustomerID == CustomerID).OCTY.CityName;
                                                    objOAST.AcqDate = DateTime.Now;
                                                    objOAST.PlantID = ctx.OGCRDs.FirstOrDefault(x => x.CustomerID == DistID && x.PlantID.HasValue).PlantID;
                                                    objOAST.Volume = 1;
                                                    ctx.OASTs.Add(objOAST);
                                                }
                                                if (ctx.SCM1.Any(x => x.AssetID == objOAST.AssetID && x.Active && x.CustomerID != CustomerID))
                                                {
                                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Asset : " + AssetCode + " is already mapped with customer.',3);", true);
                                                    return;
                                                }

                                                DateTime Startdate = Convert.ToDateTime(item["From"].ToString());
                                                DateTime EndDate = Convert.ToDateTime(item["Up To"].ToString());

                                                Decimal ComPercentage = Convert.ToDecimal(item["Comp. Cont. In %"].ToString());
                                                Decimal DistPercenatage = Convert.ToDecimal(item["Dist. Cont. In %"].ToString());
                                                Decimal ExpectedSale = Convert.ToDecimal(item["Expected Sale"].ToString());
                                                Decimal CouponAmount = Convert.ToDecimal(item["Coupon Amount"].ToString());

                                                OSCM objOSCM = null;
                                                SCM4 objSCM4 = ctx.SCM4.Include("OSCM").FirstOrDefault(x => x.OSCM.ApplicableMode == "D" && x.HigherLimit == ExpectedSale && x.CompanyDisc == ComPercentage && x.DistributorDisc == DistPercenatage
                                                    && EntityFunctions.TruncateTime(x.OSCM.StartDate) == EntityFunctions.TruncateTime(Startdate) && EntityFunctions.TruncateTime(x.OSCM.EndDate) == EntityFunctions.TruncateTime(EndDate));
                                                if (objSCM4 == null)
                                                {
                                                    objOSCM = new OSCM();
                                                    objOSCM.SchemeID = SchemeID++;
                                                    objOSCM.StartDate = Startdate;
                                                    objOSCM.EndDate = EndDate;
                                                    objOSCM.ReasonID = null;
                                                    objOSCM.SchemeCode = "MCSC" + objOSCM.SchemeID.ToString();
                                                    objOSCM.SchemeName = "MCScheme" + objOSCM.SchemeID.ToString();
                                                    objOSCM.Active = true;
                                                    objOSCM.ApplicableMode = "D";

                                                    if (ctx.ORSNs.Any(x => x.ReasonDesc == "D" && x.Active))
                                                    {
                                                        objOSCM.ReasonID = ctx.ORSNs.FirstOrDefault(x => x.ReasonDesc == "D" && x.Active).ReasonID;
                                                    }

                                                    objOSCM.ApplicableOn = 3;
                                                    objOSCM.BirthDay = true;
                                                    objOSCM.Anniversary = true;
                                                    objOSCM.SpecialDay = true;
                                                    objOSCM.Monday = true;
                                                    objOSCM.Tuesday = true;
                                                    objOSCM.Wednesday = true;
                                                    objOSCM.Thursday = true;
                                                    objOSCM.Friday = true;
                                                    objOSCM.Saturday = true;
                                                    objOSCM.Sunday = true;
                                                    objOSCM.IsTaxApplicable = false;
                                                    objOSCM.Remarks = null;

                                                    objOSCM.CreatedDate = DateTime.Now;
                                                    objOSCM.CreatedBy = UserID;

                                                    objOSCM.UpdatedDate = DateTime.Now;
                                                    objOSCM.UpdatedBy = UserID;

                                                    ctx.OSCMs.Add(objOSCM);

                                                    //SCM4     
                                                    objSCM4 = new SCM4();
                                                    objSCM4.SCM4ID = SchemeCount++;
                                                    objSCM4.CompanyDisc = ComPercentage;
                                                    objSCM4.DistributorDisc = DistPercenatage;
                                                    objSCM4.SchemeID = objOSCM.SchemeID;
                                                    objSCM4.Discount = (ComPercentage + DistPercenatage);
                                                    objSCM4.LowerLimit = 0;
                                                    objSCM4.HigherLimit = ExpectedSale;
                                                    objSCM4.ItemGroupID = null;
                                                    objSCM4.ItemSubGroupID = null;
                                                    objSCM4.ItemID = null;
                                                    objSCM4.Occurrence = 0;
                                                    objSCM4.Quantity = 0;
                                                    objSCM4.BasedOn = 1;
                                                    objSCM4.DiscountType = "P";
                                                    objOSCM.SCM4.Add(objSCM4);
                                                }
                                                else
                                                {
                                                    objSCM4.OSCM.UpdatedDate = DateTime.Now;
                                                    objSCM4.OSCM.UpdatedBy = UserID;
                                                }


                                                SCM3 objSCM3 = ctx.SCM3.FirstOrDefault(x => x.SchemeID == objSCM4.SchemeID && x.DivisionID == DivisionlID);
                                                if (objSCM3 == null)
                                                {
                                                    objSCM3 = new SCM3();
                                                    objSCM3.SCM3ID = SCM3Count++;
                                                    objSCM3.SchemeID = objSCM4.SchemeID;
                                                    objSCM3.IsInclude = true;
                                                    objSCM3.DivisionID = DivisionlID;
                                                    ctx.SCM3.Add(objSCM3);
                                                }

                                                SCM1 objoldSCM1 = ctx.SCM1.FirstOrDefault(x => x.AssetID == objOAST.AssetID && x.CustomerID == CustomerID && x.Active);
                                                if (objoldSCM1 == null)
                                                {
                                                    SCM1 objSCM1 = new SCM1();
                                                    objSCM1.SCM1ID = SCM1Count++;
                                                    objSCM1.CustomerID = CustomerID;
                                                    objSCM1.SchemeID = objSCM4.SchemeID;
                                                    objSCM1.Type = 3;
                                                    objSCM1.CreatedDate = DateTime.Now;
                                                    objSCM1.Active = true;
                                                    objSCM1.IsInclude = true;
                                                    objSCM1.UsedCoupon = 0;
                                                    objSCM1.CouponAmount = CouponAmount;
                                                    objSCM1.AssetID = objOAST.AssetID;
                                                    ctx.SCM1.Add(objSCM1);
                                                }
                                                else if (objoldSCM1.SchemeID == objSCM4.SchemeID)
                                                {
                                                    objoldSCM1.Active = true;
                                                    objoldSCM1.IsInclude = true;
                                                    objoldSCM1.CouponAmount = CouponAmount;
                                                }
                                                else
                                                {
                                                    objoldSCM1.Active = false;

                                                    SCM1 objSCM1 = new SCM1();
                                                    objSCM1.SCM1ID = SCM1Count++;
                                                    objSCM1.CustomerID = CustomerID;
                                                    objSCM1.Type = 3;
                                                    objSCM1.SchemeID = objSCM4.SchemeID;
                                                    objSCM1.CreatedDate = DateTime.Now;
                                                    objSCM1.Active = true;
                                                    objSCM1.IsInclude = true;
                                                    objSCM1.UsedCoupon = objoldSCM1.UsedCoupon;
                                                    objSCM1.CouponAmount = CouponAmount;
                                                    objSCM1.AssetID = objoldSCM1.AssetID;
                                                    ctx.SCM1.Add(objSCM1);
                                                }
                                                ctx.SaveChanges();
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
                                        return;
                                    }

                                }
                            }
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);
                        }
                    }
                    else
                    {
                        gvMissdata.DataSource = missdata;
                        gvMissdata.DataBind();
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

    protected void btnParlourUpload_Click(object sender, EventArgs e)
    {

        try
        {
            DataTable missdata = new DataTable();
            missdata.Columns.Add("Dealer Code");
            missdata.Columns.Add("From");
            missdata.Columns.Add("Up To");
            missdata.Columns.Add("Comp. Cont. In %");
            missdata.Columns.Add("Dist. Cont. In %");
            missdata.Columns.Add("Expected Sale");
            missdata.Columns.Add("Division Code");
            missdata.Columns.Add("Coupon Amount");
            missdata.Columns.Add("Assest Code");
            missdata.Columns.Add("ErrorMsg");

            bool flag = true;

            if (flParlourUpload.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flParlourUpload.PostedFile.FileName));
                flParlourUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flParlourUpload.PostedFile.FileName);
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
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtPOH.Rows)
                            {
                                string DealerCode = item["Dealer Code"].ToString();
                                if (ctx.OCRDs.Any(x => x.CustomerCode == DealerCode && x.Type == 3 && x.Active))
                                {
                                    string AssetCode = item["Assest Code"].ToString();
                                    if (!string.IsNullOrEmpty(AssetCode))
                                    {
                                        Decimal CustomerID = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DealerCode && x.Type == 3 && x.Active).CustomerID;

                                        OAST objOAST = ctx.OASTs.FirstOrDefault(x => x.AssetCode == AssetCode);
                                        if (objOAST == null || (!ctx.SCM1.Any(x => x.AssetID == objOAST.AssetID && x.Active && x.CustomerID != CustomerID)))
                                        {
                                            Decimal DistID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == CustomerID).ParentID;
                                            if (ctx.OGCRDs.Any(x => x.CustomerID == DistID && x.PlantID.HasValue))
                                            {
                                                string DivisionCode = item["Division Code"].ToString();
                                                if (ctx.ODIVs.Any(x => x.DivisionCode == DivisionCode && x.Active))
                                                {
                                                    if (!string.IsNullOrEmpty(item["From"].ToString()) && !string.IsNullOrEmpty(item["Up To"].ToString()) &&
                                                        !string.IsNullOrEmpty(item["Comp. Cont. In %"].ToString()) && !string.IsNullOrEmpty(item["Dist. Cont. In %"].ToString())
                                                        && !string.IsNullOrEmpty(item["Expected Sale"].ToString()) && !string.IsNullOrEmpty(item["Coupon Amount"].ToString()))
                                                    {
                                                        Decimal DecNum = 0;
                                                        DateTime dt;

                                                        if (Decimal.TryParse(item["Comp. Cont. In %"].ToString(), out DecNum) &&
                                                           Decimal.TryParse(item["Dist. Cont. In %"].ToString(), out DecNum) &&
                                                           Decimal.TryParse(item["Expected Sale"].ToString(), out DecNum) &&
                                                           Decimal.TryParse(item["Coupon Amount"].ToString(), out DecNum) && DecNum > 0 &&
                                                           DateTime.TryParse(item["From"].ToString(), out dt) &&
                                                           DateTime.TryParse(item["Up To"].ToString(), out dt))
                                                        {

                                                        }
                                                        else
                                                        {
                                                            DataRow missdr = missdata.NewRow();
                                                            missdr["Dealer Code"] = DealerCode;
                                                            missdr["From"] = item["From"].ToString();
                                                            missdr["Up To"] = item["Up To"].ToString();
                                                            missdr["Comp. Cont. In %"] = item["Comp. Cont. In %"].ToString();
                                                            missdr["Dist. Cont. In %"] = item["Dist. Cont. In %"].ToString();
                                                            missdr["Expected Sale"] = item["Expected Sale"].ToString();
                                                            missdr["Division Code"] = DivisionCode;
                                                            missdr["Coupon Amount"] = item["Coupon Amount"].ToString();
                                                            missdr["Assest Code"] = AssetCode;
                                                            missdr["ErrorMsg"] = "Data is not proper.";
                                                            missdata.Rows.Add(missdr);
                                                            flag = false;
                                                        }
                                                    }
                                                    else
                                                    {
                                                        DataRow missdr = missdata.NewRow();
                                                        missdr["Dealer Code"] = DealerCode;
                                                        missdr["From"] = item["From"].ToString();
                                                        missdr["Up To"] = item["Up To"].ToString();
                                                        missdr["Comp. Cont. In %"] = item["Comp. Cont. In %"].ToString();
                                                        missdr["Dist. Cont. In %"] = item["Dist. Cont. In %"].ToString();
                                                        missdr["Expected Sale"] = item["Expected Sale"].ToString();
                                                        missdr["Division Code"] = DivisionCode;
                                                        missdr["Coupon Amount"] = item["Coupon Amount"].ToString();
                                                        missdr["Assest Code"] = AssetCode;
                                                        missdr["ErrorMsg"] = "Data is not proper.";
                                                        missdata.Rows.Add(missdr);
                                                        flag = false;
                                                    }
                                                }
                                                else
                                                {
                                                    DataRow missdr = missdata.NewRow();
                                                    missdr["Dealer Code"] = DealerCode;
                                                    missdr["From"] = "";
                                                    missdr["Up To"] = "";
                                                    missdr["Comp. Cont. In %"] = "";
                                                    missdr["Dist. Cont. In %"] = "";
                                                    missdr["Expected Sale"] = "";
                                                    missdr["Division Code"] = DivisionCode;
                                                    missdr["Coupon Amount"] = "";
                                                    missdr["Assest Code"] = AssetCode;
                                                    missdr["ErrorMsg"] = "'" + DivisionCode + "' does not exist or not active.";
                                                    missdata.Rows.Add(missdr);
                                                    flag = false;
                                                }
                                            }
                                            else
                                            {
                                                DataRow missdr = missdata.NewRow();
                                                missdr["Dealer Code"] = DealerCode;
                                                missdr["From"] = "";
                                                missdr["Up To"] = "";
                                                missdr["Comp. Cont. In %"] = "";
                                                missdr["Dist. Cont. In %"] = "";
                                                missdr["Expected Sale"] = "";
                                                missdr["Division Code"] = "";
                                                missdr["Coupon Amount"] = "";
                                                missdr["Assest Code"] = AssetCode;
                                                missdr["ErrorMsg"] = "Plant code does not exist";
                                                missdata.Rows.Add(missdr);
                                                flag = false;
                                            }
                                        }
                                        else
                                        {
                                            DataRow missdr = missdata.NewRow();
                                            missdr["Dealer Code"] = DealerCode;
                                            missdr["From"] = "";
                                            missdr["Up To"] = "";
                                            missdr["Comp. Cont. In %"] = "";
                                            missdr["Dist. Cont. In %"] = "";
                                            missdr["Expected Sale"] = "";
                                            missdr["Division Code"] = "";
                                            missdr["Coupon Amount"] = "";
                                            missdr["Assest Code"] = AssetCode;
                                            missdr["ErrorMsg"] = "Same Asset : " + AssetCode + " is already mapped with customer.";
                                            missdata.Rows.Add(missdr);
                                            flag = false;
                                        }
                                    }
                                    else
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Dealer Code"] = DealerCode;
                                        missdr["From"] = "";
                                        missdr["Up To"] = "";
                                        missdr["Comp. Cont. In %"] = "";
                                        missdr["Dist. Cont. In %"] = "";
                                        missdr["Expected Sale"] = "";
                                        missdr["Division Code"] = "";
                                        missdr["Coupon Amount"] = "";
                                        missdr["Assest Code"] = AssetCode;
                                        missdr["ErrorMsg"] = "'" + AssetCode + "' Assest Code is compulsory.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Dealer Code"] = DealerCode;
                                    missdr["From"] = "";
                                    missdr["Up To"] = "";
                                    missdr["Comp. Cont. In %"] = "";
                                    missdr["Dist. Cont. In %"] = "";
                                    missdr["Expected Sale"] = "";
                                    missdr["Division Code"] = "";
                                    missdr["Coupon Amount"] = "";
                                    missdr["Assest Code"] = "";
                                    missdr["ErrorMsg"] = "Dealer Code: '" + DealerCode + "' does not exist or not active.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                            }
                        }
                    }

                    if (flag)
                    {

                        if (dtPOH != null && dtPOH.Rows != null && dtPOH.Rows.Count > 0)
                        {
                            using (DDMSEntities ctx = new DDMSEntities())
                            {
                                int SchemeID = ctx.GetKey("OSCM", "SchemeID", "", 0, 0).FirstOrDefault().Value;
                                int SCM1Count = ctx.GetKey("SCM1", "SCM1ID", "", 0, 0).FirstOrDefault().Value;
                                int SCM3Count = ctx.GetKey("SCM3", "SCM3ID", "", 0, 0).FirstOrDefault().Value;
                                int SchemeCount = ctx.GetKey("SCM4", "SCM4ID", "", 0, 0).FirstOrDefault().Value;
                                int AssetCount = ctx.GetKey("OAST", "AssetID", "", 0, 0).FirstOrDefault().Value;
                                foreach (DataRow item in dtPOH.Rows)
                                {
                                    try
                                    {
                                        string DealerCode = item["Dealer Code"].ToString();
                                        Decimal CustomerID = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DealerCode && x.Type == 3).CustomerID;
                                        if (CustomerID > 0)
                                        {
                                            Decimal DistID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == CustomerID).ParentID;

                                            string DivisionCode = item["Division Code"].ToString();
                                            int DivisionlID = ctx.ODIVs.FirstOrDefault(x => x.DivisionCode == DivisionCode).DivisionlID;
                                            if (DivisionlID > 0)
                                            {
                                                string AssetCode = item["Assest Code"].ToString().Trim();
                                                OAST objOAST = ctx.OASTs.FirstOrDefault(x => x.AssetCode == AssetCode);
                                                if (objOAST == null)
                                                {
                                                    objOAST = new OAST();
                                                    objOAST.AssetID = AssetCount++;
                                                    objOAST.AssetCode = AssetCode;
                                                    objOAST.AssetName = AssetCode;
                                                    objOAST.AssetTypeID = 4;
                                                    objOAST.ModelNumber = AssetCode;
                                                    objOAST.SerialNumber = AssetCode;
                                                    objOAST.AdditionalIdentifier = "99999";
                                                    objOAST.HoldByCustomerID = CustomerID;
                                                    objOAST.CreatedDate = DateTime.Now;
                                                    objOAST.CreatedBy = UserID;
                                                    objOAST.UpdatedDate = DateTime.Now;
                                                    objOAST.UpdatedBy = UserID;
                                                    objOAST.Active = true;
                                                    objOAST.AssetSubnumber = "0001";
                                                    objOAST.Location = ctx.CRD1.FirstOrDefault(x => x.CustomerID == CustomerID).OCTY.CityName;
                                                    objOAST.AcqDate = DateTime.Now;
                                                    objOAST.PlantID = ctx.OGCRDs.FirstOrDefault(x => x.CustomerID == DistID && x.PlantID.HasValue).PlantID;
                                                    objOAST.Volume = 1;
                                                    ctx.OASTs.Add(objOAST);
                                                }
                                                if (ctx.SCM1.Any(x => x.AssetID == objOAST.AssetID && x.Active && x.CustomerID != CustomerID))
                                                {
                                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Asset : " + AssetCode + " is already mapped with customer.',3);", true);
                                                    return;
                                                }

                                                DateTime Startdate = Convert.ToDateTime(item["From"].ToString());
                                                DateTime EndDate = Convert.ToDateTime(item["Up To"].ToString());

                                                Decimal ComPercentage = Convert.ToDecimal(item["Comp. Cont. In %"].ToString());
                                                Decimal DistPercenatage = Convert.ToDecimal(item["Dist. Cont. In %"].ToString());
                                                Decimal ExpectedSale = Convert.ToDecimal(item["Expected Sale"].ToString());
                                                Decimal CouponAmount = Convert.ToDecimal(item["Coupon Amount"].ToString());

                                                OSCM objOSCM = null;
                                                SCM4 objSCM4 = ctx.SCM4.Include("OSCM").FirstOrDefault(x => x.OSCM.ApplicableMode == "P" && x.HigherLimit == ExpectedSale && x.CompanyDisc == ComPercentage && x.DistributorDisc == DistPercenatage
                                                    && EntityFunctions.TruncateTime(x.OSCM.StartDate) == EntityFunctions.TruncateTime(Startdate) && EntityFunctions.TruncateTime(x.OSCM.EndDate) == EntityFunctions.TruncateTime(EndDate));
                                                if (objSCM4 == null)
                                                {
                                                    objOSCM = new OSCM();
                                                    objOSCM.SchemeID = SchemeID++;
                                                    objOSCM.StartDate = Startdate;
                                                    objOSCM.EndDate = EndDate;
                                                    objOSCM.ReasonID = null;
                                                    objOSCM.SchemeCode = "PSC" + objOSCM.SchemeID.ToString();
                                                    objOSCM.SchemeName = "PScheme" + objOSCM.SchemeID.ToString();
                                                    objOSCM.Active = true;
                                                    objOSCM.ApplicableMode = "P";
                                                    if (ctx.ORSNs.Any(x => x.ReasonDesc == "P" && x.Active))
                                                    {
                                                        objOSCM.ReasonID = ctx.ORSNs.FirstOrDefault(x => x.ReasonDesc == "P" && x.Active).ReasonID;
                                                    }
                                                    objOSCM.ApplicableOn = 3;
                                                    objOSCM.BirthDay = true;
                                                    objOSCM.Anniversary = true;
                                                    objOSCM.SpecialDay = true;
                                                    objOSCM.Monday = true;
                                                    objOSCM.Tuesday = true;
                                                    objOSCM.Wednesday = true;
                                                    objOSCM.Thursday = true;
                                                    objOSCM.Friday = true;
                                                    objOSCM.Saturday = true;
                                                    objOSCM.Sunday = true;
                                                    objOSCM.IsTaxApplicable = false;
                                                    objOSCM.Remarks = null;

                                                    objOSCM.CreatedDate = DateTime.Now;
                                                    objOSCM.CreatedBy = UserID;

                                                    objOSCM.UpdatedDate = DateTime.Now;
                                                    objOSCM.UpdatedBy = UserID;

                                                    ctx.OSCMs.Add(objOSCM);

                                                    //SCM4     
                                                    objSCM4 = new SCM4();
                                                    objSCM4.SCM4ID = SchemeCount++;
                                                    objSCM4.CompanyDisc = ComPercentage;
                                                    objSCM4.DistributorDisc = DistPercenatage;
                                                    objSCM4.SchemeID = objOSCM.SchemeID;
                                                    objSCM4.Discount = (ComPercentage + DistPercenatage);
                                                    objSCM4.LowerLimit = 0;
                                                    objSCM4.HigherLimit = ExpectedSale;
                                                    objSCM4.ItemGroupID = null;
                                                    objSCM4.ItemSubGroupID = null;
                                                    objSCM4.ItemID = null;
                                                    objSCM4.Occurrence = 0;
                                                    objSCM4.Quantity = 0;
                                                    objSCM4.BasedOn = 1;
                                                    objSCM4.DiscountType = "P";
                                                    objOSCM.SCM4.Add(objSCM4);
                                                }
                                                else
                                                {
                                                    objSCM4.OSCM.UpdatedDate = DateTime.Now;
                                                    objSCM4.OSCM.UpdatedBy = UserID;
                                                }


                                                SCM3 objSCM3 = ctx.SCM3.FirstOrDefault(x => x.SchemeID == objSCM4.SchemeID && x.DivisionID == DivisionlID);
                                                if (objSCM3 == null)
                                                {
                                                    objSCM3 = new SCM3();
                                                    objSCM3.SCM3ID = SCM3Count++;
                                                    objSCM3.SchemeID = objSCM4.SchemeID;
                                                    objSCM3.IsInclude = true;
                                                    objSCM3.DivisionID = DivisionlID;
                                                    ctx.SCM3.Add(objSCM3);
                                                }

                                                SCM1 objoldSCM1 = ctx.SCM1.FirstOrDefault(x => x.AssetID == objOAST.AssetID && x.CustomerID == CustomerID && x.Active);
                                                if (objoldSCM1 == null)
                                                {
                                                    SCM1 objSCM1 = new SCM1();
                                                    objSCM1.SCM1ID = SCM1Count++;
                                                    objSCM1.CustomerID = CustomerID;
                                                    objSCM1.SchemeID = objSCM4.SchemeID;
                                                    objSCM1.Type = 3;
                                                    objSCM1.CreatedDate = DateTime.Now;
                                                    objSCM1.Active = true;
                                                    objSCM1.IsInclude = true;
                                                    objSCM1.UsedCoupon = 0;
                                                    objSCM1.CouponAmount = CouponAmount;
                                                    objSCM1.AssetID = objOAST.AssetID;
                                                    ctx.SCM1.Add(objSCM1);
                                                }
                                                else if (objoldSCM1.SchemeID == objSCM4.SchemeID)
                                                {
                                                    objoldSCM1.Active = true;
                                                    objoldSCM1.IsInclude = true;
                                                    objoldSCM1.CouponAmount = CouponAmount;
                                                }
                                                else
                                                {
                                                    objoldSCM1.Active = false;

                                                    SCM1 objSCM1 = new SCM1();
                                                    objSCM1.SCM1ID = SCM1Count++;
                                                    objSCM1.CustomerID = CustomerID;
                                                    objSCM1.Type = 3;
                                                    objSCM1.SchemeID = objSCM4.SchemeID;
                                                    objSCM1.CreatedDate = DateTime.Now;
                                                    objSCM1.Active = true;
                                                    objSCM1.IsInclude = true;
                                                    objSCM1.UsedCoupon = objoldSCM1.UsedCoupon;
                                                    objSCM1.CouponAmount = CouponAmount;
                                                    objSCM1.AssetID = objoldSCM1.AssetID;
                                                    ctx.SCM1.Add(objSCM1);
                                                }
                                                ctx.SaveChanges();

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
                                        return;
                                    }

                                }
                            }
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);
                        }
                    }
                    else
                    {
                        gvMissdata.DataSource = missdata;
                        gvMissdata.DataBind();
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

    protected void btnVRSUpload_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable missdata = new DataTable();
            missdata.Columns.Add("Dealer Code");
            missdata.Columns.Add("From");
            missdata.Columns.Add("Up To");
            missdata.Columns.Add("Comp. Cont. In %");
            missdata.Columns.Add("Dist. Cont. In %");
            missdata.Columns.Add("Expected Sale");
            missdata.Columns.Add("Division Code");
            missdata.Columns.Add("Coupon Amount");
            missdata.Columns.Add("Assest Code");
            missdata.Columns.Add("ErrorMsg");

            bool flag = true;

            if (flVRSUpload.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flVRSUpload.PostedFile.FileName));
                flVRSUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flVRSUpload.PostedFile.FileName);
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
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtPOH.Rows)
                            {
                                string DealerCode = item["Dealer Code"].ToString();
                                if (ctx.OCRDs.Any(x => x.CustomerCode == DealerCode && x.Type == 3 && x.Active))
                                {
                                    string AssetCode = item["Assest Code"].ToString();
                                    if (!string.IsNullOrEmpty(AssetCode))
                                    {
                                        Decimal CustomerID = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DealerCode && x.Type == 3 && x.Active).CustomerID;

                                        OAST objOAST = ctx.OASTs.FirstOrDefault(x => x.AssetCode == AssetCode);
                                        if (objOAST == null || (!ctx.SCM1.Any(x => x.AssetID == objOAST.AssetID && x.Active && x.CustomerID != CustomerID)))
                                        {
                                            Decimal DistID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == CustomerID).ParentID;
                                            if (ctx.OGCRDs.Any(x => x.CustomerID == DistID && x.PlantID.HasValue))
                                            {
                                                string DivisionCode = item["Division Code"].ToString();
                                                if (ctx.ODIVs.Any(x => x.DivisionCode == DivisionCode && x.Active))
                                                {
                                                    if (!string.IsNullOrEmpty(item["From"].ToString()) && !string.IsNullOrEmpty(item["Up To"].ToString()) &&
                                                        !string.IsNullOrEmpty(item["Comp. Cont. In %"].ToString()) && !string.IsNullOrEmpty(item["Dist. Cont. In %"].ToString())
                                                        && !string.IsNullOrEmpty(item["Expected Sale"].ToString()) && !string.IsNullOrEmpty(item["Coupon Amount"].ToString()))
                                                    {
                                                        Decimal DecNum = 0;
                                                        DateTime dt;

                                                        if (Decimal.TryParse(item["Comp. Cont. In %"].ToString(), out DecNum) &&
                                                           Decimal.TryParse(item["Dist. Cont. In %"].ToString(), out DecNum) &&
                                                           Decimal.TryParse(item["Expected Sale"].ToString(), out DecNum) &&
                                                           Decimal.TryParse(item["Coupon Amount"].ToString(), out DecNum) && DecNum > 0 &&
                                                           DateTime.TryParse(item["From"].ToString(), out dt) &&
                                                           DateTime.TryParse(item["Up To"].ToString(), out dt))
                                                        {

                                                        }
                                                        else
                                                        {
                                                            DataRow missdr = missdata.NewRow();
                                                            missdr["Dealer Code"] = DealerCode;
                                                            missdr["From"] = item["From"].ToString();
                                                            missdr["Up To"] = item["Up To"].ToString();
                                                            missdr["Comp. Cont. In %"] = item["Comp. Cont. In %"].ToString();
                                                            missdr["Dist. Cont. In %"] = item["Dist. Cont. In %"].ToString();
                                                            missdr["Expected Sale"] = item["Expected Sale"].ToString();
                                                            missdr["Division Code"] = DivisionCode;
                                                            missdr["Coupon Amount"] = item["Coupon Amount"].ToString();
                                                            missdr["Assest Code"] = AssetCode;
                                                            missdr["ErrorMsg"] = "Data is not proper.";
                                                            missdata.Rows.Add(missdr);
                                                            flag = false;
                                                        }
                                                    }
                                                    else
                                                    {
                                                        DataRow missdr = missdata.NewRow();
                                                        missdr["Dealer Code"] = DealerCode;
                                                        missdr["From"] = item["From"].ToString();
                                                        missdr["Up To"] = item["Up To"].ToString();
                                                        missdr["Comp. Cont. In %"] = item["Comp. Cont. In %"].ToString();
                                                        missdr["Dist. Cont. In %"] = item["Dist. Cont. In %"].ToString();
                                                        missdr["Expected Sale"] = item["Expected Sale"].ToString();
                                                        missdr["Division Code"] = DivisionCode;
                                                        missdr["Coupon Amount"] = item["Coupon Amount"].ToString();
                                                        missdr["Assest Code"] = AssetCode;
                                                        missdr["ErrorMsg"] = "Data is not proper.";
                                                        missdata.Rows.Add(missdr);
                                                        flag = false;
                                                    }
                                                }
                                                else
                                                {
                                                    DataRow missdr = missdata.NewRow();
                                                    missdr["Dealer Code"] = DealerCode;
                                                    missdr["From"] = "";
                                                    missdr["Up To"] = "";
                                                    missdr["Comp. Cont. In %"] = "";
                                                    missdr["Dist. Cont. In %"] = "";
                                                    missdr["Expected Sale"] = "";
                                                    missdr["Division Code"] = DivisionCode;
                                                    missdr["Coupon Amount"] = "";
                                                    missdr["Assest Code"] = AssetCode;
                                                    missdr["ErrorMsg"] = "'" + DivisionCode + "' does not exist or not active.";
                                                    missdata.Rows.Add(missdr);
                                                    flag = false;
                                                }
                                            }
                                            else
                                            {
                                                DataRow missdr = missdata.NewRow();
                                                missdr["Dealer Code"] = DealerCode;
                                                missdr["From"] = "";
                                                missdr["Up To"] = "";
                                                missdr["Comp. Cont. In %"] = "";
                                                missdr["Dist. Cont. In %"] = "";
                                                missdr["Expected Sale"] = "";
                                                missdr["Division Code"] = "";
                                                missdr["Coupon Amount"] = "";
                                                missdr["Assest Code"] = AssetCode;
                                                missdr["ErrorMsg"] = "Plant code does not exist";
                                                missdata.Rows.Add(missdr);
                                                flag = false;
                                            }
                                        }
                                        else
                                        {
                                            DataRow missdr = missdata.NewRow();
                                            missdr["Dealer Code"] = DealerCode;
                                            missdr["From"] = "";
                                            missdr["Up To"] = "";
                                            missdr["Comp. Cont. In %"] = "";
                                            missdr["Dist. Cont. In %"] = "";
                                            missdr["Expected Sale"] = "";
                                            missdr["Division Code"] = "";
                                            missdr["Coupon Amount"] = "";
                                            missdr["Assest Code"] = AssetCode;
                                            missdr["ErrorMsg"] = "Same Asset : " + AssetCode + " is already mapped with customer.";
                                            missdata.Rows.Add(missdr);
                                            flag = false;
                                        }
                                    }
                                    else
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Dealer Code"] = DealerCode;
                                        missdr["From"] = "";
                                        missdr["Up To"] = "";
                                        missdr["Comp. Cont. In %"] = "";
                                        missdr["Dist. Cont. In %"] = "";
                                        missdr["Expected Sale"] = "";
                                        missdr["Division Code"] = "";
                                        missdr["Coupon Amount"] = "";
                                        missdr["Assest Code"] = AssetCode;
                                        missdr["ErrorMsg"] = "'" + AssetCode + "' Assest Code is compulsory.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Dealer Code"] = DealerCode;
                                    missdr["From"] = "";
                                    missdr["Up To"] = "";
                                    missdr["Comp. Cont. In %"] = "";
                                    missdr["Dist. Cont. In %"] = "";
                                    missdr["Expected Sale"] = "";
                                    missdr["Division Code"] = "";
                                    missdr["Coupon Amount"] = "";
                                    missdr["Assest Code"] = "";
                                    missdr["ErrorMsg"] = "Dealer Code: '" + DealerCode + "' does not exist or not active.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                            }
                        }
                    }

                    if (flag)
                    {

                        if (dtPOH != null && dtPOH.Rows != null && dtPOH.Rows.Count > 0)
                        {
                            using (DDMSEntities ctx = new DDMSEntities())
                            {
                                int SchemeID = ctx.GetKey("OSCM", "SchemeID", "", 0, 0).FirstOrDefault().Value;
                                int SCM1Count = ctx.GetKey("SCM1", "SCM1ID", "", 0, 0).FirstOrDefault().Value;
                                int SCM3Count = ctx.GetKey("SCM3", "SCM3ID", "", 0, 0).FirstOrDefault().Value;
                                int SchemeCount = ctx.GetKey("SCM4", "SCM4ID", "", 0, 0).FirstOrDefault().Value;
                                int AssetCount = ctx.GetKey("OAST", "AssetID", "", 0, 0).FirstOrDefault().Value;
                                foreach (DataRow item in dtPOH.Rows)
                                {
                                    try
                                    {
                                        string DealerCode = item["Dealer Code"].ToString();
                                        Decimal CustomerID = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DealerCode && x.Type == 3).CustomerID;
                                        if (CustomerID > 0)
                                        {
                                            Decimal DistID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == CustomerID).ParentID;

                                            string DivisionCode = item["Division Code"].ToString();
                                            int DivisionlID = ctx.ODIVs.FirstOrDefault(x => x.DivisionCode == DivisionCode).DivisionlID;
                                            if (DivisionlID > 0)
                                            {
                                                string AssetCode = item["Assest Code"].ToString().Trim();
                                                OAST objOAST = ctx.OASTs.FirstOrDefault(x => x.AssetCode == AssetCode);
                                                if (objOAST == null)
                                                {
                                                    objOAST = new OAST();
                                                    objOAST.AssetID = AssetCount++;
                                                    objOAST.AssetCode = AssetCode;
                                                    objOAST.AssetName = AssetCode;
                                                    objOAST.AssetTypeID = 4;
                                                    objOAST.ModelNumber = AssetCode;
                                                    objOAST.SerialNumber = AssetCode;
                                                    objOAST.AdditionalIdentifier = "99999";
                                                    objOAST.HoldByCustomerID = CustomerID;
                                                    objOAST.CreatedDate = DateTime.Now;
                                                    objOAST.CreatedBy = UserID;
                                                    objOAST.UpdatedDate = DateTime.Now;
                                                    objOAST.UpdatedBy = UserID;
                                                    objOAST.Active = true;
                                                    objOAST.AssetSubnumber = "0001";
                                                    objOAST.Location = ctx.CRD1.FirstOrDefault(x => x.CustomerID == CustomerID).OCTY.CityName;
                                                    objOAST.AcqDate = DateTime.Now;
                                                    objOAST.PlantID = ctx.OGCRDs.FirstOrDefault(x => x.CustomerID == DistID && x.PlantID.HasValue).PlantID;
                                                    objOAST.Volume = 1;
                                                    ctx.OASTs.Add(objOAST);
                                                }
                                                if (ctx.SCM1.Any(x => x.AssetID == objOAST.AssetID && x.Active && x.CustomerID != CustomerID))
                                                {
                                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Asset : " + AssetCode + " is already mapped with customer.',3);", true);
                                                    return;
                                                }

                                                DateTime Startdate = Convert.ToDateTime(item["From"].ToString());
                                                DateTime EndDate = Convert.ToDateTime(item["Up To"].ToString());

                                                Decimal ComPercentage = Convert.ToDecimal(item["Comp. Cont. In %"].ToString());
                                                Decimal DistPercenatage = Convert.ToDecimal(item["Dist. Cont. In %"].ToString());
                                                Decimal ExpectedSale = Convert.ToDecimal(item["Expected Sale"].ToString());
                                                Decimal CouponAmount = Convert.ToDecimal(item["Coupon Amount"].ToString());

                                                OSCM objOSCM = null;
                                                SCM4 objSCM4 = ctx.SCM4.Include("OSCM").FirstOrDefault(x => x.OSCM.ApplicableMode == "V" && x.HigherLimit == ExpectedSale && x.CompanyDisc == ComPercentage && x.DistributorDisc == DistPercenatage
                                                    && EntityFunctions.TruncateTime(x.OSCM.StartDate) == EntityFunctions.TruncateTime(Startdate) && EntityFunctions.TruncateTime(x.OSCM.EndDate) == EntityFunctions.TruncateTime(EndDate));
                                                if (objSCM4 == null)
                                                {
                                                    objOSCM = new OSCM();
                                                    objOSCM.SchemeID = SchemeID++;
                                                    objOSCM.StartDate = Startdate;
                                                    objOSCM.EndDate = EndDate;
                                                    objOSCM.ReasonID = null;
                                                    objOSCM.SchemeCode = "VRS" + objOSCM.SchemeID.ToString();
                                                    objOSCM.SchemeName = "VRSScheme" + objOSCM.SchemeID.ToString();
                                                    objOSCM.Active = true;
                                                    objOSCM.ApplicableMode = "V";
                                                    if (ctx.ORSNs.Any(x => x.ReasonDesc == "V" && x.Active))
                                                    {
                                                        objOSCM.ReasonID = ctx.ORSNs.FirstOrDefault(x => x.ReasonDesc == "V" && x.Active).ReasonID;
                                                    }
                                                    objOSCM.ApplicableOn = 3;
                                                    objOSCM.BirthDay = true;
                                                    objOSCM.Anniversary = true;
                                                    objOSCM.SpecialDay = true;
                                                    objOSCM.Monday = true;
                                                    objOSCM.Tuesday = true;
                                                    objOSCM.Wednesday = true;
                                                    objOSCM.Thursday = true;
                                                    objOSCM.Friday = true;
                                                    objOSCM.Saturday = true;
                                                    objOSCM.Sunday = true;
                                                    objOSCM.IsTaxApplicable = false;
                                                    objOSCM.Remarks = null;

                                                    objOSCM.CreatedDate = DateTime.Now;
                                                    objOSCM.CreatedBy = UserID;

                                                    objOSCM.UpdatedDate = DateTime.Now;
                                                    objOSCM.UpdatedBy = UserID;

                                                    ctx.OSCMs.Add(objOSCM);

                                                    //SCM4     
                                                    objSCM4 = new SCM4();
                                                    objSCM4.SCM4ID = SchemeCount++;
                                                    objSCM4.CompanyDisc = ComPercentage;
                                                    objSCM4.DistributorDisc = DistPercenatage;
                                                    objSCM4.SchemeID = objOSCM.SchemeID;
                                                    objSCM4.Discount = (ComPercentage + DistPercenatage);
                                                    objSCM4.LowerLimit = 0;
                                                    objSCM4.HigherLimit = ExpectedSale;
                                                    objSCM4.ItemGroupID = null;
                                                    objSCM4.ItemSubGroupID = null;
                                                    objSCM4.ItemID = null;
                                                    objSCM4.Occurrence = 0;
                                                    objSCM4.Quantity = 0;
                                                    objSCM4.BasedOn = 1;
                                                    objSCM4.DiscountType = "P";
                                                    objOSCM.SCM4.Add(objSCM4);
                                                }
                                                else
                                                {
                                                    objSCM4.OSCM.UpdatedDate = DateTime.Now;
                                                    objSCM4.OSCM.UpdatedBy = UserID;
                                                }


                                                SCM3 objSCM3 = ctx.SCM3.FirstOrDefault(x => x.SchemeID == objSCM4.SchemeID && x.DivisionID == DivisionlID);
                                                if (objSCM3 == null)
                                                {
                                                    objSCM3 = new SCM3();
                                                    objSCM3.SCM3ID = SCM3Count++;
                                                    objSCM3.SchemeID = objSCM4.SchemeID;
                                                    objSCM3.IsInclude = true;
                                                    objSCM3.DivisionID = DivisionlID;
                                                    ctx.SCM3.Add(objSCM3);
                                                }

                                                SCM1 objoldSCM1 = ctx.SCM1.FirstOrDefault(x => x.AssetID == objOAST.AssetID && x.CustomerID == CustomerID && x.Active);
                                                if (objoldSCM1 == null)
                                                {
                                                    SCM1 objSCM1 = new SCM1();
                                                    objSCM1.SCM1ID = SCM1Count++;
                                                    objSCM1.CustomerID = CustomerID;
                                                    objSCM1.SchemeID = objSCM4.SchemeID;
                                                    objSCM1.Type = 3;
                                                    objSCM1.CreatedDate = DateTime.Now;
                                                    objSCM1.Active = true;
                                                    objSCM1.IsInclude = true;
                                                    objSCM1.UsedCoupon = 0;
                                                    objSCM1.CouponAmount = CouponAmount;
                                                    objSCM1.AssetID = objOAST.AssetID;
                                                    ctx.SCM1.Add(objSCM1);
                                                }
                                                else if (objoldSCM1.SchemeID == objSCM4.SchemeID)
                                                {
                                                    objoldSCM1.Active = true;
                                                    objoldSCM1.IsInclude = true;
                                                    objoldSCM1.CouponAmount = CouponAmount;
                                                }
                                                else
                                                {
                                                    objoldSCM1.Active = false;

                                                    SCM1 objSCM1 = new SCM1();
                                                    objSCM1.SCM1ID = SCM1Count++;
                                                    objSCM1.CustomerID = CustomerID;
                                                    objSCM1.Type = 3;
                                                    objSCM1.SchemeID = objSCM4.SchemeID;
                                                    objSCM1.CreatedDate = DateTime.Now;
                                                    objSCM1.Active = true;
                                                    objSCM1.IsInclude = true;
                                                    objSCM1.UsedCoupon = objoldSCM1.UsedCoupon;
                                                    objSCM1.CouponAmount = CouponAmount;
                                                    objSCM1.AssetID = objoldSCM1.AssetID;
                                                    ctx.SCM1.Add(objSCM1);
                                                }
                                                ctx.SaveChanges();

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
                                        return;
                                    }

                                }
                            }
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);
                        }
                    }
                    else
                    {
                        gvMissdata.DataSource = missdata;
                        gvMissdata.DataBind();
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


    #endregion


}