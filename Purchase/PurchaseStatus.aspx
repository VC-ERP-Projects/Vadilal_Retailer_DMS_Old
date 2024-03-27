<%@ Page Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="PurchaseStatus.aspx.cs" Inherits="Purchase_PurchaseStatus" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>

    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>


    <script type="text/javascript">

        $(function () {
            Reload();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Reload();
        }

        function OpenPoUtility(lnk) {

            var Data = $(lnk).parent().parent();

            var ParentID = Data.find('.lblParentID').text();
            var InwardID = Data.find('.lblOrderID').text();

            $.colorbox({
                width: '90%',
                height: '90%',
                iframe: true,
                href: '../Master/POItemUtility.aspx?InwardID=' + InwardID + '&DistributorID=' + ParentID,
                onClosed: function () {
                    //parent.location.reload();
                }
            });
        }

        function Reload() {
            if ($('.gvOrder thead tr').length > 0) {

                $('.gvOrder').DataTable(
                    {
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '50vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "bPaginate": false
                    });
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" onfocus="this.blur();" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-default" OnClick="btnSearch_Click" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" onfocus="this.blur();" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDisplay" runat="server" Text="Display" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlDisplay" CssClass="form-control">
                            <asp:ListItem Text="Success" Value="1" />
                            <asp:ListItem Text="Error" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group" runat="server" id="divInward">
                        <asp:Label ID="lblDocNo" runat="server" Text="Inward Number" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtDocNo" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDocNumber" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetInwardReportNo" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDocNo">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12" style="height: 430px; overflow-x: auto;">
                    <asp:GridView runat="server" ID="gvOrder" AutoGenerateColumns="false" Style="font-size: 11px; width: auto;" CssClass="gvOrder table nowrap" OnRowCommand="gvOrder_RowCommand" OnPreRender="gvOrder_PreRender" HeaderStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found.">
                        <Columns>
                            <asp:TemplateField HeaderText="Sr." HeaderStyle-Width="3%">
                                <ItemTemplate>
                                    <%#Container.DataItemIndex+1 %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Distributor Code & Name" ItemStyle-Width="25%" HeaderStyle-Width="25%">
                                <ItemTemplate>
                                    <asp:Label ID="lblCustName" runat="server" Text='<%# Eval("Customer") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="PO Date/Time" ItemStyle-Width="10%" HeaderStyle-Width="10%">
                                <ItemTemplate>
                                    <asp:Label ID="lblTotalInvoice" runat="server" Text='<%# Eval("Date","{0:dd/MM/yyyy HH:mm}") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="PO NO." ItemStyle-Width="4%" HeaderStyle-Width="4%">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkOrderNo" Text='<%# Eval("InvoiceNumber") %>' Visible='<%# ddlDisplay.SelectedValue == "1" ? false : true %>' runat="server" OnClientClick="OpenPoUtility(this);"></asp:LinkButton>
                                    <asp:Label ID="lblOrderNo" Text='<%# Eval("InvoiceNumber") %>' Visible='<%# ddlDisplay.SelectedValue == "1" ? true : false %>' runat="server"></asp:Label>
                                    <asp:Label ID="lblOrderID" CssClass="lblOrderID" Text='<%# Eval("InwardID") %>' runat="server" Style="display: none;"></asp:Label>
                                    <asp:Label ID="lblParentID" CssClass="lblParentID" Text='<%# Eval("ParentID") %>' runat="server" Style="display: none;"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Division" ItemStyle-Width="7%" HeaderStyle-Width="7%">
                                <ItemTemplate>
                                    <asp:Label ID="lblDivision" runat="server" Text='<%# Eval("DivisionName") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Qty" ItemStyle-Width="3%" HeaderStyle-Width="3%" ItemStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="lblqty" runat="server" Text='<%# Eval("Qty","{0:0}") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Gross Amount" ItemStyle-Width="5%" HeaderStyle-Width="5%" ItemStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="lblGrossAmount" runat="server" Text='<%# Eval("GrossAmount","{0:0.00}") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Tax Amount" ItemStyle-Width="5%" HeaderStyle-Width="5%" ItemStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="lblTax" Text='<%# Eval("TaxAmount","{0:0.00}") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Net Amount" ItemStyle-Width="5%" HeaderStyle-Width="5%" ItemStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="lblTotal" Text='<%# Eval("NetAmount","{0:0.00}") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Paid Amount" ItemStyle-Width="5%" HeaderStyle-Width="5%" ItemStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="lblPaid" Text='<%# Eval("PaidAmount","{0:0.00}") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Pending Amount" ItemStyle-Width="5%" HeaderStyle-Width="5%" ItemStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="lblPending" runat="server" Text='<%# Eval("PendingAmount","{0:0.00}") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Plant Code & Name" ItemStyle-Width="10%" HeaderStyle-Width="10%">
                                <ItemTemplate>
                                    <asp:Label ID="lblplant" runat="server" Text='<%# Eval("PlantName") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Last Updated Date" ItemStyle-Width="10%" HeaderStyle-Width="10%">
                                <ItemTemplate>
                                    <asp:Label ID="lblUpdatedDate" runat="server" Text='<%# Eval("UpdatedDte","{0:dd/MM/yyyy HH:mm}") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Message" ItemStyle-Width="35%" HeaderStyle-Width="30%">
                                <ItemTemplate>
                                    <asp:Label ID="lblMessage" runat="server" Text='<%# Eval("Message") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Re-send" ItemStyle-Width="7%" HeaderStyle-Width="7%" Visible="false">
                                <ItemTemplate>
                                    <asp:Button ID="btnResend" runat="server" Text="Resend" CommandName="RESEND" CommandArgument="<%# ((GridViewRow) Container).RowIndex %>" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

