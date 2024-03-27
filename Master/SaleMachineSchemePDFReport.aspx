<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="SaleMachineSchemePDFReport.aspx.cs" Inherits="Master_SaleMachineSchemePDFReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        var ParentID = <% = ParentID%>;
        var CustType = '<% =CustType%>';

        function autoCompletePlant_OnClientPopulating(sender, args) {
            var key = $('.txtRegion').val().split('-')[0];
            sender.set_contextKey(key);
        }
        $(function () {
            Relaod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function _btnCheck() {
            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }

        function autoCompleteDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }
        function EndRequestHandler2(sender, args) {
            Relaod();
        }

        //added by dipali for datepicker validation

        function Relaod() {
            $(document).ready(function () {
                var today = new Date();
                var fromDateInput = $('.datepicker');
                var toDateInput = $('.datepicker1');

                fromDateInput.datepicker({
                    autoclose: true,
                    minDate: today,
                    dateFormat: 'dd/mm/yy',
                    onSelect: function (selectedDate) {
                        var fromDate = $(this).datepicker('getDate');
                        toDateInput.datepicker('option', 'minDate', fromDate);
                    }
                });

                toDateInput.datepicker({
                    autoclose: true,
                    minDate: today,
                    dateFormat: 'dd/mm/yy',
                    onSelect: function (selectedDate) {
                        var toDate = $(this).datepicker('getDate');
                        fromDateInput.datepicker('option', 'maxDate', toDate);
                    }
                });

                fromDateInput.click(function () {
                    $(this).datepicker('show');
                });
                fromDateInput.change(function () {
                    $(this).datepicker('show');
                });

                toDateInput.click(function () {
                    $(this).datepicker('show');
                });
            })
        }
        function PreventDeleteAndBackspace(e) {
            var keyCode = e.keyCode || e.which;

            // 8 is the keyCode for Backspace
            // 46 is the keyCode for Delete
            if (keyCode === 8 || keyCode === 46) {
                e.preventDefault();
            }
        }

         //function autoCompleteDistriCode_OnClientPopulating(sender, args) {
         //    var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
         //    var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
         //    var ss = "";
         //    if (CustType == 4)
         //        ss = $('.txtDistRegion').is(":visible") ? $('.txtDistRegion').val().split('-').pop() : ParentID;
         //    else
         //        ss = $('.txtDistRegion').is(":visible") ? $('.txtDistRegion').val().split('-').pop() : "0";
         //    sender.set_contextKey(reg + "-0-" + "0" + "-" + ss + "-" + EmpID);
         //}


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblNo" runat="server" Text="No." CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPolicyNo" runat="server" OnTextChanged="txtPolicyNo_TextChanged" CssClass="form-control" AutoPostBack="true" autocomplete="off" data-bv-notempty="true" TabIndex="1" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtName" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetSaleMachineSchemeNo" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPolicyNo">
                        </asp:AutoCompleteExtender>
                    </div>

                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" CssClass="datepicker1 form-control" TabIndex="4" onkeyup="return ValidateDate(this);" onkeydown="PreventDeleteAndBackspace(event);"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblDistRegion" runat="server" Text='Dist. Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistRegion" CssClass="form-control txtDistCode" runat="server" TabIndex="7" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender3" runat="server"
                            ServiceMethod="SaleSchmeGetDistributorRegionCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtDistRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                        <%--<asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender3" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistRegion">
                        </asp:AutoCompleteExtender>--%>
                    </div>

                    <asp:Button ID="btnSubmit" runat="server" Text="Submit" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" CssClass="btn btn-default" TabIndex="10" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" TabIndex="11" />

                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPolicyName" runat="server" Text="Scheme Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPName" runat="server" CssClass="form-control" data-bv-notempty="true" autocomplete="off" data-bv-notempty-message="Field is required" TabIndex="2"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblemployee" runat="server" Text='Employee' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" CssClass="txtCode form-control txtCode" TabIndex="5" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeListSalesSchme" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>


                    <%--<div class="input-group form-group">
                        <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPlant" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtPlant form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServiceMethod="GetPlant"
                            ServicePath="../WebService.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>--%>

                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Upload File" ID="lblUpload" CssClass="input-group-addon"></asp:Label>
                        <asp:FileUpload ID="flCUpload" runat="server" CssClass="form-control" TabIndex="8" />
                    </div>
                    <div class="input-group form-group">
                        <a href="#" target="_blank" id="lnkDownloadFile" runat="server"></a>
                    </div>

                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" TabIndex="3" runat="server" MaxLength="10" CssClass="datepicker form-control" onkeyup="return ValidateDate(this);" onkeydown="PreventDeleteAndBackspace(event);"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Dealer Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealRegion" CssClass="txtRegion form-control" TabIndex="6" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <%--<asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" OnClientPopulating="autoCompleteDealerCode_OnClientPopulating"
                            ServiceMethod="SaleMachineGetDealerRegionCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtDealRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>--%>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                            ServiceMethod="GetStatesCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtDealRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>

                    </div>

                    <div class="input-group form-group">
                        <asp:Label ID="lblAStatus" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkAcitve" runat="server" Checked="true" CssClass="form-control" TabIndex="9" />
                    </div>


                </div>
            </div>
        </div>
    </div>
</asp:Content>

