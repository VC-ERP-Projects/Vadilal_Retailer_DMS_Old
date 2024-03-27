using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class AccessError : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.QueryString["q"] != null)
        {
            if (Request.QueryString["q"] == "unquie")
                divAccessError.Visible = true;
            else if (Request.QueryString["q"] == "pnf")
                div404.Visible = true;
            else if (Request.QueryString["q"] == "ace")
                div403.Visible = true;
            else if (Request.QueryString["q"] == "isr")
                div500.Visible = true;
            else
                divAccessError.Visible = true;
        }
        else
            divAccessError.Visible = true;
    }
}