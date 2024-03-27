using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Objects.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_PriceListMaster : System.Web.UI.Page
{
    #region Declaration

    DDMSEntities ctx;
    protected String AuthType;
    protected int UserID;
    protected decimal ParentID;
    protected int PriceListID;
    string strtype;

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
                        var unit = xml.Descendants("pricelist_master");
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
            txtNo.Enabled = acettxtName.Enabled = false;
            btnSubmit.Text = "Submit";
            txtNo.Style.Remove("background-color");
            txtNo.Text = "Auto Generated";
            txtName.Focus();
        }
        else
        {
            txtNo.Enabled = acettxtName.Enabled = true;
            txtNo.Text = "";
            btnSubmit.Text = "Submit";
            txtNo.Style.Add("background-color", "rgb(250, 255, 189);");
            txtNo.Focus();
        }

        txtEffectiveDate.Text = Common.DateTimeConvert(DateTime.Now);
        txtName.Text = txtDescription.Text = txtBasePriceList.Text = "";
        ddlState.SelectedValue = ddlTax.SelectedValue = txtDiscount.Text = "0";
        chkIsActive.Checked = true;
        ViewState["PriceListID"] = null;

        var Query = (from t in ctx.ITM1.Include("OITM").Include("OUNT")
                     where t.Active && t.OITM.Active && t.UnitItemID == null && t.UnitType != 0 && ctx.ITM1.Any(x => x.ItemID == t.ItemID && x.IsBaseUnit)
                     orderby t.OITM.ItemName, t.IsBaseUnit descending, t.UnitID
                     select t).ToList();

        List<IPL1> Data = new List<IPL1>();
        foreach (ITM1 item in Query)
        {
            IPL1 temp = new IPL1();
            temp.ItemID = item.ItemID;
            temp.OITM = item.OITM;
            temp.UnitID = item.UnitID;
            temp.UnitPrice = item.Price;
            temp.OUNT = item.OUNT;
            temp.DiscountPer = 0;
            temp.DiscountAmt = 0;
            temp.SellPrice = 0;
            temp.TaxID = 0;
            Data.Add(temp);
        }
        gvItem.DataSource = Data;
        gvItem.DataBind();
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
            if (Page.IsValid)
            {
                OIPL objOIPL;
                int IntNum = 0;
                Decimal DecNum = 0;

                if (ViewState["PriceListID"] != null && Int32.TryParse(ViewState["PriceListID"].ToString(), out PriceListID))
                    objOIPL = ctx.OIPLs.FirstOrDefault(x => x.PriceListID == PriceListID);
                else
                {
                    objOIPL = new OIPL();
                    objOIPL.PriceListID = ctx.GetKey("OIPL", "PriceListID", "", 0, 0).FirstOrDefault().Value;
                    objOIPL.CreatedDate = DateTime.Now;
                    objOIPL.CreatedBy = UserID;
                    ctx.OIPLs.Add(objOIPL);
                }
                objOIPL.Name = txtName.Text;
                objOIPL.Notes = txtDescription.Text;
                objOIPL.Currency = Constant.Currency;
                objOIPL.StateID = Int32.TryParse(ddlState.SelectedValue, out IntNum) ? IntNum : 0;
                objOIPL.EffectiveDate = Common.DateTimeConvert(txtEffectiveDate.Text);
                objOIPL.Active = chkIsActive.Checked;
                objOIPL.UpdatedDate = DateTime.Now;
                objOIPL.UpdatedBy = UserID;

                int Count = ctx.GetKey("IPL1", "ItemPriceID", "", 0, 0).FirstOrDefault().Value;
                int ItemID;
                int UnitID;

                foreach (GridViewRow item in gvItem.Rows)
                {
                    Label lblItemID = (Label)item.FindControl("lblItemID");
                    Label lblUnitID = (Label)item.FindControl("lblUnitID");
                    TextBox txtPacketPrice = (TextBox)item.FindControl("txtPacketPrice");
                    TextBox txtDiscountPer = (TextBox)item.FindControl("txtDiscountPer");
                    TextBox txtDiscountAmt = (TextBox)item.FindControl("txtDiscountAmt");
                    TextBox txtSellPrice = (TextBox)item.FindControl("txtSellPrice");
                    DropDownList ddlTaxCode = (DropDownList)item.FindControl("ddlTaxCode");

                    ItemID = Int32.TryParse(lblItemID.Text, out IntNum) ? IntNum : 0;
                    UnitID = Int32.TryParse(lblUnitID.Text, out IntNum) ? IntNum : 0;

                    IPL1 objIPL1 = objOIPL.IPL1.FirstOrDefault(x => x.ItemID == ItemID && x.UnitID == UnitID);
                    if (objIPL1 == null)
                    {
                        objIPL1 = new IPL1();
                        objIPL1.ItemPriceID = Count++;
                        objIPL1.ItemID = ItemID;
                        objIPL1.UnitID = UnitID;
                        objOIPL.IPL1.Add(objIPL1);
                    }
                    objIPL1.UnitPrice = Decimal.TryParse(txtPacketPrice.Text, out DecNum) ? DecNum : 0;
                    objIPL1.DiscountPer = Decimal.TryParse(txtDiscountPer.Text, out DecNum) ? DecNum : 0;
                    objIPL1.DiscountAmt = Decimal.TryParse(txtDiscountAmt.Text, out DecNum) ? DecNum : 0;
                    objIPL1.SellPrice = Decimal.TryParse(txtSellPrice.Text, out DecNum) ? DecNum : 0;
                    objIPL1.TaxID = Int32.TryParse(ddlTaxCode.SelectedValue, out IntNum) ? IntNum : 0;
                }

                ctx.SaveChanges();
                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully : " + objOIPL.Name + "',1);", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter packet price!',3);", true);
            }

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

    protected void txtChangeEvent(object sender, EventArgs e)
    {
        try
        {
            TextBox txtQuantity = (TextBox)sender;

            if (String.IsNullOrEmpty(txtQuantity.Text))
                txtQuantity.Text = "0";

            GridViewRow Currentgvr = (GridViewRow)txtQuantity.NamingContainer;
            if (Currentgvr != null)
            {
                TextBox txtPacketPrice = (TextBox)Currentgvr.FindControl("txtPacketPrice");
                TextBox txtNotes = (TextBox)Currentgvr.FindControl("txtNotes");
                if (((System.Web.UI.Control)(sender)).ID == "txtPacketPrice")
                    txtNotes.Focus();
            }

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void txtNo_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && !string.IsNullOrEmpty(txtNo.Text))
            {
                var word = txtNo.Text.Split("-".ToArray()).First().Trim();
                int ID = Convert.ToInt32(word);
                var objOIPL = ctx.OIPLs.FirstOrDefault(x => x.PriceListID == ID);
                if (objOIPL != null)
                {
                    ViewState["PriceListID"] = objOIPL.PriceListID;
                    txtNo.Text = objOIPL.PriceListID.ToString();
                    txtName.Text = objOIPL.Name;
                    txtDescription.Text = objOIPL.Notes;
                    if (objOIPL.StateID.HasValue)
                        ddlState.SelectedValue = objOIPL.StateID.ToString();
                    txtEffectiveDate.Text = Common.DateTimeConvert(objOIPL.EffectiveDate);
                    chkIsActive.Checked = objOIPL.Active;


                    var Query = (from t in ctx.ITM1.Include("OITM").Include("OUNT")
                                 where t.Active && t.OITM.Active && t.UnitItemID == null && t.UnitType != 0 && ctx.ITM1.Any(x => x.ItemID == t.ItemID && x.IsBaseUnit)
                                 orderby t.OITM.ItemName, t.IsBaseUnit descending, t.UnitID
                                 select t).ToList();

                    List<IPL1> Data = new List<IPL1>();
                    var DbData = objOIPL.IPL1.ToList();
                    IPL1 Rec;
                    foreach (ITM1 item in Query)
                    {
                        IPL1 temp = new IPL1();
                        temp.ItemID = item.ItemID;
                        temp.OITM = item.OITM;
                        temp.UnitID = item.UnitID;
                        temp.OUNT = item.OUNT;
                        Rec = DbData.FirstOrDefault(x => x.ItemID == item.ItemID && x.UnitID == temp.UnitID);
                        if (Rec != null)
                        {
                            temp.DiscountPer = Rec.DiscountPer;
                            temp.DiscountAmt = Rec.DiscountAmt;
                            temp.SellPrice = Rec.SellPrice;
                            temp.TaxID = Rec.TaxID;
                            temp.UnitPrice = Rec.UnitPrice;
                        }
                        else
                        {
                            temp.UnitPrice = item.Price;
                            temp.DiscountPer = 0;
                            temp.DiscountAmt = 0;
                            temp.SellPrice = 0;
                            temp.TaxID = 0;
                        }
                        Data.Add(temp);
                    }

                    gvItem.DataSource = Data;
                    gvItem.DataBind();
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper price list',3);", true);
                    ClearAllInputs();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtName.Focus();
    }

    protected void txtBasePriceList_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!string.IsNullOrEmpty(txtBasePriceList.Text))
            {
                var word = txtBasePriceList.Text.Split("-".ToArray()).First().Trim();
                int ID = Convert.ToInt32(word);
                var objOIPL = ctx.OIPLs.FirstOrDefault(x => x.PriceListID == ID);
                if (objOIPL != null)
                {
                    var Query = (from t in ctx.ITM1.Include("OITM").Include("OITM.IPL1").Include("OUNT")
                                 where t.Active && t.OITM.Active && t.UnitItemID == null && t.UnitType != 0 && ctx.ITM1.Any(x => x.ItemID == t.ItemID && x.IsBaseUnit)
                                 orderby t.OITM.ItemName, t.IsBaseUnit descending, t.UnitID
                                 select t).ToList();

                    List<IPL1> Data = new List<IPL1>();
                    IPL1 objIPL1 = null;
                    foreach (ITM1 item in Query)
                    {
                        objIPL1 = item.OITM.IPL1.FirstOrDefault(x => x.PriceListID == objOIPL.PriceListID && x.ItemID == item.ItemID && x.UnitID == item.UnitID);

                        IPL1 temp = new IPL1();
                        temp.ItemID = item.ItemID;
                        temp.OITM = item.OITM;
                        temp.UnitID = item.UnitID;
                        temp.OUNT = item.OUNT;
                        if (objIPL1 != null)
                        {
                            temp.UnitPrice = objIPL1.UnitPrice;
                            temp.DiscountPer = objIPL1.DiscountPer;
                            temp.DiscountAmt = objIPL1.DiscountAmt;
                            temp.SellPrice = objIPL1.SellPrice;
                            temp.TaxID = objIPL1.TaxID;
                        }
                        Data.Add(temp);
                    }

                    gvItem.DataSource = Data;
                    gvItem.DataBind();
                }

                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper price list',3);", true);
                    ClearAllInputs();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtName.Focus();
    }

    #endregion

    #region GridEvents

    protected void gvItem_PreRender(object sender, EventArgs e)
    {
        if (gvItem.Rows.Count > 0)
        {
            gvItem.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvItem.FooterRow.TableSection = TableRowSection.TableFooter;
        }
        MergeRows(gvItem);
    }

    public static void MergeRows(GridView gridView)
    {
        for (int rowIndex = gridView.Rows.Count - 2; rowIndex >= 0; rowIndex--)
        {
            GridViewRow row = gridView.Rows[rowIndex];
            GridViewRow previousRow = gridView.Rows[rowIndex + 1];

            for (int i = 0; i < 2; i++)
            {
                if (row.Cells[i].Text == previousRow.Cells[i].Text)
                {
                    row.Cells[i].RowSpan = previousRow.Cells[i].RowSpan < 2 ? 2 : previousRow.Cells[i].RowSpan + 1;
                    previousRow.Cells[i].Visible = false;
                }
            }
        }
    }

    #endregion
}