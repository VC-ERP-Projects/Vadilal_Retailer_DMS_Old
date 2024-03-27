using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Transactions;
using System.Data;
using System.Drawing;

/// <summary>
/// Summary description for GridViewTemplate
/// </summary>

//A customized class for displaying the Template Column
public class GridViewTemplate : ITemplate
{

    public enum Controls
    {
        Textbox,
        Lable,
        CheckBox
    }

    //A variable to hold the type of ListItemType.
    ListItemType _templateType;

    //A variable to hold the column name.
    string _columnName;

    string _id;

    Boolean _Enabled;

    string _controls;

    string _javascriptName;
    //Constructor where we define the template type and column name.
    public GridViewTemplate(ListItemType type, string colname, string ID = "", Boolean Enabled = true, Controls Con = Controls.Textbox, string javascriptName ="")
    {
        //Stores the template type.
        _templateType = type;

        //Stores the column name.
        _columnName = colname;
        _id = ID;
        _Enabled = Enabled;
        _controls = Con.ToString();
        _javascriptName = javascriptName;
    }

    void ITemplate.InstantiateIn(System.Web.UI.Control container)
    {
        switch (_templateType)
        {
            case ListItemType.Header:
                //Creates a new label control and add it to the container.
                Label lbl = new Label();            //Allocates the new label object.
                lbl.Text = _columnName;             //Assigns the name of the column in the lable.
                container.Controls.Add(lbl);        //Adds the newly created label control to the container.
                break;

            case ListItemType.Item:

                if (_controls.ToString() == Controls.Textbox.ToString())
                {
                    TextBox tb1 = new TextBox();                            //Allocates the new text box object.

                    tb1.DataBinding += new EventHandler(tb1_DataBinding);   //Attaches the data binding event.
                    tb1.Columns = 4;                                        //Creates a column with size 4.
                    tb1.Enabled = _Enabled;
                    tb1.ID = _id;
                    tb1.Attributes.Add("onkeyup", "return isNumberKey(event);");
                    if (_javascriptName != "")
                    {
                        tb1.Attributes.Add("onkeyup", "return " + _javascriptName + "(this,'" + _id + "');");
                    }
                    container.Controls.Add(tb1);                            //Adds the newly created textbox to the container.

                    if (_javascriptName.ToString().ToUpper() == "CHANGECHECKBOXVALUE")
                    {
                        CheckBox chk = new CheckBox();                            //Allocates the new text box object.                       
                        chk.Checked = true;
                        chk.Attributes.Add("onClick", "CalculateQty(this);");
                        chk.ID = "chkTotalAllocation";
                        container.Controls.Add(chk);   
                    }
                    break;
                }
                else if (_controls.ToString() == Controls.Lable.ToString())
                {
                    Label lbl1 = new Label();                            //Allocates the new text box object.
                    lbl1.DataBinding += new EventHandler(lbl_DataBinding);   //Attaches the data binding event.                                        
                    lbl1.ID = _id;
                    container.Controls.Add(lbl1);                            //Adds the newly created textbox to the container.
                    break;
                }
                else 
                {
                    CheckBox chk = new CheckBox();                            //Allocates the new text box object.
                    //chk.DataBinding += new EventHandler(lbl_DataBinding);   //Attaches the data binding event.                                        
                    chk.ID = _id;
                    container.Controls.Add(chk);                            //Adds the newly created textbox to the container.
                    break;
                }
            //Creates a new text box control and add it to the container.


            //case ListItemType.Item1:
            //    Creates a new text box control and add it to the container.
            //    TextBox tb1 = new TextBox();                            //Allocates the new text box object.
            //    tb1.DataBinding += new EventHandler(tb1_DataBinding);   //Attaches the data binding event.
            //    tb1.Columns = 4;                                        //Creates a column with size 4.
            //    container.Controls.Add(tb1);                            //Adds the newly created textbox to the container.
            //    break;

            case ListItemType.EditItem:
                //As, I am not using any EditItem, I didnot added any code here.
                break;

            case ListItemType.Footer:
                CheckBox chkColumn = new CheckBox();
                chkColumn.ID = "Chk" + _columnName;
                container.Controls.Add(chkColumn);
                break;
        }
    }

    /// <summary>
    /// This is the event, which will be raised when the binding happens.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    void tb1_DataBinding(object sender, EventArgs e)
    {
        TextBox txtdata = (TextBox)sender;
        GridViewRow container = (GridViewRow)txtdata.NamingContainer;
        object dataValue = DataBinder.Eval(container.DataItem, _columnName);

        if (dataValue != DBNull.Value)
        {
            txtdata.Text = dataValue.ToString();
        }
    }

    void lbl_DataBinding(object sender, EventArgs e)
    {
        Label txtdata = (Label)sender;
        GridViewRow container = (GridViewRow)txtdata.NamingContainer;
        object dataValue = DataBinder.Eval(container.DataItem, _columnName);

        if (dataValue != DBNull.Value)
        {
            txtdata.Text = dataValue.ToString();
        }
    }
}
