using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Transactions;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_NotificationMessage : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    int PinCodeNo;
    DDMSEntities ctx;

    #endregion

    #region Helper Method

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
                        var unit = xml.Descendants("bill_of_material");
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
        txtSubject.Text = txtDesc.Text = "";
        txtCouponCode.Style.Add("background-color", "rgb(250, 255, 189);");

        edsddlGroup.Where = "it.Active==true";
        ddlGroup.DataBind();
        ddlGroup.Items.Insert(0, new ListItem("---Select---", "0"));
        ddlGroup.SelectedValue = "0";
        PinCodeNo = 0;

        ddlCity.SelectedValue = "0";
        acePinCode.Enabled = true;
        txtPinCode.Text = "";
        txtPinCode.Style.Add("background-color", "rgb(250, 255, 189);");

    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)

            ClearAllInputs();
    }

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            string pinNo = "";
            if (Page.IsValid)
            {
                if (!String.IsNullOrEmpty(txtPinCode.Text))
                {
                    int code = 0;
                    var pin = txtPinCode.Text.Split("-".ToArray());
                    if (pin.Length == 2)
                    {
                        code = Convert.ToInt32(pin.First().Trim());
                    }
                    OPIN objOPIN = ctx.OPINs.FirstOrDefault(x => x.PinCodeID == code);
                    if (objOPIN != null)
                    {
                        PinCodeNo = objOPIN.PinCodeID;
                        pinNo = txtPinCode.Text;
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper pincode!',3);", true);
                        return;
                    }
                }

                ONTF objONTF = new ONTF();
                objONTF.Subject = txtSubject.Text;
                objONTF.Message = txtDesc.Text;
                objONTF.CreatedDate = DateTime.Now;

                if (ddlGroup.SelectedValue != "0")
                    objONTF.CustGroupID = Convert.ToInt32(ddlGroup.SelectedValue);
                if (ddlCity.SelectedValue != "0")
                    objONTF.CityID = Convert.ToInt32(ddlCity.SelectedValue);
                if (PinCodeNo != 0)
                    objONTF.PinCodeID = PinCodeNo;

                ctx.ONTFs.Add(objONTF);
                ctx.SaveChanges();

                //WebService wbService = new WebService();
                //string message = objONTF.Subject + " - " + objONTF.Message;
                //wbService.PushNotificationByCriteria(message, Convert.ToInt32(ddlGroup.SelectedValue), Convert.ToInt32(ddlCity.SelectedValue), pinNo);

                ClearAllInputs();

                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Message sent successfully: " + "',1);", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter proper data!',3);", true);
            }

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + ex.Message.Replace("'", "") + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Master.aspx");
    }

    protected void txtCouponCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!String.IsNullOrEmpty(txtCouponCode.Text))
            {
                var word = txtCouponCode.Text.Split("-".ToArray());
                if (word.Length == 2)
                {
                    string code = Convert.ToString(word.First().Trim());
                    var objOCPN = ctx.OCPNs.FirstOrDefault(x => x.CouponCode == code);
                    if (objOCPN != null)
                    {
                        txtSubject.Text = objOCPN.CouponCode;
                        txtDesc.Text = objOCPN.Description;
                        txtCouponCode.Visible = true;
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "DisplayCoupon();", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper coupon!',3);", true);
                        ClearAllInputs();
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper coupon!',3);", true);
                    ClearAllInputs();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + ex.Message.Replace("'", "") + "',2);", true);
        }
    }
    #endregion

}