using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_ClaimDocDownload : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    public int CustType;
    public decimal ParentID;
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


        if (CustType == 4) // SS
        {
           // divDealer.Attributes.Add("style", "display:none;");
            ddlSaleBy.SelectedValue = "4";
            txtSSCode.Enabled = ddlSaleBy.Enabled = false;

            using (DDMSEntities ctx = new DDMSEntities())
            {
                var SS = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtSSCode.Text = SS.CustomerCode + " - " + SS.CustomerName + " - " + SS.CustomerID;
            }
        }
        else if (CustType == 2)
        {
            divSS.Attributes.Add("style", "display:none;");
            ddlSaleBy.SelectedValue = "2";
            txtDistCode.Enabled = ddlSaleBy.Enabled = false;

            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }
        }
    }

    #endregion
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            using (DDMSEntities ctx = new DDMSEntities())
            {

                ddlMode.DataTextField = "ReasonName";
                ddlMode.DataValueField = "ReasonID";
                //ddlMode.DataSource = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), x.ReasonID }).OrderBy(x => x.ReasonName).ToList();
                ddlMode.DataSource = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), x.ReasonID, x.IsAuto }).OrderByDescending(x => x.IsAuto).ToList();
                ddlMode.DataBind();
                ddlMode.Items.Insert(0, new ListItem("---Select---", "0"));
            }
            txtDate.Text = "10/2022";
            txtToDate.Text = DateTime.Now.AddMonths(-1).ToString("MM/yyyy");
            //txtDistCode.Text = "DABJIT45 - JITESHWARY SALES AGENCY - 2015960000100000";
        }
    }

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            string IPAdd = hdnIPAdd.Value;
            if (IPAdd == "undefined")
                IPAdd = "";
            if (IPAdd.Length > 15)
                IPAdd = IPAdd = IPAdd.Substring(0, 15);

            if (String.IsNullOrEmpty(txtDate.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Date.',3);", true);
                txtDate.Text = "";
                txtDate.Focus();
                return;
            }

            Decimal SSID = Decimal.TryParse(txtSSCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;

            if (ddlSaleBy.SelectedValue == "4" && SSID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one SS / Dist.',3);", true);
                return;
            }
            else if (ddlSaleBy.SelectedValue == "2" && DistID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one Dist / Dealer.',3);", true);
                return;
            }
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                return;
            }

            //Decimal PID = ddlSaleBy.SelectedValue == "4" ? SSID : DistID;
            //Decimal CustomerID = ddlSaleBy.SelectedValue == "4" ? DistID : DealerID;

            DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
            DateTime Todate = Convert.ToDateTime(txtToDate.Text);

            Todate = new DateTime(Todate.Year, Todate.Month, DateTime.DaysInMonth(Todate.Year, Todate.Month));

            if (Fromdate > Todate)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim To Month  is not less than From Month.',3);", true);
                return;
            }
            int lastDay = DateTime.DaysInMonth(DateTime.Now.Year, DateTime.Now.Month);
            var endDate = lastDay.ToString() + "/" + DateTime.Now.Month.ToString() + "/" + DateTime.Now.Year.ToString();
            DateTime origDT = Convert.ToDateTime(endDate);
            DateTime lastDate = new DateTime(origDT.Year, origDT.Month, 1).AddMonths(1).AddDays(-1);
            if (Todate > lastDate)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you can not select future month.',3);", true);
                return;

            }
            //if (ddlMode.SelectedValue.ToString() == "57")
            //{
            //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select this claim type because it is direct sync to SAP Z-Table.',3);", true);
            //    return;
            //}
            string ipvalue = (string.IsNullOrEmpty(IPAdd) ? "" : " / " + IPAdd);

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "usp_GetClaimDocDowload";
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@DistributorID", DistID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@SSID", SSID);
            Cm.Parameters.AddWithValue("@FromDate", Fromdate.ToString("yyyyMMdd"));
            Cm.Parameters.AddWithValue("@ToDate", Todate.ToString("yyyyMMdd"));
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@Stype", ddlMode.SelectedValue);
            Cm.Parameters.AddWithValue("@ReportBy", ddlSaleBy.SelectedValue);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                gvCommon.DataSource = ds.Tables[0];
                gvCommon.DataBind();

                //ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
                //Button btnDown = gvCommon.FindControl("lbldownloadimg") as Button;
                //scriptManager.RegisterPostBackControl(btnDown);
            }
            else
            {
                gvCommon.DataSource = null;
                gvCommon.DataBind();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Data Found',2);", true);
            }
        }
        catch (Exception ex)
        {
            gvCommon.DataSource = null;
            gvCommon.DataBind();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }


    protected void gvCommon_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Image")
        {
            //Determine the RowIndex of the Row whose Button was clicked.
            int rowIndex = Convert.ToInt32(e.CommandArgument);

            //Reference the GridView Row.
            GridViewRow row = gvCommon.Rows[rowIndex];

            //Fetch value of Name.
            string ParentId = (row.FindControl("hdnCustomerID") as HiddenField).Value;
            string ClaimId = (row.FindControl("hdnParentClaimID") as HiddenField).Value;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenItemImage('" + ClaimId + "','" + ParentId + "','0');", true);
        }
        else if (e.CommandName == "Download")
        {
            //Determine the RowIndex of the Row whose Button was clicked.
            int rowIndex = Convert.ToInt32(e.CommandArgument);

            //Reference the GridView Row.
            GridViewRow row = gvCommon.Rows[rowIndex];

            //Fetch value of Name.
            string ParentId = (row.FindControl("hdnCustomerID") as HiddenField).Value;
            string ClaimId = (row.FindControl("hdnParentClaimID") as HiddenField).Value;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenItemImage('" + ClaimId + "','" + ParentId + "','1');", true);

            //Response.ContentType = "application/pdf";
            //Response.AppendHeader("Content-Disposition", "attachment; filename=MyFile.pdf");
            //// Write the file to the Response
            //const int bufferLength = 10000;
            //byte[] buffer = new Byte[bufferLength];
            //int length = 0;
            //Stream download = null;
            //try
            //{
            //    Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            //    SqlCommand Cm = new SqlCommand();

            //    Cm.Parameters.Clear();
            //    Cm.CommandType = CommandType.StoredProcedure;
            //    Cm.CommandText = "usp_GetClaimDocmentForDownload";
            //    Cm.Parameters.AddWithValue("@ParentId", ParentId);
            //    Cm.Parameters.AddWithValue("@ParentClaimId", ClaimId);
            //    DataSet ds = objClass.CommonFunctionForSelect(Cm);
            //    if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            //    {
            //        for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
            //        {
            //            download = new FileStream(Server.MapPath("~/Document/ClaimDocument/" + ds.Tables[0].Rows[i]["ImageName"]),
            //                                                     FileMode.Open,
            //                                                     FileAccess.Read);


            //            do
            //            {
            //                if (Response.IsClientConnected)
            //                {
            //                    length = download.Read(buffer, 0, bufferLength);
            //                    Response.OutputStream.Write(buffer, 0, length);
            //                    buffer = new Byte[bufferLength];
            //                }
            //                else
            //                {
            //                    length = -1;
            //                }
            //            }
            //            while (length > 0);
            //            Response.Flush();
            //            Response.End();

            //        }
            //    }
            //}
            //finally
            //{
            //    if (download != null)
            //        download.Close();
            //}
        }
    }




    protected void gvCommon_PreRender(object sender, EventArgs e)
    {
        if (gvCommon.Rows.Count > 0)
        {
            gvCommon.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvCommon.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

}