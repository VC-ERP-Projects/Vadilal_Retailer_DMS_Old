using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Reports_Reminder : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                lvData.DataSource = ctx.OMSGs.Where(x => x.Active).OrderByDescending(x => x.CreatedDate).Select(x => new { x.Subject, x.MessageBody }).ToList();
                lvData.DataBind();
            }
        }
        catch (Exception)
        {
        }
    }
}