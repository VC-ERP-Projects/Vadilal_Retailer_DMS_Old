using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_NotifyItemReport : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    public int CustType;
    public decimal ParentID;
    protected String AuthType;
    protected String Version;

    #endregion
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    private void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int EGID = Convert.ToInt32(Session["GroupID"]);
                CustType = Convert.ToInt32(Session["Type"]);
                Version = Convert.ToString(ConfigurationManager.AppSettings["Version"]);

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
                    hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();

                    hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();

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
        using (DDMSEntities ctx = new DDMSEntities())
        {
            ddlItemGroup.DataSource = ctx.OITBs.OrderBy(x => x.SortOrder).ToList();
            ddlItemGroup.DataBind();
            ddlItemGroup.Items.Insert(0, new ListItem("---Select---", "0"));

            var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            ddlDivision.DataSource = Division;
            ddlDivision.DataBind();
            ddlDivision.Items.Insert(0, new ListItem("---Select---", "0"));


        }
        txtCode.Text = "";
        txtRegion.Text = "";
        txtCode.Style.Add("background-color", "rgb(250, 255, 189);");
        txtFromDate.Text = txtToDate.Text = Common.DateTimeConvert(DateTime.Now);
        //txtGroup.Text = "";
        txtItem.Text = "";
        gvgrid.DataSource = null;
        gvgrid.DataBind();
    }
    protected void gvgrid_PreRender(object sender, EventArgs e)
    {
        if (gvgrid.Rows.Count > 0)
        {
            gvgrid.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvgrid.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
    protected void ddlDivision_SelectedIndexChanged(object sender, EventArgs e)
    {
        Int32 divisionID = (Int32.TryParse(ddlDivision.SelectedValue, out divisionID)) ? divisionID : 0;
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (divisionID > 0)
            {
                var itemGroupList = (from a in ctx.OITBs
                                     join b in ctx.OITMs on a.ItemGroupID equals b.GroupID
                                     join c in ctx.OGITMs on b.ItemID equals c.ItemID
                                     where c.DivisionlID == divisionID
                                     orderby a.SortOrder
                                     select new
                                     {
                                         a.ItemGroupID,
                                         a.ItemGroupName
                                     }
                                  ).ToList().Distinct();
                ddlItemGroup.DataSource = itemGroupList;
            }
            else
            {
                ddlItemGroup.DataSource = ctx.OITBs.OrderBy(x => x.SortOrder).ToList();
            }
        }
        ddlItemGroup.DataBind();
        ddlItemGroup.Items.Insert(0, new ListItem("---Select---", "0"));
        txtItem.Text = String.Empty;
        ddlDivision.Focus();
    }
    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            //DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            //DateTime EndDate = Convert.ToDateTime(txtToDate.Text);

            int DistributerRegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out DistributerRegionID) ? DistributerRegionID : 0;
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            Decimal DistributorID = Decimal.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
           //Int32 ItemGrpID = Int32.TryParse(txtGroup.Text.Split("-".ToArray()).Last().Trim(), out ItemGrpID) ? ItemGrpID : 0;
            Int32 ItemID = Int32.TryParse(txtItem.Text.Split("-".ToArray()).Last().Trim(), out ItemID) ? ItemID : 0;

            if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                return;
            }
            //if (DistributerRegionID == 0 && SUserID == 0 && DistributorID == 0)
            //{
            //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
            //    return;
            //}

            //CustomerID = CustomerID > 0 ? CustomerID : DistributorID > 0 ? DistributorID : SSID > 0 ? SSID : 0;

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetNotifyItems";
            Cm.Parameters.AddWithValue("@FromDate", Convert.ToDateTime(txtFromDate.Text));
            Cm.Parameters.AddWithValue("@ToDate", Convert.ToDateTime(txtToDate.Text));
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@RegionID", DistributerRegionID);
            Cm.Parameters.AddWithValue("@DivsionId", ddlDivision.SelectedValue);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ProductGroupID", ddlItemGroup.SelectedValue);
            Cm.Parameters.AddWithValue("@ItemID", ItemID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);

            //string DivisionName = ddlDivision.SelectedValue.ToString() != "0" ? ddlDivision.SelectedItem.ToString() : "ALL";
            DataSet Ds = new DataSet();
            Ds = objClass.CommonFunctionForSelect(Cm);
            if (Ds.Tables.Count > 0)
            {

                gvgrid.DataSource = Ds.Tables[0];
                gvgrid.DataBind();


            }

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

}