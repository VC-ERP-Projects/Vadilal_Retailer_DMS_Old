<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="EmailSettings.aspx.cs" Inherits="EmailSettings" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }


    </script>
    <style>
        .wrapper {
            /* margin-top: 80px;*/
            margin-bottom: 80px;
        }

        .form-signin {
            max-width: 500px;
            padding: 15px 35px 45px;
            margin: 0 auto;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="wrapper">

        <div class="form-signin">

            <div class="row _masterForm">
                <div class="col-lg-12">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="E-Mail" ID="lblEmailID" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtEmailID" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" data-bv-emailaddress="true"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="UserName" ID="lblUserName" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtUserName" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Password" ID="lblPassword" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtPassword" TextMode="Password" autocomplete="new-password" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Domain" ID="lblDomain" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtDomain" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Port" ID="lblPort" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtPort" MaxLength="5" onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
            </div>
            <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-default" OnClick="btnSubmit_Click"
                OnClientClick="return _btnCheck();" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" />
        </div>
    </div>
</asp:Content>

