<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="CollectedCheques.aspx.cs" Inherits="Finance_CollectedCheques" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="center-block">
                <asp:Button ID="btnDeposit" CssClass="btn btn-default" TabIndex="1" runat="server"
                    Text="Submit" OnClick="btnDeposit_Click" />
                <asp:Button ID="btnCancel" CssClass="btn btn-default" runat="server"
                    Text="Cancel" OnClick="btnCancel_Click" UseSubmitBehavior="false" TabIndex="2" CausesValidation="false" />
            </div>
            <br />
            <br />
            <asp:DropDownList runat="server" ID="ddlStatus" AutoPostBack="true" TabIndex="3" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged" CssClass="form-control">
                <asp:ListItem Text="Pending" Value="P" Selected="True" />
                <asp:ListItem Text="Deposit" Value="U" />
                <asp:ListItem Text="Reconcile" Value="R" />
                <asp:ListItem Text="Cancel" Value="L" />
            </asp:DropDownList>
            <br />
            <asp:GridView ID="gvCollectedCheques" runat="server" AutoGenerateColumns="False" CssClass="table" OnRowDataBound="gvCollectedCheques_RowDataBound" EmptyDataText="No Record Found." HeaderStyle-CssClass="table-header-gradient" Width="100%">
                <Columns>
                    <asp:TemplateField HeaderText="Select">
                        <ItemTemplate>
                            <asp:CheckBox runat="server" ID="chkCheck" />
                            <asp:Label Visible="false" ID="lblID" runat="server" Text='<%# Eval("POS2ID") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <asp:DropDownList runat="server" ID="ddlStatus" SelectedValue='<%# Eval("Status") %>' CssClass="form-control">
                                <asp:ListItem Text="Pending" Value="P" Selected="True" />
                                <asp:ListItem Text="Deposit" Value="U" />
                                <asp:ListItem Text="Reconcile" Value="R" />
                                <asp:ListItem Text="Cancel" Value="L" />
                            </asp:DropDownList>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Customer Name">
                        <ItemTemplate>
                            <asp:Label ID="lblCustomerID" Visible="false" runat="server" Text='<%# Bind("CustomerID") %>'></asp:Label>
                            <asp:Label ID="lblCustomerName" runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Amount">
                        <ItemTemplate>
                            <asp:Label ID="lblAmount" runat="server" Text='<%# Bind("Amount","{0:0.00}") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Bank">
                        <ItemTemplate>
                            <asp:Label ID="lblBankName" runat="server" Text='<%# Bind("DocName") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Cheque No.">
                        <ItemTemplate>
                            <asp:Label ID="lblchqno" runat="server" Text='<%# Bind("DocNo") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Cheque Date">
                        <ItemTemplate>
                            <asp:Label ID="lblchqdate" runat="server" Text='<%# Bind("Date","{0:dd/MM/yyyy}") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Deposit Date">
                        <ItemTemplate>
                            <asp:TextBox ID="txtDepositDate" onfocus="this.blur();" CssClass="form-control datepick" runat="server" Text='<%# Bind("DepositDate","{0:dd/MM/yyyy}") %>'></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Reconcile Date">
                        <ItemTemplate>
                            <asp:TextBox ID="txtReconcileDate" onfocus="this.blur();" CssClass="form-control datepick" runat="server" Text='<%# Bind("ReconcileDate","{0:dd/MM/yyyy}") %>'></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Notes">
                        <ItemTemplate>
                            <asp:TextBox ID="txtNotes" runat="server" CssClass="form-control"></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>

