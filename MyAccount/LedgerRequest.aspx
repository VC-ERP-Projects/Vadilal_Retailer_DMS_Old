<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="LedgerRequest.aspx.cs" Inherits="MyAccount_LedgerRequest" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        $(function () {
            Reload();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Reload();
        }

        function Reload() {

            $('.txtReqDate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
            });

        }

        function _btnCheck() {

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();

            if ($('.txtDivision').val() == "") {
                IsValid = false;
            }

            return IsValid;
        }


    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">

    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" TabIndex="1" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblDivision" runat="server" Text='Division' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDivision" runat="server" TabIndex="2" CssClass="txtDivision form-control" autocomplete="off" AutoCompleteType="Disabled" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDivision" runat="server" ServicePath="~/WebService.asmx"
                            ServiceMethod="GetCustomerWiseDivision" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDivision">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Notes" ID="lblNotes" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtNotes" TextMode="MultiLine" CssClass="form-control" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" />
                        &nbsp;&nbsp;&nbsp;
                        <span style="color: blue; text-transform: lowercase" id="txtCustEmail" runat="server"></span>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Is Confirm" runat="server" CssClass="input-group-addon" ID="lblIsConfirm" />
                        <asp:CheckBox ID="chkIsConfirm" TabIndex="2" runat="server" Checked="true" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblReqDate" runat="server" Text="Required Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtReqDate" Enabled="false" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="txtReqDate form-control"></asp:TextBox>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>

