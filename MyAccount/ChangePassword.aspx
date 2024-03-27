<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ChangePassword.aspx.cs" Inherits="MyAccount_ChangePassword" %>

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
            <div class="panel panel-default">
                <div class="panel-body">
                    <div class="row _masterForm">
                        <div class="col-lg-12">
                            <div class="input-group form-group">
                                <asp:Label runat="server" ID="lblOldPassword" Text="Old Password" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtOldPassword" runat="server" placeholder="Old Password" TextMode="Password" CssClass="form-control" name="oldpassword" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-12">
                            <div class="input-group form-group">
                                <asp:Label runat="server" ID="lblNewPassword" Text="New Password" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtNewPassword" runat="server" placeholder="New Password" TextMode="Password" CssClass="form-control" name="password" data-bv-notempty="true"
                                    data-bv-notempty-message="Field is required"
                                    data-bv-identical="true"
                                    data-bv-identical-field="ctl00$body$txtConfirmPassword"
                                    data-bv-identical-message="The password and its confirm are not the same"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-12">
                            <div class="input-group form-group">
                                <asp:Label runat="server" ID="lblConfirmPassword" Text="Confirm Password" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtConfirmPassword" runat="server" placeholder="Confirm Password" TextMode="Password" name="confirmPassword" CssClass="form-control"
                                    Text="1" data-bv-notempty="true"
                                    data-bv-notempty-message="Field is required"
                                    data-bv-identical="true"
                                    data-bv-identical-field="ctl00$body$txtNewPassword"
                                    data-bv-identical-message="The password and its confirm are not the same"></asp:TextBox>
                            </div>
                        </div>
                        <br />
                        <div class="col-lg-12">
                            <div class="input-group form-group">
                                <asp:Label runat="server" ID="lblError" Text="Please Change Password" style="color:red" Visible="false"></asp:Label>
                            </div>
                        </div>
                    </div>
                    <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>


</asp:Content>

