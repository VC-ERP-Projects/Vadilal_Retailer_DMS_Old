using System;
using System.Collections.Generic;
using System.Data.Objects.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class MyAccount_ViewProfile : System.Web.UI.Page
{

    #region DeclarationgvProfile

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
            int EGID = Convert.ToInt32(Session["GroupID"]);
            CustType = Convert.ToInt32(Session["Type"]);
            using (DDMSEntities ctx = new DDMSEntities())
            {
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
                            var unit = xml.Descendants("customer_master");
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
            if (CustType == 1)
            {
                Int32 Status = Int32.TryParse(ddlStatus.SelectedValue, out Status) ? Status : 0;
                var IsComposite = chkIsComposite.Checked ? "1" : "0";

                gvProfile.DataSource = (from c in ctx.TOCRDs
                                        join d in ctx.OCRDs on c.ParentID equals d.CustomerID
                                        where c.Active && (ddlStatus.SelectedValue == "0" || c.Status == Status) && c.VAT == IsComposite
                                        select new
                                        {
                                            c.TCustID,
                                            c.ParentID,
                                            d.CustomerCode,
                                            d.CustomerName,
                                            CreatedDate = ctx.TOCRDs.Where(x => x.ParentID == c.ParentID && x.Status == 1).OrderByDescending(x => x.TCustID).FirstOrDefault().CreatedDate,
                                            c.Status,
                                            VerifyDate = c.CreatedDate,
                                            VerifyBy = c.CreatedBy,
                                            c.GST,
                                            c.PAN,
                                        }).ToList().
                                        Select(x => new
                                        {
                                            x.TCustID,
                                            x.ParentID,
                                            x.CustomerCode,
                                            x.CustomerName,
                                            x.CreatedDate,
                                            Status = (x.Status == 2 ? "Verified" : "Not Verified"),
                                            VerifyDate = x.Status == 2 ? x.VerifyDate.ToString("dd/MM/yyyy hh:mm:ss") : "",
                                            VerifyBy = x.Status == 2 ? ctx.OEMPs.FirstOrDefault(y => y.EmpID == x.VerifyBy && y.ParentID == ParentID).Name : "",
                                            x.GST,
                                            x.PAN
                                        }).ToList();
                gvProfile.DataBind();
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
        }
    }

    protected void gvProfile_PreRender(object sender, EventArgs e)
    {
        if (gvProfile.Rows.Count > 0)
        {
            gvProfile.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvProfile.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
    protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    protected void gvProfile_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (!string.IsNullOrEmpty(e.CommandArgument.ToString()))
        {
            Int32 TCustID = Int32.TryParse(e.CommandArgument.ToString().Split(",".ToArray()).First(), out TCustID) ? TCustID : 0;
            Decimal DistriID = Decimal.TryParse(e.CommandArgument.ToString().Split(",".ToArray()).Last(), out DistriID) ? DistriID : 0;

            if (e.CommandName.Trim() == "DeleteMode" && TCustID > 0 && DistriID > 0)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    TOCRD objTOCRD = ctx.TOCRDs.FirstOrDefault(x => x.TCustID == TCustID && x.ParentID == DistriID && x.Active);
                    if (objTOCRD != null)
                    {
                        objTOCRD.Active = false;
                        objTOCRD.DeletedBy = UserID;
                        objTOCRD.DeletedDate = DateTime.Now;
                        ctx.SaveChanges();
                    }
                }

                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Record deleted successfully!',1);", true);
            }
        }
    }
}