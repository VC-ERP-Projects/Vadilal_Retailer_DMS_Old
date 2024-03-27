using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_PurchaseReceiptPendingRPT : System.Web.UI.Page
{
    #region Property

    protected int UserID;
    public int CustType;
    public decimal ParentID;
    protected String AuthType;
    public String EmpName;

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

    public void ClearAllInputs()
    {
        txtDistCode.Text = txtRegion.Text = txtPlant.Text = "";
        using (DDMSEntities ctx = new DDMSEntities())
        {
            EmpName = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
            if (CustType == 2 || CustType == 4)
            {
                divRegion.Style.Add("Display", "none");
                divPlant.Style.Add("Display", "none");

                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();

                txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
                txtDistCode.Enabled = false;
                gvGrid2.DataSource = null;
                gvGrid2.DataBind();
            }
            else
            {
                gvGrid.DataSource = null;
                gvGrid.DataBind();
            }
        }
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    #region Button click

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            Int32 RegionID, PlantID = 0;
            Decimal DistributorID = 0;
            RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
            PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;
            DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            if (CustType == 1 && RegionID == 0 && PlantID == 0 && DistributorID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select atleast one parameter.',3);", true);
                return;
            }

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "PurchaseReceiptPending";
            Cm.Parameters.AddWithValue("@RegionID", RegionID);
            Cm.Parameters.AddWithValue("@PlantID", PlantID);
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                if (CustType == 2 || CustType == 4)
                {
                    gvGrid2.DataSource = ds.Tables[0];
                    gvGrid2.DataBind();
                }
                else
                {
                    gvGrid.DataSource = ds.Tables[0];
                    gvGrid.DataBind();
                }
            }
            else
            {
                ClearAllInputs();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }

    }

    #endregion

    #region Griedview Events

    protected void gvGrid_PreRender(object sender, EventArgs e)
    {
        if (gvGrid.Rows.Count > 0)
        {
            gvGrid.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvGrid.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvGrid_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        try
        {
            if (!string.IsNullOrEmpty(e.CommandArgument.ToString()))
            {
                Int32 InwardID = Int32.TryParse(e.CommandArgument.ToString().Split("#".ToArray()).First(), out InwardID) ? InwardID : 0;
                Decimal DistriID = Decimal.TryParse(e.CommandArgument.ToString().Split("#".ToArray())[1], out DistriID) ? DistriID : 0;
                string DocType = e.CommandArgument.ToString().Split("#".ToArray()).Last().ToString();
                if (e.CommandName.Trim() == "DeleteInward" && InwardID > 0 && DistriID > 0)
                {
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        if (DocType == "P")
                        {
                            OMID objDeletedOMID = ctx.OMIDs.FirstOrDefault(x => x.InwardID == InwardID && x.ParentID == DistriID && x.InwardType == 5);
                            if (objDeletedOMID == null)
                            {

                                OMID objOMID = ctx.OMIDs.FirstOrDefault(x => x.InwardID == InwardID && x.ParentID == DistriID && x.InwardType == 2);

                                if (objOMID != null)
                                {// ticket :9019 as per discussion :
                                    //  objOMID.MID1.ToList().ForEach(x => ctx.MID1.Remove(x));
                                    objOMID.InwardType = 5;// 5 means cancel/delete.
                                    //ctx.OMIDs.Remove(objOMID);

                                    ctx.SaveChanges();

                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record Deleted Successfully.',1);", true);
                                    btnGenerat_Click(btnGenerat, EventArgs.Empty);
                                }
                                else
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Proper Invoice.',3);", true);
                                }
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invoice " + objDeletedOMID.BillNumber + " is already In-Active .',3);", true);

                            }
                        }
                        else if (DocType == "S")
                        {
                            OPOS objOPos = ctx.OPOS.FirstOrDefault(x => x.SaleID == InwardID && x.ParentID == DistriID && x.Status == "O" && new int[] { 12, 13 }.Contains(x.OrderType));

                            if (objOPos != null)
                            {
                                objOPos.IsDelivered = true;

                                ctx.SaveChanges();

                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record Deleted Successfully.',1);", true);
                                btnGenerat_Click(btnGenerat, EventArgs.Empty);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Proper Invoice.',3);", true);
                            }
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion

    protected void gvGrid2_PreRender(object sender, EventArgs e)
    {
        if (gvGrid2.Rows.Count > 0)
        {
            gvGrid2.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvGrid2.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
}