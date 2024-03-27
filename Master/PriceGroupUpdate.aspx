<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="PriceGroupUpdate.aspx.cs" Inherits="Master_PriceGroupUpdate" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        
        var CustType = <% = CustType%>;
        function _btnCheck() {

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        $(function () {
            ChangeReportFor('3');
            load();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ChangeReportFor('3');
            load();
        }

        function load() {
            $(".ddlDivision").change(function () {
                $('#body_txtSSCode').val('');
                $('#body_txtDistCode').val('');
                $('#body_txtDealerCode').val('');
                $('#body_txtPriceGroup').val('');
                $('.txtStatus').val('');
                $('.txtParentCode').val('');
                $('.txtUpdateDate').val('');
                $('.txtUpdatedBy').val('');
            });
            
            $(".ddlCustType").change(function () {
                $('#body_txtSSCode').val('');
                $('#body_txtDistCode').val('');
                $('#body_txtDealerCode').val('');
                $('#body_txtPriceGroup').val('');
                $('.txtStatus').val('');
                $('.txtParentCode').val('');
                $('.txtUpdateDate').val('');
                $('.txtUpdatedBy').val('');
            });
        }

        function ChangeReportFor(SelType) {
            if ($('.ddlCustType').val() == "4") {
                $('.txtSSCode').val('');
                $('.txtDistCode').val('');
                $('.txtDealerCode').val('');
                $('.divSS').removeAttr('style');
                $('.divDistributor').attr('style', 'display:none;');
                $('.divDealer').attr('style', 'display:none;');
            }
            else if ($('.ddlCustType').val() == "2") {
                $('.txtSSCode').val('');
                $('.txtDistCode').val('');
                $('.txtDealerCode').val('');
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').attr('style', 'display:none;');
                $('.divDistributor').removeAttr('style');
            }
            else {
                $('.txtSSCode').val('');
                $('.txtDistCode').val('');
                $('.txtDealerCode').val('');
                $('.divSS').attr('style', 'display:none;');
                $('.divDistributor').attr('style', 'display:none;');
                $('.divDealer').removeAttr('style');
            }
        }
     
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row" style="margin-bottom: 0px">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Division</label>
                        <asp:DropDownList runat="server" ID="ddlDivision" TabIndex="1" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Option</label>
                        <asp:DropDownList ID="ddlCustType" runat="server" CssClass="ddlCustType form-control" onchange="ChangeReportFor('2');" TabIndex="2">
                            <asp:ListItem Value="4">Super Stockist</asp:ListItem>
                            <asp:ListItem Value="2">Distributor</asp:ListItem>
                            <asp:ListItem Value="3" Selected="true">Dealer</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSCode" runat="server" TabIndex="3" OnTextChanged="txtSSCode_TextChanged" Style="background-color: rgb(250, 255, 189);" AutoPostBack="true" CssClass="form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetALLCustomerByType" MinimumPrefixLength="1" CompletionInterval="10" ContextKey="4"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" OnTextChanged="txtDistCode_TextChanged" TabIndex="4" AutoPostBack="true" CssClass="form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetALLCustomerByType" MinimumPrefixLength="1" CompletionInterval="10" ContextKey="2"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDealer" id="divDealer" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" OnTextChanged="txtDlrCode_TextChanged" TabIndex="5" AutoPostBack="true" CssClass="form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetALLCustomerByType" MinimumPrefixLength="1" CompletionInterval="10" ContextKey="3"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divPriceGroup" runat="server">
                        <asp:Label ID="lblPriceGroup" runat="server" Text="Price Group" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPriceGroup" runat="server" TabIndex="6" CssClass="txtPriceGroup form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtPriceList" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetPriceListByID" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPriceGroup">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblStatus" runat="server" Text="Status" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtStatus" runat="server" TabIndex="7" CssClass="txtStatus form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="div1" runat="server">
                        <asp:Label ID="lblParentCode" runat="server" Text="Parent Code & Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtParentCode" runat="server" TabIndex="8" CssClass="txtParentCode form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="div2" runat="server">
                        <asp:Label ID="lblUpdateDate" runat="server" Text="Update Date/Time" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtUpdateDate" TabIndex="9" runat="server" CssClass="txtUpdateDate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="div3" runat="server">
                        <asp:Label ID="lblUpdatedBy" runat="server" Text="Update By" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtUpdatedBy" runat="server" TabIndex="10" CssClass="txtUpdatedBy form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnSubmit" CssClass="btn btn-default" runat="server" TabIndex="11" Text="Submit" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" />
                        &nbsp;
                        <asp:Button ID="btnCancel" UseSubmitBehavior="false" CausesValidation="false" TabIndex="12" CssClass="btn btn-default" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>
    </div>
</asp:Content>


