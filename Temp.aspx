<%@ Page Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="Temp.aspx.cs" Inherits="Temp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        function getUserIP(onNewIP) { //  onNewIp - your listener function for new IPs
            //compatibility for firefox and chrome  
            var myPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
            var pc = new myPeerConnection({
                iceServers: []
            }),
            noop = function () { },
            localIPs = {},
            ipRegex = /([0-9]{1,3}(\.[0-9]{1,3}){3}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){7})/g,
            key;

            function iterateIP(ip) {
                if (!localIPs[ip]) onNewIP(ip);
                localIPs[ip] = true;
            }

            //create a bogus data channel
            pc.createDataChannel("");

            // create offer and set local description
            pc.createOffer(function (sdp) {
                sdp.sdp.split('\n').forEach(function (line) {
                    if (line.indexOf('candidate') < 0) return;
                    line.match(ipRegex).forEach(iterateIP);
                });

                pc.setLocalDescription(sdp, noop, noop);
            }, noop);

            //listen for candidate events
            pc.onicecandidate = function (ice) {
                if (!ice || !ice.candidate || !ice.candidate.candidate || !ice.candidate.candidate.match(ipRegex)) return;
                ice.candidate.candidate.match(ipRegex).forEach(iterateIP);
            };
        }
        // Usage
        getUserIP(function (ip) {
            if ($("#hdnclientipaddress").val() == 0 || $("#hdnclientipaddress").val() == "" || $("#hdnclientipaddress").val() == undefined) {
                $("#hdnclientipaddress").val(ip);
                alert('Got your IP ! : ' + ip);
            }

        });
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
        //            vibrate: [500,110,500,110,450,110,200,110,170,40,450,110,200,110,170,40,500],
        //            actions: [
        //                    {
        //                        action: 'download-book-action',
        //                        title: 'Download Book',
        //                        icon: '/Images/delete2.png'
        //                    }
        //            ]
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

        $(function () {
            //customnotify('Hello', ' You Have New Message,Your work is about to due , Your work is about to due, Your work is about to due, Your work is about to due', 'https://www.google.co.in/', 'Your work is about to due');
            //var regex = /^([a-zA-Z0-9\s_\\.\-:])+(.csv|.txt)$/;
            //    var regex = /^([a-za-z0-9\s_\\.\-:])+(.csv|.txt)$/;
            //    if (regex.test($("#fileUpload").val().toLowerCase())) {
            //        if (typeof (filereader) != "undefined") {
            //            var reader = new filereader();
            //            reader.onload = function (e) {
            //                var rows = e.target.result.split("\n");
            //                var row = ""
            //                for (var i = 0; i < rows.length; i++) {
            //                    var cells = rows[i].split(",");
            //                    for (var j = 0; j < cells.length; j++) {
            //                        row += cells[j] + ','
            //                    }
            //                }
            //                $("#txtinput").val(row);
            //            }
            //            reader.readastext($("#fileupload")[0].files[0]);
            //        } else {
            //            alert("this browser does not support html5.");
            //        }
            //    } else {
            //        alert("please upload a valid csv file.");
            //    }
            //});
            $("#btnImport").bind("click", function () {

                var regex = /^([a-zA-Z0-9\s_\\.\-:])+(.csv|.txt)$/;
                if (regex.test($("#fileUpload").val().toLowerCase())) {
                    if (typeof (FileReader) != "undefined") {
                        var reader = new FileReader();
                        reader.onload = function (e) {
                            var table = $("<table />");
                            var rows = e.target.result.split("\n");
                            var Value = "";
                            for (var i = 0; i < rows.length; i++) {
                                var row = $("<tr />");
                                var cells = rows[i].split(",");
                                for (var j = 0; j < cells.length; j++) {
                                    if (cells[j] != "") {
                                        Value += cells[j] + ',';
                                        var cell = $("<td />");
                                        cell.html(cells[j]);
                                        row.append(cell);
                                    }
                                }
                                table.append(row);
                            }
                            $("#dvCSV").html('');
                            $("#dvCSV").append(table);
                            $("#txtinput").val(Value.replace(/,\s*$/, ""));
                        }
                        reader.readAsText($("#fileUpload")[0].files[0]);
                    } else {
                        alert("This browser does not support HTML5.");
                    }
                } else {
                    alert("Please upload a valid CSV file.");
                }
            });
        });

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <input type="hidden" id="hdnclientipaddress" value="0" runat="server" clientidmode="static" />
    <div class="panel panel-default">
        <div class="panel-body">
            <asp:LinkButton ID="btnlnkHome" runat="server" Text="GoToHome" PostBackUrl="~/Home.aspx"></asp:LinkButton>
            <div class="panel panel-default">
                <div class="panel-body">
                    <div class="row">
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblFdate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtFromDate" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblTdate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtTodate" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label runat="server" Text="Upload File" ID="lblUpload" CssClass="input-group-addon"></asp:Label>
                                <input type="file" id="fileUpload" />
                                <input type="button" id="btnImport" value="Upload" />
                                <input type="text" id="txtinput" />
                            </div>

                        </div>
                        <div class="col-lg-4">
                            <div id="dvCSV">
                            </div>
                        </div>
                    </div>
                </div>
                <asp:Button ID="btnExportSales" CssClass="btn btn-default" runat="server" Text="SalesRegisterExport" OnClick="btnExport_Click" Visible="false" />
                <asp:Button ID="btnExportPurchase" CssClass="btn btn-default" runat="server" Text="Send Email" OnClick="btnExportPurchase_Click" />
                <%--<asp:Button ID="btnClick" CssClass="btn btn-default" runat="server" Text="Click" OnClick="btnClick_Click" />--%>
            </div>
        </div>

    </div>


</asp:Content>


