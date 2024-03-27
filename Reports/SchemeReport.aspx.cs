using System;
using System.Collections.Generic;
using System.Data;
using System.Data.EntityClient;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_ShemeReport : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    DDMSEntities ctx;
    protected String AuthType;

    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            ctx = new DDMSEntities();
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
        txtDealerCode.Text = txtPlant.Text = txtRegion.Text = txtDistCode.Text = "";
        chkIsActive.Checked = true;

        if (CustType == 1)
        {
            divDistributor.Visible = true;
            acetxtName.ContextKey = (CustType + 1).ToString();
        }
        else
        {
            divDistributor.Visible = false;
            divDistributor.Style.Add("Display", "none");
            acetxtDealerCode.ContextKey = ParentID.ToString();
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
            ddltype.Focus();
        }
    }

    #endregion

    #region BuutonClick

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        int PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).First().Trim(), out PlantID) ? PlantID : 0;
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).First().Trim(), out RegionID) ? RegionID : 0;

        if (DistributorID == 0 && DealerID == 0 && PlantID == 0 && RegionID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
            return;
        }

        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "SchemeReport";

        Cm.Parameters.AddWithValue("@DealerID", DealerID);
        Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
        Cm.Parameters.AddWithValue("@RegionID", RegionID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@Type", ddltype.SelectedValue);
        Cm.Parameters.AddWithValue("@Active", chkIsActive.Checked ? "1" : "0");

        DataSet ds = objClass.CommonFunctionForSelect(Cm);

        gvScheme.DataSource = ds;
        gvScheme.DataBind();

    }

    #endregion

    #region Gridview Event

    protected void gvScheme_PreRender(object sender, EventArgs e)
    {
        if (gvScheme.Rows.Count > 0)
        {
            gvScheme.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvScheme.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion
}