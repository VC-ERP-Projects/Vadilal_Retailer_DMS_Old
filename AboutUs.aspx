<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="AboutUs.aspx.cs" Inherits="AboutUs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">

    <div class="panel" style="margin-left: 12px">
        <div class="panel-body">
            <div class="row">
                <table width="100%">
                    <tr>
                        <td width="50%">
                            <asp:Label runat="server" Style="width: 50%"><strong style="text-decoration:underline;font-size: 30px; ">User Manual</strong></asp:Label></td>

                    </tr>
                </table>

            </div>
            <div class="row">
                <div class="col-lg-12">
                    <table class="table">
                        <tr style="border-bottom: 1px solid #CCC; height: 80px;">
                            <td width="10%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: center; vertical-align: middle">
                                <asp:LinkButton OnClientClick="return setfunc('admin');" PostBackUrl="~/AboutPDF.aspx" runat="server"><img src="Images/Admin.png" Style="width: 100%;"/></asp:LinkButton>
                            </td>
                            <td width="40%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: justify" align="left">
                                <asp:Label Text="Administration helps you to give authorization to different employee group and allows you to change password" runat="server" ID="lblMaster" />
                            </td>
                            <td width="10%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: center; vertical-align: middle">

                                <asp:LinkButton OnClientClick="return setfunc('purchase');" PostBackUrl="~/AboutPDF.aspx" runat="server"><img src="Images/Purchase.png" Style="width: 100%;"/></asp:LinkButton>
                            </td>
                            <td width="40%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: justify" align="left">
                                <asp:Label Text="Purchase order will allow you to place your purchase order from the company vendors as well as local vendors." runat="server" ID="lblInventory" />
                            </td>
                        </tr>
                        <tr style="border-bottom: 1px solid #CCC; height: 80px;">
                            <td width="10%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: center; vertical-align: middle">

                                <asp:LinkButton OnClientClick="return setfunc('master');" PostBackUrl="~/AboutPDF.aspx" runat="server"><img src="Images/Master.png" Style="width: 100%;"/></asp:LinkButton>
                            </td>
                            <td width="40%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: justify" align="left">
                                <asp:Label Text="Master page will allow you to make entry in all the master pages. General Masters include masters of expense, customer group, relation, employee group, city, state, country, food type and question" runat="server" ID="lblRoute" />
                            </td>
                            <td width="10%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: center; vertical-align: middle">

                                <asp:LinkButton OnClientClick="return setfunc('sales');" PostBackUrl="~/AboutPDF.aspx" runat="server"><img src="Images/Sales.png" Style="width: 100%;"/></asp:LinkButton>
                            </td>
                            <td width="40%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: justify" align="left">
                                <asp:Label Text="Sales module includes day close and handover payment. Day close will help you to view the day close for that particular day." runat="server" ID="lblFleet" />

                            </td>
                        </tr>
                        <tr style="border-bottom: 1px solid #CCC; height: 80px;">
                            <td width="10%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: center; vertical-align: middle">

                                <asp:LinkButton OnClientClick="return setfunc('bp');" PostBackUrl="~/AboutPDF.aspx" runat="server"><img src="Images/BP.png" Style="width: 100%;"/></asp:LinkButton>
                            </td>
                            <td width="40%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: justify" align="left">
                                <asp:Label Text="Business Partner includes the form to add new vendors and customers. You can add and update local vendors here. On the form of customer, you have the facility to add new customers of different customer groups that are defined in master." runat="server" ID="lblDailyactivity" />

                            </td>
                            <td width="10%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: center; vertical-align: middle">

                                <asp:LinkButton OnClientClick="return setfunc('crm');" PostBackUrl="~/AboutPDF.aspx" runat="server"><img src="Images/CRM.png" Style="width: 100%;"/></asp:LinkButton>
                            </td>
                            <td width="40%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: justify" align="left">
                                <asp:Label Text="CRM has all the details related to the feedback of products given by client. It also has the details of the company in company profile, and it also shows you product profile." runat="server" ID="lblFinance" />
                            </td>
                        </tr>
                        <tr style="border-bottom: 1px solid #CCC; height: 80px;">
                            <td width="10%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: center; vertical-align: middle">

                                <asp:LinkButton OnClientClick="return setfunc('hrms');" PostBackUrl="~/AboutPDF.aspx" runat="server"><img src="Images/HRMS.png" Style="width: 100%;"/></asp:LinkButton>
                            </td>
                            <td width="40%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: justify" align="left">
                                <asp:Label Text="HRMS includes the employee master. It allows you to enter the details of employees and update existing one.Employee master will allow you to enter the details of the new employee or update the information of existing employees." runat="server" ID="lblOrder" />
                            </td>
                            <td width="10%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: center; vertical-align: middle">

                                <asp:LinkButton OnClientClick="return setfunc('utility');" PostBackUrl="~/AboutPDF.aspx" runat="server"><img src="Images/utility.png" Style="width: 100%;"/></asp:LinkButton>
                            </td>
                            <td width="40%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: justify" align="left">
                                <asp:Label Text="This utility will help you sync your data with live server. Get data will help you get master data i.e. new items, or change in items or their price. Sync data with SAP will help you sync your data to SAP database." runat="server" ID="lblMarketing" />

                            </td>
                        </tr>
                        <tr style="height: 80px;">
                            <td width="10%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: center; vertical-align: middle">

                                <asp:LinkButton OnClientClick="return setfunc('inventory');" PostBackUrl="~/AboutPDF.aspx" runat="server"><img src="Images/Inventory.png" Style="width: 100%;"/></asp:LinkButton>
                            </td>
                            <td width="40%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: justify" align="left">
                                <asp:Label Text="Inventory module has all the details of the warehouse and quantity in it. Bill of material allows you to make new BOM and update existing ones. Wastage allows you to do entry of materials that are wasted in a day. Consume allows you to do the entry of the materials that are auto consumed on that day." runat="server" ID="lblInvoice" />
                            </td>
                            <td width="10%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: center; vertical-align: middle">

                                <asp:LinkButton OnClientClick="return setfunc('report');" PostBackUrl="~/AboutPDF.aspx" runat="server"><img src="Images/1Reports.png" Style="width: 100%;"/></asp:LinkButton>
                            </td>
                            <td width="40%" style="-webkit-box-shadow: .0px 0px 0px .0px #888; box-shadow: .0px 0px 0px .0px #888; text-align: justify" align="left">
                                <asp:Label Text="Reports and Analytics will give you all the type of reports, you need. It will show you the stock reports as well as reports related to accounts also and all other modules too. " runat="server" ID="lblReports" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </div>





</asp:Content>

