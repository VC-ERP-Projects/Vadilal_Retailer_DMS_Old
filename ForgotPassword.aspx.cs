using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ForgotPassword : System.Web.UI.Page
{
    #region Helper Methods

    private void ClearAllInputs()
    {
        txtCode.Focus();
        txtCode.Text = txtEmail.Text = txtPhoneNo.Text = "";
        rdbPhone.Checked = rdbEmail.Checked = false;
        rdbPhone.Enabled = rdbEmail.Enabled = false;
    }

    public void ChangeEvent()
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == txtCode.Text && x.Active && new[] { 2, 4 }.Contains(x.Type));
                if (objOCRD == null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Customer Code does not Exist !',3);", true);
                    ClearAllInputs();
                    return;
                }
                else
                {
                    txtPhoneNo.Text = txtEmail.Text = "";
                    if (!string.IsNullOrEmpty(objOCRD.Phone) && !string.IsNullOrEmpty(objOCRD.EMail1))
                    {
                        rdbPhone.Checked = false;
                        rdbEmail.Checked = false;
                        rdbPhone.Enabled = rdbEmail.Enabled = true;
                        txtPhoneNo.Text = objOCRD.Phone;
                        txtEmail.Text = objOCRD.EMail1;
                    }
                    else if (!string.IsNullOrEmpty(objOCRD.EMail1))
                    {
                        rdbPhone.Checked = false;
                        rdbEmail.Checked = true;
                        rdbPhone.Enabled = rdbEmail.Enabled = false;
                        txtEmail.Text = objOCRD.EMail1;
                    }
                    else if (!string.IsNullOrEmpty(objOCRD.Phone))
                    {
                        rdbPhone.Checked = true;
                        rdbEmail.Checked = false;
                        rdbPhone.Enabled = rdbEmail.Enabled = false;
                        txtPhoneNo.Text = objOCRD.Phone;
                    }
                    else
                    {
                        rdbPhone.Enabled = rdbEmail.Enabled = false;
                        rdbPhone.Checked = false;
                        rdbEmail.Checked = false;
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Details Not Found, Please Contact to Company !',3);", true);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }
    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ClearAllInputs();
            if (Request.QueryString["CD"] != null)
            {
                txtCode.Text = Request.QueryString["CD"].ToString();
                ChangeEvent();
            }
        }
    }

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {

        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == txtCode.Text && x.Active && new[] { 2, 4 }.Contains(x.Type));
                if (objOCRD == null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Customer Code does not Exist !',3);", true);
                    return;
                }
                if (rdbPhone.Checked)
                {
                    if (!string.IsNullOrEmpty(objOCRD.Phone))
                    {
                        OEMP objEmp = ctx.OEMPs.FirstOrDefault(x => x.ParentID == objOCRD.CustomerID && x.EmpID == 1);
                        string Message = "Dear+" + objOCRD.CustomerName + "%2C+your+password+is%3A+" + Common.DecryptNumber(objEmp.UserName, objEmp.Password) + "+Regards+DMS+Team";
                        Service wb = new Service();
                        wb.SendSMS(objOCRD.Phone, Message);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Mobile No does not Exist !',3);", true);
                        return;
                    }
                }
                else if (rdbEmail.Checked)
                {
                    if (!String.IsNullOrEmpty(objOCRD.EMail1))
                    {
                        OEMP objEmp = ctx.OEMPs.FirstOrDefault(x => x.ParentID == objOCRD.CustomerID && x.EmpID == 1);
                        string mailBody = "";
                        mailBody += "<html><body style='background:url(http://vadilalicecreams.com/wp-content/uploads/2015/04/doodle.jpg)'>";
                        mailBody += "<div style='padding:5px;width:100%'>";
                        mailBody += "<table>";
                        mailBody += "<tr>Dear<strong> " + objOCRD.CustomerName + "</strong>,</tr>";
                        mailBody += "<tr><td></br></td><td></td></tr>";
                        mailBody += "<tr><td>Your Password : </td><td>" + Common.DecryptNumber(objEmp.UserName, objEmp.Password) + "</td></tr>";
                        mailBody += "<tr><td></br></td><td></td></tr>";
                        mailBody += "<tr><td></br></td><td></td></tr>";
                        mailBody += "<tr><td>Regards,</td></tr>";
                        mailBody += "<tr><td>DMS Team</td></tr>";
                        mailBody += "</table>";
                        mailBody += "</br>";
                        mailBody += "<hr>";
                        mailBody += "<div align='center' style='font-size:12px'>Vadilal Industries Ltd,Nr. Navrangpura Rly Crossing,Navangapura, Ahmedabad -9,Gujarat,India</div>";
                        mailBody += "<div align='center' style='font-size:12px'>Tele: +91 79 26564018 to 24 Email : info@vadilalgroup.com</div><hr>";
                        mailBody += "<div align='center'><span>This is an electronically generated Mail and do not reply.</span></div></div>";
                        mailBody += "</body></html>";

                        Common.SendMail("Password Recovery of " + objOCRD.CustomerName + "", mailBody, objOCRD.EMail1, "", null, null);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Email Address does not Exist !',3);", true);
                        return;
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please Select At least one Option !',3);", true);
                    return;
                }
                ClearAllInputs();

                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Password Details sent successfully!',1); window.location.href='Login.aspx';", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/Login.aspx");
    }

    #endregion
}