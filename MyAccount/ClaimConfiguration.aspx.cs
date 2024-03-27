﻿using System;
using System.Collections.Generic;
using System.Data.Objects.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class MyAccount_FOWConfiguration : System.Web.UI.Page
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
        txtState.Style.Add("background-color", "rgb(250, 255, 189);");
        txtCustCode.Style.Add("background-color", "rgb(250, 255, 189);");
        txtdealer.Style.Add("background-color", "rgb(250, 255, 189);");

        if (CustType == 1)
        {
            divDistributor.Visible = true;
            acetxtName.ContextKey = (CustType + 1).ToString();
        }
        else
        {
            divDistributor.Visible = false;
            divDistributor.Style.Add("Display", "none");
            acetxtdealer.ContextKey = ParentID.ToString();
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
        }

    }

    #endregion

    #region Button Click

    protected void btnReset_Click(object sender, EventArgs e)
    {

        try
        {
            int StateID = 0;
            Decimal DistributorID = 0, DealerID = 0, Percentage = 0, Amount = 0;

            if (Decimal.TryParse(txtPercentage.Text, out Percentage) && Decimal.TryParse(txtAmount.Text, out Amount) && Percentage > 0 && Amount > 0)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    string Per = Percentage.ToString();
                    string Amt = Amount.ToString();

                    int CustGroupID = ctx.CGRPs.FirstOrDefault(x => x.CustGroupDesc == "FOW").CustGroupID;

                    if (!string.IsNullOrEmpty(txtdealer.Text))
                    {
                        DealerID = Decimal.TryParse(txtdealer.Text.Split("-".ToArray()).Last().ToString(), out DealerID) ? DealerID : 0;

                        ctx.OCRDs.Where(x => x.CustomerID == DealerID && x.CustGroupID == CustGroupID).ToList().ForEach(y =>
                        {
                            y.CUsername = Per;
                            y.CPassword = Amt;
                        });

                    }
                    else if (!string.IsNullOrEmpty(txtCustCode.Text))
                    {
                        DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().ToString(), out DistributorID) ? DistributorID : 0;

                        ctx.OCRDs.Where(x => x.ParentID == DistributorID && x.CustGroupID == CustGroupID && x.Type == 3 && x.Active).ToList().ForEach(y =>
                        {
                            y.CUsername = Per;
                            y.CPassword = Amt;
                        });
                    }
                    else if (!string.IsNullOrEmpty(txtState.Text))
                    {
                        StateID = Int32.TryParse(txtState.Text.Split("-".ToArray()).First().ToString(), out StateID) ? StateID : 0;

                        ctx.OCRDs.Where(x => x.CRD1.Any(y => y.StateID == StateID) && x.CustGroupID == CustGroupID && x.Type == 3 && x.Active).ToList().ForEach(y =>
                        {
                            y.CUsername = Per;
                            y.CPassword = Amt;
                        });
                    }

                    ctx.SaveChanges();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully: ',1);", true);
                    ClearAllInputs();
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter Percentage or Amount.',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }

    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        try
        {
            int StateID = 0;
            Decimal DistributorID = 0, DealerID = 0;

            using (DDMSEntities ctx = new DDMSEntities())
            {
                int CustGroupID = ctx.CGRPs.FirstOrDefault(x => x.CustGroupDesc == "FOW").CustGroupID;

                if (!string.IsNullOrEmpty(txtdealer.Text))
                {
                    DealerID = Decimal.TryParse(txtdealer.Text.Split("-".ToArray()).Last().ToString(), out DealerID) ? DealerID : 0;

                    var objOCRD = ctx.OCRDs.Where(x => x.CustomerID == DealerID && x.CustGroupID == CustGroupID).Select(x => new
                     {
                         x.CustomerCode,
                         x.CustomerName,
                         Percentage = x.CUsername,
                         Amount = x.CPassword,
                         Region = x.CRD1.FirstOrDefault().OCST.StateName
                     }).ToList();

                    gvClaimConfiguration.DataSource = objOCRD;
                    gvClaimConfiguration.DataBind();
                }
                else if (!string.IsNullOrEmpty(txtCustCode.Text))
                {
                    DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().ToString(), out DistributorID) ? DistributorID : 0;
                    var objOCRD = ctx.OCRDs.Where(x => x.ParentID == DistributorID && x.CustGroupID == CustGroupID && x.Type == 3 && x.Active).Select(x => new
                    {
                        x.CustomerCode,
                        x.CustomerName,
                        Percentage = x.CUsername,
                        Amount = x.CPassword,
                        Region = x.CRD1.FirstOrDefault().OCST.StateName
                    }).ToList();

                    gvClaimConfiguration.DataSource = objOCRD;
                    gvClaimConfiguration.DataBind();
                }
                else if (!string.IsNullOrEmpty(txtState.Text))
                {
                    StateID = Int32.TryParse(txtState.Text.Split("-".ToArray()).First().ToString(), out StateID) ? StateID : 0;
                    var objOCRD = ctx.OCRDs.Where(x => x.CRD1.Any(y => y.StateID == StateID) && x.CustGroupID == CustGroupID && x.Type == 3 && x.Active).Select(x => new
                    {
                        x.CustomerCode,
                        x.CustomerName,
                        Percentage = x.CUsername,
                        Amount = x.CPassword,
                        Region = x.CRD1.FirstOrDefault().OCST.StateName
                    }).ToList();

                    gvClaimConfiguration.DataSource = objOCRD;
                    gvClaimConfiguration.DataBind();
                }

            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion
}