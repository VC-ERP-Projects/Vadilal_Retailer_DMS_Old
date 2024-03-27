using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Transactions;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;


public partial class Master_CouponMaster : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

    private List<CPN1> CityList
    {
        get { return this.ViewState["CPN1"] as List<CPN1>; }
        set { this.ViewState["CPN1"] = value; }
    }
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

        if (chkMode.Checked)
        {
            btnSubmit.Text = "Submit";
            txtCouponCode.Focus();
            txtCouponCode.Style.Remove("background-color");
            txtCouponCode.AutoPostBack = false;
            acettxtCouponCode.Enabled = false;
            chkApplyToAll.Checked = true;
            //  DivCoupen.Visible = false;
        }
        else
        {
            txtCouponCode.Text = "";
            txtCouponCode.Focus();
            acettxtCouponCode.Enabled = true;
            btnSubmit.Text = "Submit";
            txtCouponCode.Style.Add("background-color", "rgb(250, 255, 189);");
            txtCouponCode.AutoPostBack = true;
            acettxtCouponCode.Enabled = true;
            chkApplyToAll.Checked = true;
        }

        acettxtState.Enabled = true;
        txtState.Style.Add("background-color", "rgb(250, 255, 189);");
        txtCity.Style.Add("background-color", "rgb(250, 255, 189);");
        txtPinCode.Style.Add("background-color", "rgb(250, 255, 189);");
        txtCouponCode.Text = txtDiscount.Text = txtDesc.Text = txtCouponName.Text = txtMinBillValue.Text = txtMaxBillValue.Text = "";
        txtStartDate.Text = txtStartTime.Text = txtExpireDate.Text = txtExpireTime.Text = "";
        txtMaxNoUseable.Text = txtTotalNoUseable.Text = "";
        chkNewUser.Checked = chkMultipleUse.Checked = false;
        ddlDiscount.SelectedValue = "A";
        chkActive.Checked = true;
        chkNotify.Checked = false;

        CityList = null;
        gvCoupen.DataSource = null;
        gvCoupen.DataBind();
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
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
            bool newCpn = false;
            if (Page.IsValid)
            {
                int CouponID = 0;
                decimal Deci;
                OCPN objOCPN;

                if (ViewState["CouponID"] != null && Int32.TryParse(ViewState["CouponID"].ToString(), out CouponID))
                {
                    objOCPN = ctx.OCPNs.FirstOrDefault(x => x.CouponID == CouponID);
                }
                else
                {
                    if (ctx.OCPNs.Any(x => x.CouponCode == txtCouponCode.Text))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Coupon Code already exist!',3);", true);
                        return;
                    }
                    objOCPN = new OCPN();
                    objOCPN.CouponID = ctx.GetKey("OCPN", "CouponID", "", 0, 0).FirstOrDefault().Value;
                    objOCPN.CouponCode = txtCouponCode.Text;
                    objOCPN.CreatedDate = DateTime.Now;
                    objOCPN.CreatedBy = UserID;
                    ctx.OCPNs.Add(objOCPN);
                    newCpn = true;
                }

                objOCPN.CouponCode = txtCouponCode.Text;
                objOCPN.CouponName = txtCouponName.Text;
                objOCPN.Description = txtDesc.Text;
                objOCPN.DiscountType = ddlDiscount.SelectedValue;
                objOCPN.DiscountValue = Decimal.TryParse(txtDiscount.Text, out Deci) ? Deci : 0;
                objOCPN.MinBillValue = Decimal.TryParse(txtMinBillValue.Text, out Deci) ? Deci : 0;
                objOCPN.MaxBillValue = Decimal.TryParse(txtMaxBillValue.Text, out Deci) ? Deci : 0;

                if (!string.IsNullOrEmpty(txtStartDate.Text))
                {
                    objOCPN.StartDate = Convert.ToDateTime(txtStartDate.Text);
                }
                if (!string.IsNullOrEmpty(txtExpireDate.Text))
                {
                    objOCPN.ExpireDate = Convert.ToDateTime(txtExpireDate.Text);
                }
                if (!string.IsNullOrEmpty(txtStartTime.Text))
                {
                    objOCPN.StartTime = TimeSpan.Parse(txtStartTime.Text);
                }
                if (!string.IsNullOrEmpty(txtExpireTime.Text))
                {
                    objOCPN.ExpireTime = TimeSpan.Parse(txtExpireTime.Text);
                }

                objOCPN.TotalNoUsuable = string.IsNullOrEmpty(txtTotalNoUseable.Text) ? 0 : Convert.ToInt32(txtTotalNoUseable.Text);
                objOCPN.MaxNoUsuable = string.IsNullOrEmpty(txtMaxNoUseable.Text) ? 0 : Convert.ToInt32(txtMaxNoUseable.Text);

                objOCPN.IsMultipleUse = chkMultipleUse.Checked;
                objOCPN.IsApplyToAll = chkApplyToAll.Checked;
                objOCPN.IsNewUser = chkNewUser.Checked;
                objOCPN.Active = chkActive.Checked;
                objOCPN.UpdatedDate = DateTime.Now;
                objOCPN.UpdatedBy = UserID;

                CPN1 objCPN1 = null;
                int CPN1ID = ctx.GetKey("CPN1", "CPN1ID", "", 0, 0).FirstOrDefault().Value;
                objOCPN.CPN1.ToList().ForEach(x => ctx.CPN1.Remove(x));

                if (chkApplyToAll.Checked == false)
                {
                    if (CityList != null)
                    {
                        foreach (CPN1 tmpObj in CityList)
                        {
                            objCPN1 = new CPN1();
                            objCPN1.CPN1ID = CPN1ID++;
                            objCPN1.CouponID = objOCPN.CouponID;

                            if (tmpObj.StateID.HasValue)
                            {
                                objCPN1.StateID = tmpObj.StateID.Value;
                            }
                            else
                            {
                                objCPN1.StateID = null;
                            }

                            if (tmpObj.CityID.HasValue)
                            {
                                objCPN1.CityID = tmpObj.CityID.Value;
                                OCTY OCTY = ctx.OCTies.FirstOrDefault(x => x.CityID == tmpObj.CityID.Value);
                                if (OCTY != null)
                                    objCPN1.StateID = OCTY.StateID;
                            }
                            else
                            {
                                objCPN1.CityID = null;
                            }

                            if (tmpObj.PinCodeID.HasValue)
                            {
                                objCPN1.PinCodeID = tmpObj.PinCodeID.Value;
                                OPIN OPIN = ctx.OPINs.FirstOrDefault(x => x.PinCodeID == tmpObj.PinCodeID);
                                if (OPIN != null)
                                {
                                    objCPN1.CityID = OPIN.CityID;
                                    objCPN1.StateID = OPIN.StateID;
                                }
                            }
                            else
                            {
                                objCPN1.PinCodeID = null;
                            }

                            ctx.CPN1.Add(objCPN1);
                        }
                    }
                }
                ctx.SaveChanges();
                ClearAllInputs();

                //// If New Coupon, then PUSH Notification
                //if (newCpn == true && chkNotify.Checked)
                //{
                //    WebService wbService = new WebService();
                //    string message = objOCPN.CouponCode + " - " + objOCPN.Description;
                //    wbService.PushNotification(message);
                //}
                ViewState["CouponID"] = null;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully: " + objOCPN.CouponCode + "',1);", true);
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

    #endregion

    #region Change Event

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    protected void txtCouponCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && !String.IsNullOrEmpty(txtCouponCode.Text))
            {
                var word = txtCouponCode.Text.Split("-".ToArray());
                if (word.Length == 2)
                {
                    string code = Convert.ToString(word.First().Trim());
                    var objOCPN = ctx.OCPNs.FirstOrDefault(x => x.CouponCode == code);
                    if (objOCPN != null)
                    {
                        txtCouponCode.Text = objOCPN.CouponCode;
                        txtCouponName.Text = objOCPN.CouponName;
                        txtDesc.Text = objOCPN.Description;
                        chkActive.Checked = objOCPN.Active;
                        chkMultipleUse.Checked = objOCPN.IsMultipleUse.Value;
                        chkNewUser.Checked = objOCPN.IsNewUser.Value;

                        txtStartDate.Text = objOCPN.StartDate == null ? "" : objOCPN.StartDate.Value.ToString("dd/MM/yyyy");
                        txtExpireDate.Text = objOCPN.ExpireDate == null ? "" : objOCPN.ExpireDate.Value.ToString("dd/MM/yyyy");
                        txtStartTime.Text = objOCPN.StartTime == null ? "" : objOCPN.StartTime.Value.ToString();
                        txtExpireTime.Text = objOCPN.ExpireTime == null ? "" : objOCPN.ExpireTime.Value.ToString();

                        ddlDiscount.SelectedValue = objOCPN.DiscountType;
                        txtDiscount.Text = objOCPN.DiscountValue.Value.ToString("0.00");
                        txtMaxNoUseable.Text = objOCPN.MaxNoUsuable.Value.ToString();
                        txtTotalNoUseable.Text = objOCPN.TotalNoUsuable.Value.ToString();
                        txtMinBillValue.Text = objOCPN.MinBillValue.Value.ToString("0.00");
                        txtMaxBillValue.Text = objOCPN.MaxBillValue.Value.ToString("0.00");
                        chkApplyToAll.Checked = objOCPN.IsApplyToAll;

                        if (objOCPN.IsApplyToAll == false)
                        {
                            CityList = objOCPN.CPN1.ToList();
                            gvCoupen.DataSource = CityList;
                            gvCoupen.DataBind();
                        }

                        ViewState["CouponID"] = objOCPN.CouponID;
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper coupon!',3);", true);
                        ClearAllInputs();
                    }
                }
                //else
                //{
                //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper coupon!',3);", true);
                //    ClearAllInputs();
                //}
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + ex.Message.Replace("'", "") + "',2);", true);
        }
    }


    #endregion

    //protected void txtState_TextChanged(object sender, EventArgs e)
    //{
    //    acettxtCity.ContextKey = txtState.Text.Split('-').ToArray().First().Trim();

    //}

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        try
        {
            int Rowindex;
            CPN1 objCPN1;
            if (ViewState["Rowindex"] != null && Int32.TryParse(ViewState["Rowindex"].ToString(), out Rowindex))
            {
                objCPN1 = CityList[Rowindex];
                btnAdd.Text = "Add";
            }
            else
            {
                objCPN1 = new CPN1();
                if (CityList == null)
                    CityList = new List<CPN1>();
                CityList.Add(objCPN1);
            }

            if (txtState.Text != "")
            {
                int StateID;
                var State = txtState.Text.Split("-".ToArray()).First().Trim();
                objCPN1.StateID = Int32.TryParse(State, out StateID) ? StateID : 0;
                if (StateID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('State does not Exist! Please enter proper State.',3);", true);
                    return;
                }
                objCPN1.OCST = ctx.OCSTs.FirstOrDefault(x => x.StateID == StateID);
            }

            if (txtCity.Text != "")
            {
                int CityID;
                var City = txtCity.Text.Split("-".ToArray()).First().Trim();
                objCPN1.CityID = Int32.TryParse(City, out CityID) ? CityID : 0;
                if (CityID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('City does not Exist! Please enter proper City.',3);", true);
                    return;
                }
                objCPN1.OCTY = ctx.OCTies.FirstOrDefault(x => x.CityID == CityID);
                objCPN1.StateID = objCPN1.OCTY.StateID;
                objCPN1.OCST = ctx.OCSTs.FirstOrDefault(x => x.StateID == objCPN1.OCTY.StateID);
            }

            if (txtPinCode.Text != "")
            {
                int PincodeID;
                var PinCode = txtPinCode.Text.Split("-".ToArray()).First().Trim();
                objCPN1.PinCodeID = Int32.TryParse(PinCode, out PincodeID) ? PincodeID : 0;
                if (PincodeID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('PinCode does not Exist! Please enter proper PinCode.',3);", true);
                    return;
                }
                objCPN1.OPIN = ctx.OPINs.FirstOrDefault(x => x.PinCodeID == PincodeID);
                objCPN1.CityID = objCPN1.OPIN.CityID;
                objCPN1.StateID = objCPN1.OPIN.StateID;
                objCPN1.OCST = ctx.OCSTs.FirstOrDefault(x => x.StateID == objCPN1.OPIN.StateID);
                objCPN1.OCTY = ctx.OCTies.FirstOrDefault(x => x.CityID == objCPN1.OPIN.CityID);
            }

            gvCoupen.DataSource = CityList;
            gvCoupen.DataBind();
            txtState.Text = txtCity.Text = txtPinCode.Text = "";
            ViewState["Rowindex"] = null;
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void gvCoupen_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int Rowindex = Convert.ToInt32(e.CommandArgument);
        var obj = CityList[Rowindex];
        if (e.CommandName == "DeleteMode")
        {
            CityList.Remove(obj);
            gvCoupen.DataSource = CityList;
            gvCoupen.DataBind();
            txtState.Text = txtCity.Text = txtPinCode.Text = "";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Record deleted successfully!',1);", true);
        }
        else if (e.CommandName == "EditMode")
        {
            ViewState["Rowindex"] = Rowindex;
            txtState.Text = txtCity.Text = txtPinCode.Text = "";

            if (obj.OCST != null)
                txtState.Text = Convert.ToString(obj.StateID + " - " + obj.OCST.StateName);
            if (obj.OCTY != null)
                txtCity.Text = Convert.ToString(obj.CityID + " - " + obj.OCTY.CityName);
            if (obj.OPIN != null)
                txtPinCode.Text = Convert.ToString(obj.PinCodeID + " - " + obj.OPIN.Area);

            btnAdd.Text = "Update";
        }
    }

    //protected void chkApplyToAll_CheckedChanged(object sender, EventArgs e)
    //{
    //    if (!chkApplyToAll.Checked)
    //    {
    //        DivCoupen.Visible = true;
    //    }
    //}
}