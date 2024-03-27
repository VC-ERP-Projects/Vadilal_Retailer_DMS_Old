using System;
using System.Data.Entity.Validation;
using System.IO;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_Masters : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected int CustType;
    String TempPath = Path.GetTempPath();

    #endregion

    #region Helper Method

    private void ClearAllInputs()
    {
        if (chkMode.Checked)
        {
            txtNo.Enabled = ACEtxtName.Enabled = false;
            btnSubmit.Text = "Submit";
            txtNo.Style.Remove("background-color");
            txtNo.Text = "Auto Generated";
            txtName.Focus();
        }
        else
        {
            txtNo.Enabled = ACEtxtName.Enabled = true;
            txtNo.Text = "";
            btnSubmit.Text = "Submit";
            txtNo.Style.Add("background-color", "rgb(250, 255, 189);");
            txtNo.Focus();
        }
        lblName.Text = "Name";
        ddlPriceList.SelectedValue = ddlType.SelectedValue = ddlDocType.SelectedValue = ddlCampaign.SelectedValue = "0";
        ddlDocType_SelectedIndexChanged(ddlDocType, EventArgs.Empty);
        lblResType.Visible = lblexptype.Visible = ddlexptype.Visible = ddlResType.Visible = false;
        chkIsActive.Checked = true;
        txtExName.Text = txtEmpSortOrder.Text = txtInMins.Text = txtOutMins.Text = txtName.Text = txtCode.Text = txtCreatedBy.Text = txtCreatedTime.Text = txtUpdatedBy.Text = txtUpdatedTime.Text = "";
        txtName.MaxLength = 500;
        txtName.Attributes.Remove("onkeypress");
        ViewState["MstID"] = null;

        string selectedvalue = ddlModule.SelectedValue;

        ddlModule.Items.Clear();

        if (CustType == 2)
        {
            ddlModule.Items.Add(new ListItem("--- Select ---", "0"));
            ddlModule.Items.Add(new ListItem("Employee Group", "OGRP"));
        }
        else if (CustType == 1)
        {

            ddlModule.Items.Add(new ListItem("--- Select ---", "0"));
            ddlModule.Items.Add(new ListItem("Brand", "OBRND"));
            ddlModule.Items.Add(new ListItem("Reason", "ORSN"));
            ddlModule.Items.Add(new ListItem("Expense Type", "OEXT"));
            ddlModule.Items.Add(new ListItem("Expense Mode", "OEXM"));
            ddlModule.Items.Add(new ListItem("Employee Group", "OGRP"));
            ddlModule.Items.Add(new ListItem("Asset Type", "OASTY"));
            ddlModule.Items.Add(new ListItem("Asset Sub Type", "OASTYB"));
            ddlModule.Items.Add(new ListItem("Asset Size", "OASTZ"));
            ddlModule.Items.Add(new ListItem("Asset Brand", "OASTB"));
            ddlModule.Items.Add(new ListItem("Asset Condition", "OASTC"));
            ddlModule.Items.Add(new ListItem("Asset Status", "OASTU"));
            ddlModule.Items.Add(new ListItem("Task Reason", "OTRSN"));
            //ddlModule.Items.Add(new ListItem("Task Type", "OTTY"));
            ddlModule.Items.Add(new ListItem("Task Problem", "OPLM"));
            //ddlModule.Items.Add(new ListItem("Task Created Source", "OTCF"));
            //ddlModule.Items.Add(new ListItem("Task Problem CheckList", "OPLCK"));
        }

        ddlModule.SelectedValue = selectedvalue;
    }

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
                    var UserType = Session["UserType"].ToString();
                    if (Auth.OMNU.MenuType.ToUpper() == "B" || UserType.ToUpper() == "B" || UserType.ToUpper() == Auth.OMNU.MenuType.ToUpper()) { }
                    else
                        Response.Redirect("~/AccessError.aspx");

                    if (Session["Lang"] != null && Session["Lang"].ToString() == "gujarati")
                    {
                        try
                        {
                            var xml = XDocument.Load(Server.MapPath("../Document/forlanguage.xml"));
                            var unit = xml.Descendants("employee_grp_master");
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
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    #region Button Click

    protected void btnSubmitClick(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                int MstID = 0;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    // Item Type

                    if (ddlModule.SelectedValue == "0")
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Module First',3);", true);
                        return;
                    }
                    if (ddlModule.SelectedValue == "OITP")
                    {
                        var objOITP = new OITP();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOITP = ctx.OITPs.FirstOrDefault(x => x.TypeID == MstID);
                            if (ctx.OITMs.Any(x => x.Type == MstID && x.Active))
                            {
                                if (!chkIsActive.Checked)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('This Item type is assign to Item, so you can not deactivated it!',3);", true);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            if (ctx.OITPs.Any(x => x.TypeName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Item type name is not allowed!',3);", true);
                                return;
                            }
                            objOITP.TypeID = ctx.GetKey("OITP", "TypeID", "", 0, 0).FirstOrDefault().Value;
                            objOITP.CreatedDate = DateTime.Now;
                            objOITP.CreatedBy = UserID;
                            ctx.OITPs.Add(objOITP);
                        }
                        objOITP.TypeName = txtName.Text;
                        objOITP.Active = chkIsActive.Checked;
                        objOITP.UpdatedDate = DateTime.Now;
                        objOITP.UpdatedBy = UserID;
                    }

                    // Item Group
                    else if (ddlModule.SelectedValue == "OITB")
                    {
                        var objOITB = new OITB();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOITB = ctx.OITBs.FirstOrDefault(x => x.ItemGroupID == MstID);
                        }
                        else
                        {
                            if (ctx.OITBs.Any(x => x.ItemGroupName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Item group name is not allowed!',3);", true);
                                return;
                            }
                            objOITB.ItemGroupID = ctx.GetKey("OITB", "ItemGroupID", "", 0, 0).FirstOrDefault().Value;
                            objOITB.CreatedDate = DateTime.Now;
                            objOITB.CreatedBy = UserID;
                            ctx.OITBs.Add(objOITB);
                        }
                        objOITB.ItemGroupName = txtName.Text;
                        objOITB.Active = chkIsActive.Checked;
                        objOITB.UpdatedDate = DateTime.Now;
                        objOITB.UpdatedBy = UserID;
                        if (Session["ItemGroupSubGroupPhotoFileName"] != null)
                        {
                            string FileName = Session["ItemGroupSubGroupPhotoFileName"].ToString();
                            string SavePath = Path.Combine(Server.MapPath(Constant.ItemGroupPhoto), FileName);
                            string SourcePath = TempPath + FileName;
                            File.Copy(SourcePath, SavePath);

                            if (!String.IsNullOrEmpty(objOITB.Image) && File.Exists(Server.MapPath(Constant.ItemGroupPhoto + objOITB.Image)))
                                File.Delete(Server.MapPath(Constant.ItemGroupPhoto + objOITB.Image));

                            objOITB.Image = FileName;
                            Session["ItemGroupSubGroupPhotoFileName"] = null;
                        }
                        if (Session["BannerPhotoFileName"] != null)
                        {
                            string FileName = Session["BannerPhotoFileName"].ToString();
                            string SavePath = Path.Combine(Server.MapPath(Constant.BannerPhoto), FileName);
                            string SourcePath = TempPath + FileName;
                            File.Copy(SourcePath, SavePath);

                            if (!String.IsNullOrEmpty(objOITB.Image) && File.Exists(Server.MapPath(Constant.BannerPhoto + objOITB.Image)))
                                File.Delete(Server.MapPath(Constant.BannerPhoto + objOITB.Image));

                            objOITB.Banner = FileName;
                            Session["BannerPhotoFileName"] = null;
                        }
                    }

                    // Baner Details

                    else if (ddlModule.SelectedValue == "OIMG")
                    {
                        var objOIMG = new OIMG();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOIMG = ctx.OIMGs.FirstOrDefault(x => x.ImageID == MstID);
                        }
                        else
                        {
                            if (ctx.OIMGs.Any(x => x.ImageName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Image name is not allowed!',3);", true);
                                return;
                            }
                            objOIMG.ImageID = ctx.GetKey("OIMG", "ImageID", "", 0, 0).FirstOrDefault().Value;
                            objOIMG.CreatedDate = DateTime.Now;
                            objOIMG.CreatedBy = UserID;
                            ctx.OIMGs.Add(objOIMG);
                        }
                        objOIMG.Active = chkIsActive.Checked;
                        objOIMG.UpdatedDate = DateTime.Now;
                        objOIMG.UpdatedBy = UserID;
                        if (Session["BannerPhotoFileName"] != null)
                        {
                            string FileName = Session["BannerPhotoFileName"].ToString();
                            string SavePath = Path.Combine(Server.MapPath(Constant.BannerPhoto), FileName);
                            string SourcePath = TempPath + FileName;
                            File.Copy(SourcePath, SavePath);

                            if (!String.IsNullOrEmpty(objOIMG.ImageName) && File.Exists(Server.MapPath(Constant.BannerPhoto + objOIMG.ImageName)))
                                File.Delete(Server.MapPath(Constant.BannerPhoto + objOIMG.ImageName));

                            objOIMG.ImageName = FileName;
                            Session["BannerPhotoFileName"] = null;
                        }
                    }

                    // Item Unit
                    else if (ddlModule.SelectedValue == "OUNT")
                    {
                        var objOUNT = new OUNT();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOUNT = ctx.OUNTs.FirstOrDefault(x => x.UnitID == MstID);
                            if (ctx.ITM1.Any(x => x.UnitID == MstID && x.Active))
                            {
                                if (!chkIsActive.Checked)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('This Item unit is assign to Item, so you can not deactivated it!',3);", true);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            if (ctx.OUNTs.Any(x => x.UnitName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Item unit name is not allowed!',3);", true);
                                return;
                            }
                            objOUNT.UnitID = ctx.GetKey("OUNT", "UnitID", "", 0, 0).FirstOrDefault().Value;
                            objOUNT.CreatedDate = DateTime.Now;
                            objOUNT.CreatedBy = UserID;
                            ctx.OUNTs.Add(objOUNT);
                        }
                        objOUNT.UnitName = txtName.Text;
                        objOUNT.Active = chkIsActive.Checked;
                        objOUNT.UpdatedDate = DateTime.Now;
                        objOUNT.UpdatedBy = UserID;
                    }

                     // Country
                    else if (ddlModule.SelectedValue == "OCRY")
                    {
                        var objOCRY = new OCRY();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOCRY = ctx.OCRies.FirstOrDefault(x => x.CountryID == MstID);
                            if (ctx.CRD1.Any(x => x.CountryID == MstID) || ctx.EMP1.Any(x => x.CountryID == MstID) || ctx.OCSTs.Any(x => x.CountryID == MstID && x.Active) || ctx.OVNDs.Any(x => x.CountryID == MstID && x.Active) || ctx.OWHS.Any(x => x.CountryID == MstID))
                            {
                                if (!chkIsActive.Checked)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('This country is assign, so you can not deactivated it!',3);", true);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            if (ctx.OCRies.Any(x => x.CountryName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same country name is not allowed!',3);", true);
                                return;
                            }
                            objOCRY.CountryID = ctx.GetKey("OCRY", "CountryID", "", 0, 0).FirstOrDefault().Value;
                            objOCRY.CreatedDate = DateTime.Now;
                            objOCRY.CreatedBy = UserID;
                            ctx.OCRies.Add(objOCRY);
                        }
                        objOCRY.CountryName = txtName.Text;
                        objOCRY.Active = chkIsActive.Checked;
                        objOCRY.UpdatedDate = DateTime.Now;
                        objOCRY.UpdatedBy = UserID;
                    }

                     // State
                    else if (ddlModule.SelectedValue == "OCST")
                    {
                        var objOCST = new OCST();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOCST = ctx.OCSTs.FirstOrDefault(x => x.StateID == MstID);
                            if (ctx.CRD1.Any(x => x.StateID == MstID) || ctx.EMP1.Any(x => x.StateID == MstID) || ctx.OCTies.Any(x => x.StateID == MstID && x.Active) || ctx.OVNDs.Any(x => x.StateID == MstID && x.Active) || ctx.OWHS.Any(x => x.StateID == MstID))
                            {
                                if (!chkIsActive.Checked)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('This state is assign, so you can not deactivated it!',3);", true);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            if (ctx.OCSTs.Any(x => x.StateName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same state name is not allowed!',3);", true);
                                return;
                            }
                            objOCST.StateID = ctx.GetKey("OCST", "StateID", "", 0, 0).FirstOrDefault().Value;
                            objOCST.CreatedDate = DateTime.Now;
                            objOCST.CreatedBy = UserID;
                            ctx.OCSTs.Add(objOCST);
                        }
                        objOCST.StateName = txtName.Text;
                        if (ddlMst.SelectedValue != "0")
                            objOCST.CountryID = Convert.ToInt32(ddlMst.SelectedValue);
                        objOCST.Active = chkIsActive.Checked;
                        objOCST.UpdatedDate = DateTime.Now;
                        objOCST.UpdatedBy = UserID;
                    }

                    // City
                    else if (ddlModule.SelectedValue == "OCTY")
                    {
                        var objOCTY = new OCTY();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOCTY = ctx.OCTies.FirstOrDefault(x => x.CityID == MstID);
                            if (ctx.CRD1.Any(x => x.CityID == MstID) || ctx.EMP1.Any(x => x.CityID == MstID) || ctx.OVNDs.Any(x => x.CityID == MstID && x.Active) || ctx.OWHS.Any(x => x.CityID == MstID))
                            {
                                if (!chkIsActive.Checked)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('This city is assign, so you can not deactivated it!',3);", true);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            if (ctx.OCTies.Any(x => x.CityName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same city name is not allowed!',3);", true);
                                return;
                            }
                            objOCTY.CityID = ctx.GetKey("OCTY", "CityID", "", 0, 0).FirstOrDefault().Value;
                            objOCTY.CreatedDate = DateTime.Now;
                            objOCTY.CreatedBy = UserID;
                            ctx.OCTies.Add(objOCTY);
                        }
                        objOCTY.CityName = txtName.Text;
                        if (ddlMst.SelectedValue != "0")
                            objOCTY.StateID = Convert.ToInt32(ddlMst.SelectedValue);
                        objOCTY.Active = chkIsActive.Checked;
                        objOCTY.UpdatedDate = DateTime.Now;
                        objOCTY.UpdatedBy = UserID;
                    }
                    // Food Type
                    else if (ddlModule.SelectedValue == "OFTP")
                    {
                        var objOFTP = new OFTP();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOFTP = ctx.OFTPs.FirstOrDefault(x => x.TypeID == MstID);
                        }
                        else
                        {
                            if (ctx.OFTPs.Any(x => x.TypeName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same food type name is not allowed!',3);", true);
                                return;
                            }
                            objOFTP.TypeID = ctx.GetKey("OFTP", "TypeID", "", 0, 0).FirstOrDefault().Value;
                            objOFTP.CreatedDate = DateTime.Now;
                            objOFTP.CreatedBy = UserID;
                            ctx.OFTPs.Add(objOFTP);
                        }
                        objOFTP.TypeName = txtName.Text;
                        objOFTP.TypeSortName = txtExName.Text;
                        objOFTP.Active = chkIsActive.Checked;
                        objOFTP.UpdatedDate = DateTime.Now;
                        objOFTP.UpdatedBy = UserID;
                    }

                    // Relation
                    else if (ddlModule.SelectedValue == "ORLN")
                    {
                        var objORLN = new ORLN();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objORLN = ctx.ORLNs.FirstOrDefault(x => x.RelationID == MstID);
                            if (ctx.CRD2.Any(x => x.RelationID == MstID))
                            {
                                if (!chkIsActive.Checked)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('This relation is assign to customer, so you can not deactivated it!',3);", true);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            if (ctx.ORLNs.Any(x => x.RelationName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same relation name is not allowed!',3);", true);
                                return;
                            }
                            objORLN.RelationID = ctx.GetKey("ORLN", "RelationID", "", 0, 0).FirstOrDefault().Value;
                            objORLN.CreatedDate = DateTime.Now;
                            objORLN.CreatedBy = UserID;
                            ctx.ORLNs.Add(objORLN);
                        }
                        objORLN.RelationName = txtName.Text;
                        objORLN.Active = chkIsActive.Checked;
                        objORLN.UpdatedDate = DateTime.Now;
                        objORLN.UpdatedBy = UserID;
                    }

                    // Customer Group
                    else if (ddlModule.SelectedValue == "CGRP")
                    {
                        var objCGRP = new CGRP();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objCGRP = ctx.CGRPs.FirstOrDefault(x => x.CustGroupID == MstID);
                            if (ctx.OCRDs.Any(x => x.CustGroupID == MstID))
                            {
                                if (!chkIsActive.Checked)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('This customer group is assign to customer, so you can not deactivated it!',3);", true);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            if (ctx.CGRPs.Any(x => x.CustGroupName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same customer group name is not allowed!',3);", true);
                                return;
                            }
                            objCGRP.CustGroupID = ctx.GetKey("CGRP", "CustGroupID", "", 0, 0).FirstOrDefault().Value;
                            objCGRP.CreatedDate = DateTime.Now;
                            objCGRP.CreatedBy = UserID;
                            objCGRP.CustGroupDesc = "";
                            ctx.CGRPs.Add(objCGRP);
                        }
                        objCGRP.PriceListID = Convert.ToInt32(ddlPriceList.SelectedValue);
                        objCGRP.CustGroupName = txtName.Text;
                        if (ddlMst.SelectedValue != "0")
                            objCGRP.Type = Convert.ToInt32(ddlMst.SelectedValue);
                        objCGRP.Active = chkIsActive.Checked;
                        objCGRP.UpdatedDate = DateTime.Now;
                        objCGRP.UpdatedBy = UserID;
                    }

                     // Item Subgroup
                    else if (ddlModule.SelectedValue == "OITG")
                    {
                        var objOITG = new OITG();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOITG = ctx.OITGs.FirstOrDefault(x => x.ItemSubGroupID == MstID);
                            //if (ctx.OITBs.Any(x => x.ItemGroupID == MstID))
                            //{
                            //    if (!chkIsActive.Checked)
                            //    {
                            //        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('This city is assign, so you can not deactivated it!',3);", true);
                            //        return;
                            //    }
                            //}


                        }
                        else
                        {
                            if (ctx.OITGs.Any(x => x.ItemSubGroupName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same item subgroup name is not allowed!',3);", true);
                                return;
                            }
                            objOITG.ItemSubGroupID = ctx.GetKey("OITG", "ItemSubGroupID", "", 0, 0).FirstOrDefault().Value;
                            objOITG.CreatedDate = DateTime.Now;
                            objOITG.CreatedBy = UserID;
                            ctx.OITGs.Add(objOITG);
                        }
                        objOITG.ItemSubGroupName = txtName.Text;
                        if (ddlMst.SelectedValue != "0")
                            objOITG.ItemGroupID = Convert.ToInt32(ddlMst.SelectedValue);
                        objOITG.Active = chkIsActive.Checked;
                        objOITG.UpdatedDate = DateTime.Now;
                        objOITG.UpdatedBy = UserID;
                        if (Session["ItemGroupSubGroupPhotoFileName"] != null)
                        {
                            string FileName = Session["ItemGroupSubGroupPhotoFileName"].ToString();
                            string SavePath = Path.Combine(Server.MapPath(Constant.ItemSubGroupPhoto), FileName);
                            string SourcePath = TempPath + FileName;
                            File.Copy(SourcePath, SavePath);

                            if (!String.IsNullOrEmpty(objOITG.Image) && File.Exists(Server.MapPath(Constant.ItemSubGroupPhoto + objOITG.Image)))
                                File.Delete(Server.MapPath(Constant.ItemSubGroupPhoto + objOITG.Image));

                            objOITG.Image = FileName;
                            Session["ItemGroupSubGroupPhotoFileName"] = null;
                        }
                    }

                     // Question
                    else if (ddlModule.SelectedValue == "OQUS")
                    {
                        var objOQUS = new OQU();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOQUS = ctx.OQUS.FirstOrDefault(x => x.QuesID == MstID && x.ParentID == ParentID);
                            if (ctx.OEMPs.Any(x => x.SecQueID == MstID && x.ParentID == ParentID) || ctx.CFB1.Any(x => x.QuesID == MstID && x.ParentID == ParentID) || ctx.CMP1.Any(x => x.QuesID == MstID && x.ParentID == ParentID))
                            {
                                if (!chkIsActive.Checked)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('This question is assign, so you can not deactivated it!',3);", true);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            if (ctx.OQUS.Any(x => x.QuesName == txtName.Text && x.ParentID == ParentID))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same question name is not allowed!',3);", true);
                                return;
                            }
                            objOQUS.QuesID = ctx.GetKey("OQUS", "QuesID", "", ParentID, 0).FirstOrDefault().Value;
                            objOQUS.ParentID = ParentID;
                            objOQUS.CreatedDate = DateTime.Now;
                            objOQUS.CreatedBy = UserID;
                            ctx.OQUS.Add(objOQUS);
                        }
                        objOQUS.QuesName = txtName.Text;
                        if (ddlDocType.SelectedValue != "0")
                            objOQUS.DocType = ddlDocType.SelectedValue;
                        if (ddlType.SelectedValue != "0")
                            objOQUS.Type = ddlType.SelectedValue;
                        if (ddlCampaign.SelectedValue != "0")
                            objOQUS.CampaignID = Convert.ToInt32(ddlCampaign.SelectedValue);
                        objOQUS.Active = chkIsActive.Checked;
                        objOQUS.UpdatedDate = DateTime.Now;
                        objOQUS.UpdatedBy = UserID;
                    }

                    // Employee Group
                    else if (ddlModule.SelectedValue == "OGRP")
                    {
                        var objOGRP = new OGRP();
                        Int16 SortOrder = Int16.TryParse(txtEmpSortOrder.Text, out SortOrder) ? SortOrder : Convert.ToInt16(0);
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOGRP = ctx.OGRPs.FirstOrDefault(x => x.EmpGroupID == MstID && x.ParentID == ParentID);
                            if (ctx.OEMPs.Any(x => x.EmpGroupID == MstID && x.ParentID == ParentID))
                            {
                                if (!chkIsActive.Checked)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('This employee group is assign, so you can not deactivated it!',3);", true);
                                    return;
                                }
                            }
                        }
                        else
                        {
                            if (ctx.OGRPs.Any(x => x.EmpGroupName == txtName.Text && x.ParentID == ParentID))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same employee group name is not allowed!',3);", true);
                                return;
                            }
                            objOGRP.EmpGroupID = ctx.GetKey("OGRP", "EmpGroupID", "", ParentID, 0).FirstOrDefault().Value;
                            objOGRP.EmpGroupDesc = "";
                            objOGRP.ParentID = ParentID;
                            objOGRP.CreatedDate = DateTime.Now;
                            objOGRP.CreatedBy = UserID;
                            ctx.OGRPs.Add(objOGRP);
                        }
                        objOGRP.SortOrder = SortOrder;
                        objOGRP.EmpGroupName = txtName.Text;
                        objOGRP.Active = chkIsActive.Checked;
                        objOGRP.UpdatedDate = DateTime.Now;
                        objOGRP.UpdatedBy = UserID;
                    }

                    // Expense Type
                    else if (ddlModule.SelectedValue == "OEXT")
                    {
                        var objOEXT = new OEXT();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOEXT = ctx.OEXTs.FirstOrDefault(x => x.ExpTypeID == MstID);
                        }
                        else
                        {
                            if (ctx.OEXTs.Any(x => x.ExpType == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Expense Type name is not allowed!',3);", true);
                                return;
                            }
                            objOEXT.ExpTypeID = ctx.GetKey("OEXT", "ExpTypeID", "", 0, 0).FirstOrDefault().Value;
                            objOEXT.CreatedDate = DateTime.Now;
                            objOEXT.CreatedBy = UserID;
                            ctx.OEXTs.Add(objOEXT);
                        }
                        objOEXT.ExpType = txtName.Text;
                        objOEXT.Notes = ddlexptype.SelectedValue;
                        objOEXT.Active = chkIsActive.Checked;
                        objOEXT.UpdatedDate = DateTime.Now;
                        objOEXT.UpdatedBy = UserID;
                    }

                    // Brand 
                    else if (ddlModule.SelectedValue == "OBRND")
                    {
                        var objOBRND = new OBRND();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOBRND = ctx.OBRNDs.FirstOrDefault(x => x.BrandID == MstID);
                        }
                        else
                        {
                            if (ctx.OBRNDs.Any(x => x.BrandName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Brand name is not allowed!',3);", true);
                                return;
                            }
                            objOBRND.BrandID = ctx.GetKey("OBRND", "BrandID", "", 0, 0).FirstOrDefault().Value;
                            objOBRND.CreatedDate = DateTime.Now;
                            objOBRND.CreatedBy = UserID;
                            ctx.OBRNDs.Add(objOBRND);
                        }

                        objOBRND.BrandName = txtName.Text;
                        objOBRND.BrandCode = "";
                        objOBRND.Active = chkIsActive.Checked;
                        objOBRND.UpdatedDate = DateTime.Now;
                        objOBRND.UpdatedBy = UserID;
                    }

                    // Reason
                    else if (ddlModule.SelectedValue == "ORSN")
                    {
                        var objORSN = new ORSN();
                        if (String.IsNullOrEmpty(txtName.Text))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Reason Name is mandatory',3);", true);
                            return;
                        }
                        if (String.IsNullOrEmpty(txtExName.Text))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('SAP Reason Code is mandatory',3);", true);
                            return;
                        }
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objORSN = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == MstID);
                            if (ctx.ORSNs.Any(x => x.ReasonName == txtName.Text && x.ReasonID != objORSN.ReasonID))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same reason name is not allowed!',3);", true);
                                return;
                            }
                            if (ctx.ORSNs.Any(x => x.SAPReasonItemCode == txtExName.Text && x.ReasonID != objORSN.ReasonID))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same SAP Reason Code is not allowed!',3);", true);
                                return;
                            }
                        }
                        else
                        {
                            if (ctx.ORSNs.Any(x => x.ReasonName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same reason name is not allowed!',3);", true);
                                return;
                            }
                            if (ctx.ORSNs.Any(x => x.SAPReasonItemCode == txtExName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same SAP Reason Code is not allowed!',3);", true);
                                return;
                            }
                            objORSN.ReasonID = ctx.GetKey("ORSN", "ReasonID", "", 0, 0).FirstOrDefault().Value;
                            objORSN.CreatedDate = DateTime.Now;
                            objORSN.CreatedBy = UserID;
                            ctx.ORSNs.Add(objORSN);
                        }

                        objORSN.SAPReasonItemCode = txtExName.Text;
                        objORSN.ReasonName = txtName.Text;
                        objORSN.Type = ddlResType.SelectedValue;
                        if (objORSN.Type == "S")
                        {
                            objORSN.ReasonDesc = objORSN.SAPReasonItemCode;
                        }
                        objORSN.Active = chkIsActive.Checked;
                        objORSN.UpdatedDate = DateTime.Now;
                        objORSN.UpdatedBy = UserID;
                    }

                    // Asset Group
                    else if (ddlModule.SelectedValue == "OASTG")
                    {
                        var objOASTG = new OASTG();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOASTG = ctx.OASTGs.FirstOrDefault(x => x.AssetGroupID == MstID);
                            if (ctx.OASTGs.Any(x => x.AssetGroupName == txtName.Text && x.AssetGroupID != objOASTG.AssetGroupID))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same asset group is not allowed!',3);", true);
                                return;
                            }
                        }
                        else
                        {
                            if (ctx.OASTGs.Any(x => x.AssetGroupName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same asset group is not allowed!',3);", true);
                                return;
                            }
                            objOASTG.CreatedDate = DateTime.Now;
                            objOASTG.CreatedBy = UserID;
                            ctx.OASTGs.Add(objOASTG);
                        }
                        objOASTG.AssetGroupName = txtName.Text.Trim();
                        objOASTG.AssetGroupCode = txtName.Text.Trim();
                        objOASTG.Active = chkIsActive.Checked;
                        objOASTG.UpdatedDate = DateTime.Now;
                        objOASTG.UpdatedBy = UserID;
                    }

                    // Asset Status
                    else if (ddlModule.SelectedValue == "OASTU")
                    {
                        var objOASTU = new OASTU();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOASTU = ctx.OASTUs.FirstOrDefault(x => x.AssetStatusID == MstID);
                            if (ctx.OASTUs.Any(x => x.AssetStatusName == txtName.Text && x.AssetStatusID != objOASTU.AssetStatusID))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same asset status is not allowed!',3);", true);
                                return;
                            }
                        }
                        else
                        {
                            if (ctx.OASTUs.Any(x => x.AssetStatusName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same asset status is not allowed!',3);", true);
                                return;
                            }
                            objOASTU.CreatedDate = DateTime.Now;
                            objOASTU.CreatedBy = UserID;
                            ctx.OASTUs.Add(objOASTU);
                        }
                        objOASTU.AssetStatusName = txtName.Text.Trim();
                        objOASTU.Active = chkIsActive.Checked;
                        objOASTU.UpdatedDate = DateTime.Now;
                        objOASTU.UpdatedBy = UserID;
                    }

                    // Asset Condition
                    else if (ddlModule.SelectedValue == "OASTC")
                    {
                        var objOASTC = new OASTC();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOASTC = ctx.OASTCs.FirstOrDefault(x => x.AssetConditionID == MstID);
                            if (ctx.OASTCs.Any(x => x.AssetConditionName == txtName.Text && x.AssetConditionID != objOASTC.AssetConditionID))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same asset condition is not allowed!',3);", true);
                                return;
                            }
                        }
                        else
                        {
                            if (ctx.OASTCs.Any(x => x.AssetConditionName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same asset condition is not allowed!',3);", true);
                                return;
                            }
                            objOASTC.CreatedDate = DateTime.Now;
                            objOASTC.CreatedBy = UserID;
                            ctx.OASTCs.Add(objOASTC);
                        }
                        objOASTC.AssetConditionName = txtName.Text.Trim();
                        objOASTC.Active = chkIsActive.Checked;
                        objOASTC.UpdatedDate = DateTime.Now;
                        objOASTC.UpdatedBy = UserID;
                    }
                    // Expense Mode
                    else if (ddlModule.SelectedValue == "OEXM")
                    {
                        var objOEXM = new OEXM();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOEXM = ctx.OEXMs.FirstOrDefault(x => x.ExpModeID == MstID);
                            if (ctx.OEXMs.Any(x => x.ExpMode == txtName.Text && x.ExpModeID != objOEXM.ExpModeID))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Expense Mode is not allowed!',3);", true);
                                return;
                            }
                        }
                        else
                        {
                            if (ctx.OEXMs.Any(x => x.ExpMode == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Expense Mode Name is not allowed!',3);", true);
                                return;
                            }
                            objOEXM.ExpModeID = ctx.GetKey("OEXM", "ExpModeID", "", 0, 0).FirstOrDefault().Value;
                            objOEXM.CreatedDate = DateTime.Now;
                            objOEXM.CreatedBy = UserID;
                            ctx.OEXMs.Add(objOEXM);
                        }
                        if (ddlMst.SelectedValue != "0")
                            objOEXM.ExpTypeID = Convert.ToInt32(ddlMst.SelectedValue);
                        objOEXM.ExpMode = txtName.Text.Trim();
                        objOEXM.EmpGradeID = null;
                        objOEXM.Active = chkIsActive.Checked;
                        objOEXM.UpdatedDate = DateTime.Now;
                        objOEXM.UpdatedBy = UserID;
                    }

                    // Asset Type
                    else if (ddlModule.SelectedValue == "OASTY")
                    {
                        var objOASTY = new OASTY();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOASTY = ctx.OASTies.FirstOrDefault(x => x.AssetTypeID == MstID);
                            if (ctx.OASTies.Any(x => x.AssetTypeName == txtName.Text && x.AssetTypeID != objOASTY.AssetTypeID))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Asset Type is not allowed!',3);", true);
                                return;
                            }
                        }
                        else
                        {
                            if (ctx.OASTies.Any(x => x.AssetTypeName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Asset Type is not allowed!',3);", true);
                                return;
                            }
                            objOASTY.CreatedDate = DateTime.Now;
                            objOASTY.CreatedBy = UserID;
                            ctx.OASTies.Add(objOASTY);
                        }
                        objOASTY.AssetTypeName = txtName.Text.Trim();
                        objOASTY.AssetTypeCode = txtName.Text.Trim();
                        objOASTY.Active = chkIsActive.Checked;
                        objOASTY.UpdatedDate = DateTime.Now;
                        objOASTY.UpdatedBy = UserID;
                    }

                    // Asset Sub Type Name
                    else if (ddlModule.SelectedValue == "OASTYB")
                    {
                        var objOASTYB = new OASTYB();
                        int masterid = Convert.ToInt32(ddlMst.SelectedValue);
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOASTYB = ctx.OASTYBs.FirstOrDefault(x => x.AssetSubTypeID == MstID);
                            if (ctx.OASTYBs.Any(x => x.AssetSubTypeName == txtName.Text && x.AssetTypeID == masterid && x.AssetSubTypeID != objOASTYB.AssetSubTypeID))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Asset Sub Type Name is not allowed!',3);", true);
                                return;
                            }
                        }
                        else
                        {
                            if (ctx.OASTYBs.Any(x => x.AssetSubTypeName == txtName.Text && x.AssetTypeID == masterid))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Asset Sub Type Name is not allowed!',3);", true);
                                return;
                            }
                            objOASTYB.CreatedDate = DateTime.Now;
                            objOASTYB.CreatedBy = UserID;
                            ctx.OASTYBs.Add(objOASTYB);
                        }
                        objOASTYB.AssetTypeID = masterid;
                        objOASTYB.AssetSubTypeCode = "AB" + objOASTYB.AssetSubTypeID.ToString("D2");
                        objOASTYB.AssetSubTypeName = txtName.Text.Trim();
                        objOASTYB.Active = chkIsActive.Checked;
                        objOASTYB.IsDefault = false;
                        objOASTYB.UpdatedDate = DateTime.Now;
                        objOASTYB.UpdatedBy = UserID;
                    }
                    // Asset SIZE
                    else if (ddlModule.SelectedValue == "OASTZ")
                    {
                        var objOASTZ = new OASTZ();
                        int masterid = Convert.ToInt32(ddlMst.SelectedValue);
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOASTZ = ctx.OASTZs.FirstOrDefault(x => x.AssetSizeID == MstID);
                            if (ctx.OASTZs.Any(x => x.AssetSizeName == txtName.Text && x.AssetSubTypeID == masterid && x.AssetSizeID != objOASTZ.AssetSizeID))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same asset size is not allowed!',3);", true);
                                return;
                            }
                        }
                        else
                        {
                            if (ctx.OASTZs.Any(x => x.AssetSizeName == txtName.Text && x.AssetSubTypeID == masterid))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same asset size is not allowed!',3);", true);
                                return;
                            }
                            objOASTZ.CreatedDate = DateTime.Now;
                            objOASTZ.CreatedBy = UserID;
                            ctx.OASTZs.Add(objOASTZ);
                        }
                        objOASTZ.AssetSubTypeID = masterid;
                        objOASTZ.AssetSizeName = txtName.Text.Trim();
                        objOASTZ.Active = chkIsActive.Checked;
                        objOASTZ.UpdatedDate = DateTime.Now;
                        objOASTZ.UpdatedBy = UserID;
                    }
                    // Asset BRAND
                    else if (ddlModule.SelectedValue == "OASTB")
                    {
                        var objOASTB = new OASTB();
                        int masterid = Convert.ToInt32(ddlMst.SelectedValue);
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOASTB = ctx.OASTBs.FirstOrDefault(x => x.AssetBrandID == MstID);
                            if (ctx.OASTBs.Any(x => x.AssetBrandName == txtName.Text && x.AssetSizeID == masterid && x.AssetBrandID != objOASTB.AssetBrandID))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same asset brand is not allowed!',3);", true);
                                return;
                            }
                        }
                        else
                        {
                            if (ctx.OASTBs.Any(x => x.AssetBrandName == txtName.Text && x.AssetSizeID == masterid))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same asset brand is not allowed!',3);", true);
                                return;
                            }

                            objOASTB.CreatedDate = DateTime.Now;
                            objOASTB.CreatedBy = UserID;
                            ctx.OASTBs.Add(objOASTB);
                        }
                        objOASTB.AssetSizeID = masterid;
                        objOASTB.AssetBrandName = txtName.Text.Trim();
                        objOASTB.Active = chkIsActive.Checked;
                        objOASTB.UpdatedDate = DateTime.Now;
                        objOASTB.UpdatedBy = UserID;
                    }
                    // Plant 
                    else if (ddlModule.SelectedValue == "OPLT")
                    {
                        var objOPLT = new OPLT();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOPLT = ctx.OPLTs.FirstOrDefault(x => x.PlantID == MstID);
                        }
                        else
                        {
                            if (ctx.OPLTs.Any(x => x.PlantName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same item subgroup name is not allowed!',3);", true);
                                return;
                            }
                            objOPLT.PlantID = ctx.GetKey("OPLT", "PlantID", "", 0, 0).FirstOrDefault().Value;
                            objOPLT.CreatedDate = DateTime.Now;
                            objOPLT.CreatedBy = UserID;
                            ctx.OPLTs.Add(objOPLT);
                        }
                        objOPLT.PlantName = txtName.Text;
                        objOPLT.PlantCode = txtCode.Text;
                        //if (ddlMst.SelectedValue != "0")
                        //    objOPLT.RegionID  = Convert.ToInt32(ddlMst.SelectedValue);
                        objOPLT.Active = chkIsActive.Checked;
                        objOPLT.UpdatedDate = DateTime.Now;
                        objOPLT.UpdatedBy = UserID;
                    }
                    // PinCode
                    else if (ddlModule.SelectedValue == "OPIN")
                    {
                        var objOPIN = new OPIN();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOPIN = ctx.OPINs.FirstOrDefault(x => x.PinCodeID == MstID);
                        }
                        else
                        {
                            if (ctx.OPINs.Any(x => x.PinCodeID == MstID))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same PinCode is not allowed!',3);", true);
                                return;
                            }
                            objOPIN.PinCodeID = ctx.GetKey("OPIN", "PinCodeID", "", 0, 0).FirstOrDefault().Value;
                            objOPIN.CreatedDate = DateTime.Now;
                            objOPIN.CreatedBy = UserID;
                            ctx.OPINs.Add(objOPIN);
                        }
                        objOPIN.PinCodeID = Convert.ToInt32(txtName.Text);
                        objOPIN.Area = txtCode.Text;
                        objOPIN.Active = chkIsActive.Checked;
                        objOPIN.UpdatedDate = DateTime.Now;
                        objOPIN.UpdatedBy = UserID;
                    }
                    else if (ddlModule.SelectedValue == "OTRSN")
                    {
                        var objOTRSN = new OTRSN();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOTRSN = ctx.OTRSNs.FirstOrDefault(x => x.TaskReasonID == MstID);
                        }
                        else
                        {
                            if (ctx.OTRSNs.Any(x => x.TaskReasonName == txtName.Text && x.ReasonType == ddlTaskReason.SelectedValue))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Task Reason name is not allowed in same Reason Type!',3);", true);
                                return;
                            }
                            objOTRSN.TaskReasonID = ctx.GetKey("OTRSN", "TaskReasonID", "", 0, 0).FirstOrDefault().Value;
                            objOTRSN.CreatedDate = DateTime.Now;
                            objOTRSN.CreatedBy = UserID;
                            ctx.OTRSNs.Add(objOTRSN);
                        }
                        objOTRSN.TaskReasonName = txtName.Text;
                        objOTRSN.TaskReasonCode = MstID.ToString();
                        objOTRSN.ReasonType = ddlTaskReason.SelectedValue;
                        objOTRSN.Active = chkIsActive.Checked;
                        objOTRSN.UpdatedDate = DateTime.Now;
                        objOTRSN.UpdatedBy = UserID;
                    }
                    else if (ddlModule.SelectedValue == "OPLCK")
                    {
                        var objOPLCK = new OPLCK();
                        //int EmpGrpID = Convert.ToInt32(ddlEGroup.SelectedValue);
                        //int ProbID = Convert.ToInt32(ddlProbType.SelectedValue);

                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOPLCK = ctx.OPLCKs.FirstOrDefault(x => x.ProblemCheckID == MstID);
                        }
                        else
                        {

                            if (ctx.OPLCKs.Any(x => x.CheckPointTask == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Checklist is not allowed in same Problem Type and same Employee Group!',3);", true);
                                return;
                            }
                            objOPLCK.ProblemCheckID = ctx.GetKey("OPLCK", "ProblemCheckID", "", 0, 0).FirstOrDefault().Value;
                            objOPLCK.CreatedDate = DateTime.Now;
                            objOPLCK.CreatedBy = UserID;
                            ctx.OPLCKs.Add(objOPLCK);
                        }
                        objOPLCK.CheckPointTask = txtName.Text;
                        objOPLCK.Active = chkIsActive.Checked;
                        objOPLCK.UpdatedDate = DateTime.Now;
                        objOPLCK.UpdatedBy = UserID;
                    }
                    else if (ddlModule.SelectedValue == "OTTY")
                    {
                        var objOTTY = new OTTY();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOTTY = ctx.OTTies.FirstOrDefault(x => x.TaskTypeID == MstID);
                        }
                        else
                        {
                            if (ctx.OTTies.Any(x => x.TaskTypeName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Task Type name is not allowed!',3);", true);
                                return;
                            }
                            objOTTY.TaskTypeID = ctx.GetKey("OTTY", "TaskTypeID", "", 0, 0).FirstOrDefault().Value;
                            objOTTY.CreatedDate = DateTime.Now;
                            objOTTY.CreatedBy = UserID;
                            ctx.OTTies.Add(objOTTY);
                        }
                        objOTTY.TaskTypeName = txtName.Text;
                        objOTTY.TaskTypeCode = MstID.ToString();
                        objOTTY.Active = chkIsActive.Checked;
                        objOTTY.UpdatedDate = DateTime.Now;
                        objOTTY.UpdatedBy = UserID;
                    }
                    else if (ddlModule.SelectedValue == "OTCF")
                    {
                        var objOTCF = new OTCF();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOTCF = ctx.OTCFs.FirstOrDefault(x => x.TaskCreatedFromID == MstID);
                        }
                        else
                        {
                            if (ctx.OTCFs.Any(x => x.TaskCreatedFrom == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Created Source name is not allowed!',3);", true);
                                return;
                            }
                            objOTCF.TaskCreatedFromID = ctx.GetKey("OTCF", "TaskCreatedFromID", "", 0, 0).FirstOrDefault().Value;
                            objOTCF.CreatedDate = DateTime.Now;
                            objOTCF.CreatedBy = UserID;
                            ctx.OTCFs.Add(objOTCF);
                        }
                        objOTCF.TaskCreatedFrom = txtName.Text;
                        objOTCF.Active = chkIsActive.Checked;
                        objOTCF.UpdatedDate = DateTime.Now;
                        objOTCF.UpdatedBy = UserID;
                    }
                    else if (ddlModule.SelectedValue == "OPLM")
                    {
                        var objOPLM = new OPLM();
                        if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                        {
                            objOPLM = ctx.OPLMs.FirstOrDefault(x => x.ProblemID == MstID);
                        }
                        else
                        {
                            if (ctx.OPLMs.Any(x => x.ProbemName == txtName.Text))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Created Source name is not allowed!',3);", true);
                                return;
                            }
                            objOPLM.ProblemID = ctx.GetKey("OPLM", "ProblemID", "", 0, 0).FirstOrDefault().Value;
                            objOPLM.CreatedDate = DateTime.Now;
                            objOPLM.CreatedBy = UserID;
                            ctx.OPLMs.Add(objOPLM);
                        }
                        objOPLM.ProbemName = txtName.Text;
                        objOPLM.TaskTypeID = Convert.ToInt32(ddlTaskType.SelectedValue);
                        objOPLM.InCityMins = Convert.ToInt64(txtInMins.Text);
                        objOPLM.OutCityMins = Convert.ToInt64(txtOutMins.Text);
                        objOPLM.Active = chkIsActive.Checked;
                        objOPLM.UpdatedDate = DateTime.Now;
                        objOPLM.UpdatedBy = UserID;
                    }
                    ctx.SaveChanges();
                    ClearAllInputs();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully.',1);", true);
                }
            }
        }
        catch (DbEntityValidationException ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + ex.EntityValidationErrors.FirstOrDefault().ValidationErrors.FirstOrDefault().ErrorMessage + "',2);", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }

    }

    protected void btnCancelClick(object sender, EventArgs e)
    {
        Response.Redirect("Master.aspx");
    }

    #endregion

    #region Change Event

    protected void txtNo_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && !string.IsNullOrEmpty(txtNo.Text))
            {
                var word = txtNo.Text.Split("-".ToArray());
                if (word.Length > 1)
                {
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        int ID = Convert.ToInt32(word.First().Trim());

                        if (ddlModule.SelectedValue == "OITP")
                        {
                            var objOITP = ctx.OITPs.FirstOrDefault(x => x.TypeID == ID);
                            if (objOITP != null)
                            {
                                txtNo.Text = objOITP.TypeID.ToString();
                                txtName.Text = objOITP.TypeName;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOITP.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOITP.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOITP.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOITP.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                chkIsActive.Checked = objOITP.Active;
                                ViewState["MstID"] = objOITP.TypeID;

                            }
                        }
                        else if (ddlModule.SelectedValue == "OBRND")
                        {
                            var objOBRND = ctx.OBRNDs.FirstOrDefault(x => x.BrandID == ID);
                            if (objOBRND != null)
                            {
                                txtNo.Text = objOBRND.BrandID.ToString();
                                txtName.Text = objOBRND.BrandName;
                                chkIsActive.Checked = objOBRND.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOBRND.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOBRND.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOBRND.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOBRND.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOBRND.BrandID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OITB")
                        {
                            var objOITB = ctx.OITBs.FirstOrDefault(x => x.ItemGroupID == ID);
                            if (objOITB != null)
                            {
                                txtNo.Text = objOITB.ItemGroupID.ToString();
                                txtName.Text = objOITB.ItemGroupName;
                                chkIsActive.Checked = objOITB.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOITB.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOITB.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOITB.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOITB.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOITB.ItemGroupID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OIMG")
                        {
                            var objOIMG = ctx.OIMGs.FirstOrDefault(x => x.ImageID == ID);
                            if (objOIMG != null)
                            {
                                txtNo.Text = objOIMG.ImageID.ToString();
                                txtName.Text = objOIMG.ImageName.Split(".".ToArray()).First();
                                chkIsActive.Checked = objOIMG.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOIMG.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOIMG.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOIMG.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOIMG.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOIMG.ImageID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OUNT")
                        {
                            var objOUNT = ctx.OUNTs.FirstOrDefault(x => x.UnitID == ID);
                            if (objOUNT != null)
                            {
                                txtNo.Text = objOUNT.UnitID.ToString();
                                txtName.Text = objOUNT.UnitName;
                                chkIsActive.Checked = objOUNT.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOUNT.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOUNT.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOUNT.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOUNT.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOUNT.UnitID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OCRY")
                        {
                            var objOCRY = ctx.OCRies.FirstOrDefault(x => x.CountryID == ID);
                            if (objOCRY != null)
                            {
                                txtNo.Text = objOCRY.CountryID.ToString();
                                txtName.Text = objOCRY.CountryName;
                                chkIsActive.Checked = objOCRY.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOCRY.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOCRY.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOCRY.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOCRY.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOCRY.CountryID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OCST")
                        {
                            var objOCST = ctx.OCSTs.FirstOrDefault(x => x.StateID == ID);
                            if (objOCST != null)
                            {
                                txtNo.Text = objOCST.StateID.ToString();
                                txtName.Text = objOCST.StateName;
                                ddlMst.SelectedValue = objOCST.CountryID.ToString();
                                chkIsActive.Checked = objOCST.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOCST.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOCST.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOCST.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOCST.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOCST.StateID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OCTY")
                        {
                            var objOCTY = ctx.OCTies.FirstOrDefault(x => x.CityID == ID);
                            if (objOCTY != null)
                            {
                                txtNo.Text = objOCTY.CityID.ToString();
                                txtName.Text = objOCTY.CityName;
                                ddlMst.SelectedValue = objOCTY.StateID.ToString();
                                chkIsActive.Checked = objOCTY.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOCTY.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOCTY.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOCTY.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOCTY.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOCTY.CityID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OFTP")
                        {
                            var objOFTP = ctx.OFTPs.FirstOrDefault(x => x.TypeID == ID);
                            if (objOFTP != null)
                            {
                                txtNo.Text = objOFTP.TypeID.ToString();
                                txtName.Text = objOFTP.TypeName;
                                chkIsActive.Checked = objOFTP.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOFTP.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOFTP.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOFTP.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOFTP.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOFTP.TypeID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "ORLN")
                        {
                            var objORLN = ctx.ORLNs.FirstOrDefault(x => x.RelationID == ID);
                            if (objORLN != null)
                            {
                                txtNo.Text = objORLN.RelationID.ToString();
                                txtName.Text = objORLN.RelationName;
                                chkIsActive.Checked = objORLN.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objORLN.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objORLN.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objORLN.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objORLN.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objORLN.RelationID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "CGRP")
                        {
                            var objCGRP = ctx.CGRPs.FirstOrDefault(x => x.CustGroupID == ID);
                            if (objCGRP != null)
                            {
                                txtNo.Text = objCGRP.CustGroupID.ToString();
                                txtName.Text = objCGRP.CustGroupName;
                                ddlMst.SelectedValue = objCGRP.Type.ToString();
                                ddlPriceList.SelectedValue = objCGRP.PriceListID.ToString();
                                chkIsActive.Checked = objCGRP.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objCGRP.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objCGRP.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objCGRP.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objCGRP.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objCGRP.CustGroupID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OITG")
                        {
                            var objOITG = ctx.OITGs.FirstOrDefault(x => x.ItemSubGroupID == ID);
                            if (objOITG != null)
                            {
                                txtNo.Text = objOITG.ItemSubGroupID.ToString();
                                txtName.Text = objOITG.ItemSubGroupName;
                                ddlMst.SelectedValue = objOITG.ItemGroupID.ToString();
                                chkIsActive.Checked = objOITG.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOITG.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOITG.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOITG.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOITG.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOITG.ItemSubGroupID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OQUS")
                        {
                            var objOQUS = ctx.OQUS.FirstOrDefault(x => x.QuesID == ID && x.ParentID == ParentID);
                            if (objOQUS != null)
                            {
                                txtNo.Text = objOQUS.QuesID.ToString();
                                txtName.Text = objOQUS.QuesName;
                                if (ddlType.Items.FindByValue(objOQUS.Type) != null)
                                    ddlType.SelectedValue = objOQUS.Type;
                                if (ddlDocType.Items.FindByValue(objOQUS.DocType) != null)
                                    ddlDocType.SelectedValue = objOQUS.DocType;
                                if (ddlDocType.SelectedValue == "C")
                                {
                                    ddlCampaign.SelectedValue = objOQUS.CampaignID.Value.ToString();
                                    ddlDocType_SelectedIndexChanged(ddlDocType, EventArgs.Empty);
                                }
                                chkIsActive.Checked = objOQUS.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOQUS.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOQUS.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOQUS.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOQUS.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOQUS.QuesID;
                                ddlDocType_SelectedIndexChanged(ddlDocType.SelectedValue, EventArgs.Empty);
                            }
                        }
                        else if (ddlModule.SelectedValue == "OGRP")
                        {
                            var objOGRP = ctx.OGRPs.FirstOrDefault(x => x.EmpGroupID == ID && x.ParentID == ParentID);
                            if (objOGRP != null)
                            {
                                txtNo.Text = objOGRP.EmpGroupID.ToString();
                                txtName.Text = objOGRP.EmpGroupName;
                                chkIsActive.Checked = objOGRP.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOGRP.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOGRP.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOGRP.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOGRP.UpdatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtEmpSortOrder.Text = objOGRP.SortOrder.ToString();
                                ViewState["MstID"] = objOGRP.EmpGroupID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OEXT")
                        {
                            var objOEXT = ctx.OEXTs.FirstOrDefault(x => x.ExpTypeID == ID);
                            if (objOEXT != null)
                            {
                                txtNo.Text = objOEXT.ExpTypeID.ToString();
                                txtName.Text = objOEXT.ExpType;
                                chkIsActive.Checked = objOEXT.Active;
                                ddlexptype.SelectedValue = objOEXT.Notes;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOEXT.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOEXT.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOEXT.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOEXT.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOEXT.ExpTypeID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "ORSN")
                        {
                            var objORSN = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ID);
                            if (objORSN != null)
                            {
                                txtNo.Text = objORSN.ReasonID.ToString();
                                txtExName.Text = objORSN.SAPReasonItemCode;
                                txtName.Text = objORSN.ReasonName;
                                ddlResType.SelectedValue = objORSN.Type;
                                chkIsActive.Checked = objORSN.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objORSN.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objORSN.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objORSN.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objORSN.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objORSN.ReasonID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OASTU")
                        {
                            var objOASTU = ctx.OASTUs.FirstOrDefault(x => x.AssetStatusID == ID);
                            if (objOASTU != null)
                            {
                                txtNo.Text = objOASTU.AssetStatusID.ToString();
                                txtName.Text = objOASTU.AssetStatusName;
                                chkIsActive.Checked = objOASTU.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOASTU.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOASTU.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOASTU.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOASTU.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOASTU.AssetStatusID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OASTG")
                        {
                            var objOASTG = ctx.OASTGs.FirstOrDefault(x => x.AssetGroupID == ID);
                            if (objOASTG != null)
                            {
                                txtNo.Text = objOASTG.AssetGroupID.ToString();
                                txtName.Text = objOASTG.AssetGroupName;
                                chkIsActive.Checked = objOASTG.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOASTG.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOASTG.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOASTG.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOASTG.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOASTG.AssetGroupID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OASTY")
                        {
                            var objOASTY = ctx.OASTies.FirstOrDefault(x => x.AssetTypeID == ID);
                            if (objOASTY != null)
                            {
                                txtNo.Text = objOASTY.AssetTypeID.ToString();
                                txtName.Text = objOASTY.AssetTypeName;
                                chkIsActive.Checked = objOASTY.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOASTY.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOASTY.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOASTY.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOASTY.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOASTY.AssetTypeID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OEXM")
                        {
                            var objOEXM = ctx.OEXMs.FirstOrDefault(x => x.ExpModeID == ID);
                            if (objOEXM != null)
                            {
                                txtNo.Text = objOEXM.ExpModeID.ToString();
                                txtName.Text = objOEXM.ExpMode;
                                ddlMst.SelectedValue = objOEXM.ExpTypeID.ToString();
                                chkIsActive.Checked = objOEXM.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOEXM.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOEXM.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOEXM.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOEXM.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOEXM.ExpModeID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OASTC")
                        {
                            var objOASTC = ctx.OASTCs.FirstOrDefault(x => x.AssetConditionID == ID);
                            if (objOASTC != null)
                            {
                                txtNo.Text = objOASTC.AssetConditionID.ToString();
                                txtName.Text = objOASTC.AssetConditionName;
                                chkIsActive.Checked = objOASTC.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOASTC.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOASTC.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOASTC.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOASTC.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOASTC.AssetConditionID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OASTYB")
                        {
                            var objOASTYB = ctx.OASTYBs.FirstOrDefault(x => x.AssetSubTypeID == ID);
                            if (objOASTYB != null)
                            {
                                txtNo.Text = objOASTYB.AssetSubTypeID.ToString();
                                txtName.Text = objOASTYB.AssetSubTypeName;
                                ddlMst.SelectedValue = objOASTYB.AssetTypeID.ToString();
                                chkIsActive.Checked = objOASTYB.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOASTYB.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOASTYB.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOASTYB.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOASTYB.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOASTYB.AssetSubTypeID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OASTB")
                        {
                            var objOASTB = ctx.OASTBs.FirstOrDefault(x => x.AssetBrandID == ID);
                            if (objOASTB != null)
                            {
                                txtNo.Text = objOASTB.AssetBrandID.ToString();
                                txtName.Text = objOASTB.AssetBrandName;
                                ddlMst.SelectedValue = objOASTB.AssetSizeID.ToString();
                                chkIsActive.Checked = objOASTB.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOASTB.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOASTB.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOASTB.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOASTB.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOASTB.AssetBrandID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OASTZ")
                        {
                            var objOASTZ = ctx.OASTZs.FirstOrDefault(x => x.AssetSizeID == ID);
                            if (objOASTZ != null)
                            {
                                txtNo.Text = objOASTZ.AssetSizeID.ToString();
                                ddlMst.SelectedValue = objOASTZ.AssetSubTypeID.ToString();
                                txtName.Text = objOASTZ.AssetSizeName;
                                chkIsActive.Checked = objOASTZ.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOASTZ.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOASTZ.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOASTZ.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOASTZ.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOASTZ.AssetSizeID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OPLT")
                        {
                            var objOPLT = ctx.OPLTs.FirstOrDefault(x => x.PlantID == ID);
                            if (objOPLT != null)
                            {
                                txtNo.Text = objOPLT.PlantID.ToString();
                                txtName.Text = objOPLT.PlantName;
                                txtCode.Text = objOPLT.PlantCode;
                                //ddlMst.SelectedValue = objOPLT.RegionID.ToString();
                                chkIsActive.Checked = objOPLT.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOPLT.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOPLT.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOPLT.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOPLT.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                //ViewState["MstID"] = objOPLT.RegionID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OPIN")
                        {
                            var objOPIN = ctx.OPINs.FirstOrDefault(x => x.PinCodeID == ID);
                            if (objOPIN != null)
                            {
                                txtNo.Text = objOPIN.PinCodeID.ToString();
                                txtName.Text = objOPIN.PinCodeID.ToString();
                                txtCode.Text = objOPIN.Area;
                                chkIsActive.Checked = objOPIN.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOPIN.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOPIN.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOPIN.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOPIN.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOPIN.PinCodeID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OTRSN")
                        {
                            var objOTRSN = ctx.OTRSNs.FirstOrDefault(x => x.TaskReasonID == ID);
                            if (objOTRSN != null)
                            {
                                txtNo.Text = objOTRSN.TaskReasonID.ToString();
                                txtName.Text = objOTRSN.TaskReasonName.ToString();
                                txtCode.Text = objOTRSN.TaskReasonID.ToString();
                                chkIsActive.Checked = objOTRSN.Active;
                                ddlTaskReason.SelectedValue = objOTRSN.ReasonType.ToString();

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOTRSN.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOTRSN.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOTRSN.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOTRSN.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOTRSN.TaskReasonID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OPLCK")
                        {
                            var objOPLCK = ctx.OPLCKs.FirstOrDefault(x => x.ProblemCheckID == ID);
                            if (objOPLCK != null)
                            {
                                txtNo.Text = objOPLCK.ProblemCheckID.ToString();
                                txtName.Text = objOPLCK.CheckPointTask.ToString();
                                txtCode.Text = objOPLCK.ProblemCheckID.ToString();
                                chkIsActive.Checked = objOPLCK.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOPLCK.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOPLCK.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOPLCK.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOPLCK.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOPLCK.ProblemCheckID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OTTY")
                        {
                            var objOTTY = ctx.OTTies.FirstOrDefault(x => x.TaskTypeID == ID);
                            if (objOTTY != null)
                            {
                                txtNo.Text = objOTTY.TaskTypeID.ToString();
                                txtName.Text = objOTTY.TaskTypeName.ToString();
                                txtCode.Text = objOTTY.TaskTypeCode;
                                chkIsActive.Checked = objOTTY.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOTTY.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOTTY.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOTTY.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOTTY.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOTTY.TaskTypeID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OPLM")
                        {
                            var objOPLM = ctx.OPLMs.FirstOrDefault(x => x.ProblemID == ID && x.TaskTypeID == 2);
                            if (objOPLM != null)
                            {
                                txtNo.Text = objOPLM.ProblemID.ToString();
                                txtName.Text = objOPLM.ProbemName.ToString();
                                txtCode.Text = objOPLM.ProblemID.ToString();
                                chkIsActive.Checked = objOPLM.Active;
                                ddlTaskType.SelectedValue = objOPLM.TaskTypeID.ToString();
                                txtInMins.Text = objOPLM.InCityMins.ToString();
                                txtOutMins.Text = objOPLM.OutCityMins.ToString();

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOPLM.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOPLM.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOPLM.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOPLM.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOPLM.ProblemID;
                            }
                        }
                        else if (ddlModule.SelectedValue == "OTCF")
                        {
                            var objOTCF = ctx.OTCFs.FirstOrDefault(x => x.TaskCreatedFromID == ID);
                            if (objOTCF != null)
                            {
                                txtNo.Text = objOTCF.TaskCreatedFromID.ToString();
                                txtName.Text = objOTCF.TaskCreatedFrom.ToString();
                                txtCode.Text = objOTCF.TaskCreatedFromID.ToString();
                                chkIsActive.Checked = objOTCF.Active;

                                txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOTCF.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtCreatedTime.Text = objOTCF.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                                txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOTCF.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                                txtUpdatedTime.Text = objOTCF.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                                ViewState["MstID"] = objOTCF.TaskCreatedFromID;
                            }
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper data!',3);", true);
                            ClearAllInputs();
                        }
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "ModelMsg", "ModelMsg('Select proper data!',3);", true);
                    ClearAllInputs();
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper data!',3);", true);
                ClearAllInputs();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtName.Focus();
    }

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        try
        {
            ClearAllInputs();

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion

    #region Dropdown Events

    protected void ddlModule_SelectedIndexChanged(object sender, EventArgs e)
    {
        // ClearAllInputs();
        lblName.Text = "Name";
        lblPriceList.Visible = ddlPriceList.Visible = afuBannerPhoto.Visible = lblBannerPhoto.Visible = lblItemGroupSubGroupPhoto.Visible = afuItemGroupSubGroupPhoto.Visible =
            lblMst.Visible = ddlMst.Visible = lblDoctype.Visible = ddlDocType.Visible = lblType.Visible = ddlType.Visible = lblCampaign.Visible = ddlCampaign.Visible =
            lblExName.Visible = lblGrpSort.Visible = txtEmpSortOrder.Visible = txtExName.Visible = lblCode.Visible = txtCode.Visible = ddlexptype.Visible = lblexptype.Visible = ddlResType.Visible = lblResType.Visible = ddlTaskReason.Visible = lblTaskReason.Visible =
            lblInMins.Visible = txtInMins.Visible = lblOutMins.Visible = txtOutMins.Visible = ddlTaskType.Visible = lblTaskType.Visible = ddlEGroup.Visible = lblEmpGroup.Visible = lblProbType.Visible = ddlProbType.Visible = false;
        ACEtxtName.ContextKey = ddlModule.SelectedValue;
        txtNo.Text = txtName.Text = txtCode.Text = txtExName.Text = txtEmpSortOrder.Text = "";
        txtName.MaxLength = 500;
        txtName.Attributes.Remove("onkeypress");

        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (ddlModule.SelectedValue == "OCST")
            {
                lblMst.Visible = ddlMst.Visible = true;
                lblMst.Text = "Country";
                var MData = ctx.OCRies.Where(x => x.Active).ToList();
                ddlMst.DataSource = MData;
                ddlMst.DataValueField = "CountryID";
                ddlMst.DataTextField = "CountryName";
                ddlMst.DataBind();
            }
            else if (ddlModule.SelectedValue == "OCTY")
            {
                lblMst.Visible = ddlMst.Visible = true;
                lblMst.Text = "State";
                var MData = ctx.OCSTs.Where(x => x.Active).ToList();
                ddlMst.DataSource = MData;
                ddlMst.DataValueField = "StateID";
                ddlMst.DataTextField = "StateName";
                ddlMst.DataBind();
            }
            else if (ddlModule.SelectedValue == "CGRP")
            {
                lblMst.Visible = ddlMst.Visible = true;
                lblPriceList.Visible = ddlPriceList.Visible = true;
                lblMst.Text = "Type";
                ddlMst.Items.Clear();
                ddlMst.Items.Add(new ListItem("Company", "1"));
                ddlMst.Items.Add(new ListItem("Outlet", "2"));
                ddlMst.Items.Add(new ListItem("Customer", "3"));
            }
            else if (ddlModule.SelectedValue == "OITG")
            {
                lblMst.Visible = ddlMst.Visible = afuItemGroupSubGroupPhoto.Visible = lblItemGroupSubGroupPhoto.Visible = true;
                lblItemGroupSubGroupPhoto.Text = "SubGroup Image";
                lblMst.Text = "Item Group";
                var MData = ctx.OITBs.OrderBy(x => x.SortOrder).ToList();
                ddlMst.DataSource = MData;
                ddlMst.DataValueField = "ItemGroupID";
                ddlMst.DataTextField = "ItemGroupName";
                ddlMst.DataBind();
            }
            else if (ddlModule.SelectedValue == "OITB")
            {
                afuItemGroupSubGroupPhoto.Visible = afuBannerPhoto.Visible = lblItemGroupSubGroupPhoto.Visible = lblBannerPhoto.Visible = true;
                lblItemGroupSubGroupPhoto.Text = "Group Image";
            }
            else if (ddlModule.SelectedValue == "OGRP")
            {
                lblGrpSort.Visible = txtEmpSortOrder.Visible = true;
            }
            else if (ddlModule.SelectedValue == "OIMG")
            {
                afuBannerPhoto.Visible = lblBannerPhoto.Visible = true;
            }
            else if (ddlModule.SelectedValue == "OQUS")
            {
                ddlType.SelectedValue = ddlDocType.SelectedValue = ddlCampaign.SelectedValue = "0";
                lblDoctype.Visible = ddlDocType.Visible = lblType.Visible = ddlType.Visible = true;
            }
            else if (ddlModule.SelectedValue == "OFTP")
            {
                lblExName.Visible = txtExName.Visible = true;
                lblExName.Text = "Food Sort Name";
            }
            else if (ddlModule.SelectedValue == "ORSN")
            {
                lblResType.Visible = ddlResType.Visible = true;
                lblExName.Visible = txtExName.Visible = true;
                lblExName.Text = "SAP Reason Item";
            }
            else if (ddlModule.SelectedValue == "OASTYB")
            {
                lblMst.Visible = ddlMst.Visible = true;
                lblMst.Text = "Asset Type";
                var Mdata = ctx.OASTies.Where(x => x.Active).OrderBy(x => x.AssetTypeName).ToList();
                ddlMst.DataSource = Mdata;
                ddlMst.DataValueField = "AssetTypeID";
                ddlMst.DataTextField = "AssetTypeName";
                ddlMst.DataBind();
            }
            else if (ddlModule.SelectedValue == "OEXT")
            {
                lblexptype.Visible = ddlexptype.Visible = true;
            }
            else if (ddlModule.SelectedValue == "OEXM")
            {
                lblMst.Visible = ddlMst.Visible = true;
                lblMst.Text = "Expense Type";
                var Mdata = ctx.OEXTs.Where(x => x.Active).OrderBy(x => x.ExpType).ToList();
                ddlMst.DataSource = Mdata;
                ddlMst.DataValueField = "ExpTypeID";
                ddlMst.DataTextField = "ExpType";
                ddlMst.DataBind();
            }
            else if (ddlModule.SelectedValue == "OASTZ")
            {
                lblMst.Visible = ddlMst.Visible = true;
                lblMst.Text = "Asset Sub Type";
                var Mdata = ctx.OASTYBs.Where(x => x.Active).Select(x => new { AssetSubTypeID = x.AssetSubTypeID, AssetSubTypeName = x.AssetSubTypeName + " - " + x.OASTY.AssetTypeName }).OrderBy(x => x.AssetSubTypeName).ToList();
                ddlMst.DataSource = Mdata;
                ddlMst.DataValueField = "AssetSubTypeID";
                ddlMst.DataTextField = "AssetSubTypeName";
                ddlMst.DataBind();
            }
            else if (ddlModule.SelectedValue == "OASTB")
            {
                lblMst.Visible = ddlMst.Visible = true;
                lblMst.Text = "Asset Size";
                var Mdata = ctx.OASTZs.Where(x => x.Active).Select(x => new { AssetSizeID = x.AssetSizeID, AssetSizeName = x.AssetSizeName + " - " + x.OASTYB.AssetSubTypeName }).OrderBy(x => x.AssetSizeName).ToList();
                ddlMst.DataSource = Mdata;
                ddlMst.DataValueField = "AssetSizeID";
                ddlMst.DataTextField = "AssetSizeName";
                ddlMst.DataBind();
            }
            else if (ddlModule.SelectedValue == "OPIN")
            {
                lblName.Text = "PinCode";
                lblCode.Visible = txtCode.Visible = true;
                lblCode.Text = "Area";
                txtName.MaxLength = 6;
                txtName.Attributes.Add("onkeypress", "return isNumberKey(event);");
            }
            else if (ddlModule.SelectedValue == "OTRSN")
            {
                lblName.Text = "Task Reasons";
                ddlTaskReason.Visible = lblTaskReason.Visible = true;
            }
            else if (ddlModule.SelectedValue == "OTCF")
            {
                lblName.Text = "Task Created Source";
            }
            else if (ddlModule.SelectedValue == "OTTY")
            {
                lblName.Text = "Task Type";
            }
            else if (ddlModule.SelectedValue == "OPLM")
            {
                lblName.Text = "Task Problem Type";
                lblInMins.Visible = txtInMins.Visible = lblOutMins.Visible = txtOutMins.Visible = ddlTaskType.Visible = lblTaskType.Visible = true;
            }
            else if (ddlModule.SelectedValue == "OPLCK")
            {
                lblName.Text = "Task Problem Type";
                //lblEmpGroup.Visible = ddlEGroup.Visible = lblProbType.Visible = ddlProbType.Visible = true;
            }
        }
    }

    protected void ddlDocType_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlDocType.SelectedValue == "F")
        {
            lblType.Visible = ddlType.Visible = true;
            ddlType.SelectedValue = "0";
        }
        else
        {
            lblType.Visible = ddlType.Visible = false;
            ddlType.SelectedValue = "O";
        }

        ddlMst.Focus();
    }

    #endregion

    #region ImageUpload Event

    protected void afuBannerPhoto_UploadedComplete(object sender, AjaxControlToolkit.AsyncFileUploadEventArgs e)
    {
        try
        {
            if (afuBannerPhoto != null && afuBannerPhoto.HasFile)
            {
                System.IO.FileInfo f = new FileInfo(afuBannerPhoto.PostedFile.FileName);
                if (Int32.Parse(e.FileSize) > 1024000)
                {
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('File size is greater than 1MB!',3);", true);
                    return;
                }
                if ((f.Extension.ToLower() == ".jpg") || (f.Extension.ToLower() == ".png") || (f.Extension.ToLower() == ".gif") || (f.Extension.ToLower() == ".jpeg"))
                {
                    string newFile;
                    if (ddlModule.SelectedValue == "OITB")
                        newFile = Guid.NewGuid().ToString("N") + Path.GetExtension(afuBannerPhoto.FileName);
                    else
                        newFile = txtName.Text + Path.GetExtension(afuBannerPhoto.FileName);
                    Session["BannerPhotoFileName"] = newFile;
                    afuBannerPhoto.PostedFile.SaveAs(TempPath + newFile);
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
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void afuItemGroupSubGroupPhoto_UploadedComplete(object sender, AjaxControlToolkit.AsyncFileUploadEventArgs e)
    {
        try
        {
            if (afuItemGroupSubGroupPhoto != null && afuItemGroupSubGroupPhoto.HasFile)
            {
                System.IO.FileInfo f = new FileInfo(afuItemGroupSubGroupPhoto.PostedFile.FileName);
                if (Int32.Parse(e.FileSize) > 1024000)
                {
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('File size is greater than 1MB!',3);", true);
                    return;
                }
                if ((f.Extension.ToLower() == ".jpg") || (f.Extension.ToLower() == ".png") || (f.Extension.ToLower() == ".gif") || (f.Extension.ToLower() == ".jpeg"))
                {
                    string newFile = Guid.NewGuid().ToString("N") + Path.GetExtension(afuItemGroupSubGroupPhoto.FileName);
                    Session["ItemGroupSubGroupPhotoFileName"] = newFile;
                    afuItemGroupSubGroupPhoto.PostedFile.SaveAs(TempPath + newFile);
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
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion
}