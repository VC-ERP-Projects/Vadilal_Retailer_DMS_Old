<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="ForgotPassword.aspx.cs" Inherits="ForgotPassword" %>

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

        .rdbEmail {
            margin-left: 25px;
        }

        .rdbPhone {
            margin-left: 20px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">

    <div class="panel panel-primary" style="max-width: 500px; margin: 0 auto; box-shadow: 5px 5px 0px 0px lightgrey; border-radius: 5px; border: 2px solid #428bca; margin-bottom: 5%">
        <div class="panel-heading">
            <h3 class="panel-title">Forgot Password</h3>
        </div>
        <div class="form-signin _masterForm">
            <div class="row">
                <div class="col-lg-12">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Cutomer Code" ID="lblCode" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtCode" Enabled="false" CssClass="form-control" autocomplete="off"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="input-group form-group">
                        <asp:Label ID="lblEmail" runat="server" Text="Email" CssClass="input-group-addon">
                            <asp:RadioButton ID="rdbEmail" runat="server" GroupName="Group1" CssClass="rdbEmail" /></asp:Label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" data-bv-emailaddress="true" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-12" style="display: none">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPhoneNo" runat="server" Text="Mobile" CssClass="input-group-addon">
                            <asp:RadioButton ID="rdbPhone" runat="server" GroupName="Group1" CssClass="rdbPhone" /></asp:Label>
                        <asp:TextBox ID="txtPhoneNo" runat="server" data-bv-stringlength="false" MaxLength="10"
                            onkeypress="return isNumberKey(event);" CssClass="form-control" onpaste="return false;" Enabled="false"></asp:TextBox>
                    </div>
                </div>
            </div>
            <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-primary" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" />
            <asp:Button ID="btnCancel" runat="server" Text="Go to Login" CssClass="btn btn-primary" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" />
        </div>
    </div>

</asp:Content>

