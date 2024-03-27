using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_PMDue : System.Web.UI.Page
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
                var UserType = Session["UserType"].ToString();
                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
                int menuid = ctx.OMNUs.FirstOrDefault(x => x.PageName == pagename && (UserType == "b" ? true : x.MenuType == UserType)).MenuID;
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.MenuID == menuid && x.EmpGroupID == EGID && x.ParentID == ParentID);
                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(CustType == 1 ? Auth.OMNU.Company : CustType == 2 ? Auth.OMNU.CMS : CustType == 3 ? Auth.OMNU.DMS : CustType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
                    AuthType = Auth.AuthorizationType;
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
        }
        else
        {
            Response.Redirect("~/Login.aspx");
        }
    }

    public void ClearAllInputes()
    {
        txtAsOnDate.Text = Common.DateTimeConvert(DateTime.Now);
        gvpmdue.DataSource = null;
        gvpmdue.DataBind();
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var MachineType = ctx.OASTies.Where(x => x.Active).ToList();
            ddlMachineType.DataTextField = "AssetTypeName";
            ddlMachineType.DataValueField = "AssetTypeID";
            ddlMachineType.DataSource = MachineType;
            ddlMachineType.DataBind();
            ddlMachineType.Items.Insert(0, new ListItem("---Select---", "0"));
        }
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            ClearAllInputes();
        }

    }
    #endregion

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            if (Session["UserID"] != null && Session["ParentID"] != null &&
            Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
            {
                Int32.TryParse(Session["UserID"].ToString(), out UserID);
                Decimal.TryParse(Session["ParentID"].ToString(), out ParentID);
            }
            SqlCommand Cm = new SqlCommand();
            gvpmdue.DataSource = null;
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();

            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            Int32 CityID = Int32.TryParse(txtCity.Text.Split("-".ToArray()).Last().Trim(), out CityID) ? CityID : 0;
            Int32 MechEmpID = Int32.TryParse(txtMechEmp.Text.Split("-".ToArray()).Last().Trim(), out MechEmpID) ? MechEmpID : 0;

            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            Int32 MachineType = 0;
            int.TryParse(ddlMachineType.SelectedValue, out MachineType);
            DateTime AsOnDate = Convert.ToDateTime(txtAsOnDate.Text);

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "MECH_PMDue_Report";

            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@MachineType", MachineType);
            Cm.Parameters.AddWithValue("@AsOnDate", AsOnDate);
            Cm.Parameters.AddWithValue("@Location", txtlocation.Text);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@CityID", CityID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@MechanicID", MechEmpID);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                gvpmdue.DataSource = ds.Tables[0];
                gvpmdue.DataBind();
            }
            else
            {
                gvpmdue.DataSource = null;
                gvpmdue.DataBind();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #region Griedview Events

    protected void gvpmdue_PreRender(object sender, EventArgs e)
    {
        if (gvpmdue.Rows.Count > 0)
        {
            gvpmdue.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvpmdue.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
    #endregion
}