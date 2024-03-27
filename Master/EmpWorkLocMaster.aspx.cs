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
using System.Web.UI.HtmlControls;
using System.Text;

public partial class Master_EmpWorkLocMaster : System.Web.UI.Page
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
        txtCode.Text = txtDevice.Text= txtDesign.Text = txtHomeLat.Text = txtHomeLong.Text = txtReportTo.Text = txtWorkLat.Text = txtWorkLong.Text = "";
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    #region Change Event

    protected void txtCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var empCode = txtCode.Text.Split("-".ToArray()).First().Trim();
                OEMP objOEMP = ctx.OEMPs.FirstOrDefault(x => x.EmpCode == empCode);
                if (objOEMP != null)
                {
                    txtDesign.Text = ctx.OGRPs.Where(x => x.EmpGroupID == objOEMP.EmpGroupID).Select(x => x.EmpGroupName + " - " + x.EmpGroupDesc).DefaultIfEmpty("").FirstOrDefault();

                    OEMP objManager = ctx.OEMPs.FirstOrDefault(x => x.EmpID == objOEMP.ManagerID);
                    if (objManager != null)
                    {
                        string reportToName = objManager.EmpCode + " - " + objManager.Name;
                        string reportToGroup = ctx.OGRPs.Where(x => x.EmpGroupID == objManager.EmpGroupID).Select(x => x.EmpGroupName + " / " + x.EmpGroupDesc).DefaultIfEmpty("").FirstOrDefault();

                        txtReportTo.Text = reportToName + "   " + reportToGroup;
                    }
                    txtDevice.Text = objOEMP.MobileName;
                    txtHomeLat.Text = !string.IsNullOrEmpty(objOEMP.GCMID) ? objOEMP.GCMID.Split("#".ToArray()).First().Trim() : "";
                    txtHomeLong.Text = !string.IsNullOrEmpty(objOEMP.GCMID) ? objOEMP.GCMID.Split("#".ToArray()).Last().Trim() : "";
                    txtWorkLat.Text = !string.IsNullOrEmpty(objOEMP.GCM2ID) ? objOEMP.GCM2ID.Split("#".ToArray()).First().Trim() : "";
                    txtWorkLong.Text = !string.IsNullOrEmpty(objOEMP.GCM2ID) ? objOEMP.GCM2ID.Split("#".ToArray()).Last().Trim() : "";
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper employee!',3);", true);
                    ClearAllInputs();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtCode.Focus();
    }

    #endregion

    #region Button Events

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                if (string.IsNullOrEmpty(txtDevice.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select device name of employee.!',3);", true);
                    return;
                }
                if (string.IsNullOrEmpty(txtHomeLat.Text) || string.IsNullOrEmpty(txtHomeLong.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select home lattitude and longitude of employee.!',3);", true);
                    return;
                }
                if (string.IsNullOrEmpty(txtWorkLat.Text) || string.IsNullOrEmpty(txtWorkLong.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select work lattitude and longitude of employee.!',3);", true);
                    return;
                }
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int EmpID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : 0;

                    if (EmpID > 0)
                    {
                        OEMP objOEMP = ctx.OEMPs.FirstOrDefault(x => x.EmpID == EmpID);
                        if (objOEMP != null)
                        {
                            objOEMP.GCMID = txtHomeLat.Text + "#" + txtHomeLong.Text;
                            objOEMP.GCM2ID = txtWorkLat.Text + "#" + txtWorkLong.Text;
                            objOEMP.MobileName = txtDevice.Text;
                            objOEMP.UpdatedBy = UserID;
                            objOEMP.UpdatedDate = DateTime.Now;
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select proper employee!',3);", true);
                            return;
                        }
                        ctx.SaveChanges();
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully of " + txtCode.Text + "',1);", true);
                        ClearAllInputs();
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select proper employee!',3);", true);
                        return;
                    }
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Page is invalid!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    #endregion
}