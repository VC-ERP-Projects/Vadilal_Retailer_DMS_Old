using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity.Validation;
using System.Data.Objects;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Sales_EInvoiceJsonUpload : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
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
                int CustType = Convert.ToInt32(Session["Type"]);

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
                            var unit = xml.Descendants("change_password");
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

    #endregion
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        gvMissdata.DataSource = null;
        gvMissdata.DataBind();

        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(btnCUpload);
    }
    #region Button Click

    protected void btnCUpload_Click(object sender, EventArgs e)
    {
        try
        {
           

            DataTable missdata = new DataTable();
            missdata.Columns.Add("Invoice No");
            missdata.Columns.Add("Invoice Date");
            missdata.Columns.Add("GSTIN");
            missdata.Columns.Add("Dealer Name");
            missdata.Columns.Add("Sup Type");
            missdata.Columns.Add("Invoice Total");
            missdata.Columns.Add("ErrorMsg");

            bool flag = true;

            if (flCUpload.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedGSTFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedGSTFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedGSTFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flCUpload.PostedFile.FileName));
                flCUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flCUpload.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtPOH = new DataTable();
                    

                    if (dtPOH != null && dtPOH.Rows != null && dtPOH.Rows.Count > 0)
                    {
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtPOH.Rows)
                            {
                                String DealerCode = item["Dealer Code"].ToString();
                                string DivisionCode = item["Division Code"].ToString();

                                if (ctx.OCRDs.Any(x => x.CustomerCode == DealerCode && x.Type == 3 && x.Active))
                                {
                                    if (ctx.ODIVs.Any(x => x.DivisionCode == DivisionCode && x.Active))
                                    {
                                        if (!string.IsNullOrEmpty(item["From"].ToString()) && !string.IsNullOrEmpty(item["Up To"].ToString()) &&
                                            !string.IsNullOrEmpty(item["Comp. Cont. In %"].ToString()) && !string.IsNullOrEmpty(item["Dist. Cont. In %"].ToString())
                                            && !string.IsNullOrEmpty(item["Expected Sale"].ToString()))
                                        {
                                            Decimal DecNum = 0;
                                            DateTime dt;


                                            if (Decimal.TryParse(item["Comp. Cont. In %"].ToString(), out DecNum) &&
                                               Decimal.TryParse(item["Dist. Cont. In %"].ToString(), out DecNum) &&
                                               Decimal.TryParse(item["Expected Sale"].ToString(), out DecNum) &&
                                               DateTime.TryParse(item["From"].ToString(), out dt) &&
                                               DateTime.TryParse(item["Up To"].ToString(), out dt))
                                            {

                                            }
                                            else
                                            {
                                                DataRow missdr = missdata.NewRow();
                                                missdr["Dealer Code"] = DealerCode;
                                                missdr["From"] = item["From"].ToString();
                                                missdr["Up To"] = item["Up To"].ToString();
                                                missdr["Comp. Cont. In %"] = item["Comp. Cont. In %"].ToString();
                                                missdr["Dist. Cont. In %"] = item["Dist. Cont. In %"].ToString();
                                                missdr["Expected Sale"] = item["Expected Sale"].ToString();
                                                missdr["Division Code"] = DivisionCode;
                                                missdr["ErrorMsg"] = "Data is not proper.";
                                                missdata.Rows.Add(missdr);
                                                flag = false;
                                            }
                                        }
                                        else
                                        {
                                            DataRow missdr = missdata.NewRow();
                                            missdr["Dealer Code"] = DealerCode;
                                            missdr["From"] = item["From"].ToString();
                                            missdr["Up To"] = item["Up To"].ToString();
                                            missdr["Comp. Cont. In %"] = item["Comp. Cont. In %"].ToString();
                                            missdr["Dist. Cont. In %"] = item["Dist. Cont. In %"].ToString();
                                            missdr["Expected Sale"] = item["Expected Sale"].ToString();
                                            missdr["Division Code"] = DivisionCode;
                                            missdr["ErrorMsg"] = "Data is not proper.";
                                            missdata.Rows.Add(missdr);
                                            flag = false;
                                        }
                                    }
                                    else
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Dealer Code"] = DealerCode;
                                        missdr["From"] = "";
                                        missdr["Up To"] = "";
                                        missdr["Comp. Cont. In %"] = "";
                                        missdr["Dist. Cont. In %"] = "";
                                        missdr["Expected Sale"] = "";
                                        missdr["Division Code"] = DivisionCode;
                                        missdr["ErrorMsg"] = "'" + DivisionCode + "' does not exist or not active.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Dealer Code"] = DealerCode;
                                    missdr["From"] = "";
                                    missdr["Up To"] = "";
                                    missdr["Comp. Cont. In %"] = "";
                                    missdr["Dist. Cont. In %"] = "";
                                    missdr["Expected Sale"] = "";
                                    missdr["Division Code"] = "";
                                    missdr["ErrorMsg"] = "Dealer Code: '" + DealerCode + "' does not exist or not active.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                            }
                        }
                    }

                    if (flag)
                    {

                        if (dtPOH != null && dtPOH.Rows != null && dtPOH.Rows.Count > 0)
                        {
                            using (DDMSEntities ctx = new DDMSEntities())
                            {
                                int SchemeID = ctx.GetKey("OSCM", "SchemeID", "", 0, 0).FirstOrDefault().Value;
                                int SCM1Count = ctx.GetKey("SCM1", "SCM1ID", "", 0, 0).FirstOrDefault().Value;
                                int SCM3Count = ctx.GetKey("SCM3", "SCM3ID", "", 0, 0).FirstOrDefault().Value;
                                int SchemeCount = ctx.GetKey("SCM4", "SCM4ID", "", 0, 0).FirstOrDefault().Value;

                                foreach (DataRow item in dtPOH.Rows)
                                {
                                    try
                                    {
                                        String DealerCode = item["Dealer Code"].ToString();

                                        var objDealer = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DealerCode && x.Type == 3);
                                        if (objDealer != null)
                                        {
                                            ctx.SCM1.Where(x => x.OSCM.ApplicableMode == "M" && x.CustomerID == objDealer.CustomerID).ToList().ForEach(x => x.Active = false);

                                            DateTime Startdate = Convert.ToDateTime(item["From"].ToString());
                                            DateTime EndDate = Convert.ToDateTime(item["Up To"].ToString());

                                            Decimal ComPercentage = Convert.ToDecimal(item["Comp. Cont. In %"].ToString());
                                            Decimal DistPercenatage = Convert.ToDecimal(item["Dist. Cont. In %"].ToString());
                                            Decimal ExpectedSale = Convert.ToDecimal(item["Expected Sale"].ToString());

                                            OSCM objOSCM = null;
                                            SCM4 objSCM4 = ctx.SCM4.Include("OSCM").FirstOrDefault(x => x.OSCM.ApplicableMode == "M" && x.HigherLimit == ExpectedSale && x.CompanyDisc == ComPercentage && x.DistributorDisc == DistPercenatage
                                                && EntityFunctions.TruncateTime(x.OSCM.StartDate) == EntityFunctions.TruncateTime(Startdate) && EntityFunctions.TruncateTime(x.OSCM.EndDate) == EntityFunctions.TruncateTime(EndDate));
                                            if (objSCM4 == null)
                                            {
                                                objOSCM = new OSCM();
                                                objOSCM.SchemeID = SchemeID++;
                                                objOSCM.StartDate = Startdate;
                                                objOSCM.EndDate = EndDate;
                                                objOSCM.ReasonID = null;
                                                objOSCM.SchemeCode = "SC" + objOSCM.SchemeID.ToString();
                                                objOSCM.SchemeName = "Scheme" + objOSCM.SchemeID.ToString();
                                                objOSCM.Active = true;
                                                objOSCM.ApplicableMode = "M";
                                                objOSCM.ReasonID = null;
                                                if (ctx.ORSNs.Any(x => x.ReasonDesc == "M" && x.Active))
                                                {
                                                    objOSCM.ReasonID = ctx.ORSNs.FirstOrDefault(x => x.ReasonDesc == "M" && x.Active).ReasonID;
                                                }

                                                objOSCM.ApplicableOn = 3;
                                                objOSCM.BirthDay = true;
                                                objOSCM.Anniversary = true;
                                                objOSCM.SpecialDay = true;
                                                objOSCM.Monday = true;
                                                objOSCM.Tuesday = true;
                                                objOSCM.Wednesday = true;
                                                objOSCM.Thursday = true;
                                                objOSCM.Friday = true;
                                                objOSCM.Saturday = true;
                                                objOSCM.Sunday = true;
                                                objOSCM.IsTaxApplicable = false;
                                                objOSCM.Remarks = null;

                                                objOSCM.CreatedDate = DateTime.Now;
                                                objOSCM.CreatedBy = UserID;

                                                objOSCM.UpdatedDate = DateTime.Now;
                                                objOSCM.UpdatedBy = UserID;

                                                ctx.OSCMs.Add(objOSCM);

                                                //SCM4     
                                                objSCM4 = new SCM4();

                                                objSCM4.SCM4ID = SchemeCount++;
                                                objSCM4.CompanyDisc = ComPercentage;
                                                objSCM4.DistributorDisc = DistPercenatage;
                                                objSCM4.SchemeID = objOSCM.SchemeID;
                                                objSCM4.Discount = (ComPercentage + DistPercenatage);
                                                objSCM4.LowerLimit = 0;
                                                objSCM4.HigherLimit = ExpectedSale;
                                                objSCM4.ItemGroupID = null;
                                                objSCM4.ItemSubGroupID = null;
                                                objSCM4.ItemID = null;
                                                objSCM4.Occurrence = 0;
                                                objSCM4.Quantity = 0;
                                                objSCM4.BasedOn = 1;
                                                objSCM4.DiscountType = "P";
                                                objOSCM.SCM4.Add(objSCM4);
                                            }
                                            else
                                            {
                                                objSCM4.OSCM.UpdatedDate = DateTime.Now;
                                                objSCM4.OSCM.UpdatedBy = UserID;
                                            }


                                            ctx.SaveChanges();
                                        }
                                    }
                                    catch (DbEntityValidationException ex)
                                    {
                                        var error = ex.EntityValidationErrors.First().ValidationErrors.First();
                                        if (error != null)
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + error.ErrorMessage.Replace("'", "") + "',2);", true);
                                        else
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                                        return;
                                    }

                                }
                            }
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);
                        }
                    }
                    else
                    {
                        gvMissdata.DataSource = missdata;
                        gvMissdata.DataBind();
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }
    #endregion
}