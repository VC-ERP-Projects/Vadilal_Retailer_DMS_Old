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
using System.Data.Objects.SqlClient;

public partial class Master_PriceGroupUpdate : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
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
                            var unit = xml.Descendants("reports");
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
                        {

                        }
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
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            ddlDivision.DataSource = Division;
            ddlDivision.DataBind();
            ddlDivision.ClearSelection();
        }
        txtStatus.Enabled = txtParentCode.Enabled = txtUpdateDate.Enabled = txtUpdatedBy.Enabled = false;
        ddlCustType.SelectedValue = "3";
        txtDealerCode.Text = txtDistCode.Text = txtSSCode.Text = txtPriceGroup.Text = txtStatus.Text = txtParentCode.Text = txtUpdateDate.Text = txtUpdatedBy.Text = "";
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

    protected void txtDlrCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (txtDealerCode.Text.Split("-".ToArray()).Length != 3)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Dealer',3);", true);
                    ClearAllInputs();
                    return;
                }
                var DealerCode = txtDealerCode.Text.Split("-".ToArray()).First().Trim();
                if (string.IsNullOrEmpty(DealerCode))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Dealer',3);", true);
                    ClearAllInputs();
                    return;
                }
                else
                {
                    var objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DealerCode);
                    if (objOCRD == null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Dealer',3);", true);
                        ClearAllInputs();
                        return;
                    }
                    else if (objOCRD.Active)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('SAP Status is Active so You can not Update Pricing Group',3);", true);
                        return;
                    }
                    else
                    {
                        var objAOCRD = ctx.AOCRDs.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID);
                        Int32 DivisionID = Int32.TryParse(ddlDivision.SelectedValue, out DivisionID) ? DivisionID : 0;

                        OGCRD objOGCRD = ctx.OGCRDs.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID && x.DivisionlID == DivisionID);
                        if (objOGCRD != null)
                        {
                            if (objOCRD.ParentID == 1000010000000000)
                            {
                                if (objOGCRD.PlantID.HasValue)
                                {
                                    txtParentCode.Text = ctx.OPLTs.Where(x => x.PlantID == objOGCRD.PlantID.Value).Select(x => x.PlantCode + " - " + x.PlantName).FirstOrDefault();
                                }
                                else
                                {
                                    txtParentCode.Text = "";
                                }
                            }
                            else
                            {
                                txtParentCode.Text = ctx.OCRDs.Where(x => x.CustomerID == objOCRD.ParentID).Select(x => x.CustomerCode + " - " + x.CustomerName).DefaultIfEmpty().FirstOrDefault();
                            }

                            txtPriceGroup.Text = ctx.OIPLs.Where(x => x.PriceListID == objOGCRD.PriceListID).Select(x => x.Name + " - " + SqlFunctions.StringConvert((double)x.PriceListID).Trim()).FirstOrDefault();

                            List<RUT1> objRUT1 = ctx.RUT1.Where(x => x.CustomerID == objOCRD.CustomerID).ToList();

                            txtStatus.Text = (objOCRD.Active ? "SAP : Y" : "SAP : N") + "     " + (objAOCRD == null || objAOCRD.Active ? "DMS : Y" : "DMS : N") + "     " + (objRUT1 != null && objRUT1.Count > 0 && objRUT1.FirstOrDefault(x => x.Active) != null ? "Beat : Y" : objRUT1 != null && objRUT1.Count > 0 && objRUT1.FirstOrDefault(x => !x.Active) != null ? "Beat : N" : "Beat : ");
                            txtUpdateDate.Text = objOCRD.UpdatedDate.ToString("dd-MMM-yy HH:mm");
                            txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOCRD.UpdatedBy).Select(x => x.EmpCode + " - " + x.Name).DefaultIfEmpty().FirstOrDefault();
                            txtDealerCode.Text = txtDealerCode.Text + " ";
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Plant Entry found',3);", true);
                            return;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtDealerCode.Focus();
    }

    protected void txtDistCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (txtDistCode.Text.Split("-".ToArray()).Length != 3)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor',3);", true);
                    ClearAllInputs();
                    return;
                }
                var DistCode = txtDistCode.Text.Split("-".ToArray()).First().Trim();
                if (string.IsNullOrEmpty(DistCode))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor',3);", true);
                    ClearAllInputs();
                    return;
                }
                else
                {
                    var objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DistCode);
                    if (objOCRD == null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor',3);", true);
                        ClearAllInputs();
                        return;
                    }
                    else if (objOCRD.Active)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('SAP Status is Active so You can not Update Pricing Group',3);", true);
                        return;
                    }
                    else
                    {
                        var objAOCRD = ctx.AOCRDs.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID);
                        Int32 DivisionID = Int32.TryParse(ddlDivision.SelectedValue, out DivisionID) ? DivisionID : 0;
                        OGCRD objOGCRD = ctx.OGCRDs.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID && x.DivisionlID == DivisionID);
                        if (objOGCRD != null)
                        {
                            if (objOCRD.ParentID == 1000010000000000)
                            {
                                if (objOGCRD.PlantID.HasValue)
                                {
                                    txtParentCode.Text = ctx.OPLTs.Where(x => x.PlantID == objOGCRD.PlantID.Value).Select(x => x.PlantCode + " - " + x.PlantName).FirstOrDefault();
                                }
                                else
                                {
                                    txtParentCode.Text = "";
                                }
                            }
                            else
                            {
                                txtParentCode.Text = ctx.OCRDs.Where(x => x.CustomerID == objOCRD.ParentID).Select(x => x.CustomerCode + " - " + x.CustomerName).DefaultIfEmpty().FirstOrDefault();
                            }

                            txtPriceGroup.Text = ctx.OIPLs.Where(x => x.PriceListID == objOGCRD.PriceListID).Select(x => x.Name + " - " + SqlFunctions.StringConvert((double)x.PriceListID).Trim()).FirstOrDefault();

                            List<RUT1> objRUT1 = ctx.RUT1.Where(x => x.CustomerID == objOCRD.CustomerID).ToList();

                            txtStatus.Text = (objOCRD.Active ? "SAP : Y" : "SAP : N") + "     " + (objAOCRD == null || objAOCRD.Active ? "DMS : Y" : "DMS : N") + "     " + (objRUT1 != null && objRUT1.Count > 0 && objRUT1.FirstOrDefault(x => x.Active) != null ? "Beat : Y" : objRUT1 != null && objRUT1.Count > 0 && objRUT1.FirstOrDefault(x => !x.Active) != null ? "Beat : N" : "Beat : ");
                            txtUpdateDate.Text = objOCRD.UpdatedDate.ToString("dd-MMM-yy HH:mm");
                            txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOCRD.UpdatedBy).Select(x => x.EmpCode + " - " + x.Name).DefaultIfEmpty().FirstOrDefault();
                            txtDistCode.Text = txtDistCode.Text + " ";
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Plant Entry found',3);", true);
                            return;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtDistCode.Focus();
    }

    protected void txtSSCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (txtSSCode.Text.Split("-".ToArray()).Length != 3)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper SS',3);", true);
                    ClearAllInputs();
                    return;
                }
                var SSCode = txtSSCode.Text.Split("-".ToArray()).First().Trim();
                if (string.IsNullOrEmpty(SSCode))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper SS',3);", true);
                    ClearAllInputs();
                    return;
                }
                else
                {
                    var objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == SSCode);
                    if (objOCRD == null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper SS',3);", true);
                        ClearAllInputs();
                        return;
                    }
                    else if (objOCRD.Active)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('SAP Status is Active so You can not Update Pricing Group',3);", true);
                        return;
                    }
                    else
                    {
                        var objAOCRD = ctx.AOCRDs.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID);
                        Int32 DivisionID = Int32.TryParse(ddlDivision.SelectedValue, out DivisionID) ? DivisionID : 0;
                        OGCRD objOGCRD = ctx.OGCRDs.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID && x.DivisionlID == DivisionID);
                        if (objOGCRD != null)
                        {
                            if (objOCRD.ParentID == 1000010000000000)
                            {
                                if (objOGCRD.PlantID.HasValue)
                                {
                                    txtParentCode.Text = ctx.OPLTs.Where(x => x.PlantID == objOGCRD.PlantID.Value).Select(x => x.PlantCode + " - " + x.PlantName).FirstOrDefault();
                                }
                                else
                                {
                                    txtParentCode.Text = "";
                                }
                            }
                            else
                            {
                                txtParentCode.Text = ctx.OCRDs.Where(x => x.CustomerID == objOCRD.ParentID).Select(x => x.CustomerCode + " - " + x.CustomerName).DefaultIfEmpty().FirstOrDefault();
                            }

                            txtPriceGroup.Text = ctx.OIPLs.Where(x => x.PriceListID == objOGCRD.PriceListID).Select(x => x.Name + " - " + SqlFunctions.StringConvert((double)x.PriceListID).Trim()).FirstOrDefault();

                            List<RUT1> objRUT1 = ctx.RUT1.Where(x => x.CustomerID == objOCRD.CustomerID).ToList();

                            txtStatus.Text = (objOCRD.Active ? "SAP : Y" : "SAP : N") + "     " + (objAOCRD == null || objAOCRD.Active ? "DMS : Y" : "DMS : N") + "     " + (objRUT1 != null && objRUT1.Count > 0 && objRUT1.FirstOrDefault(x => x.Active) != null ? "Beat : Y" : objRUT1 != null && objRUT1.Count > 0 && objRUT1.FirstOrDefault(x => !x.Active) != null ? "Beat : N" : "Beat : ");
                            txtUpdateDate.Text = objOCRD.UpdatedDate.ToString("dd-MMM-yy HH:mm");
                            txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOCRD.UpdatedBy).Select(x => x.EmpCode + " - " + x.Name).DefaultIfEmpty().FirstOrDefault();
                            txtSSCode.Text = txtSSCode.Text + " ";
                        }

                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Plant Entry found',3);", true);
                            return;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtSSCode.Focus();
    }

    #endregion

    #region Button Events

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    decimal DealerID = decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last(), out DealerID) ? DealerID : 0;
                    decimal DistID = decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last(), out DistID) ? DistID : 0;
                    decimal SSID = decimal.TryParse(txtSSCode.Text.Split("-".ToArray()).Last(), out SSID) ? SSID : 0;

                    if (ddlCustType.SelectedValue == "2" && DistID == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
                        return;
                    }
                    else if (ddlCustType.SelectedValue == "3" && DealerID == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Dealer.',3);", true);
                        return;
                    }
                    else if (ddlCustType.SelectedValue == "4" && SSID == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper SS.',3);", true);
                        return;
                    }

                    decimal CustomerID = ddlCustType.SelectedValue == "2" ? DistID : ddlCustType.SelectedValue == "3" ? DealerID : SSID;
                    Int32 DivisionID = Int32.TryParse(ddlDivision.SelectedValue, out DivisionID) ? DivisionID : 0;

                    var PriceGroup = txtPriceGroup.Text.Split("-".ToArray()).Last().Trim();

                    Int32 PriceListID = Int32.TryParse(PriceGroup, out PriceListID) ? PriceListID : 0;
                    if (ctx.OIPLs.FirstOrDefault(x => x.PriceListID == PriceListID) == null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper PriceList.',3);", true);
                        return;
                    }

                    var objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == CustomerID);
                    if (objOCRD == null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Customer',3);", true);
                        return;
                    }
                    if (objOCRD.Active)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('SAP Status is Active so You can not Update Pricing Group',3);", true);
                        return;
                    }

                    var objOGCRD = ctx.OGCRDs.FirstOrDefault(x => x.CustomerID == CustomerID && x.DivisionlID == DivisionID);
                    if (objOGCRD != null)
                    {
                        objOGCRD.PriceListID = PriceListID;
                        objOCRD.UpdatedBy = UserID;
                        objOCRD.UpdatedDate = DateTime.Now;

                        ctx.SaveChanges();
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record updated successfully of : " + objOCRD.CustomerCode + "',1);", true);
                        ClearAllInputs();
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Selected customer has price not maintained.',3);", true);
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