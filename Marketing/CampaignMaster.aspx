<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="CampaignMaster.aspx.cs" Inherits="Marketing_CampaignMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        $(document).ready(function () {
            $('.ChekCamp tbody tr td label').css('vertical-align', 'bottom').css('margin-right', '5px');
            $('.ChekCamp tbody tr td label').css('vertical-align', 'bottom').css('font-size', '12px');
        });
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
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCampaignName" runat="server" Text="Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCampaignName" TabIndex="1" runat="server" OnTextChanged="txtCampaignName_OnTextChanged" AutoPostBack="true" autocomplete="off" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtCampaignName" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetCampaign" MinimumPrefixLength="1" CompletionInterval="10"
                            Enabled="false" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCampaignName">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Start Date" ID="lblSDate" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtSDate" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Target People" runat="server" ID="lblTppl" CssClass="input-group-addon" />
                        <asp:CheckBoxList runat="server" ID="cblTppl" TabIndex="3" RepeatDirection="Horizontal" CssClass="ChekCamp chkwoborder form-control" Style="padding-left:3px;padding:0px;padding-top:2px">
                            <asp:ListItem Text="Consumer" Value="C" />
                            <asp:ListItem Text="Retailer" Value="R" />
                            <asp:ListItem Text="Dealer" Value="D" />
                            <asp:ListItem Text="Distributor" Value="B" />
                        </asp:CheckBoxList>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblActive" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkActive" runat="server" Checked="true" TabIndex="4" CssClass="form-control" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="End Date" ID="lblEDate" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtEDate" MaxLength="10" onkeyup="return ValidateDate(this);" TabIndex="5" CssClass="todate form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Type" ID="lblType" runat="server" CssClass="input-group-addon" />
                        <asp:CheckBoxList runat="server" ID="cblType" TabIndex="6" RepeatDirection="Horizontal" Style="padding-left:3px;padding:0px;padding-top:2px" CssClass="ChekCamp chkwoborder form-control">
                            <asp:ListItem Text="Product" Value="P" />
                            <asp:ListItem Text="Service" Value="S" />
                            <asp:ListItem Text="Other" Value="O" />
                        </asp:CheckBoxList>
                    </div>
                </div>

            </div>
            <div class="row">
                <div class="col-lg-12 _textArea">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDesc" runat="server" Text="Description" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDesc" runat="server" TabIndex="7" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>
            </div>
            <asp:Button ID="btnSubmit" runat="server" Text="Submit" TabIndex="8" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" TabIndex="9" CssClass="btn btn-default" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" />
        </div>
    </div>


</asp:Content>
