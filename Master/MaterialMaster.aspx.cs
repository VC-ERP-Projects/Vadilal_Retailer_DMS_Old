using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Transactions;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_MaterialMaster : System.Web.UI.Page
{
    #region Declaration

    DDMSEntities ctx;
    protected String AuthType;
    protected int UserID;
    protected int MenuID;
    protected decimal ParentID;
    String TempPath = Path.GetTempPath();

    private List<ITM1> ITM1s
    {
        get { return this.ViewState["ITM1"] as List<ITM1>; }
        set { this.ViewState["ITM1"] = value; }
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
                MenuID = Auth.MenuID;
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
                        var unit = xml.Descendants("material_master");
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
            acettxtCode.Enabled = false;
            btnSubmit.Text = "Submit";
            txtCode.Style.Remove("background-color");
            txtCode.TextChanged -= txtCode_TextChanged;
            txtCode.AutoPostBack = false;
        }
        else
        {
            acettxtCode.Enabled = true;
            btnSubmit.Text = "Submit";
            txtCode.Style.Add("background-color", "rgb(250, 255, 189);");
            txtCode.TextChanged += txtCode_TextChanged;
            txtCode.AutoPostBack = true;
        }
        txtCode.Focus();

        chkIsActive.Checked = true;
        chkSellable.Checked = chkKOT.Checked = false;
        ddlManageBy.SelectedValue = "1";
        txtBarcode.Text = txtCode.Text = txtName.Text = txtIngrediance.Text = "";
        ddlGroup.SelectedValue = "0";

        var Data = ctx.OUNTs.Where(x => x.Active).ToList();
        rdblstUnits.DataSource = Data;
        rdblstUnits.DataBind();

        ITM1s = new List<ITM1>();
        gvItem.DataSource = ITM1s;
        gvItem.DataBind();
        ViewState["ITEMID"] = null;

        alink.HRef = imgMaterial.ImageUrl = "~/Images/no.jpg";
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "$.cookie('MaterialMaster', 'tabs-1');", true);
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ctx = new DDMSEntities();
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            int Bflag = 0, Uflag = 0;
            if (Page.IsValid)
            {
                if (gvItem.Rows.Count == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You must have map at least one unit.',3);", true);
                    return;
                }

                foreach (GridViewRow item in gvItem.Rows)
                {
                    DropDownList ddlUnit = (DropDownList)item.FindControl("ddlUnit");
                    HtmlInputRadioButton rdbCheck = (HtmlInputRadioButton)item.FindControl("rdbCheck");
                    HtmlInputCheckBox chkActive = (HtmlInputCheckBox)item.FindControl("chkActive");
                    if (chkActive.Checked)
                    {
                        if (rdbCheck.Checked)
                            Bflag += 1;

                        if (ddlUnit.SelectedValue == "1" || ddlUnit.SelectedValue == "3")
                            Uflag += 1;
                    }
                }

                if (Bflag == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one base unit.',3);", true);
                    return;
                }

                if (Uflag > 1)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select only one sales unit.',3);", true);
                    return;
                }

                int IntNum = 0;
                Decimal DecNum = 0;
                int ItemID;
                OITM objOITM;
                if (ViewState["ITEMID"] != null && Int32.TryParse(ViewState["ITEMID"].ToString(), out ItemID))
                {
                    objOITM = ctx.OITMs.Include("ITM1").FirstOrDefault(x => x.ItemID == ItemID);
                    if (objOITM.ItemCode != txtCode.Text)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Item Code cannot be changed!',3);", true);
                        return;
                    }
                }
                else
                {
                    if (ctx.OITMs.Any(x => x.ItemCode == txtCode.Text))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Item Code is not allowed!',3);", true);
                        return;
                    }
                    objOITM = new OITM();
                    objOITM.ItemID = ctx.GetKey("OITM", "ItemID", "", 0, 0).FirstOrDefault().Value;
                    objOITM.ItemCode = txtCode.Text;
                    objOITM.CreatedDate = DateTime.Now;
                    objOITM.CreatedBy = UserID;
                    ctx.OITMs.Add(objOITM);
                }
                objOITM.ItemName = txtName.Text;
                objOITM.Date = DateTime.Now;
                objOITM.GroupID = Convert.ToInt32(ddlGroup.SelectedValue);
                if (Int32.TryParse(ddlSubGroup.SelectedValue, out IntNum))
                    objOITM.SubGroupID = IntNum;
                objOITM.ManagedBy = Convert.ToInt32(ddlManageBy.SelectedValue);
                objOITM.Type = Convert.ToInt32(ddlType.SelectedValue);
                objOITM.BarCode = txtBarcode.Text;
                objOITM.Ingredients = txtIngrediance.Text;
                objOITM.IsSellable = chkSellable.Checked;
                objOITM.IsKOT = chkKOT.Checked;
                objOITM.Active = chkIsActive.Checked;
                objOITM.UpdatedDate = DateTime.Now;
                objOITM.UpdatedBy = UserID;

                if (Session["MatPhotoFileName"] != null)
                {
                    string FileName = Session["MatPhotoFileName"].ToString();
                    string SavePath = Path.Combine(Server.MapPath(Constant.MaterialPhoto), FileName);
                    string SourcePath = TempPath + FileName;
                    File.Copy(SourcePath, SavePath);

                    if (!String.IsNullOrEmpty(objOITM.Image) && File.Exists(Constant.MaterialPhoto + objOITM.Image))
                        File.Delete(Constant.MaterialPhoto + objOITM.Image);

                    objOITM.Image = FileName;
                    Session["MatPhotoFileName"] = null;
                }


                int Count = ctx.GetKey("ITM1", "ItemMunitID", "", 0, 0).FirstOrDefault().Value;

                int? UnitItemID = null;
                ITM1 objITM1;

                objOITM.ITM1.ToList().ForEach(x => ctx.ITM1.Remove(x));

                foreach (GridViewRow item in gvItem.Rows)
                {
                    Label lblUnitID = (Label)item.FindControl("lblUnitID");
                    HtmlInputCheckBox chkActive = (HtmlInputCheckBox)item.FindControl("chkActive");
                    if (Int32.TryParse(lblUnitID.Text, out IntNum) && chkActive.Checked)
                    {
                        DropDownList ddlUnit = (DropDownList)item.FindControl("ddlUnit");
                        HtmlInputRadioButton rdbCheck = (HtmlInputRadioButton)item.FindControl("rdbCheck");

                        TextBox txtItemName = (TextBox)item.FindControl("txtItemName");
                        if (!String.IsNullOrEmpty(txtItemName.Text) && txtItemName.Text.Split("-".ToArray()).Length == 2)
                            UnitItemID = Convert.ToInt32(txtItemName.Text.Split("-".ToArray()).First());
                        else
                            UnitItemID = null;

                        TextBox txtPacket = (TextBox)item.FindControl("txtPacket");
                        TextBox txtPrice1 = (TextBox)item.FindControl("txtPrice");

                        objITM1 = objOITM.ITM1.FirstOrDefault(x => x.UnitID == IntNum && x.UnitItemID == UnitItemID);
                        if (objITM1 == null)
                        {
                            objITM1 = new ITM1();
                            objITM1.UnitID = IntNum;
                            objITM1.UnitItemID = UnitItemID;
                            objITM1.ItemMunitID = Count++;
                            objOITM.ITM1.Add(objITM1);
                        }
                        objITM1.IsBaseUnit = rdbCheck.Checked;
                        objITM1.Active = chkActive.Checked;
                        objITM1.UnitType = Int32.TryParse(ddlUnit.SelectedValue, out IntNum) ? IntNum : 0;
                        objITM1.Currency = Constant.Currency;
                        objITM1.Quantity = Decimal.TryParse(txtPacket.Text, out DecNum) ? DecNum : 0;
                        objITM1.Price = Decimal.TryParse(txtPrice1.Text, out DecNum) ? DecNum : 0;
                    }
                }
                ctx.SaveChanges();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record Submitted Successfully : " + objOITM.ItemCode + "',1);", true);
                ClearAllInputs();
            }
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

    #endregion

    #region Change Event

    protected void txtCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && !string.IsNullOrEmpty(txtCode.Text))
            {
                var word = txtCode.Text.Split("-".ToArray()).First().Trim();
                var objOITM = ctx.OITMs.Include("ITM1").FirstOrDefault(x => x.ItemCode == word);
                if (objOITM != null)
                {
                    ViewState["ITEMID"] = objOITM.ItemID;
                    txtCode.Text = objOITM.ItemCode;
                    txtName.Text = objOITM.ItemName;
                    ddlGroup.SelectedValue = objOITM.GroupID.ToString();
                    if (objOITM.SubGroupID.HasValue)
                    {
                        ddlSubGroup.DataBind();
                        ddlSubGroup.SelectedValue = objOITM.SubGroupID.ToString();
                    }
                    ddlManageBy.SelectedValue = objOITM.ManagedBy.ToString();
                    ddlType.SelectedValue = objOITM.Type.ToString();
                    txtBarcode.Text = objOITM.BarCode;
                    txtIngrediance.Text = objOITM.Ingredients;
                    chkSellable.Checked = objOITM.IsSellable;
                    chkKOT.Checked = objOITM.IsKOT;
                    chkIsActive.Checked = objOITM.Active;

                    if (!String.IsNullOrEmpty(objOITM.Image))
                        alink.HRef = imgMaterial.ImageUrl = Constant.MaterialPhoto + objOITM.Image;
                    else
                        alink.HRef = imgMaterial.ImageUrl = "~/Images/no.jpg";

                    ITM1s = objOITM.ITM1.ToList();
                    if (ITM1s.Any(x => x.IsBaseUnit))
                        rdblstUnits.Items.FindByValue(ITM1s.FirstOrDefault(x => x.IsBaseUnit).UnitID.ToString()).Selected = true;
                    gvItem.DataSource = ITM1s;
                    gvItem.DataBind();
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper Item name!',3);", true);
                    ClearAllInputs();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtCode.Focus();
    }

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    #endregion

    protected void btnBindUnit_Click(object sender, EventArgs e)
    {
        int IntNum;
        Decimal DecNum;
        ITM1 objITM1;
        if (ITM1s == null) ITM1s = new List<ITM1>();
        if (rdblstUnits.SelectedItem != null)
        {
            IntNum = Convert.ToInt32(rdblstUnits.SelectedItem.Value);

            var temp = new ITM1();
            temp.UnitID = IntNum;
            temp.OUNT = ctx.OUNTs.FirstOrDefault(x => x.UnitID == IntNum);
            temp.UnitType = 0;
            temp.Active = true;
            ITM1s.Add(temp);
            foreach (GridViewRow item in gvItem.Rows)
            {
                objITM1 = ITM1s[item.RowIndex];
                DropDownList ddlUnit = (DropDownList)item.FindControl("ddlUnit");
                HtmlInputCheckBox chkActive = (HtmlInputCheckBox)item.FindControl("chkActive");
                HtmlInputRadioButton rdbCheck = (HtmlInputRadioButton)item.FindControl("rdbCheck");

                TextBox txtPacket = (TextBox)item.FindControl("txtPacket");
                TextBox txtPrice1 = (TextBox)item.FindControl("txtPrice");

                objITM1.IsBaseUnit = rdbCheck.Checked;
                objITM1.Active = chkActive.Checked;
                objITM1.UnitType = Int32.TryParse(ddlUnit.SelectedValue, out IntNum) ? IntNum : 0;
                objITM1.Currency = Constant.Currency;
                objITM1.Quantity = Decimal.TryParse(txtPacket.Text, out DecNum) ? DecNum : 0;
                objITM1.Price = Decimal.TryParse(txtPrice1.Text, out DecNum) ? DecNum : 0;
            }
            gvItem.DataSource = ITM1s;
            gvItem.DataBind();
        }
        else
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select any unit.',3);", true);
            return;
        }

    }

    protected void gvItem_PreRender(object sender, EventArgs e)
    {
        if (gvItem.Rows.Count > 0)
        {
            gvItem.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvItem.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void txtItemName_TextChanged(object sender, EventArgs e)
    {
        TextBox txtItemName = (TextBox)sender;
        GridViewRow Currentgvr = (GridViewRow)txtItemName.NamingContainer;
        var IGs = txtItemName.Text.Split("-".ToArray());
        if (IGs.Length == 2)
        {
            string Code = IGs.First().Trim();
            OITM objOITM = ctx.OITMs.FirstOrDefault(x => x.ItemCode == Code);
            if (objOITM != null)
            {
                ITM1s[Currentgvr.RowIndex].UnitItemID = objOITM.ItemID;
                ITM1s[Currentgvr.RowIndex].OITM1 = objOITM;
            }
        }
        else
        {
            ITM1s[Currentgvr.RowIndex].UnitItemID = null;
            ITM1s[Currentgvr.RowIndex].OITM1 = null;
            txtItemName.Text = "";
        }

    }

    protected void gvItem_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            AutoCompleteExtender ACEtxtItemID = (AutoCompleteExtender)e.Row.FindControl("ACEtxtItemID");
            ACEtxtItemID.ContextKey = ParentID.ToString();
        }
    }

    protected void afuMaterialPhoto_UploadedComplete(object sender, AsyncFileUploadEventArgs e)
    {
        try
        {
            if (afuMaterialPhoto != null && afuMaterialPhoto.HasFile)
            {
                System.IO.FileInfo f = new FileInfo(afuMaterialPhoto.PostedFile.FileName);
                if (Int32.Parse(e.FileSize) > 1024000)
                {
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('File size is greater than 1MB!',3);", true);
                    return;
                }
                if ((f.Extension.ToLower() == ".jpg") || (f.Extension.ToLower() == ".png") || (f.Extension.ToLower() == ".gif") || (f.Extension.ToLower() == ".jpeg"))
                {
                    string newFile = Guid.NewGuid().ToString("N") + Path.GetExtension(afuMaterialPhoto.FileName);
                    Session["MatPhotoFileName"] = newFile;
                    afuMaterialPhoto.PostedFile.SaveAs(TempPath + newFile);

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
}