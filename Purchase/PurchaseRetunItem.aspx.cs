using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Purchase_PurchaseRetunItem : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (Request.QueryString["ORETID"] != "" && Request.QueryString["ParentID"] != "")
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int OrderNo = Convert.ToInt32(Request.QueryString["ORETID"].ToString());
                    Decimal ParentID = Convert.ToDecimal(Request.QueryString["ParentID"].ToString());

                    var lstData = ctx.RET1.Where(x => x.ORETID == OrderNo && x.ParentID == ParentID).ToList();

                    gvItemDetail.DataSource = lstData;
                    gvItemDetail.DataBind();
                }
            }

        }
    }

}