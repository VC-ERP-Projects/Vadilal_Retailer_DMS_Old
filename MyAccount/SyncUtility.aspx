<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="SyncUtility.aspx.cs" Inherits="MyAccount_SyncUtility" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        function ReloadRadio() {
            if ($('.chkCheck').find('input').length == $('.chkCheck:checked').find('input').length)
                $('.chkhead').prop('checked', true);
            else
                $('.chkhead').prop('checked', false);
        }

        function ClickHead(chk) {
            if ($(chk).is(':checked')) {
                $('.chkCheck').find('input').prop('checked', true);
            }
            else {
                $('.chkCheck').find('input').prop('checked', false);
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-8">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" Style="background-color: rgb(250, 255, 189);" TabIndex="2" CssClass="txtCustCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" style="display: none;">
                        <asp:Label ID="lblReqDate" runat="server" Text="Required Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtReqDate" Enabled="false" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="txtReqDate form-control"></asp:TextBox>
                    </div>
                </div>
                <%--<div class="col-lg-4"></div>--%>
            </div>
            <asp:Button ID="btnSearch" runat="server" Text="Search" TabIndex="4" CssClass="btn btn-info" OnClick="btnSearch_Click" />
            &nbsp;
            <asp:Button ID="btnSubmit" runat="server" Text="Receive Order" OnClientClick="return confirm('Are you sure to want to confirm?');" TabIndex="4" CssClass="btn btn-success" OnClick="btnSubmit_Click" />
            &nbsp;
            <asp:Button ID="btnCancel" runat="server" Text="Cancel Order" OnClientClick="return confirm('Are you sure to want to cancel order?');" TabIndex="4" CssClass="btn btn-danger" OnClick="btnCancel_Click" />
            <br />
            <br />
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView runat="server" ID="gvOrder" CssClass="gvOrder table" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" EmptyDataText="No Data Found.">
                        <Columns>
                            <asp:TemplateField HeaderText="No.">
                                <ItemTemplate>
                                    <%# Container.DataItemIndex + 1 %>
                                </ItemTemplate>
                                <HeaderStyle Width="3%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Check">
                                <HeaderTemplate>
                                    <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkcheck" class="chkCheck" Checked="true" Enabled='<%# Eval("InwardType").ToString() == "2" ? true : false %>' runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="DMS Ref No">
                                <ItemTemplate>
                                    <%# Eval("InvoiceNumber") %>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="SAP Invoice No.">
                                <ItemTemplate>
                                    <asp:Label ID="lblOrderID" Text='<%# Eval("InwardID") %>' runat="server" Visible="false"></asp:Label>
                                    <asp:Label ID="lblParentID" Text='<%# Eval("ParentID") %>' runat="server" Visible="false"></asp:Label>
                                    <%# Eval("BillNumber") %>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Date">
                                <ItemTemplate>
                                    <%# Eval("Date","{0:dd/MM/yyyy}") %>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="SAP Invoice Date">
                                <ItemTemplate>
                                    <%# Eval("InvoiceDate","{0:dd/MM/yyyy}") %>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Receive Date">
                                <ItemTemplate>
                                    <%# Eval("ReceiveDate","{0:dd/MM/yyyy}") %>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Item Total Quantity">
                                <ItemTemplate>
                                    <%# Eval("TotalItems","{0:0}") %>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Right" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="SubTotal">
                                <ItemTemplate>
                                    <%# Eval("SubTotal","{0:0.00}") %>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Right" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Tax">
                                <ItemTemplate>
                                    <%# Eval("Tax","{0:0.00}") %>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Right" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Total">
                                <ItemTemplate>
                                    <%# Eval("Total","{0:0.00}") %>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Right" />
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

