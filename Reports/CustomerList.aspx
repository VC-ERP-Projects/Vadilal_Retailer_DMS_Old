<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="CustomerList.aspx.cs" Inherits="Reports_CustomerList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        function fnValidateGSTIN(txt) {

            var gstval = $(txt).val();
            if (gstval != "") {

                var panPat = /^[0-9]{2}[A-Za-z]{5}[0-9]{4}[A-Za-z]{1}[0-9a-zA-Z]{1}[a-zA-Z]{1}[0-9a-zA-Z]{1}$/;

                if (gstval.search(panPat) == -1) {
                    ModelMsg("Invalid GSTIN No", 3);
                    $(txt).val("");
                    return false;
                }
            }
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var isTemp = $('.ChkTemp').val();
            if ($('.ChkTemp').find('input').is(':checked'))
                sender.set_contextKey(reg + "-1-2,3,4");
            else
                sender.set_contextKey(reg + "-0-2,3,4");
        }

        function Clear(txt) {           
            var txtVal = $(txt).val();
            $('.txtCustCode').val('');
            $('.txtPhoneNo').val('');
            $('.txtGSTIN').val('');
            $('input[type=checkbox]').prop('checked', false);
            $('#body_ifmCustomer').attr('src', '');
        }

        function Clearsub(txt) {
            $('.txtPhoneNo').val('');
            $('.txtGSTIN').val('');          
            $('#body_ifmCustomer').attr('src', '');
        }

    </script>
    <style>
        .ifmCustomer {
            height: 470px !important;
            width: 100%;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" TabIndex="1" onchange="return Clear(this);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                            ServiceMethod="GetStates" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-2">
                    <div class="input-group form-group">
                        <asp:Label ID="lblTemp" runat="server" Text="Is Temp" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="ChkTemp" runat="server" CssClass="ChkTemp form-control" TabIndex="2" />
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" onchange="return Clearsub(this);" runat="server" TabIndex="3" CssClass="txtCustCode form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" Style="background-color: rgb(250, 255, 189);" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomerByTypeTempState" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode" BehaviorID="CustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divMobile" runat="server" visible="false">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPhoneNo" runat="server" Text="Mobile" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPhoneNo" TabIndex="4" autocomplete="off" runat="server" data-bv-stringlength="false" MaxLength="10" onkeypress="return isNumberKey(event);" CssClass="txtPhoneNo form-control" onpaste="return true;"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" id="divMobile2" runat="server" visible="false">
                    <div class="input-group form-group">
                        <asp:Label ID="Label1" runat="server" Text="Mobile 2" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPhoneNo2" TabIndex="4" autocomplete="off" runat="server" data-bv-stringlength="false" MaxLength="10" onkeypress="return isNumberKey(event);" CssClass="txtPhoneNo form-control" onpaste="return true;"></asp:TextBox>
                    </div>
                </div>
                 <div class="col-lg-4" id="divMobile3" runat="server" visible="false">
                    <div class="input-group form-group">
                        <asp:Label ID="Label2" runat="server" Text="Mobile 3" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPhoneNo3" TabIndex="4" autocomplete="off" runat="server" data-bv-stringlength="false" MaxLength="10" onkeypress="return isNumberKey(event);" CssClass="txtPhoneNo form-control" onpaste="return true;"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" id="divGST" runat="server" visible="false">
                    <div class="input-group form-group">
                        <asp:Label ID="lblGSTIN" runat="server" Text="GSTIN Number" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtGSTIN" TabIndex="5" runat="server" autocomplete="off" MaxLength="20" CssClass="txtGSTIN form-control" onblur="fnValidateGSTIN(this);"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" style="float: left;">
                        <asp:Button ID="btnGenerat" TabIndex="6" runat="server" Text="GO" CssClass="btn btn-default" OnClick="btnGenerat_Click" OnClientClick="return _btnCheck();" />&nbsp
                        <asp:Button Text="Export To Excel" TabIndex="7" ID="btnExport" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                    <div class="input-group form-group" id="divSubmit" runat="server" visible="false" style="float: right;">
                        <asp:Button ID="btnSubmit" runat="server" TabIndex="8" Text="Submit" CssClass="btn btn-danger" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" Style="float: right;" />&nbsp
                    </div>
                </div>
                <div class="col-lg-4">
                </div>
                <div class="col-lg-4">
                    <asp:Label ID="lblSearch" runat="server" Text="Search with % and Space Seperator" Style="color: red; font-size: 11px;"></asp:Label>
                </div>
            </div>
            <iframe id="ifmCustomer" class="ifmCustomer embed-responsive-item" runat="server" onload="ifmCustomer_Load"></iframe>
        </div>
    </div>
</asp:Content>

