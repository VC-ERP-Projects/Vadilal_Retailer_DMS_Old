<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="TaxMaster.aspx.cs" Inherits="Master_TaxMaster" %>

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
    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label Text="Name" ID="lblTCode" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtTaxName" AutoPostBack="true" OnTextChanged="txtTaxName_TextChanged" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtTName" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetTaxName" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtTaxName">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Description" ID="lblDesc" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtDesc" TextMode="MultiLine" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label Text="Percent" ID="lblPercent" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtPercent" onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Is Active" ID="lblActive" runat="server" CssClass="input-group-addon" />
                        <asp:CheckBox ID="chkActive" runat="server" CssClass="form-control" />
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <asp:Label Text="Calculation Formula" ID="lblFormula" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtFormula" TextMode="MultiLine" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <asp:Label Text="Type" ID="lblType" runat="server" Visible="false" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlTaxType" Visible="false" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                            <asp:ListItem Text="---Select---" Value="0" Selected="True" />
                            <asp:ListItem Text="Vat" Value="V" />
                            <asp:ListItem Text="Add Vat" Value="A" />
                            <asp:ListItem Text="CST" Value="C" />
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
            </div>
        </div>
    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title">Tax Details</h3>
        </div>
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label Text="Name" ID="lblRCode" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtRCode" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label Text="Percent" ID="lblRPercentage" runat="server" CssClass="input-group-addon" />
                        <table width="100%">
                            <tr>
                                <td width="70%">
                                    <asp:TextBox runat="server" ID="txtRPercentage" onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control" />
                                </td>
                                <td width="30%">&nbsp
                                    <asp:Button Text="Add Tax" ID="btnAddTax" CssClass="btn btn-default" runat="server" OnClick="btnAddTax_Click" Style="float: right" />
                                </td>
                            </tr>
                        </table>

                    </div>
                </div>
                <br />
               
            </div>
             <asp:GridView ID="gvTax" OnPreRender="gvTax_PreRender" CssClass="gvTax HighLightRowColor2  table" runat="server" EmptyDataText="No Tax Found." AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" OnRowCommand="gvTax_RowCommand">
                    <Columns>
                        <asp:TemplateField HeaderText="No.">
                            <ItemTemplate>
                                <asp:Label ID="lblGVNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Name">
                            <ItemTemplate>
                                <asp:Label ID="lblGVCode" runat="server" Text='<%#Eval("Code") %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle Width="13%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Percentage">
                            <ItemTemplate>
                                <asp:Label ID="lblGVPer" runat="server" Text='<%#Eval("Percentage","{0:0.00}") %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle Width="15%" />
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:Button ID="btnEdit" runat="server" Text="Edit" CssClass="btn btn-default" CommandName="EditTax"
                                    CommandArgument='<%# Container.DataItemIndex  %>'></asp:Button>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-default" CommandName="DeleteTax"
                                    CommandArgument='<%# Container.DataItemIndex  %>'></asp:Button>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            
        </div>
    </div>
    <asp:Button Text="Submit" ID="btnSubmit" CssClass="btn btn-default" OnClientClick="return _btnCheck();" runat="server" OnClick="btnSubmit_Click" />
            <asp:Button Text="Cancel" ID="btnCancel" CssClass="btn btn-default" runat="server" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" />
</asp:Content>


