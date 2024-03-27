using System;
using System.Net.Mail;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class HelpDesk : System.Web.UI.Page
{
    #region Helper Methods

    private void ClearAllInputs()
    {
        txtDealerCode.Text = txtQuery.Text = txtUsername.Text = "";
        ddlModule.DataBind();
        ddlModule.Items.Insert(0, new ListItem("---Select---", "0"));
        ddlModule.Items.Insert(0, new ListItem("Other", "null"));
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ClearAllInputs();
            txtDealerCode.Focus();
        }
    }

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        MailMessage msg = new MailMessage();
        System.Net.Mail.SmtpClient client = new System.Net.Mail.SmtpClient();
        using (var ctx = new DDMSEntities())
        {
            try
            {
                if (Page.IsValid)
                {
                    if (String.IsNullOrEmpty(txtUsername.Text))
                    {
                        this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('UserName is required!',3);", true);
                        return;
                    }

                    var Cust = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == txtDealerCode.Text);
                    if (Cust == null)
                    {
                        this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('Dealer code does not exist!',3);", true);
                        return;
                    }
                    var Emp = ctx.OEMPs.FirstOrDefault(x => x.UserName == txtUsername.Text && x.ParentID == Cust.CustomerID);
                    if (Emp != null && Emp.EmpID > 0)
                    {
                        var objHELP = new HELP();

                        objHELP.HelpID = ctx.GetKey("HELP", "HelpID", "", 0, 0).FirstOrDefault().Value;
                        int MenuID;
                        if (Int32.TryParse(ddlModule.SelectedValue, out MenuID) && MenuID > 0)
                            objHELP.MenuID = MenuID;

                        objHELP.CustID = Cust.CustomerID;
                        objHELP.EmpID = Emp.EmpID;
                        objHELP.Query = txtQuery.Text;
                        ctx.HELPs.Add(objHELP);

                        var objOEML = new OEML();
                        objOEML = ctx.OEMLs.FirstOrDefault(x => x.ParentID == Cust.CustomerID);

                        msg.Subject = "Query By Dealer Code :" + txtDealerCode.Text;
                        msg.Body = "This Query :" + txtQuery.Text + ": Send By UserName :" + txtUsername.Text;
                        msg.From = new MailAddress("" + objOEML.Email);
                        msg.To.Add("hdoshi@vc-erp.com");
                        msg.IsBodyHtml = true;
                        client.Host = "" + objOEML.Domain;

                        System.Net.NetworkCredential basicauthenticationinfo = new System.Net.NetworkCredential("" + objOEML.UserName, "" + objOEML.Password);
                        client.Port = int.Parse("" + objOEML.Port);
                        client.EnableSsl = false;
                        client.UseDefaultCredentials = false;
                        client.Credentials = basicauthenticationinfo;
                        client.DeliveryMethod = SmtpDeliveryMethod.Network;
                        client.Send(msg);
                        ClearAllInputs();
                        ctx.SaveChanges();
                        this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('Query sent successfully!',1);", true);
                    }
                    else
                    {
                        this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('Invalid UserName and Dealer Code!',3);", true);
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Page is invalid!',3);", true);
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Error : " + Common.GetString(ex) + "',2);", true);
            }
        }

    }
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Login.aspx");
    }
    #endregion
}