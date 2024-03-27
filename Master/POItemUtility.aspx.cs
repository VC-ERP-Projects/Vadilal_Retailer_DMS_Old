using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_POItemUtility : System.Web.UI.Page
{

    #region Declaration

    public Decimal DistributorID = 0;
    public Int32 InwardID = 0;
    protected int UserID;
    protected decimal ParentID;

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
         Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
        }
        else
        {
            Response.Redirect("~/Login.aspx");
        }

        InwardID = Int32.TryParse(Request.QueryString["InwardID"].ToString(), out InwardID) ? InwardID : 0;
        DistributorID = Decimal.TryParse(Request.QueryString["DistributorID"].ToString(), out DistributorID) ? DistributorID : 0;

        if (!IsPostBack)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var ItemData = (from a in ctx.OMIDs
                                join b in ctx.MID1 on new { a.InwardID, a.ParentID } equals new { b.InwardID, b.ParentID }
                                where a.InwardID == InwardID && a.ParentID == DistributorID
                                select new
                                {
                                    a.InwardID,
                                    b.ItemID,
                                    b.OITM.ItemCode,
                                    b.OITM.ItemName,
                                    b.OUNT.UnitName,
                                    b.TotalQty,
                                    b.SubTotal,
                                    b.Tax,
                                    b.Total
                                }).ToList();

                if (ItemData != null)
                {
                    gvOrder.DataSource = ItemData;
                    gvOrder.DataBind();
                }
            }
        }
    }

    #endregion

    #region ButtonClick

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            bool errFound = true;
            bool uncheckedcn = false;
            if (Page.IsValid)
            {
                for (int i = 0; i < gvOrder.Rows.Count; i++)
                {
                    HtmlInputCheckBox chk = (HtmlInputCheckBox)gvOrder.Rows[i].FindControl("chkCheck");

                    if (chk.Checked)
                        errFound = false;
                    else
                        uncheckedcn = true;

                }


                if (errFound == true)
                {
                    this.ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Please select atleast one row!');", true);
                    return;
                }

                Int32 ItemID = 0;
                Decimal DecNum = 0;

                if (DistributorID > 0 && InwardID > 0)
                {
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        OMID objOMID = ctx.OMIDs.FirstOrDefault(x => x.ParentID == DistributorID && x.InwardID == InwardID);

                        if (objOMID != null)
                        {
                            Decimal SubTotal = 0, Tax = 0, Total = 0;

                            foreach (GridViewRow item in gvOrder.Rows)
                            {
                                HtmlInputCheckBox chk = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                Label lblInwardID = (Label)item.FindControl("lblInwardID");
                                Label lblItemID = (Label)item.FindControl("lblItemID");
                                Label lblSubTotal = (Label)item.FindControl("lblSubTotal");
                                Label lblTax = (Label)item.FindControl("lblTax");
                                Label lblTotal = (Label)item.FindControl("lblTotal");

                                if (chk.Checked && Int32.TryParse(lblItemID.Text, out ItemID) && ItemID > 0)
                                {
                                    if (objOMID.MID1.Any(x => x.ItemID == ItemID))
                                    {
                                        objOMID.MID1.Where(x => x.ItemID == ItemID).ToList().ForEach(x => ctx.MID1.Remove(x));
                                    }
                                }
                                else
                                {
                                    SubTotal += Decimal.TryParse(lblSubTotal.Text, out DecNum) ? DecNum : 0;
                                    Tax += Decimal.TryParse(lblTax.Text, out DecNum) ? DecNum : 0;
                                    Total += Decimal.TryParse(lblTotal.Text, out DecNum) ? DecNum : 0;
                                }
                            }

                            objOMID.SubTotal = SubTotal;
                            objOMID.Tax = Tax;
                            objOMID.Rounding = Total - Math.Round(Total);
                            objOMID.Total = Math.Round(Total);
                            objOMID.Pending = Total;
                            objOMID.UpdatedDate = DateTime.Now;
                            objOMID.UpdatedBy = UserID;

                            if (!uncheckedcn)
                            {
                                objOMID.InwardType = 5;
                            }
                            ctx.SaveChanges();
                            this.ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Record submitted successfully.'); parent.$.colorbox.close();", true);
                        }
                        else
                            this.ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Selected inward detail not found..!');", true);
                    }

                }
                else
                    this.ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Please select again po no. !');", true);
            }
        }
        catch (Exception ex)
        {
            this.ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('" + Common.GetString(ex) + "');", true);
        }
    }

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                StringBuilder builder = new StringBuilder();
                string strFileName = "PO Sync Success/Error Status Items_" + DateTime.Now.ToShortDateString() + ".csv";
                var objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == DistributorID);
                builder.Append("Customer : ," + (objOCRD != null ? objOCRD.CustomerCode + " # " + objOCRD.CustomerName : "") + Environment.NewLine);
                builder.Append("No. ,Item Code,Item Name,Unit,Order Qty.,SubTotal,Tax,Total" + Environment.NewLine);

                foreach (GridViewRow row in gvOrder.Rows)
                {
                    Label lblNo = row.FindControl("lblNo") as Label;
                    Label lblItemCode = row.FindControl("lblItemCode") as Label;
                    Label lblItemName = row.FindControl("lblItemName") as Label;
                    Label lblUnitName = row.FindControl("lblUnitName") as Label;
                    Label lblTotalQty = row.FindControl("lblTotalQty") as Label;
                    Label lblSubTotal = row.FindControl("lblSubTotal") as Label;
                    Label lblTax = row.FindControl("lblTax") as Label;
                    Label lblTotal = row.FindControl("lblTotal") as Label;

                    string No = lblNo.Text;
                    string ItemCode = lblItemCode.Text;
                    string ItemName = lblItemName.Text;
                    string Unit = lblUnitName.Text;
                    string OrderQty = lblTotalQty.Text;
                    string SubTotal = lblSubTotal.Text;
                    string Tax = lblTax.Text;
                    string Total = lblTotal.Text;

                    builder.Append(No + "," + ItemCode + "," + ItemName + "," + Unit + "," + OrderQty + "," + SubTotal + "," + Tax + "," + Total + Environment.NewLine);
                }
                Response.Clear();
                Response.ContentType = "text/csv";
                Response.AddHeader("Content-Disposition", "attachment;filename=" + strFileName);
                Response.Write(builder.ToString());
                Response.End();
            }
        }

        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }
    #endregion
}