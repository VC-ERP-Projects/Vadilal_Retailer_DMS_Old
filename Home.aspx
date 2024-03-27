<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Home.aspx.cs" Inherits="Home" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Vadilal House Vadilal Enterprises Ltd.</title>

    <link href="css/index.css" rel="stylesheet" type="text/css" />
    <link href="Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <link href="Scripts/BootStrapCSS/bootstrap.min.css" rel="stylesheet" />
    <link href="Scripts/SlickSlider/slick-theme.css" rel="stylesheet" />
    <link href="Scripts/SlickSlider/slick.css" rel="stylesheet" />

    <script type="text/javascript" src="Scripts/jquery-1.9.1.js"></script>
    <script type="text/javascript" src="Scripts/SlickSlider/slick.min.js"></script>
    <script type="text/javascript" src="Scripts/colorbox/jquery.colorbox-min.js"></script>

    <script type="text/javascript">

        function OpenReminder() {
            $.colorbox({
                width: '95%',
                height: '90%',
                iframe: true,
                href: 'Reports/Notification.aspx',
                onClosed: function () {
                    parent.location.reload();
                }
            });
        }
        function OpenReminderEmp() {
            $.colorbox({
                width: '95%',
                height: '90%',
                iframe: true,
                href: 'Reports/NotificationEmp.aspx',
                onClosed: function () {
                    parent.location.reload();
                }
            });
        }

        $(document).ready(function () {

            $('._admin').click(function () {
                sessionStorage.setItem('color', '#6E0063');
            });
            $('._master').click(function () {
                sessionStorage.setItem('color', '#160C56');
            });
            $('._bp').click(function () {
                sessionStorage.setItem('color', '#7F3300');
            });
            $('._finance').click(function () {
                sessionStorage.setItem('color', '#3D0064');
            });
            $('._inventory').click(function () {
                sessionStorage.setItem('color', '#074E11');
            });
            $('._purchase').click(function () {
                sessionStorage.setItem('color', '#F84D00');
            });
            $('._sales').click(function () {
                sessionStorage.setItem('color', '#0EA9D0');
            });
            $('._crm').click(function () {
                sessionStorage.setItem('color', '#103E46');
            });
            $('._utility').click(function () {
                sessionStorage.setItem('color', '#A40808');
            });
            $('._report').click(function () {
                sessionStorage.setItem('color', '#003F94');
            });

            // Set Div and image for message broadcast
            $.ajax({
                url: 'Home.aspx/GetMessageBroadcastList',
                type: 'POST',
                dataType: 'json',
                data: null,
                contentType: 'application/json',
                success: function (result) {
                    res = JSON.parse(result.d);
                    var hei = $('.images_icons_sales').length <= 8 ? 360 : 215;
                    if (res != null && res != "") {
                        var html = '';
                        //for (var i = 0; i < res[0].length; i++) {
                        //    html = html + '';
                        //    if (res[0][i].ImageUpload.length > 0 && res[0][i].MessageBody.length > 0) {
                        //        html += '  <li style="min-height:' + hei + 'px;"> <div class="col-ld-12"> <div class="col-md-6"> ';
                        //        html += '    <b style="text-decoration: underline solid black;overflow-wrap: break-word;">' + res[0][i].Subject + '</b>  <br /> ' + res[0][i].MessageBody + '</div>';
                        //        html += '  <div class="col-md-6" style="margin-top: 17px;"><img src=' + res[0][i].ImageUpload + ' style="margin-left:-30px;max-width: 119%; width: ' + hei + 'px;height:274px;max-height: 100%;" /></div>';
                        //        html += ' </div></li>';
                        //    }
                        //    else if (res[0][i].ImageUpload.length > 0 && res[0][i].MessageBody.length == 0) {
                        //        //html += ' <li style="min-height:' + hei + 'px;"> <div class="col-ld-12">  <div class="col-md-6">';
                        //        var textHeight = hei + 20;
                        //        html += ' <li style="min-height:' + textHeight + 'px;height:' + hei + 'px;"> <div class="col-ld-12"> ';
                        //        html += ' <b style="text-decoration: underline solid black;overflow-wrap: break-word;">' + res[0][i].Subject + '</b>';
                        //        //html += '  <div class="col-md-6"> <img src=' + res[0][i].ImageUpload + ' style="max-width: 100%;width: ' + hei + 'px;height:' + hei + 'px;max-height: 100%;" /> ';
                        //        html += '   <br /> </ <br /><img src=' + res[0][i].ImageUpload + ' style="height:' + hei + 'px;max-height: 100%;" /> ';
                        //        html += ' </div></li>';
                        //    }
                        //    else if (res[0][i].ImageUpload.length == 0 && res[0][i].MessageBody.length > 0) {
                        //        var textHeight = hei + 20;
                        //        html += ' <li style="min-height:' + textHeight + 'px;height:' + hei + 'px;"> <div class="col-ld-12"> ';
                        //        html += ' <b style="text-decoration: underline solid black;overflow-wrap: break-word;">' + res[0][i].Subject + '</b> ';
                        //        html += ' <br /> ' + res[0][i].MessageBody;
                        //        html += ' </div></li>';
                        //    }
                        //    $('.slider').html(html);
                        //}
                        for (var i = 0; i < res[0].length; i++) {
                            html = html + '';
                            if (res[0][i].ImageUpload.length > 0 && res[0][i].MessageBody.length > 0) {
                                html += '  <li style="min-height:' + hei + 'px;"> <div class="col-ld-12"> <div class="col-md-6"> ';
                                html += ' <br /> ' +  res[0][i].MessageBody + '</div>';
                                html += '  <div class="col-md-6" style="margin-top: 17px;"><img src=' + res[0][i].ImageUpload + ' style="margin-left:-30px;max-width: 119%; width: ' + hei + 'px;height:' + hei + 'px;max-height: 100%;" /></div>';
                                html += ' </div></li>';
                            }
                            else if (res[0][i].ImageUpload.length > 0 && res[0][i].MessageBody.length == 0) {
                                //html += ' <li style="min-height:' + hei + 'px;"> <div class="col-ld-12">  <div class="col-md-6">';
                                var textHeight = hei + 20;
                                html += ' <li style="min-height:' + textHeight + 'px;height:' + hei + 'px;"> <div class="col-ld-12"> ';
                                html += ' <b style="text-decoration: underline solid black;overflow-wrap: break-word;">' + res[0][i].Subject + '</b>';
                                //html += '  <div class="col-md-6"> <img src=' + res[0][i].ImageUpload + ' style="max-width: 100%;width: ' + hei + 'px;height:' + hei + 'px;max-height: 100%;" /> ';
                                html += '   <br /> </ <br /><img src=' + res[0][i].ImageUpload + ' style="height:' + hei + 'px;max-height: 100%;" /> ';
                                html += ' </div></li>'; 
                            }
                            else if (res[0][i].ImageUpload.length == 0 && res[0][i].MessageBody.length > 0) {
                                var textHeight = hei + 20;
                                html += ' <li style="min-height:' + textHeight + 'px;height:' + hei + 'px;"> <div class="col-ld-12"> ';
                              //  html += ' <b style="text-decoration: underline solid black;overflow-wrap: break-word;">' + res[0][i].Subject + '</b> ';
                                html += ' <br /> ' + res[0][i].MessageBody;
                                html += ' </div></li>';
                            }
                            console.log(html);
                            $('.slider').html(html);
                           // document.getElementById("vertical-ticker").innerHTML = html;
                        }
                        $('#divBoradCastMsg').css('display', 'block');
                        $(".lazy").slick({//related to msg broadcasting Slick Slider.
                            lazyLoad: 'ondemand',
                            infinite: true,
                            centerMode: false,
                            autoplaySpeed: 5000,
                            slidesToShow: 3,
                            slidesToScroll: 1,
                            autoplay: true,
                            dots: false
                        });
                    }
                },
                error: function (result) {
                    alert(result);
                }
            });

        });

    </script>

  <%--  <style type="text/css">
        html, body {
            margin: 0;
            padding: 0;
        }

        * {
            box-sizing: border-box;
        }

        .slider {
            width: 98%;
            margin: 3px 3px 3px 3px;
            padding-inline-start: 22px;
        }

        .slick-track li {
            background: #ddd;
            padding: 10px;
            min-height: 100px;
        }

        .slick-slide {
            margin: 0px 8px;
        }

            .slick-slide img {
                width: 100%;
            }

        .slick-prev {
            left: 2px;
        }

        .slick-next {
            right: -20px;
        }

            .slick-prev:before,
            .slick-next:before {
                color: black;
            }


        .slick-slide {
            transition: all ease-in-out .3s;
            opacity: .2;
        }

        .slick-active {
            opacity: 1;
        }

        .slick-current {
            opacity: 1;
        }

        #vertical-ticker li {
            list-style: none;
        }

        .images_icons_sales {
            width: 10%;
        }

            .images_icons_sales:first-child {
                margin-left: 3.7%;
            }
    </style>--%>
    <style type="text/css">
        html, body {
            margin: 0;
            padding: 0;
        }

        * {
            box-sizing: border-box;
        }
      
        .slider {
            width: 98%;
            margin: 3px 3px 3px 3px;
            padding-inline-start: 22px;
        }

        .slick-track li {
          /*  background: #ddd;*/
            padding: 10px;
            min-height: 100px;
                border: 2px solid;
        }

        .slick-slide {
            margin: 0px 8px;
        }

           /* .slick-slide img {
                width: 100%;
            }*/

        .slick-prev {
            left: 2px;
        }

        .slick-next {
            right: -20px;
        }

            .slick-prev:before,
            .slick-next:before {
                color: black;
            }


        .slick-slide {
            transition: all ease-in-out .3s;
            opacity: .2;
        }

        .slick-active {
            opacity: 1;
        }

        .slick-current {
            opacity: 1;
        }

        #vertical-ticker li {
            list-style: none;
        }

        .images_icons_sales {
            width: 10%;
        }

            .images_icons_sales:first-child {
                margin-left: 3.7%;
            }
    </style>

