using AjaxControlToolkit;
using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Marketing_ClientFeedBack : System.Web.UI.Page
{

    #region Declration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;
    int CustType;

    #endregion

    #region Helper Mrthod

    private void ClearAllInputs()
    {
        ddlFeedBackType.SelectedValue = "0";
        txtName.Text = txtContactName.Text = txtWebsite.Text = txtEmail.Text = txtPhoneNumber.Text = txtNotes.Text = "";

        gvFeedBackQue.DataSource = null;
        gvFeedBackQue.DataBind();

        ddlSR.DataSource = ctx.OEMPs.Where(x => x.ParentID == ParentID && x.Active).ToList();
        ddlSR.DataBind();
        ddlSR.Items.Insert(0, new ListItem("---Select---", "0"));
        ddlSR.SelectedValue = "0";
        ddlFeedBackFrom_SelectedIndexChanged(ddlFeedBackType, EventArgs.Empty);
    }

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            ctx = new DDMSEntities();
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
                        var unit = xml.Descendants("client_feedback");
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
        acettxtCustomerName.ContextKey = (CustType + 1).ToString();
        if (!IsPostBack)
            ClearAllInputs();
    }

    #endregion

    #region Drop-Down List Select change

    protected void ddlFeedBackFrom_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlFeedBackFrom.SelectedValue == "D")
        {
            acettxtCustomerName.Enabled = false;
            var Customer = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == ParentID);
            txtName.Text = Customer.CustomerName;
            txtContactName.Text = Customer.CRD1.FirstOrDefault().ContactPerson;
            txtEmail.Text = Customer.EMail1;
            txtPhoneNumber.Text = Customer.Phone;
            txtWebsite.Text = Customer.Website;

            txtName.Enabled = false;
            txtName.Style.Remove("background-color");
        }
        else
        {
            acettxtCustomerName.ContextKey = (CustType + 1).ToString();
            txtName.Enabled = true;
            txtName.Text = "";
            acettxtCustomerName.Enabled = true;
            txtName.Style.Add("background-color", "rgb(250, 255, 189);");
        }
        ddlFeedBackFrom.Focus();
    }

    protected void ddlFeedBackType_SelectedIndexChanged(object sender, System.EventArgs e)
    {
        gvFeedBackQue.DataSource = ctx.OQUS.Where(x => x.ParentID == ParentID && x.Type == ddlFeedBackType.SelectedValue && x.Active && x.DocType == "F").OrderBy(c => Guid.NewGuid()).Take(5).ToList();
        gvFeedBackQue.DataBind();
        ddlFeedBackType.Focus();
    }

    #endregion

    #region Change Event

    protected void txtName_TextChanged(object sender, System.EventArgs e)
    {
        if (txtName != null && !String.IsNullOrEmpty(txtName.Text))
        {
            var word = txtName.Text.Split("-".ToArray());
            if (word.Length > 1)
            {
                var code = word.First().Trim();
                var objCustomer = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == code);
                if (objCustomer != null)
                {
                    txtName.Text = objCustomer.CustomerCode + " - " + objCustomer.CustomerName;
                    txtContactName.Text = objCustomer.CRD1.FirstOrDefault().ContactPerson;
                    txtEmail.Text = objCustomer.EMail1;
                    txtPhoneNumber.Text = objCustomer.Phone;
                    txtWebsite.Text = objCustomer.Website;
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please search proper customer!',3);", true);

                }
            }

        }
        txtName.Focus();
    }

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, System.EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                var objOCFB = new OCFB();

                objOCFB.FeedbackID = ctx.GetKey("OCFB", "FeedbackID", "", ParentID, 0).FirstOrDefault().Value;
                objOCFB.ParentID = ParentID;
                objOCFB.FeedbackFrom = ddlFeedBackFrom.SelectedValue;
                objOCFB.CompanyName = txtName.Text;
                objOCFB.ContactName = txtContactName.Text;
                objOCFB.Website = txtWebsite.Text;
                objOCFB.Email = txtEmail.Text;
                objOCFB.FeedbackType = ddlFeedBackType.SelectedValue;
                objOCFB.Phone = txtPhoneNumber.Text;
                objOCFB.Notes = txtNotes.Text;
                objOCFB.Date = DateTime.Now;
                objOCFB.SalesRepresentativeID = Convert.ToInt32(ddlSR.SelectedValue);
                objOCFB.Active = true;
                objOCFB.CreatedDate = DateTime.Now;
                objOCFB.CreatedBy = UserID;
                objOCFB.UpdatedBy = UserID;
                objOCFB.UpdatedDate = DateTime.Now;

                ctx.OCFBs.Add(objOCFB);

                Decimal Avg = 0;
                int Count = ctx.GetKey("CFB1", "CFB1ID", "FeedbackID", 0, objOCFB.FeedbackID).FirstOrDefault().Value;

                foreach (GridViewRow item in gvFeedBackQue.Rows)
                {
                    var objCFB1 = new CFB1();

                    Rating rating = item.FindControl("ratgvFeedbackQue") as Rating;
                    Label lblQuesID = (Label)item.FindControl("lblQuesID");
                    TextBox txtNotes1 = (TextBox)item.FindControl("txtNotes");

                    objCFB1.CFB1ID = Count++;
                    objCFB1.FeedbackID = objOCFB.FeedbackID;
                    objCFB1.QuesID = Convert.ToInt32(lblQuesID.Text);
                    objCFB1.FeedbackType = ddlFeedBackType.SelectedValue;
                    objCFB1.Active = true;
                    objCFB1.Notes = txtNotes1.Text;
                    objCFB1.Rating = Convert.ToDecimal(rating.CurrentRating);
                    Avg += Convert.ToDecimal(rating.CurrentRating);
                    objCFB1.CreatedDate = DateTime.Now;
                    objCFB1.CreatedBy = UserID;
                    objCFB1.UpdatedBy = UserID;
                    objCFB1.UpdatedDate = DateTime.Now;
                    objCFB1.ParentID = ParentID;

                    objOCFB.CFB1.Add(objCFB1);
                }

                objOCFB.Rating = Avg / 5;

                ctx.SaveChanges();
                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record Submitted Sucessfully!',1);", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Page is invalid!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + ex.Message.Replace("'", "") + "',2);", true);
        }

    }

    protected void btnCancel_Click(object sender, System.EventArgs e)
    {
        Response.Redirect("Marketing.aspx");
    }

    #endregion

}