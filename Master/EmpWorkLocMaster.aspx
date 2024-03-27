<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="EmpWorkLocMaster.aspx.cs" Inherits="Master_EmpWorkLocMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        function _btnCheck() {

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        $(function () {
            load();
           
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            load();
        }

        function load() {
            // allow decimal values only
            $(".allownumericwithdecimal").keydown(function (e) {
                // Allow: backspace, delete, tab, escape, enter
                if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190, 86, 67]) !== -1 ||
                    // Allow: Ctrl+A, Command+A
                    ((e.keyCode == 65 || e.keyCode == 86 || e.keyCode == 67) && (e.ctrlKey === true || e.metaKey === true)) ||
                    // Allow: home, end, left, right, down, up
                    (e.keyCode >= 35 && e.keyCode <= 40)) {
                    // let it happen, don't do anything

                    var myval = $(this).val();
                    if (myval != "") {
                        //if (isNaN(myval)) {
                        //    //$(this).val('');
                        //    //e.preventDefault();
                        //    return false;
                        //}
                    }
                    return;
                }
                // Ensure that it is a number and stop the keypress
                if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                    e.preventDefault();
                }
            });
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row" style="margin-bottom: 0px">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" OnTextChanged="txtCode_TextChanged" TabIndex="1" AutoPostBack="true" CssClass="form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDesign" runat="server" Text="Designation / Grade" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDesign" runat="server" Enabled="false" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblReportTo" runat="server" Text="Reporting To" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtReportTo" runat="server" CssClass="form-control" Enabled="false" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                 <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDevice" runat="server" Text="Device" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDevice" runat="server" CssClass="txtDevice form-control" TabIndex="6" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblHomeLat" runat="server" Text="Home Latitude" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtHomeLat" runat="server" CssClass="form-control allownumericwithdecimal" TabIndex="2" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblHomeLong" runat="server" Text="Home Longitude" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtHomeLong" runat="server" CssClass="form-control allownumericwithdecimal" TabIndex="3" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblWorkLat" runat="server" Text="Work Latitude" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtWorkLat" runat="server" CssClass="form-control allownumericwithdecimal" TabIndex="4" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblWorkLong" runat="server" Text="Work Longitude" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtWorkLong" runat="server" CssClass="form-control allownumericwithdecimal" TabIndex="5" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                
                <div class="col-lg-2">
                    <div class="input-group form-group">
                        <asp:Button ID="btnSubmit" CssClass="btn btn-default" runat="server" TabIndex="7" Text="Submit" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" />
                        &nbsp;
                        <asp:Button ID="btnCancel" UseSubmitBehavior="false" CausesValidation="false" TabIndex="8" CssClass="btn btn-default" runat="server" Text="Cancel"  OnClick="btnCancel_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>


