using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Objects;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;


public partial class Master_CompanyDayClose : System.Web.UI.Page
{
    #region Property

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region Page Load

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

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        btnSubmit.Visible = false;
        btnDayEndSubmit.Visible = false;
    }

    #endregion

    #region Button

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            Decimal DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            if (DistributorID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                return;
            }
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "CompanyDayClose";
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            if (ds.Tables[0].Rows.Count > 0)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if (Convert.ToString(ds.Tables[0].Rows[0][0]).Length > 0)
                    {
                        lblMsg.Text = Convert.ToString(ds.Tables[0].Rows[0][0]);
                    }
                    else
                    {
                        OEOD objOEOD = ctx.OEODs.Where(x => x.ParentID == DistributorID).OrderByDescending(x => x.Date).FirstOrDefault();
                        if (objOEOD != null)
                        {
                            btnSubmit.Visible = objOEOD.IsConfirm;
                            chkIsConfirm.Checked = objOEOD.IsConfirm;
                            lblMsg.Text = "Last Day Close Date # " + Common.DateTimeConvert(objOEOD.Date);
                        }
                        else
                            lblMsg.Text = "No Day Close Entry was found.";
                    }

                }

            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            Decimal DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            if (DistributorID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                return;
            }
            using (DDMSEntities ctx = new DDMSEntities())
            {
                OEOD objOEOD = ctx.OEODs.Where(x => x.ParentID == DistributorID).OrderByDescending(x => x.Date).FirstOrDefault();

                objOEOD.IsConfirm = chkIsConfirm.Checked;
                if (!objOEOD.IsConfirm && objOEOD.EOD4.Count > 0)
                {
                    objOEOD.EOD4.ToList().ForEach(x => ctx.EOD4.Remove(x));
                }
                ctx.SaveChanges();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Submitted Successfully',1);", true);

                txtCustCode.Text = "";
                lblMsg.Text = "";
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }


    protected void btnDayEndGo_Click(object sender, EventArgs e)
    {
        try
        {
            int EmpID = Int32.TryParse(txtEmp.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : 0;
            if (EmpID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Proper Employee.',3);", true);
                return;
            }
            using (DDMSEntities ctx = new DDMSEntities())
            {
                btnDayEndSubmit.Visible = false;
                var objLastOENT = ctx.OENTs.Where(x => x.ParentID == ParentID && x.EmpID == EmpID).OrderByDescending(x => x.InDate).FirstOrDefault();
                if (objLastOENT == null)
                {
                    lblDayEnd.Text = "No Activity Found";
                }
                else if (!objLastOENT.OutDate.HasValue)
                {
                    lblDayEnd.Text = "Your last Activity is already open";
                }
                else
                {
                    btnDayEndSubmit.Visible = true;
                    lblDayEnd.Text = "Last Day End Date # " + objLastOENT.OutDate.Value.ToString("dd/MM/yyyy hh:mm:ss tt");
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }
    protected void btnDayEndSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            int EmpID = Int32.TryParse(txtEmp.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : 0;
            if (EmpID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Proper Employee.',3);", true);
                return;
            }
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var objLastOENT = ctx.OENTs.Where(x => x.ParentID == ParentID && x.EmpID == EmpID).OrderByDescending(x => x.InDate).FirstOrDefault();
                if (objLastOENT == null)
                {
                    lblDayEnd.Text = "No Activity Found";
                }
                else if (!objLastOENT.OutDate.HasValue)
                {
                    lblDayEnd.Text = "Your last Activity is already open";
                }
                else
                {
                    objLastOENT.OutDate = null;
                    objLastOENT.OutLat = null;
                    objLastOENT.OutLong = null;
                    objLastOENT.OutCity = null;
                    objLastOENT.OutCItyName = null;
                    objLastOENT.UpdatedDate = DateTime.Now;
                    ctx.SaveChanges();
                }

                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Submitted Successfully',1);", true);

                txtEmp.Text = lblDayEnd.Text = "";
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }
    #endregion
}