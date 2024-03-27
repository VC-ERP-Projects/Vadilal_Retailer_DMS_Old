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

public partial class Master_FSSAIVerifyMaster : System.Web.UI.Page
{
    #region Declaration

    string OrderNumber;
    protected int UserID, CustType;
    protected decimal ParentID, CustomerID;
    DDMSEntities ctx;
    protected String AuthType;
    Decimal DefaultPageSize = 50;
    int ViewPageNumber = 10;
    string RejectRemarks;
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

    #endregion
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            txtFromDate.Text = "01/10/2022";
            txtToDate.Text = DateTime.Now.AddMonths(-1).ToString("MM/yyyy");
            BindGrid(1, "");

        }
    }

    private void BindGrid(int pageIndex, string pageName)
    {
        try
        {


            DateTime start = Convert.ToDateTime(txtFromDate.Text);
            DateTime end = Convert.ToDateTime(txtToDate.Text);

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "usp_GetFSSAIVerifyPendingData";
            Cm.Parameters.AddWithValue("@FromDate", start);
            Cm.Parameters.AddWithValue("@ToDate", end);
            Cm.Parameters.AddWithValue("@SUserID", UserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                gvOrder.DataSource = ds.Tables[0];
                gvOrder.DataBind();
            }
            else
            {
                gvOrder.DataSource = null;
                gvOrder.DataBind();
                //  ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('No Data Found',2);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }
    protected void gvOrder_Prerender(object sender, EventArgs e)
    {
        if (gvOrder.Rows.Count > 0)
        {
            gvOrder.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvOrder.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
    #region ButtonClick

    protected void btnGenerat_Click(object sender, EventArgs e)
    {

        bool errFound = true;
        try
        {
            if (Page.IsValid)
            {
                for (int i = 0; i < gvOrder.Rows.Count; i++)
                {
                    HtmlInputCheckBox chk = (HtmlInputCheckBox)gvOrder.Rows[i].FindControl("chkCheck");
                    if (chk.Checked == true)
                    {
                        errFound = false;
                    }
                }
                if (errFound == true)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select atleast one row!',3);", true);
                    return;
                }
                for (int i = 0; i < gvOrder.Rows.Count; i++)
                {
                    HtmlInputCheckBox chk = (HtmlInputCheckBox)gvOrder.Rows[i].FindControl("chkCheck");

                    if (chk.Checked)
                    {
                        TextBox txtRemarks = (TextBox)gvOrder.Rows[i].FindControl("txtTextRemarks");
                        if (txtRemarks.Text == "")
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please enter rejection remarks',3);", true);
                            return;
                        }
                        Label lblOFSSIID = (Label)gvOrder.Rows[i].FindControl("lblOFSSIID");
                        Int32 OFSSIID = Int32.TryParse(lblOFSSIID.Text, out OFSSIID) ? OFSSIID : 0;
                        OFSSI ObjCLMP = ctx.OFSSIs.Where(x => x.OFSSIID == OFSSIID).FirstOrDefault();
                        if (ObjCLMP != null)
                        {
                            ObjCLMP.VerifyIs = 2;
                            ObjCLMP.Remarks = txtRemarks.Text;
                            ObjCLMP.VerifyBy = UserID;
                            ObjCLMP.VerifyDateTime = DateTime.Now;
                        }
                    }
                }
                ctx.SaveChanges();
                BindGrid(1, "");
                //for (int i = 0; i < gvOrder.Rows.Count; i++)
                //{
                //    HtmlInputCheckBox chk = (HtmlInputCheckBox)gvOrder.Rows[i].FindControl("chkCheck");
                //    if (chk.Checked)
                //    {
                //        TextBox txtRemarks = (TextBox)gvOrder.Rows[i].FindControl("txtTextRemarks");
                //        if (txtRemarks.Text == "")
                //        {
                //            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please enter rejection remarks!',3);", true);
                //            return;
                //        }
                //        Label lblOFSSIID = (Label)gvOrder.Rows[i].FindControl("lblOFSSIID");
                //        OrderNumber += lblOFSSIID.Text + ',';
                //        RejectRemarks += txtRemarks.Text + '|';
                //    }
                //}
                //OrderNumber = OrderNumber.TrimEnd(",".ToArray());
                //RejectRemarks = RejectRemarks.TrimEnd("|".ToArray());
                //Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                //SqlCommand Cm = new SqlCommand();

                //Cm.Parameters.Clear();
                //Cm.CommandType = CommandType.StoredProcedure;
                //Cm.CommandText = "usp_UpdateVerifyOFSSAIRequest";

                //Cm.Parameters.AddWithValue("@OFSSAIID", OrderNumber);
                //Cm.Parameters.AddWithValue("@SUserID", UserID);
                //Cm.Parameters.AddWithValue("@ParentID", ParentID);
                //Cm.Parameters.AddWithValue("@Status", 2); // Reject
                //Cm.Parameters.AddWithValue("@Remarks", RejectRemarks); // Reject
                //int JJ = objClass.CommonFunctionForInsertUpdateDelete(Cm);
                //if (JJ >= 0)
                //{
                //    BindGrid(1, "");
                //    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Data Submitted Successfully !',3);", true);
                //}
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Page is invalid!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        bool errFound = true;
        try
        {
            if (Page.IsValid)
            {
                for (int i = 0; i < gvOrder.Rows.Count; i++)
                {
                    HtmlInputCheckBox chk = (HtmlInputCheckBox)gvOrder.Rows[i].FindControl("chkCheck");
                    if (chk.Checked == true)
                    {
                        errFound = false;
                    }
                }
                if (errFound == true)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select atleast one row!',3);", true);
                    return;
                }

                for (int i = 0; i < gvOrder.Rows.Count; i++)
                {
                    HtmlInputCheckBox chk = (HtmlInputCheckBox)gvOrder.Rows[i].FindControl("chkCheck");
                    if (chk.Checked)
                    {
                        Label lblOFSSIID = (Label)gvOrder.Rows[i].FindControl("lblOFSSIID");
                        OrderNumber += lblOFSSIID.Text + ',';
                    }
                }
                OrderNumber = OrderNumber.TrimEnd(",".ToArray());
                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();

                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "usp_UpdateVerifyOFSSAIRequest";

                Cm.Parameters.AddWithValue("@OFSSAIID", OrderNumber);
                Cm.Parameters.AddWithValue("@SUserID", UserID);
                Cm.Parameters.AddWithValue("@ParentID", ParentID);
                Cm.Parameters.AddWithValue("@Status", 1); // Approve
                int JJ = objClass.CommonFunctionForInsertUpdateDelete(Cm);
                if (JJ >= 0)
                {
                    BindGrid(1, "");
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Data Submitted Successfully !',3);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Page is invalid!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }


    #endregion
}