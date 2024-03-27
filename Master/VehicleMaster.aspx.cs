using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_VehicleMaster : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx = null;
    String TempPath = Path.GetTempPath();

    private List<OATT> Attachments
    {
        get { return this.ViewState["Attachments"] as List<OATT>; }
        set { this.ViewState["Attachments"] = value; }
    }

    #endregion

    #region Helper Method

    public void ClearAllInputs()
    {
        if (chkMode.Checked)
        {
            txtVID.Enabled = acettxtVehicle.Enabled = false;
            txtVID.Text = "Auto Generated";
            txtVID.Style.Remove("background-color");
            divFSSI.Visible = false;
        }
        else
        {
            txtVID.Enabled = acettxtVehicle.Enabled = true;
            txtVID.Text = "";
            txtVID.Style.Add("background-color", "rgb(250, 255, 189);");
            divFSSI.Visible = true;
        }
        txtFSSINo.Enabled = false;
        ViewState["VehicleID"] = null;
        chkActive.Checked = true;
        txtDateOfPaint.Text = txtYearOfModel.Text = txtAverage.Text = txtLength.Text = txtNotes.Text = txtVehicleNumber.Text = txtModelName.Text = txtManufacturer.Text = txtPurDate.Text = txtSalesDate.Text = txtFSSINo.Text = "";
        ddlWheelType.SelectedValue = ddlVehicleType.SelectedValue = ddlFuelType.SelectedValue = "0";
        alink.HRef = imgVehicle.ImageUrl = "~/Images/no.jpg";

        txtAttachment.Text = txtAtchReminderDate.Text = txtAtchNotes.Text = "";

        Attachments = new List<OATT>();
        gvAttach.DataSource = Attachments;
        gvAttach.DataBind();
    }

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            ctx = new DDMSEntities();
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

        acettxtVehicle.ContextKey = ParentID.ToString();
        if (!IsPostBack)
        {
            ClearAllInputs();
            txtVehicleNumber.Focus();
        }
    }

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            int VID = 0;
            decimal IntNum;
            var objITM2 = new ITM2();
            OVCL objVehicle;
            if (!chkMode.Checked && ViewState["VehicleID"] != null && Int32.TryParse(ViewState["VehicleID"].ToString(), out VID))
            {
                objVehicle = ctx.OVCLs.FirstOrDefault(x => x.VehicleID == VID && x.ParentID == ParentID);
                if (ctx.OVCLs.Any(x => x.VehicleNumber == txtVehicleNumber.Text && x.ParentID == ParentID && x.VehicleID != VID))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same vehicle number is not allowed!',3);", true);
                    return;
                }
            }
            else
            {
                objVehicle = new OVCL();
                if (ctx.OVCLs.Any(x => x.VehicleNumber == txtVehicleNumber.Text && x.ParentID == ParentID))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same vehicle number is not allowed!',3);", true);
                    return;
                }
                objVehicle.VehicleID = ctx.GetKey("OVCL", "VehicleID", "", ParentID, 0).FirstOrDefault().Value;
                objVehicle.ParentID = ParentID;
                objVehicle.CreatedBy = UserID;

                objVehicle.CreatedDate = DateTime.Now;
                ctx.OVCLs.Add(objVehicle);
            }

            objVehicle.IsFree = true;
            objVehicle.VehicleNumber = txtVehicleNumber.Text;
            if (txtSalesDate.Text == "")
                objVehicle.Active = true;
            else
                objVehicle.Active = false;

            objVehicle.Average = Decimal.TryParse(txtAverage.Text, out IntNum) ? IntNum : 0;
            objVehicle.VehicleType = ddlVehicleType.SelectedValue;
            objVehicle.WheelType = ddlWheelType.SelectedValue;
            objVehicle.FuelType = ddlFuelType.SelectedValue;
            objVehicle.Length = Decimal.TryParse(txtLength.Text, out IntNum) ? IntNum : 0;
            objVehicle.YearOfModel = Convert.ToInt32(Decimal.TryParse(txtYearOfModel.Text, out IntNum) ? IntNum : 0);
            if (txtDateOfPaint.Text == "")
                objVehicle.DateOfPaint = DateTime.Now;
            else
                objVehicle.DateOfPaint = Common.DateTimeConvert(txtDateOfPaint.Text).Add(DateTime.Now.TimeOfDay);
            objVehicle.ModelName = txtModelName.Text;
            objVehicle.Manufacturer = txtManufacturer.Text;
            if (txtPurDate.Text == "")
                objVehicle.PurchaseDate = null;
            else
                objVehicle.PurchaseDate = Common.DateTimeConvert(txtPurDate.Text).Add(DateTime.Now.TimeOfDay);
            if (txtSalesDate.Text == "")
                objVehicle.SalesDate = null;
            else
                objVehicle.SalesDate = Common.DateTimeConvert(txtSalesDate.Text).Add(DateTime.Now.TimeOfDay);
            objVehicle.Notes = txtNotes.Text;
            objVehicle.UpdatedBy = UserID;
            objVehicle.UpdatedDate = DateTime.Now;

            if (Session["PhotoFileName"] != null)
            {
                string FileName = Session["PhotoFileName"].ToString();
                string SavePath = Path.Combine(Server.MapPath(Constant.VehiclePhoto), FileName);
                string SourcePath = TempPath + FileName;
                File.Copy(SourcePath, SavePath);

                if (!String.IsNullOrEmpty(objVehicle.VehiclePhoto) && File.Exists(Constant.VehiclePhoto + objVehicle.VehiclePhoto))
                    File.Delete(Constant.VehiclePhoto + objVehicle.VehiclePhoto);

                objVehicle.VehiclePhoto = FileName;
                Session["PhotoFileName"] = null;
            }

            int Count = ctx.GetKey("OATT", "AttachmentID", "", ParentID, 0).FirstOrDefault().Value;
            foreach (OATT item in Attachments)
            {
                OATT objOATT = null;
                if (item.AttachmentID == 0)
                {
                    objOATT = new OATT();
                    objOATT.AttachmentID = Count++;
                    objOATT.MainID = objVehicle.VehicleID;
                    objOATT.ParentID = objVehicle.ParentID;
                    objOATT.TableName = "OVCL";
                    objOATT.Active = true;
                    ctx.OATTs.Add(objOATT);
                }
                else
                {
                    objOATT = ctx.OATTs.FirstOrDefault(x => x.AttachmentID == item.AttachmentID && x.ParentID == ParentID);
                    if (item.EState == EState.Deleted)
                        objOATT.Active = false;
                }
                if (objOATT.Image != item.Image)
                {
                    string sourceFile = Path.Combine(TempPath, item.Image);
                    if (File.Exists(sourceFile))
                    {
                        string destFile = Path.Combine(Server.MapPath(Constant.VehicleDoc), item.Image);
                        File.Copy(sourceFile, destFile);
                        if (objOATT.Image != null)
                        {
                            string ExistFile = Path.Combine(Server.MapPath(Constant.VehicleDoc), objOATT.Image);
                            if (File.Exists(sourceFile))
                                File.Delete(sourceFile);
                        }
                        objOATT.Image = item.Image;
                    }
                }
                objOATT.Attachment = item.Attachment;
                objOATT.ReminderDate = item.ReminderDate;
                objOATT.Date = DateTime.Now;
                objOATT.Notes = item.Notes;
            }
            ctx.SaveChanges();

            foreach (OATT item in Attachments)
            {
                string sourceFile = Path.Combine(TempPath, item.Image);
                if (File.Exists(sourceFile))
                    File.Delete(sourceFile);
            }
            ClearAllInputs();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Record submitted successfully : " + objVehicle.VehicleNumber + "',1);", true);

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

    protected void afuVehiclePhoto_UploadedComplete(object sender, AsyncFileUploadEventArgs e)
    {
        try
        {
            if (afuVehiclePhoto != null && afuVehiclePhoto.HasFile)
            {
                System.IO.FileInfo f = new FileInfo(afuVehiclePhoto.PostedFile.FileName);
                if (Int32.Parse(e.FileSize) > 1024000)
                {
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('File size should not be greater than 1 MB!',3);", true);
                    return;
                }
                if ((f.Extension.ToLower() == ".jpg") || (f.Extension.ToLower() == ".png") || (f.Extension.ToLower() == ".gif") || (f.Extension.ToLower() == ".jpeg"))
                {
                    string newFile = Guid.NewGuid().ToString("N") + Path.GetExtension(afuVehiclePhoto.FileName);
                    Session["PhotoFileName"] = newFile;
                    afuVehiclePhoto.PostedFile.SaveAs(TempPath + newFile);

                }
                else
                {
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('Only image is allowed!',3);", true);
                    return;
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion

    #region Text Change Event

    protected void txtVehicleNumber_TextChanged(object sender, EventArgs e)
    {
        if (!chkMode.Checked && !String.IsNullOrEmpty(txtVID.Text))
        {
            var objVehicle = ctx.OVCLs.FirstOrDefault(x => x.VehicleNumber == txtVID.Text && x.ParentID == ParentID);
            if (objVehicle != null)
            {
                txtVehicleNumber.Text = objVehicle.VehicleNumber;
                txtVID.Text = objVehicle.VehicleID.ToString();
                ViewState["VehicleID"] = objVehicle.VehicleID;
                chkActive.Checked = objVehicle.Active;
                txtAverage.Text = objVehicle.Average.ToString();
                ddlFuelType.SelectedValue = objVehicle.FuelType;
                txtLength.Text = objVehicle.Length.ToString();
                txtNotes.Text = objVehicle.Notes;
                txtDateOfPaint.Text = Common.DateTimeConvert(objVehicle.DateOfPaint);
                DateTime PurchaseDate = DateTime.Now;
                if (Convert.ToString(objVehicle.PurchaseDate) != "")
                {
                    PurchaseDate = Convert.ToDateTime(objVehicle.PurchaseDate);
                    txtPurDate.Text = Common.DateTimeConvert(PurchaseDate);
                }
                DateTime SalesDate = DateTime.Now;
                if (Convert.ToString(objVehicle.SalesDate) != "")
                {
                    SalesDate = Convert.ToDateTime(objVehicle.SalesDate);
                    txtSalesDate.Text = Common.DateTimeConvert(SalesDate);
                }
                txtManufacturer.Text = objVehicle.Manufacturer;
                txtModelName.Text = objVehicle.ModelName;
                txtYearOfModel.Text = objVehicle.YearOfModel.ToString();
                txtVehicleNumber.Text = objVehicle.VehicleNumber;
                if (!String.IsNullOrEmpty(objVehicle.VehiclePhoto))
                    alink.HRef = imgVehicle.ImageUrl = Constant.VehiclePhoto + objVehicle.VehiclePhoto;
                else
                    alink.HRef = imgVehicle.ImageUrl = "~/Images/no.jpg";
                ddlVehicleType.SelectedValue = objVehicle.VehicleType;
                ddlWheelType.SelectedValue = objVehicle.WheelType;
                Attachments = ctx.OATTs.Where(x => x.TableName == "OVCL" && x.ParentID == ParentID && x.MainID == objVehicle.VehicleID && x.Active).ToList();
                var objOFSSI = ctx.OFSSIs.Where(x => x.VehicleNumber == objVehicle.VehicleNumber && x.VehicleParentID == objVehicle.ParentID).OrderByDescending(x => x.EndDate).FirstOrDefault();
                txtFSSINo.Text = objOFSSI != null ? objOFSSI.FSSINO + " / " + objOFSSI.EndDate.ToString("dd-MMM-yy") : "";
                gvAttach.DataSource = Attachments;
                gvAttach.DataBind();
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Find proper Vehicle!',3);", true);
            }
        }
        txtVehicleNumber.Focus();
    }

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    #endregion

    #region Image Upload

    protected void afuVehicle_UploadedComplete(object sender, AsyncFileUploadEventArgs e)
    {
        try
        {
            if (afuVehicle != null && afuVehicle.HasFile)
            {
                if (Int32.Parse(e.FileSize) < 1024000)
                {
                    string newFile = Guid.NewGuid().ToString("N") + Path.GetExtension(afuVehicle.FileName);
                    Session["FileName"] = newFile;
                    afuVehicle.PostedFile.SaveAs(TempPath + newFile);
                }
                else
                {
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('File size should not be greater than 1 MB!',3);", true);
                    return;
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnImageUpload_Click(object sender, EventArgs e)
    {
        try
        {
            if (String.IsNullOrEmpty(txtAttachment.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Attachment is required.',3);", true);
                return;
            }
            int Rowindex;
            OATT objOatt;
            if (ViewState["Rowindex"] != null && Int32.TryParse(ViewState["Rowindex"].ToString(), out Rowindex))
            {
                objOatt = Attachments[Rowindex];
            }
            else
            {
                if (Session["FileName"] == null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('File is not uploaded properly!',3);", true);
                    return;
                }
                objOatt = new OATT();
                if (Attachments == null)
                    Attachments = new List<OATT>();
                Attachments.Add(objOatt);
            }
            objOatt.Active = true;
            objOatt.Attachment = txtAttachment.Text;
            if (Session["FileName"] != null)
            {
                objOatt.Image = Session["FileName"].ToString();
                Session["FileName"] = null;
            }
            objOatt.Notes = txtAtchNotes.Text;
            if (!String.IsNullOrEmpty(txtAtchReminderDate.Text))
                objOatt.ReminderDate = Common.DateTimeConvert(txtAtchReminderDate.Text).Add(DateTime.Now.TimeOfDay);
            objOatt.Date = DateTime.Now;
            txtAttachment.Text = "";
            txtAtchNotes.Text = "";
            txtAtchReminderDate.Text = "";
            btnImageUpload.Text = "Add Attachment";
            ViewState["Rowindex"] = null;
            gvAttach.DataSource = Attachments.Where(x => x.Active).ToList();
            gvAttach.DataBind();
            //    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Attachment uploaded Successfully!',1);", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void gvAttach_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int Rowindex = Convert.ToInt32(e.CommandArgument);
        var obj = Attachments[Rowindex];
        if (e.CommandName == "DeleteMode")
        {
            obj.Active = false;
            obj.EState = EState.Deleted;
            gvAttach.DataSource = Attachments.Where(x => x.Active).ToList();
            gvAttach.DataBind();

            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Record deleted successfully!',1);", true);
        }
        else if (e.CommandName == "Download")
        {
            string strURL;
            var dir = Path.GetTempPath();
            if (File.Exists(Server.MapPath(Constant.VehicleDoc) + obj.Image))
            {
                strURL = Server.MapPath(Constant.VehicleDoc) + obj.Image;
            }
            else if (File.Exists(dir + obj.Image))
            {
                strURL = dir + obj.Image;
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('File does not exist!',3);", true);
                return;
            }
            WebClient req = new WebClient();
            HttpResponse response = HttpContext.Current.Response;
            response.Clear();
            response.ClearContent();
            response.ClearHeaders();
            response.Buffer = true;
            response.AddHeader("Content-Disposition", "attachment;filename=\"" + obj.Image + "\"");
            byte[] data = req.DownloadData(strURL);
            response.BinaryWrite(data);
            response.End();
        }
        else if (e.CommandName == "EditMode")
        {
            ViewState["Rowindex"] = Rowindex;
            txtAttachment.Text = obj.Attachment;
            txtAtchNotes.Text = obj.Notes;
            if (obj.ReminderDate.HasValue)
                txtAtchReminderDate.Text = Common.DateTimeConvert(obj.ReminderDate.Value);
            btnImageUpload.Text = "Update Attachment";
        }
    }

    #endregion
}