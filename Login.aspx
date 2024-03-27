<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true"
    CodeFile="Login.aspx.cs" Inherits="Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="Scripts/BootStrapCSS/Signin.css" rel="stylesheet" />
    <link href="Scripts/colorbox/colorbox.css" rel="stylesheet" />

    <script type="text/javascript" src="Scripts/totem-master/js/jquery.totemticker.min.js"></script>
    <script type="text/javascript" src="Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script type="text/javascript">

        $(document).ready(function () {
            //Detect Browser
            if (navigator.userAgent.indexOf("Chrome") != -1) {
                $('.form-signin').show();
                $('.SweetAlert').hide();
            }
            else {
                $('.SweetAlert').show();
                $('.form-signin').hide();
            }

            // Set Div and image for message broadcast
            $.ajax({
                url: 'Login.aspx/GetMessageBroadcastList',
                type: 'POST',
                dataType: 'json',
                data: null,
                contentType: 'application/json',
                success: function (result) {
                    res = JSON.parse(result.d);
                    if (res != null && res != "") {
                        $('#NewsSection').css('display', 'block');
                        $('.divBoradCastMsg').css('display', 'block');
                        var html = '';
                        for (var i = 0; i < res[0].length; i++) {
                            html = html + '';
                            if (res[0][i].ImageUpload.length > 0 && res[0][i].MessageBody.length > 0) {
                                html += '  <li style="min-height:211px;"> <div class="col-ld-12"> <div class="col-md-6 dvmsg"> ';
                                html += '    <b style="text-decoration: underline solid black; overflow-wrap: break-word;">' + res[0][i].Subject + '</b>  <br /> ' + res[0][i].MessageBody + '</div>';
                                html += '  <div class="col-md-6"><img src=' + res[0][i].ImageUpload + ' style="max-width: 100%; width: 175px; height: 136px; max-height: 100%;" /></div>';
                                html += ' </div></li>';
                            }
                            else if (res[0][i].ImageUpload.length > 0 && res[0][i].MessageBody.length == 0) {
                                html += ' <li style="min-height:211px;"> <div class="col-ld-12">  <div class="col-md-6">';
                                html += ' <b style="text-decoration: underline solid black;overflow-wrap: break-word;">' + res[0][i].Subject + '</b> </div>';
                                html += '  <div class="col-md-6"> <img src=' + res[0][i].ImageUpload + ' style="max-width: 100%; width: 175px; height: 136px; max-height: 100%;" /> ';
                                html += ' </div></li>';
                            }
                            else if (res[0][i].ImageUpload.length == 0 && res[0][i].MessageBody.length > 0) {
                                html += ' <li style="min-height:211px;"> <div class="col-ld-12 dvmsg"> ';
                                html += ' <b style="text-decoration: underline solid black;overflow-wrap: break-word;">' + res[0][i].Subject + '</b> ';
                                html += ' <br /> ' + res[0][i].MessageBody;
                                html += ' </div></li>';
                            }
                            $('.divBoradCastMsg').html(html);
                        }

                        $('.divBoradCastMsg').css('display', 'block');
                        // Slider
                        $('#vertical-ticker').totemticker({
                            row_height: '100px',
                            next: '#ticker-next',
                            previous: '#ticker-previous',
                            stop: '#stop',
                            start: '#start',
                            mousestop: true
                        });
                    }
                    else {
                        $('#NewsSection').css('display', 'none');
                        $('.divBoradCastMsg').css('display', 'none');
                    }
                },
                error: function (result) {
                    alert(result);
                }
            });
        });

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            return $('._masterForm').data('bootstrapValidator').isValid();

        }
    </script>
    <style type="text/css">
        #vertical-ticker {
            height: 400px;
            overflow: hidden;
            margin: 0;
            padding: 0;
            -webkit-box-shadow: 0 1px 3px rgba(0,0,0, .4);
            list-style: none;
        }

            #vertical-ticker li {
                height: 200px;
                padding: 15px 10px;
                display: block;
                border-bottom: 1px solid #ddd;
                text-align: left;
                font-size: 13px;
            }

        .dvmsg {
            height: 142px;
            /*width: 100%;*/
            margin: 0 auto;
            overflow: hidden;
        }

            .dvmsg:hover {
                overflow-y: scroll;
            }
             .blink_me {
            /*animation: blinker 1s linear infinite;*/
            color: red;
            font-weight: bold;
        }

        @keyframes blinker {
            50% {
                opacity: 0;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="row">
        <div class="col-lg-3">
        </div>
        <div class="col-lg-5">
            <div class="panel panel-primary" style="margin: 0 auto; box-shadow: 5px 5px 0px 0px lightgrey; border-radius: 5px; border: 2px solid #428bca;">
                <div class="panel-heading">
                    <h3 class="panel-title">Login</h3>
                </div>
                <div class="form-signin">
                    <div class="form-group" style="margin-right: -300px">
                        <asp:Label runat="server" ID="lblDealerCode" Text="Code" class="col-sm-2 control-label" Style="font-size: 16px; text-align: left"></asp:Label>
                        <div class="col-sm-10" style="width: 300px; padding-right: 0px; padding-right: 0px">
                            <asp:TextBox runat="server" ID="txtDCode" placeholder="Code" MaxLength="30" class="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                        </div>
                    </div>
                    <div class="form-group" style="margin-right: -300px">
                        <asp:Label runat="server" ID="lblUsername" Text="Username" class="col-sm-2 control-label" Style="font-size: 16px; text-align: left"></asp:Label>
                        <div class="col-sm-10" style="width: 300px; padding-right: 0px">
                            <asp:TextBox ID="txtUsername" runat="server" placeholder="Username" MaxLength="20" class="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        </div>
                    </div>
                    <div class="form-group" style="margin-right: -300px">
                        <asp:Label runat="server" ID="lblPassword" Text="Password" class="col-sm-2 control-label" Style="font-size: 16px; text-align: left"></asp:Label>
                        <div class="col-sm-10" style="width: 300px; padding-right: 0px">
                            <asp:TextBox ID="txtPassword" runat="server" placeholder="Password" TextMode="Password" MaxLength="25" class="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        </div>
                    </div>
                    <div style="display: inline-block; width: 100%">
                        <input type="checkbox" id="chkRemember" runat="server" style="margin: 0px; vertical-align: bottom; margin-right: 1%" /><span style="width: auto; display: inline; font-size: 14px;">Remember Me</span><br />
                        <asp:Button ID="btnlogin" runat="server" Text="Login" CssClass="btn btn-primary" OnClientClick="return _btnCheck();" OnClick="btnlogin_Click" Style="margin-top: -12px; float: right; margin-right: 12px; width: 102px;" />
                        <asp:LinkButton runat="server" OnClick="ForgetPassword_Click" ID="ForgetPassword" Text="Forgot Password ?" Style="text-decoration: underline; margin-right: 12px; color: black"></asp:LinkButton>
                    </div>
                </div>
              
                <div class="SweetAlert">
                    <div style="font-size: 20px; margin-top: 30px; text-align: center; font-weight: bold;">
                        This browser is not supporting DMS.
                            <br />
                        Please Login with Google Chrome browser.
                <br />
                        <br>
                        <a target="_blank" href="https://www.google.com/chrome/browser/desktop/">Click Here to Download Chrome</a>
                    </div>
                </div>
            </div>
              <br />
                  <asp:Label ID="lblIP" runat="server"  CssClass="blink_me"></asp:Label>
                <br />
                  <asp:Label ID="lblLocation" runat="server" CssClass="blink_me"></asp:Label>
            <%--    <br />
                  <asp:Label ID="Label1" runat="server" Text="" CssClass="blink_me"></asp:Label>--%>

           
        </div>
        <div class="col-lg-4" id="NewsSection" style="display: none;">
            <div class="panel panel-primary" style="margin: 0 auto; box-shadow: 5px 5px 0px 0px lightgrey; border-radius: 5px; border: 2px solid #428bca;">
                <div class="panel-heading">
                    <h3 class="panel-title">News</h3>
                </div>
                <ul id="vertical-ticker" class="divBoradCastMsg">
                </ul>
            </div>
        </div>
    </div>
</asp:Content>
