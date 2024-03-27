<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="CreditNote.aspx.cs" Inherits="Finance_CreditNote" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-6">
                    <div class="row _masterForm">
                        <div class="col-lg-12">
                            <div class="input-group form-group">
                                <asp:Label ID="lblCustomerCode" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCutomer" runat="server" AutoPostBack="True" OnTextChanged="txtCutomer_TextChanged" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACECustomer" runat="server" ServicePath="~/WebService.asmx" ContextKey="Sundry Debtor"
                                    UseContextKey="true" ServiceMethod="GetActiveCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                                    EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCutomer">
                                </asp:AutoCompleteExtender>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblCNDate" runat="server" Text="Credit Note Date" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCMDate" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblAmount" runat="server" Text="Amount" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtAmount" runat="server" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                            </div>
                            <div class="input-group form-group" style="margin-top: 0px">
                                <asp:Label ID="lblCNNO" runat="server" Text="Remain Amount" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtRemainAmount" runat="server" CssClass="form-control" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblValidTill" runat="server" Text="Valid Till" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtValidTill" runat="server" AutoPostBack="true" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label runat="server" ID="lblStatus" Text="Status" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlStatus" AppendDataBoundItems="true" CssClass="form-control">
                                    <asp:ListItem Value="C" Text="Confirm"></asp:ListItem>
                                    <asp:ListItem Value="U" Text="Used"></asp:ListItem>
                                    <asp:ListItem Value="L" Text="Cancel"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Notes" ID="lblNotes" runat="server" CssClass="input-group-addon" />
                                <asp:TextBox runat="server" ID="txtNotes" TextMode="MultiLine" CssClass="form-control" />
                            </div>
                        </div>

                    </div>
                </div>
                <div class="col-lg-6">
                    <asp:GridView ID="gvCreditNote" runat="server" AutoGenerateColumns="False" CssClass="table" HeaderStyle-CssClass="table-header-gradient" Style="margin-left: 1%"
                        EmptyDataText="No Record Found." OnPageIndexChanging="gvCreditNote_PageIndexChanging" PageSize="10" AllowPaging="true" OnRowCommand="gvCreditNote_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="CreditNoteID" HeaderText="Crdit Note No" SortExpression="CreditNoteID" />
                            <asp:BoundField DataField="CreditNoteDate" HeaderText="Crdit Note Date" SortExpression="CreditNoteDate" DataFormatString='{0:dd/MM/yyyy}' />
                            <asp:BoundField DataField="Amount" HeaderText="Amount" SortExpression="Amount" />
                            <asp:BoundField DataField="RemainAmount" HeaderText="Remain Amount" SortExpression="RemainAmount" />
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <asp:Label ID="lblCustomerName" runat="server" Text='<%# Eval("Status").ToString() == "C" ? "Confirm" : Eval("Status").ToString() == "U" ? "Used" : "Cancel" %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="ValidTillDate" HeaderText="Valid Till Date" SortExpression="ValidTillDate" DataFormatString='{0:dd/MM/yyyy}' />
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <asp:Button ID="btnEdit" runat="server" Text="Edit" CssClass="btn btn-default" CommandName="EditItem"
                                        CommandArgument='<%# Eval("CreditNoteID")  %>'></asp:Button>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
            <asp:Button ID="btnSubmit" CssClass="btn btn-default" runat="server"
                Text="Submit" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" />
            <asp:Button ID="btnCancel" CssClass="btn btn-default" UseSubmitBehavior="false" CausesValidation="false" runat="server"
                Text="Cancel" OnClick="btnCancel_Click" />
        </div>
    </div>

</asp:Content>
