<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ClaimDirect.aspx.cs" Inherits="Sales_ClaimDirect" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script type="text/javascript">
        var IpAddress;
        var Version = '<% = Version%>';
        $(function () {
            ReLoadFn();
            $("#hdnIPAdd").val(IpAddress);
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });
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
            if (IpAddress == undefined)
                IpAddress = ip;
            try {
                if ($("#hdnIPAdd").val() == 0 || $("#hdnIPAdd").val() == "" || $("#hdnIPAdd").val() == undefined) {
                    $("#hdnIPAdd").val(ip);
                }
            }
            catch (err) {

            }
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
        }

        function ExportXLS(xlsx, numrows) {
            var sheet = xlsx.xl.worksheets['sheet1.xml'];
            var clR = $('row', sheet);

            //update Row
            clR.each(function () {
                var attr = $(this).attr('r');
                var ind = parseInt(attr);
                ind = ind + numrows;
                $(this).attr("r", ind);
            });

            // Create row before data
            $('row c ', sheet).each(function () {
                var attr = $(this).attr('r');
                var pre = attr.substring(0, 1);
                var ind = parseInt(attr.substring(1, attr.length));
                ind = ind + numrows;
                $(this).attr("r", pre + ind);
            });

            return sheet;
        }

        function Addrow(index, data) {
            msg = '<row r="' + index + '">'
            for (i = 0; i < data.length; i++) {
                var key = data[i].key;
                var value = data[i].value;
                msg += '<c t="inlineStr" r="' + key + index + '">';
                msg += '<is>';
                msg += '<t>' + value + '</t>';
                msg += '</is>';
                msg += '</c>';
            }
            msg += '</row>';
            return msg;
        }

        function ReLoadFn() {

            $(".onlymonth").datepicker({
                dateFormat: 'mm/yy', showButtonPanel: true, changeYear: true, changeMonth: true,
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                }
            });

            if ($('.gvCommon thead tr').length > 0) {

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "20px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "40px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "250px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "35px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 5 });
                aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 6 });
                aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 7 });

                $('.gvCommon').DataTable({
                    bFilter: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollCollapse: true,
                    destroy: true,
                    scrollY: '60vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,
                    "order": [[0, "asc"]],
                    buttons: [{ extend: 'copy', footer: true },
                            {
                                extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                customize: function (csv) {
                                    var data = $("#lnkTitle").text() + '\n';
                                    data += 'Month,' + ($('.onlymonth').val()) + '\n';
                                    data += 'Claim Type,' + $('.ddlMode option:Selected').text() + '\n\n';

                                    return data + csv;
                                },
                                exportOptions: {
                                    format: {
                                        body: function (data, row, column, node) {
                                            //check if type is input using jquery
                                            return (data == "&nbsp;" || data == "") ? " " : data;
                                            var D = data;
                                        },
                                        footer: function (data, row, column, node) {
                                            //check if type is input using jquery
                                            return (data == "&nbsp;" || data == "") ? " " : data;
                                            var D = data;
                                        }
                                    }
                                }
                            },
                            {
                                extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                customize: function (xlsx) {

                                    sheet = ExportXLS(xlsx, 3);

                                    var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                    var r1 = Addrow(2, [{ key: 'A', value: 'Month' }, { key: 'B', value: ($('.onlymonth').val()) }]);
                                    var r2 = Addrow(3, [{ key: 'A', value: 'Applicable Mode' }, { key: 'B', value: ($('.ddlMode option:Selected').text()) }]);

                                    sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + sheet.childNodes[0].childNodes[1].innerHTML;
                                }
                            },
                            {
                                extend: 'pdfHtml5',
                                orientation: 'landscape', //portrait
                                pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                                title: $("#lnkTitle").text(),
                                footer: 'true',
                                exportOptions: {
                                    columns: ':visible',
                                    search: 'applied',
                                    order: 'applied'
                                },
                                customize: function (doc) {
                                    doc.content.splice(0, 1);
                                    var now = new Date();
                                    Date.prototype.today = function () {
                                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                                    }
                                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });
                                    doc.pageMargins = [20, 50, 20, 30];
                                    doc.defaultStyle.fontSize = 8;
                                    doc.styles.tableHeader.fontSize = 8;
                                    doc.styles.tableFooter.fontSize = 8;
                                    doc['header'] = (function () {
                                        return {
                                            columns: [
                                                {
                                                    alignment: 'left',
                                                    italics: true,
                                                    text: [{ text: 'Month : ' + $('.onlymonth').val() + "\n" },
                                                           { text: 'Applicable Mode : ' + $('.ddlMode option:Selected').text() + '\n' }],

                                                    fontSize: 10,
                                                    height: 500,
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 14,
                                                    text: $("#lnkTitle").text(),
                                                    height: 500,
                                                }
                                            ],
                                            margin: 20
                                        }
                                    });
                                    doc['footer'] = (function (page, pages) {
                                        return {
                                            columns: [
                                                {
                                                    alignment: 'left',
                                                    fontSize: 8,
                                                    text: ['Created on: ', { text: jsDate.toString() }]
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 8,
                                                    text: ['Version : ', { text: Version }]
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 8,
                                                    text: ['page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
                                                }
                                            ],
                                            margin: 20
                                        }
                                    });

                                    var objLayout = {};
                                    objLayout['hLineWidth'] = function (i) { return .5; };
                                    objLayout['vLineWidth'] = function (i) { return .5; };
                                    objLayout['hLineColor'] = function (i) { return '#000'; };
                                    objLayout['vLineColor'] = function (i) { return '#000'; };
                                    objLayout['paddingLeft'] = function (i) { return 4; };
                                    objLayout['paddingRight'] = function (i) { return 4; };
                                    doc.content[0].layout = objLayout;

                                    var rowCount = doc.content[0].table.body.length;
                                    for (i = 1; i < rowCount; i++) {
                                        doc.content[0].table.body[i][5].alignment = 'right';
                                        doc.content[0].table.body[i][6].alignment = 'right';
                                        doc.content[0].table.body[i][7].alignment = 'right';
                                    };
                                }
                            }],
                    "footerCallback": function (row, data, start, end, display) {
                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                i : 0;
                        };

                        SchemeAmount = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).text());
                        }, 0);

                        CompanyCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).text());
                        }, 0);

                        DistContTax = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).text());
                        }, 0);

                        $(api.column(5).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(6).footer()).html(CompanyCont.toFixed(2));
                        $(api.column(7).footer()).html(DistContTax.toFixed(2));
                    }
                });
            }
            else if ($('.gvRecord thead tr').length > 0) {

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "20px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 3 });
                aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 4 });
                aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 5 });
                aryJSONColTable.push({ "width": "35px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 7 });
                $('.gvRecord').DataTable({
                    bFilter: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollCollapse: true,
                    destroy: true,
                    scrollY: '60vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,
                    "order": [[0, "asc"]],
                    buttons: [{ extend: 'copy', footer: true },
                            {
                                extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                customize: function (csv) {
                                    var data = $("#lnkTitle").text() + '\n';
                                    data += 'Month,' + ($('.onlymonth').val()) + '\n';
                                    data += 'Claim Type,' + $('.ddlMode option:Selected').text() + '\n\n';

                                    return data + csv;
                                },
                                exportOptions: {
                                    format: {
                                        body: function (data, row, column, node) {
                                            //check if type is input using jquery
                                            return (data == "&nbsp;" || data == "") ? " " : data;
                                            var D = data;
                                        },
                                        footer: function (data, row, column, node) {
                                            //check if type is input using jquery
                                            return (data == "&nbsp;" || data == "") ? " " : data;
                                            var D = data;
                                        }
                                    }
                                }
                            },
                            {
                                extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                customize: function (xlsx) {

                                    sheet = ExportXLS(xlsx, 3);

                                    var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                    var r1 = Addrow(2, [{ key: 'A', value: 'Month' }, { key: 'B', value: ($('.onlymonth').val()) }]);
                                    var r2 = Addrow(3, [{ key: 'A', value: 'Applicable Mode' }, { key: 'B', value: ($('.ddlMode option:Selected').text()) }]);

                                    sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + sheet.childNodes[0].childNodes[1].innerHTML;
                                }
                            },
                            {
                                extend: 'pdfHtml5',
                                orientation: 'landscape', //portrait
                                pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                                title: $("#lnkTitle").text(),
                                footer: 'true',
                                exportOptions: {
                                    columns: ':visible',
                                    search: 'applied',
                                    order: 'applied'
                                },
                                customize: function (doc) {
                                    doc.content.splice(0, 1);
                                    var now = new Date();
                                    Date.prototype.today = function () {
                                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                                    }
                                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });
                                    doc.pageMargins = [20, 50, 20, 30];
                                    doc.defaultStyle.fontSize = 8;
                                    doc.styles.tableHeader.fontSize = 8;
                                    doc.styles.tableFooter.fontSize = 8;
                                    doc['header'] = (function () {
                                        return {
                                            columns: [
                                                {
                                                    alignment: 'left',
                                                    italics: true,
                                                    text: [{ text: 'Month : ' + $('.onlymonth').val() + "\n" },
                                                           { text: 'Applicable Mode : ' + $('.ddlMode option:Selected').text() + '\n' }],

                                                    fontSize: 10,
                                                    height: 500,
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 14,
                                                    text: $("#lnkTitle").text(),
                                                    height: 500,
                                                }
                                            ],
                                            margin: 20
                                        }
                                    });
                                    doc['footer'] = (function (page, pages) {
                                        return {
                                            columns: [
                                                {
                                                    alignment: 'left',
                                                    fontSize: 8,
                                                    text: ['Created on: ', { text: jsDate.toString() }]
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 8,
                                                    text: ['Version : ', { text: Version }]
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 8,
                                                    text: ['page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
                                                }
                                            ],
                                            margin: 20
                                        }
                                    });

                                    var objLayout = {};
                                    objLayout['hLineWidth'] = function (i) { return .5; };
                                    objLayout['vLineWidth'] = function (i) { return .5; };
                                    objLayout['hLineColor'] = function (i) { return '#000'; };
                                    objLayout['vLineColor'] = function (i) { return '#000'; };
                                    objLayout['paddingLeft'] = function (i) { return 4; };
                                    objLayout['paddingRight'] = function (i) { return 4; };
                                    doc.content[0].layout = objLayout;

                                    var rowCount = doc.content[0].table.body.length;
                                    for (i = 1; i < rowCount; i++) {
                                        doc.content[0].table.body[i][3].alignment = 'right';
                                        doc.content[0].table.body[i][4].alignment = 'right';
                                        doc.content[0].table.body[i][5].alignment = 'right';
                                    };
                                }
                            }],
                    "footerCallback": function (row, data, start, end, display) {
                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                i : 0;
                        };

                        SchemeAmount = api.column(3, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        CompanyCont = api.column(4, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistContTax = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(3).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(4).footer()).html(CompanyCont.toFixed(2));
                        $(api.column(5).footer()).html(DistContTax.toFixed(2));
                    }
                });
            }
        }

    </script>
    <style type="text/css">
        .ui-datepicker-calendar {
            display: none;
        }
        table.dataTable thead th, table.dataTable thead td {
            padding: 0px 5px !important;
        }

        table.dataTable tbody th, table.dataTable tbody td {
            padding: 0px 4px !important;
        }

        table.dataTable tfoot th, table.dataTable tfoot td {
            padding: 0px 18px 6px 18px !important;
            border-top: 1px solid #111;
        }
          .dataTables_scroll {
            overflow: auto;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div class="panel">
        <div class="panel-body">
          <asp:UpdatePanel ID="up1" runat="server">
                <Triggers>
                    <asp:PostBackTrigger ControlID="btnGenerat" />
                    <asp:PostBackTrigger ControlID="btnSAPSync" />
                </Triggers>
                <ContentTemplate>
                    <div class="row _masterForm">
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblDate" runat="server" Text="Month" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDate" TabIndex="1" runat="server" MaxLength="7" CssClass="onlymonth form-control"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="Label2" runat="server" Text="Claim Period" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlMode" CssClass="form-control">
                                    <asp:ListItem Text="1 to 10" Value="1" />
                                    <asp:ListItem Text="11 t0 20" Value="2" />
                                    <asp:ListItem Text="21 to End" Value="3" />
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="Label1" runat="server" Text="Display" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlDisplay" CssClass="ddlDisplay form-control">
                                    <asp:ListItem Text="Pending" Value="1" Selected="True" />
                                    <asp:ListItem Text="Error" Value="2" />
                                    <asp:ListItem Text="Success" Value="3" />
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-4">
                            <asp:Button ID="btnGenerat" runat="server" Text="Search" TabIndex="5" CssClass="btn btn-info" OnClick="btnGenerat_Click" />
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblClaimReport" runat="server" Text="Upload Claim Report" CssClass="input-group-addon"></asp:Label>
                                <asp:FileUpload ID="flpFileUpload" runat="server" CssClass="form-control" Multiple="Multiple"></asp:FileUpload>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <asp:Button Text="Sent To Account (SAP)" Style="float: right;" ID="btnSAPSync" TabIndex="6" CssClass="btn btn-danger" runat="server" OnClick="btnSumbit_Click" OnClientClick="return CheckValid();" />
                        </div>
                    </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvCommon" runat="server" CssClass="gvCommon nowrap table" Visible="false" Width="100%" Style="font-size: 11px;" OnPreRender="gvCommon_PreRender" ShowFooter="True" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                        <Columns>
                            <asp:TemplateField HeaderText="No.">
                                <ItemTemplate>
                                    <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                    <input type="hidden" id="hdnCustomerID" runat="server" value='<%# Eval("CustomerID") %>' />
                                    <input type="hidden" id="hdnSaleID" runat="server" value='<%# Eval("SaleID") %>' />
                                    <input type="hidden" id="hdnSchemeID" runat="server" value='<%# Eval("SchemeID") %>' />
                                    <input type="hidden" id="hdnCompanyContPer" runat="server" value='<%# Eval("CompanyContPer") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Dist Code">
                                <ItemTemplate>
                                    <asp:Label ID="lblDistCode" runat="server" Text='<%# Eval("DistCode") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Dist Name">
                                <ItemTemplate>
                                    <asp:Label ID="lblDistName" runat="server" Text='<%# Eval("DistName") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Inv no.">
                                <ItemTemplate>
                                    <asp:Label ID="lblInvoiceNumber" runat="server" Text='<%# Eval("InvoiceNumber") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Doc Type">
                                <ItemTemplate>
                                    <asp:Label ID="lblDocType" runat="server" Text='<%# Eval("DocType") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Claim Amount" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="lblSchemeAmount" ItemStyle-HorizontalAlign="Right" CssClass="lblSchemeAmount" runat="server" Text='<%# Eval("SchemeAmount", "{0:0.00}") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Purchase Amount of Dealer" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="lblSalesAmount" ItemStyle-HorizontalAlign="Right" runat="server" Text='<%# Eval("SalesAmount", "{0:0.00}") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Month Sale" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="lblMonthSale" Enabled="false" runat="server" Text='<%# Bind("SubTotal", "{0:0.00}") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                    <asp:GridView ID="gvRecord" runat="server" CssClass="gvRecord nowrap table" Visible="false" Width="100%" Style="font-size: 11px;" OnPreRender="gvRecord_PreRender" ShowFooter="True" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                        <Columns>
                            <asp:TemplateField HeaderText="No.">
                                <ItemTemplate>
                                    <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                    <input type="hidden" id="hdnParentClaimID" runat="server" value='<%# Eval("ParentClaimID") %>' />
                                    <input type="hidden" id="hdnParentID" runat="server" value='<%# Eval("ParentID") %>' />
                                    <input type="hidden" id="hdnClaimID" runat="server" value='<%# Eval("ClaimID") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Dist Code" DataField="DistCode" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Dist Name" DataField="DistName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Claim Amount" DataField="SchemeAmount" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                            <asp:BoundField HeaderText="Scheme Sale" DataField="ApprovedAmount" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                            <asp:BoundField HeaderText="Purchase Amount of Dealer" DataField="TotalPurchase" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                            <asp:BoundField HeaderText="Auto" DataField="IsAuto" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="SAPErrMsg" DataField="SAPErrMsg" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

