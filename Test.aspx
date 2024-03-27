<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Test.aspx.cs" Inherits="Test" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="css/index.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="Scripts/jquery-1.9.1.js"></script>

    <script type="text/javascript">

        //document.addEventListener('DOMContentLoaded', function () {
        //    if (Notification.permission !== "granted") {
        //        Notification.requestPermission();
        //    }
        //});

        //function customnotify(title, desc, url, data) {

        //    if (Notification.permission !== "granted") {
        //        Notification.requestPermission();
        //    }
        //    else {
        //        var notification = new Notification(title, {
        //            icon: 'http://dms.vadilalgroup.com/Images/LOGO.png',
        //            tag: 'chat-message',
        //            body: desc,
        //            data: data,
        //            badge: 'http://icons.iconarchive.com/icons/giannis-zographos/english-football-club/256/Arsenal-FC-icon.png',
        //            vibrate: [500, 110, 500, 110, 450, 110, 200, 110, 170, 40, 450, 110, 200, 110, 170, 40, 500],
        //        });

        //        /* Remove the notification from Notification Center when clicked.*/
        //        notification.onclick = function () {
        //            window.open(url);
        //        };

        //        /* Callback function when the notification is closed. */
        //        notification.onclose = function () {
        //            console.log('Notification closed');
        //        };

        //    }
        //}

        //$(document).ready(function () {
        //    customnotify('Hello', ' You Have New Message,Your work is about to due , Your work is about to due, Your work is about to due, Your work is about to due', 'https://www.google.co.in/', 'Your work is about to due');
        //});
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="row">
            <div class="col-lg-4">
                <asp:Button ID="btnSendMail" CssClass="btn btn-default" runat="server" Text="Send Email" OnClick="btnSendMail_Click" />
            </div>
            <br />
            <br />
            <div class="col-lg-4">
                <asp:Button ID="btnAutoCancel" CssClass="btn btn-default" runat="server" Text="Auto Cancel Order" OnClick="btnAutoCancel_Click" />
            </div>
            <div class="col-lg-4">
                <asp:Label ID="Label2" runat="server" Text="MobileNo To send WhatsAPP"></asp:Label>
                <asp:TextBox ID="txtMobileNo" runat="server" Text=""></asp:TextBox>
                <asp:Label ID="Label1" runat="server" Text="Message"></asp:Label>
                <asp:TextBox ID="txttest" runat="server"></asp:TextBox>

                <asp:Image runat="server" ID="imgQRcode" Width="200px" />
                <asp:Button ID="Button1" CssClass="btn btn-default" runat="server" Text="Send WhatsAPP MSG" OnClick="Button1_Click" />
                <asp:Label ID="status" runat="server"></asp:Label>
            </div>
            <br />
            <br />
            <div class="col-lg-4">
                <asp:Button ID="btnSendNoSaleMail" CssClass="btn btn-default" runat="server" Text="Send No Sale WhatsAPP MSG" OnClick="btnSendNoSaleMail_Click" />
            </div>
              <div class="col-lg-4">
                <asp:Button ID="btnSendPromotionalWhatsAPP" CssClass="btn btn-default" runat="server" Text="Send Promo WhatsAPP MSG" OnClick="btnSendPromotionalWhatsAPP_Click" />
            </div>
        </div>
    </form>
</body>
</html>