</head>
<body>
    <form id="form1" runat="server">

        <div id="mp-headerpanel_header">
            <asp:ImageButton ID="imgReminder_notification" runat="server" ImageUrl="~/Images/bell.gif" Style="width: 55px; height: 60px; margin-left: 25px;" OnClientClick="OpenReminder();  return false;" Visible="false" />
            <asp:ImageButton ID="imgReminder" runat="server" ImageUrl="~/Images/bell.png" Style="width: 55px; height: 60px; margin-left: 25px;" OnClientClick="OpenReminder();  return false;" Visible="false" />
            <asp:Label runat="server" ID="lblCounter" Style="background-color: #A40808; color: white; font-size: 13px; position: absolute; border-radius: 60px; left: 58px; font-weight: bold; height: 25px; width: 22px; padding-left: 3px; padding-bottom: 10px; padding-right: 7px; padding-top: 5px; text-align: center;" Text="0" Visible="false"></asp:Label>
             
             <asp:ImageButton ID="imgReminder_notificationEmp" runat="server" ImageUrl="~/Images/bell.gif" Style="width: 55px; height: 60px; margin-left: 25px;" OnClientClick="OpenReminderEmp();  return false;" Visible="false" />
            <asp:ImageButton ID="imgReminderEmp" runat="server" ImageUrl="~/Images/bell.png" Style="width: 55px; height: 60px; margin-left: 25px;" OnClientClick="OpenReminderEmp();  return false;" Visible="false" />
            <asp:Label runat="server" ID="lblCounterEmp" Style="background-color: #A40808; color: white; font-size: 13px; position: absolute; border-radius: 60px; left: 58px; font-weight: bold; height: 25px; width: 22px; padding-left: 3px; padding-bottom: 10px; padding-right: 7px; padding-top: 5px; text-align: center;" Text="0" Visible="false"></asp:Label>

            <div style="float: right; margin-right: 15px">


                <div style="float: right;">
                    <asp:ImageButton ID="ImageButton3" runat="server" ImageUrl="~/Images/lo.png" Style="width: 53px; float: right; vertical-align: middle; margin-left: 5px" OnClick="lnkLogout_Click" title="Logout" Visible="true" />
                </div>
                <div style="float: right;">
                    <asp:Label ID="lblloginname" runat="server" Style="font-weight: bold; font-size: 20px"></asp:Label>
                    <br />
                    <asp:Label ID="lbltype" runat="server" Style="font-weight: bold; font-size: 14px" Text="Distributor"></asp:Label>
                </div>
            </div>
        </div>
        <asp:ImageButton ImageUrl="Images/MAN.png" ID="imgAccount" runat="server" CssClass="mp-icons_header solid-yellow" Visible="false" />
        <div class="space">
        </div>
        <div class="sales_icon_one">
            <asp:ImageButton ImageUrl="Images/Purchase.png" ID="imgPurchase" runat="server" CssClass="images_icons_sales _purchase" Visible="false" />
            <asp:ImageButton ImageUrl="Images/Sales.png" ID="imgSales" runat="server" CssClass="images_icons_sales _sales" Visible="false" />
            <asp:ImageButton ImageUrl="Images/Claim.png" ID="imgUtility" runat="server" CssClass="images_icons_sales _utility" Visible="false" />
            <asp:ImageButton ImageUrl="Images/Inventory.png" ID="imgInventory" runat="server" CssClass="images_icons_sales _inventory" Visible="false" />
            <asp:ImageButton ImageUrl="Images/Finance.png" ID="imgHRMS" runat="server" CssClass="images_icons_sales _finance" Visible="false" />
            <asp:ImageButton ImageUrl="Images/Master.png" ID="imgMaster" runat="server" CssClass="images_icons_sales _master" Visible="false" />
            <asp:ImageButton ImageUrl="~/Images/Admin.png" ID="imgAdmin" runat="server" CssClass="images_icons_sales _admin" Visible="false" />
            <asp:ImageButton ImageUrl="Images/BP.png" ID="imgBusinessPartner" runat="server" CssClass="images_icons_sales _bp" Visible="false" />
            <asp:ImageButton ImageUrl="Images/CRM.png" ID="imgCRM" runat="server" CssClass="images_icons_sales _crm" Visible="false" />
            <asp:ImageButton ImageUrl="Images/1Reports.png" ID="imgReport" runat="server" CssClass="images_icons_sales _report" Visible="false" />
            <asp:ImageButton ImageUrl="Images/Task.png" ID="imgTask" runat="server" CssClass="images_icons_sales _report" Visible="false" />
        </div>


        <div class="col-lg-12" id="divBoradCastMsg" runat="server" style="display: none;">
            <div class="panel panel-primary" style="margin-bottom: 12px;border : none;">
                <div class="panel-heading" style="display: none;">
                    <%-- <h3 class="panel-title" style="text-align: center;">NEWS</h3>--%>
                </div>

                <ul id="vertical-ticker" class="lazy slider">
                    <%--  <asp:ListView runat="server" ID="lvData">
                        <ItemTemplate>
                            <li style="min-height:211px;">
                                <div class="col-ld-12">
                                    <div class="col-md-6">
                                        <img src="<%# Eval("ImageUpload") %>" style="max-width: 100%;width: 256px;height:191px;max-height: 100%;" />  
                                    </div>
                                    <div class="col-md-6">
                                           <b style="text-decoration: underline solid black;overflow-wrap: break-word;"><%# Eval("Subject") %></b>
                                            <br /> 
                                          <%# Eval("MessageBody") %>
                                    </div>
                                </div>
                             
                            </li>
                        </ItemTemplate>
                    </asp:ListView>--%>
                </ul>
            </div>
        </div>
    </form>
</body>
</html>
