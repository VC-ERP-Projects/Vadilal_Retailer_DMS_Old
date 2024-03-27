using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_Pricing_List : System.Web.UI.Page
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

    public void ClearAllInputes()
    {
        if (CustType == 1)
        {
            acetxtName.ContextKey = (CustType + 1).ToString();
        }

        using (DDMSEntities ctx = new DDMSEntities())
        {
            ddlItemGroup.DataSource = ctx.OITBs.OrderBy(x => x.SortOrder).ToList();
            ddlItemGroup.DataBind();
            ddlItemGroup.Items.Insert(0, new ListItem("---Select---", "0"));


            var ItemGroupId = Convert.ToInt32(ddlItemGroup.SelectedValue);
            ddlSubGroup.DataSource = ctx.OITGs.Where(x => x.ItemGroupID == ItemGroupId && x.Active).ToList();
            ddlSubGroup.DataBind();
            ddlSubGroup.Items.Insert(0, new ListItem("---Select---", "0"));

            txtEmpName.Text = (from a in ctx.OEMPs where a.EmpID == UserID && a.ParentID == ParentID select a.EmpCode + " # " + a.Name).FirstOrDefault();
        }

        gvprice.DataSource = null;
        gvprice.DataBind();
    }

    #endregion

    #region PageLoad
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            //acetxtName.ServiceMethod = "GetSSFromPlantState";
            ClearAllInputes();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Division = ctx.ODIVs.Where(x => x.Active).ToList();
                ddlDivision.DataSource = Division;
                ddlDivision.DataBind();
            }
        }

    }
    #endregion

    protected void ddlItemGroup_SelectedIndexChanged(object sender, EventArgs e)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var ItemGroupId = Convert.ToInt32(ddlItemGroup.SelectedValue);
            ddlSubGroup.DataSource = ctx.OITGs.Where(x => x.ItemGroupID == ItemGroupId && x.Active).ToList();
            ddlSubGroup.DataBind();
            ddlSubGroup.Items.Insert(0, new ListItem("---Select---", "0"));
        }
    }

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            int Intnum = 0;
            Decimal Decnum = 0;
            Decimal CustomerID = 0;
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out Decnum) ? Decnum : 0;
            Decimal DSTID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out Decnum) ? Decnum : 0;
            Decimal DealerID = Decimal.TryParse(txtdealer.Text.Split("-".ToArray()).Last().Trim(), out Decnum) ? Decnum : 0;
            Int32 PricelistID = Int32.TryParse(txtPriceGroup.Text.Split("-".ToArray()).First().Trim(), out Intnum) ? Intnum : 0;
            Int32 SUserID = Int32.TryParse(txtEmpCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;

            if (ddlCustType != null)
            {
                if (ddlCustType.SelectedValue == "2")
                {
                    CustomerID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;
                }
                else
                {
                    CustomerID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;
                }
            }

            if (ddlCustType.SelectedValue == "2" && DSTID == 0 && DealerID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
                return;
            }

            if (ddlCustType.SelectedValue == "4" && SSID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Super Stockist.',3);", true);
                txtCustCode.Text = "";
                txtCustCode.Focus();
                return;
            }

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "PricingList";

            //if (DealerID > 0)
            //{
            //    Cm.Parameters.AddWithValue("@PARENTID", 0);
            //    Cm.Parameters.AddWithValue("@CUSTOMERID", DealerID);
            //}
            //else if (DSTID > 0)
            //{
            //    Cm.Parameters.AddWithValue("@PARENTID", DSTID);
            //    Cm.Parameters.AddWithValue("@CUSTOMERID", 0);
            //}
            //else
            //{
            //    Cm.Parameters.AddWithValue("@PARENTID", SSID);
            //    Cm.Parameters.AddWithValue("@CUSTOMERID", 0);
            //}
            Cm.Parameters.AddWithValue("@ITEMGROUPID", ddlItemGroup.SelectedValue);
            Cm.Parameters.AddWithValue("@ITEMSUBGROUPID", ddlSubGroup.SelectedValue);
            Cm.Parameters.AddWithValue("@ACTIVE", ddlMaterialStatus.SelectedValue);
            Cm.Parameters.AddWithValue("@DIVISIONID", ddlDivision.SelectedValue);
            Cm.Parameters.AddWithValue("@PriceListID", PricelistID);
            Cm.Parameters.AddWithValue("@PARENTID", ParentID);
            Cm.Parameters.AddWithValue("@CUSTOMERID", CustomerID);
            //Cm.Parameters.AddWithValue("@SUserID", SUserID);
            //Cm.Parameters.AddWithValue("@RegionID", RegionID);
            //Cm.Parameters.AddWithValue("@EMPID", UserID);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                gvprice.DataSource = ds.Tables[0];
                gvprice.DataBind();
            }
            else
            {
                ClearAllInputes();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #region Griedview Events

    protected void gvprice_PreRender(object sender, EventArgs e)
    {
        if (gvprice.Rows.Count > 0)
        {
            gvprice.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvprice.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

}