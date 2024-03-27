using System;
using System.Collections.Generic;
using System.Linq;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Inventory_InventoryTransfer : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected int MenuID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

    #endregion

    #region Helper Method

    private void ClearAllInputs()
    {

        txtDocumentDate.Text = Common.DateTimeConvert(DateTime.Now);
        var DayCloseData = ctx.CheckDayClose(Common.DateTimeConvert(txtDocumentDate.Text), ParentID).FirstOrDefault();
        if (!String.IsNullOrEmpty(DayCloseData))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + DayCloseData + "',3);", true);
            btnSubmit.Visible = false;
            return;
        }
        else
        {
            btnSubmit.Visible = true;
        }
        var OWHS = ctx.OWHS.Where(x => x.Active == true && x.ParentID == ParentID).ToList();
        BindWarehouse(ddlFromWarehouse, OWHS.ToArray(), "WhsName", "WhsID");
        BindWarehouse(ddlToWarehouse, OWHS.ToArray(), "WhsName", "WhsID");
        ddlFromWarehouse.SelectedValue = "0";
        ddlToWarehouse.SelectedValue = "0";
        txtNotes.Text = "";
        gvItem.DataSource = null;
        gvItem.DataBind();
    }

    private void BindWarehouse(DropDownList ddl, Array Datasource, string TextField, string ValueField)
    {
        ddl.DataSource = Datasource;
        ddl.DataTextField = TextField;
        ddl.DataValueField = ValueField;
        ddl.DataBind();
        ddl.Items.Insert(0, new ListItem("---Select---", "0"));
    }

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
                        var unit = xml.Descendants("inventory_transfer");
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
        if (!IsPostBack)
        {
            ClearAllInputs();
            ddlFromWarehouse.Focus();
        }

    }

    #endregion

    #region Button Click

    protected void btnFullTransfer_Click(object sender, EventArgs e)
    {
        try
        {
            foreach (GridViewRow item in gvItem.Rows)
            {
                TextBox txtAvailQty = (TextBox)item.FindControl("txtAvailQty");
                TextBox txtEnterQty = (TextBox)item.FindControl("txtEnterQty");
                txtEnterQty.Text = txtAvailQty.Text;
            }
            ScriptManager.RegisterStartupScript(this, this.GetType(), "gettotal", "ChangeQuantity();", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Convert.ToInt32(ddlFromWarehouse.SelectedValue) == Convert.ToInt32(ddlToWarehouse.SelectedValue))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Warehouse is not allowed.',3); ChangeQuantity();", true);
                return;
            }

            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);

            int IntNum = 0;

            var INTF = new INTF();
            INTF.INTFID = ctx.GetKey("INTF", "INTFID", "", ParentID, 0).FirstOrDefault().Value;
            INTF.ParentID = ParentID;
            INTF.DocumentDate = Common.DateTimeConvert(txtDocumentDate.Text);
            INTF.TransferType = "G";
            INTF.FromWhsID = Convert.ToInt32(ddlFromWarehouse.SelectedValue);
            INTF.ToWhsID = Convert.ToInt32(ddlToWarehouse.SelectedValue);

            INTF.Notes = txtNotes.Text;

            INTF.CreatedDate = DateTime.Now;
            INTF.CreatedBy = UserID;
            INTF.UpdatedDate = DateTime.Now;
            INTF.UpdatedBy = UserID;

            ctx.INTFs.Add(INTF);

            Decimal TotalPacket = 0;
            int ItemID = 0;
            int Count = ctx.GetKey("NTF1", "NTF1ID", "", ParentID, 0).FirstOrDefault().Value;
            int CountG = ctx.GetKey("ITM2", "StockID", "", ParentID, 0).FirstOrDefault().Value;

            List<ITM2> FromITM2s = ctx.ITM2.Where(x => x.ParentID == ParentID && x.WhsID == INTF.FromWhsID).ToList();
            List<ITM2> ToITM2s = ctx.ITM2.Where(x => x.ParentID == ParentID && x.WhsID == INTF.ToWhsID).ToList();
            foreach (GridViewRow item in gvItem.Rows)
            {
                DropDownList ddlUnit = item.FindControl("ddlUnit") as DropDownList;
                Label lblItemID = (Label)item.FindControl("lblItemID");
                TextBox txtTotalQty = (TextBox)item.FindControl("txtTotalQty");

                if (Decimal.TryParse(txtTotalQty.Text, out TotalPacket) && TotalPacket > 0 && Int32.TryParse(lblItemID.Text, out ItemID) && ItemID > 0)
                {
                    TextBox txtEnterQty = (TextBox)item.FindControl("txtEnterQty");
                    TextBox txtAvailQty = (TextBox)item.FindControl("txtAvailQty");
                    TextBox txtNote = (TextBox)item.FindControl("txtNote");

                    var objNTF1 = new NTF1();

                    objNTF1.NTF1ID = Count++;
                    objNTF1.ParentID = ParentID;
                    objNTF1.INTFID = INTF.INTFID;
                    objNTF1.ItemID = ItemID;
                    objNTF1.UnitID = Int32.TryParse(ddlUnit.SelectedValue.Split(",".ToArray()).First(), out IntNum) ? IntNum : 0;
                    objNTF1.AvalQty = Int32.TryParse(txtAvailQty.Text, out IntNum) ? IntNum : 0;
                    objNTF1.Qty = Int32.TryParse(txtEnterQty.Text, out IntNum) ? IntNum : 0;
                    objNTF1.TotalQty = TotalPacket;
                    objNTF1.Notes = txtNote.Text;

                    INTF.TotalQty += objNTF1.Qty;

                    ctx.NTF1.Add(objNTF1);

                    ITM2 FromITM2 = FromITM2s.FirstOrDefault(x => x.ItemID == ItemID);
                    if (FromITM2 == null)
                    {
                        FromITM2 = new ITM2();
                        FromITM2.StockID = CountG++;
                        FromITM2.ParentID = ParentID;
                        FromITM2.WhsID = INTF.FromWhsID;
                        FromITM2.ItemID = ItemID;
                        ctx.ITM2.Add(FromITM2);
                    }
                    FromITM2.TotalPacket -= TotalPacket;

                    ITM2 ToITM2 = ToITM2s.FirstOrDefault(x => x.ItemID == ItemID);
                    if (ToITM2 == null)
                    {
                        ToITM2 = new ITM2();
                        ToITM2.StockID = CountG++;
                        ToITM2.ParentID = ParentID;
                        ToITM2.WhsID = INTF.ToWhsID;
                        ToITM2.ItemID = ItemID;
                        ctx.ITM2.Add(ToITM2);
                    }
                    ToITM2.PPrice = ((ToITM2.TotalPacket * ToITM2.PPrice) + (TotalPacket * FromITM2.PPrice)) / (ToITM2.TotalPacket + TotalPacket);

                    ToITM2.TotalPacket += TotalPacket;
                }
            }

            ctx.SaveChanges();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully : " + INTF.INTFID + "',1);", true);

            ClearAllInputs();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Inventory.aspx");
    }

    #endregion

    #region GridView Events

    protected void gvItems_PreRender(object sender, EventArgs e)
    {
        if (gvItem.Rows.Count > 0)
        {
            gvItem.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvItem.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvItem_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            NRT1 Data = e.Row.DataItem as NRT1;

            DropDownList ddlUnit = (DropDownList)e.Row.FindControl("ddlUnit");
            Dictionary<string, string> Units = new Dictionary<string, string>();
            foreach (ITM1 item in Data.OITM.ITM1)
            {
                Units.Add(item.OUNT.UnitName, item.UnitID + "," + item.OITM.ITM1.FirstOrDefault(x => x.UnitID == item.UnitID && x.ItemID == item.ItemID).Quantity);
            }
            ddlUnit.DataSource = Units;
            ddlUnit.DataBind();
        }
    }

    #endregion

    protected void ddlFromWarehouse_SelectedIndexChanged(object sender, EventArgs e)
    {
        var FromID = Convert.ToInt32(ddlFromWarehouse.SelectedValue);
        if (FromID > 0)
        {
            var Data = ctx.ITM2.Include("OITM").Include("OITM.ITM1").Include("OITM.ITM2").Where(x => x.WhsID == FromID && x.ParentID == ParentID).ToList();

            List<NRT1> Orders = new List<NRT1>();

            foreach (ITM2 item in Data)
            {
                NRT1 Order = new NRT1();
                Order.ItemID = item.ItemID;
                Order.OITM = item.OITM;
                Order.OITM.ITM1 = item.OITM.ITM1.Where(x => x.UnitItemID == null && x.Active).OrderBy(x => x.ItemMunitID).ToList();
                Order.AvalQty = item.TotalPacket;
                Orders.Add(Order);
            }
            gvItem.DataSource = Orders;
            gvItem.DataBind();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);
        }
    }
}