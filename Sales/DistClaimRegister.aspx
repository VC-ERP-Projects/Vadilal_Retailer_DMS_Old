<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="DistClaimRegister.aspx.cs" Inherits="Sales_DistClaimRegister" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript">
        var Version = '<% = Version%>';
        var IpAddress;
        var ParentID = <% = ParentID%>;
        var CustType = '<% =CustType%>';
        //var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';
        $(function () {
            Reload();
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
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

            Reload();
        }
        function ToDataURL(url, callback) {
            var xhr = new XMLHttpRequest();
            xhr.onload = function () {
                var reader = new FileReader();
                reader.onloadend = function () {
                    callback(reader.result);
                }
                reader.readAsDataURL(xhr.response);
            };
            xhr.open('GET', url);
            xhr.responseType = 'blob';
            xhr.send();
        }

        function myModal() {
            $('#myCopyModal').modal();
        }
        function hideModal() {
            $('#myCopyModal').modal('hide');
            $('.modal-backdrop').css('display', 'none');
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


        function Reload() {

            var Year = <%=DateTime.Now.Year%>;
            var Month = <%=DateTime.Now.Month - 2%>;


            $(".onlymonth").datepicker({
                dateFormat: 'mm/yy', showButtonPanel: true, changeYear: true, changeMonth: true,
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                }
            });
            $(".onlymonth").on('focus blur click', function () {
                $(".ui-datepicker-calendar").hide();

            });

            //$(".onlymonth").datepicker({
            //    dateFormat: 'mm/yy', showButtonPanel: true, changeYear: true, changeMonth: true,
            //    onClose: function (dateText, inst) {
            //        $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
            //    },
            //    //maxDate: new Date(Year, Month, 1)
            //});

            var SalesAmount = 0, SchemeAmount = 0, CompanyCont = 0, DistCont = 0, DistContTax = 0, TotalCompanyCont = 0, TotalQty = 0;
            var LogoURL = '../Images/LOGO.png';
            if ($('.gvMasterScheme thead tr').length > 0) {
                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "350px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyleft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyleft", "aTargets": 4 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 5 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 6 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 7 });//"sClass": "dtbodyLeft",
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 8 });
                //aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 9 });
                //aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 10 });

                $('.gvMasterScheme').DataTable({
                    bFilter: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollCollapse: true,
                    destroy: true,
                    "sExtends": "collection",
                    scrollY: '55vh',
                    scrollX: false,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "bSort": false,
                    "order": [[0, "asc"]],
                    "aoColumnDefs": aryJSONColTable,
                    "autoWidth": false,
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
                            var r2 = Addrow(3, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: ($('.ddlMode option:Selected').text()) }]);

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
                                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear().toString().substring(2);
                            }
                            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-GB', { hour: 'numeric', minute: 'numeric', hour12: false });
                            doc.pageMargins = [20, 80, 20, 30];
                            doc.defaultStyle.fontSize = 8;
                            doc.styles.tableHeader.fontSize = 8;
                            doc.styles.tableFooter.fontSize = 8;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: ($('.hdnCustType').val() == "2" ? "Distributor        : " : "Super Stockist : ") + $('.hdnUserName').val() + "\n" },
                                            { text: 'Region               : ' + $('.hdnRegionName').val() + "\n" },
                                            { text: 'Month                : ' + $('.onlymonth').val() + "\n" },
                                            { text: 'Claim Type        : ' + $('.ddlMode option:Selected').text() + '\n' }],

                                            fontSize: 10,
                                            height: 500,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Run Date/Time : ', { text: jsDate.toString() }, "           ", 'UserId : ', { text: $('.hdnUserName').val() }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Version : ', { text: Version }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Page: ', { text: page.toString() }, ' of ', { text: pages.toString() }]
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
                                doc.content[0].table.body[i][8].alignment = 'right';
                                //doc.content[0].table.body[i][9].alignment = 'right';
                                //doc.content[0].table.body[i][10].alignment = 'right';
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
                            return intVal(a) + intVal(b);
                        }, 0);

                        //CompanyCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        //DistContTax = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        DistCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SalesAmount = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(5).footer()).html(SchemeAmount.toFixed(2));
                        //$(api.column(6).footer()).html(CompanyCont.toFixed(2));
                        //$(api.column(7).footer()).html(DistContTax.toFixed(2));
                        $(api.column(6).footer()).html(DistCont.toFixed(2));
                        $(api.column(7).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(8).footer()).html(SalesAmount.toFixed(2));
                    }
                });
            }
            else if ($('.gvQPSScheme thead tr').length > 0) {
                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "150px", "sClass": "CustName", "aTargets": 2 });
                aryJSONColTable.push({ "width": "200px", "sClass": "dtbodyRight", "aTargets": 3 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyleft", "aTargets": 4 });
                aryJSONColTable.push({ "width": "150px", "sClass": "dtbodyleft CustName", "aTargets": 5 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyleft", "aTargets": 6 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyleft", "aTargets": 7 });//"sClass": "dtbodyLeft",
                aryJSONColTable.push({ "width": "300px", "sClass": "dtbodyRight", "aTargets": 8 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 9 });
                aryJSONColTable.push({ "width": "150px", "sClass": "dtbodyRight", "aTargets": 10 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 11 });
                $('.gvQPSScheme').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '55vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "bSort": false,
                    "order": [[0, "asc"]],
                    "aoColumnDefs": aryJSONColTable,
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
                            var r2 = Addrow(3, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: ($('.ddlMode option:Selected').text()) }]);

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
                                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear().toString().substring(2);
                            }
                            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-GB', { hour: 'numeric', minute: 'numeric', hour12: false });
                            doc.pageMargins = [20, 80, 20, 30];
                            doc.defaultStyle.fontSize = 8;
                            doc.styles.tableHeader.fontSize = 8;
                            doc.styles.tableFooter.fontSize = 8;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: ($('.hdnCustType').val() == "2" ? "Distributor        : " : "Super Stockist : ") + $('.hdnUserName').val() + "\n" },
                                            { text: 'Region               : ' + $('.hdnRegionName').val() + "\n" },
                                            { text: 'Month                : ' + $('.onlymonth').val() + "\n" },
                                            { text: 'Claim Type        : ' + $('.ddlMode option:Selected').text() + '\n' }],

                                            fontSize: 10,
                                            height: 500,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Run Date/Time : ', { text: jsDate.toString() }, "           ", 'UserId : ', { text: $('.hdnUserName').val() }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Version : ', { text: Version }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
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
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][9].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                                doc.content[0].table.body[i][11].alignment = 'right';
                                //doc.content[0].table.body[i][12].alignment = 'right';
                                //doc.content[0].table.body[i][13].alignment = 'right';
                            };
                        }
                    }],
                    "footerCallback": function (row, data, start, end, display) {
                        var api = this.api(), data;

                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                    i : 0;
                        };

                        TotalQty = api.column(3, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SchemeAmount = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        //CompanyCont = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        //DistContTax = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        DistCont = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SalesAmount = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);
                        $(api.column(3).footer()).html(TotalQty.toFixed(0));
                        $(api.column(8).footer()).html(SchemeAmount.toFixed(2));
                        //$(api.column(9).footer()).html(CompanyCont.toFixed(2));
                        //$(api.column(10).footer()).html(DistContTax.toFixed(2));
                        $(api.column(9).footer()).html(DistCont.toFixed(2));
                        $(api.column(10).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(11).footer()).html(SalesAmount.toFixed(2));
                    }
                });
            }
            else if ($('.gvMachineScheme thead tr').length > 0) {

                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "150px", "sClass": "CustName", "aTargets": 2 });
                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyleft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyleft", "aTargets": 4 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight CustName", "aTargets": 5 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 6 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 7 });//"sClass": "dtbodyLeft",
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 8 });


                $('.gvMachineScheme').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '55vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    "bSort": false,
                    "aoColumnDefs": aryJSONColTable,
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
                            var r2 = Addrow(3, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: ($('.ddlMode option:Selected').text()) }]);

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
                                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear().toString().substring(2);
                            }
                            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-GB', { hour: 'numeric', minute: 'numeric', hour12: false });
                            doc.pageMargins = [20, 80, 20, 30];
                            doc.defaultStyle.fontSize = 8;
                            doc.styles.tableHeader.fontSize = 8;
                            doc.styles.tableFooter.fontSize = 8;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: ($('.hdnCustType').val() == "2" ? "Distributor        : " : "Super Stockist : ") + $('.hdnUserName').val() + "\n" },
                                            { text: 'Region               : ' + $('.hdnRegionName').val() + "\n" },
                                            { text: 'Month                : ' + $('.onlymonth').val() + "\n" },
                                            { text: 'Claim Type        : ' + $('.ddlMode option:Selected').text() + '\n' }],

                                            fontSize: 10,
                                            height: 500,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Run Date/Time : ', { text: jsDate.toString() }, "           ", 'UserId : ', { text: $('.hdnUserName').val() }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Version : ', { text: Version }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
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
                                doc.content[0].table.body[i][8].alignment = 'right';
                                //doc.content[0].table.body[i][9].alignment = 'right';
                                //doc.content[0].table.body[i][10].alignment = 'right';
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
                            return intVal(a) + intVal(b);
                        }, 0);

                        //CompanyCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        //DistContTax = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        DistCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SalesAmount = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(5).footer()).html(SchemeAmount.toFixed(2));
                        //$(api.column(6).footer()).html(CompanyCont.toFixed(2));
                        //$(api.column(7).footer()).html(DistContTax.toFixed(2));
                        $(api.column(6).footer()).html(DistCont.toFixed(2));
                        $(api.column(7).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(8).footer()).html(SalesAmount.toFixed(2));
                    }
                });
            }
            else if ($('.gvParlourScheme thead tr').length > 0) {
                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "150px", "sClass": "CustName", "aTargets": 2 });
                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyleft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyleft", "aTargets": 4 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight CustName", "aTargets": 5 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 6 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 7 });//"sClass": "dtbodyLeft",
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 8 });
                $('.gvParlourScheme').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '55vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    "bSort": false,
                    "aoColumnDefs": aryJSONColTable,
                    buttons: [{ extend: 'copy', footer: true },
                    {
                        extend: 'csv', footer: true, filename: 'ClaimProcess_' + new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = 'Claim Process \n';
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
                        extend: 'excel', footer: true, filename: 'ClaimProcess_' + new Date().toLocaleDateString(),
                        customize: function (xlsx) {

                            sheet = ExportXLS(xlsx, 3);

                            var r0 = Addrow(1, [{ key: 'A', value: 'Claim Process' }]);
                            var r1 = Addrow(2, [{ key: 'A', value: 'Month' }, { key: 'B', value: ($('.onlymonth').val()) }]);
                            var r2 = Addrow(3, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: ($('.ddlMode option:Selected').text()) }]);

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
                                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear().toString().substring(2);
                            }
                            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-GB', { hour: 'numeric', minute: 'numeric', hour12: false });
                            doc.pageMargins = [20, 80, 20, 30];
                            doc.defaultStyle.fontSize = 8;
                            doc.styles.tableHeader.fontSize = 8;
                            doc.styles.tableFooter.fontSize = 8;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: ($('.hdnCustType').val() == "2" ? "Distributor        : " : "Super Stockist : ") + $('.hdnUserName').val() + "\n" },
                                            { text: 'Region               : ' + $('.hdnRegionName').val() + "\n" },
                                            { text: 'Month                : ' + $('.onlymonth').val() + "\n" },
                                            { text: 'Claim Type        : ' + $('.ddlMode option:Selected').text() + '\n' }],

                                            fontSize: 10,
                                            height: 500,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Run Date/Time : ', { text: jsDate.toString() }, "           ", 'UserId : ', { text: $('.hdnUserName').val() }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Version : ', { text: Version }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
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
                                doc.content[0].table.body[i][8].alignment = 'right';
                                //doc.content[0].table.body[i][9].alignment = 'right';
                                //doc.content[0].table.body[i][10].alignment = 'right';
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
                            return intVal(a) + intVal(b);
                        }, 0);

                        //CompanyCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        //DistContTax = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        DistCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SalesAmount = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(5).footer()).html(SchemeAmount.toFixed(2));
                        //$(api.column(6).footer()).html(CompanyCont.toFixed(2));
                        //$(api.column(7).footer()).html(DistContTax.toFixed(2));
                        $(api.column(6).footer()).html(DistCont.toFixed(2));
                        $(api.column(7).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(8).footer()).html(SalesAmount.toFixed(2));
                    }
                });
            }
            else if ($('.gvVRSDiscount thead tr').length > 0) {
                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "150px", "sClass": "CustName", "aTargets": 2 });
                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyleft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyleft", "aTargets": 4 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight CustName", "aTargets": 5 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 6 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 7 });//"sClass": "dtbodyLeft",
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 8 });

                $('.gvVRSDiscount').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '55vh',
                    scrollX: false,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    "bSort": false,
                    "aoColumnDefs": aryJSONColTable,
                    buttons: [{ extend: 'copy', footer: true },
                    {
                        extend: 'csv', footer: true, filename: 'ClaimProcess_' + new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = 'Claim Process \n';
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
                        extend: 'excel', footer: true, filename: 'ClaimProcess_' + new Date().toLocaleDateString(),
                        customize: function (xlsx) {

                            sheet = ExportXLS(xlsx, 3);

                            var r0 = Addrow(1, [{ key: 'A', value: 'Claim Process' }]);
                            var r1 = Addrow(2, [{ key: 'A', value: 'Month' }, { key: 'B', value: ($('.onlymonth').val()) }]);
                            var r2 = Addrow(3, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: ($('.ddlMode option:Selected').text()) }]);

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
                                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear().toString().substring(2);
                            }
                            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-GB', { hour: 'numeric', minute: 'numeric', hour12: false });
                            doc.pageMargins = [20, 80, 20, 30];
                            doc.defaultStyle.fontSize = 8;
                            doc.styles.tableHeader.fontSize = 8;
                            doc.styles.tableFooter.fontSize = 8;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: ($('.hdnCustType').val() == "2" ? "Distributor        : " : "Super Stockist : ") + $('.hdnUserName').val() + "\n" },
                                            { text: 'Region               : ' + $('.hdnRegionName').val() + "\n" },
                                            { text: 'Month                : ' + $('.onlymonth').val() + "\n" },
                                            { text: 'Claim Type        : ' + $('.ddlMode option:Selected').text() + '\n' }],

                                            fontSize: 10,
                                            height: 500,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Run Date/Time : ', { text: jsDate.toString() }, "           ", 'UserId : ', { text: $('.hdnUserName').val() }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Version : ', { text: Version }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
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
                                doc.content[0].table.body[i][8].alignment = 'right';
                                //doc.content[0].table.body[i][9].alignment = 'right';
                                //doc.content[0].table.body[i][10].alignment = 'right';
                            };
                            //Header Alignment for PDF Export.
                            doc.content[0].table.body[0][0].alignment = 'right';
                            doc.content[0].table.body[0][1].alignment = 'left';
                            doc.content[0].table.body[0][2].alignment = 'left';
                            doc.content[0].table.body[0][3].alignment = 'left';
                            doc.content[0].table.body[0][4].alignment = 'left';
                            doc.content[0].table.body[0][5].alignment = 'right';
                            doc.content[0].table.body[0][6].alignment = 'right';
                            doc.content[0].table.body[0][7].alignment = 'right';
                            doc.content[0].table.body[0][8].alignment = 'right';
                            //doc.content[0].table.body[0][9].alignment = 'right';
                            //doc.content[0].table.body[0][10].alignment = 'right';
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
                            return intVal(a) + intVal(b);
                        }, 0);

                        //CompanyCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        //DistContTax = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        DistCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SalesAmount = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(5).footer()).html(SchemeAmount.toFixed(2));
                        //$(api.column(6).footer()).html(CompanyCont.toFixed(2));
                        //$(api.column(7).footer()).html(DistContTax.toFixed(2));
                        $(api.column(6).footer()).html(DistCont.toFixed(2));
                        $(api.column(7).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(8).footer()).html(SalesAmount.toFixed(2));

                    }
                });
            }
            else if ($('.gvFOWScheme thead tr').length > 0) {
                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "150px", "sClass": "CustName", "aTargets": 2 });
                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyleft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 4 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight CustName", "aTargets": 5 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 6 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 7 });//"sClass": "dtbodyLeft",
                aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyRight", "aTargets": 8 });
                $('.gvFOWScheme').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '55vh',
                    scrollX: false,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    "bSort": false,
                    "aoColumnDefs": aryJSONColTable,
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
                            var r2 = Addrow(3, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: ($('.ddlMode option:Selected').text()) }]);

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
                                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear().toString().substring(2);
                            }
                            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-GB', { hour: 'numeric', minute: 'numeric', hour12: false });
                            doc.pageMargins = [20, 80, 20, 30];
                            doc.defaultStyle.fontSize = 8;
                            doc.styles.tableHeader.fontSize = 8;
                            doc.styles.tableFooter.fontSize = 8;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: ($('.hdnCustType').val() == "2" ? "Distributor        : " : "Super Stockist : ") + $('.hdnUserName').val() + "\n" },
                                            { text: 'Region               : ' + $('.hdnRegionName').val() + "\n" },
                                            { text: 'Month                : ' + $('.onlymonth').val() + "\n" },
                                            { text: 'Claim Type        : ' + $('.ddlMode option:Selected').text() + '\n' }],

                                            fontSize: 10,
                                            height: 500,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Run Date/Time : ', { text: jsDate.toString() }, "           ", 'UserId : ', { text: $('.hdnUserName').val() }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Version : ', { text: Version }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
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
                                doc.content[0].table.body[i][4].alignment = 'right';
                                doc.content[0].table.body[i][5].alignment = 'right';
                                doc.content[0].table.body[i][6].alignment = 'right';
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
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

                        SchemeAmount = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SalesAmount = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(6).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(7).footer()).html(SalesAmount.toFixed(2));
                    }
                });
            }
            else if ($('.gvSecFreight thead tr').length > 0) {
                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "80px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "300px", "sClass": "CustName", "aTargets": 2 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyleft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "65px", "sClass": "dtbodyleft", "aTargets": 4 });
                aryJSONColTable.push({ "width": "55px", "sClass": "dtbodyRight CustName", "aTargets": 5 });
                $('.gvSecFreight').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '55vh',
                    scrollX: false,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    "bSort": false,
                    "aoColumnDefs": aryJSONColTable,
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
                            var r2 = Addrow(3, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: ($('.ddlMode option:Selected').text()) }]);

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
                                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear().toString().substring(2);
                            }
                            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-GB', { hour: 'numeric', minute: 'numeric', hour12: false });
                            doc.pageMargins = [20, 80, 20, 30];
                            doc.defaultStyle.fontSize = 8;
                            doc.styles.tableHeader.fontSize = 8;
                            doc.styles.tableFooter.fontSize = 8;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: ($('.hdnCustType').val() == "2" ? "Distributor        : " : "Super Stockist : ") + $('.hdnUserName').val() + "\n" },
                                            { text: 'Region               : ' + $('.hdnRegionName').val() + "\n" },
                                            { text: 'Month                : ' + $('.onlymonth').val() + "\n" },
                                            { text: 'Claim Type        : ' + $('.ddlMode option:Selected').text() + '\n' }],

                                            fontSize: 10,
                                            height: 500,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Run Date/Time : ', { text: jsDate.toString() }, "           ", 'UserId : ', { text: $('.hdnUserName').val() }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Version : ', { text: Version }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
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
                            return intVal(a) + intVal(b);
                        }, 0);

                        CompanyCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(5).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(6).footer()).html(CompanyCont.toFixed(2));
                    }
                });
            }
            else if ($('.gvRateDiff thead tr').length > 0) {
                $('.gvRateDiff').DataTable({
                    bFilter: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollCollapse: true,
                    destroy: true,
                    scrollY: '55vh',
                    scrollX: true,
                    responsive: true,
                    autowidth: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    "bSort": false,
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
                            var r2 = Addrow(3, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: ($('.ddlMode option:Selected').text()) }]);

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
                                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear().toString().substring(2);
                            }
                            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-GB', { hour: 'numeric', minute: 'numeric', hour12: false });
                            doc.pageMargins = [20, 80, 20, 30];
                            doc.defaultStyle.fontSize = 8;
                            doc.styles.tableHeader.fontSize = 8;
                            doc.styles.tableFooter.fontSize = 8;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: ($('.hdnCustType').val() == "2" ? "Distributor        : " : "Super Stockist : ") + $('.hdnUserName').val() + "\n" },
                                            { text: 'Region               : ' + $('.hdnRegionName').val() + "\n" },
                                            { text: 'Month                : ' + $('.onlymonth').val() + "\n" },
                                            { text: 'Claim Type        : ' + $('.ddlMode option:Selected').text() + '\n' }],

                                            fontSize: 10,
                                            height: 500,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Run Date/Time : ', { text: jsDate.toString() }, "           ", 'UserId : ', { text: $('.hdnUserName').val() }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Version : ', { text: Version }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['Page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
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
                                doc.content[0].table.body[i][8].alignment = 'right';

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
                            return intVal(a) + intVal(b);
                        }, 0);

                        CompanyCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistContTax = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistCont = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(5).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(6).footer()).html(CompanyCont.toFixed(2));
                        $(api.column(7).footer()).html(DistContTax.toFixed(2));
                        $(api.column(8).footer()).html(DistCont.toFixed(2));
                    }
                });
            }
            else if ($('.gvIOU thead tr').length > 0) {
                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "82px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "150px", "sClass": "CustName", "aTargets": 2 });
                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyleft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyleft", "aTargets": 4 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight CustName", "aTargets": 5 });
                aryJSONColTable.push({ "width": "98px", "sClass": "dtbodyRight", "aTargets": 6 });
                aryJSONColTable.push({ "width": "103px", "sClass": "dtbodyRight", "aTargets": 7 });//"sClass": "dtbodyLeft",
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 8 });
                aryJSONColTable.push({ "width": "105px", "sClass": "dtbodyRight", "aTargets": 9 });
                aryJSONColTable.push({ "width": "90px", "sClass": "dtbodyRight", "aTargets": 10 });

                $('.gvIOU').DataTable({
                    bFilter: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollCollapse: true,
                    destroy: true,
                    scrollY: '55vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    "bSort": false,
                    "aoColumnDefs": aryJSONColTable,
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
                            var r2 = Addrow(3, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: ($('.ddlMode option:Selected').text()) }]);

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
                                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear().toString().substring(2);
                            }
                            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-GB', { hour: 'numeric', minute: 'numeric', hour12: false });
                            doc.pageMargins = [20, 80, 20, 30];
                            doc.defaultStyle.fontSize = 8;
                            doc.styles.tableHeader.fontSize = 8;
                            doc.styles.tableFooter.fontSize = 8;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: ($('.hdnCustType').val() == "2" ? "Distributor        : " : "Super Stockist : ") + $('.hdnUserName').val() + "\n" },
                                            { text: 'Region               : ' + $('.hdnRegionName').val() + "\n" },
                                            { text: 'Month                : ' + $('.onlymonth').val() + "\n" },
                                            { text: 'Claim Type        : ' + $('.ddlMode option:Selected').text() + '\n' }],

                                            fontSize: 10,
                                            height: 500,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Created on: ', { text: new Date().format('dd-MMM-yy HH:mm') }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['UserId : ', { text: $('.hdnUserName').val() }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['IP Address: ', { text: $("#hdnIPAdd").val() }]
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
                                doc.content[0].table.body[i][0].alignment = 'center';
                                doc.content[0].table.body[i][5].alignment = 'right';
                                doc.content[0].table.body[i][6].alignment = 'right';
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][9].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                            };
                            doc.content[0].table.body[0][0].alignment = 'center';
                            doc.content[0].table.body[0][1].alignment = 'left';
                            doc.content[0].table.body[0][2].alignment = 'left';
                            doc.content[0].table.body[0][3].alignment = 'left';
                            doc.content[0].table.body[0][4].alignment = 'left';
                            doc.content[0].table.body[0][5].alignment = 'right';
                            doc.content[0].table.body[0][6].alignment = 'right';
                            doc.content[0].table.body[0][7].alignment = 'right';
                            doc.content[0].table.body[0][8].alignment = 'right';
                            doc.content[0].table.body[0][9].alignment = 'right';
                            doc.content[0].table.body[0][10].alignment = 'right';

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

                        PurchaseAmt = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalQty = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        ClaimAmt = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        //PerClaimAmt = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        //PerPurClaimAmt= api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        $(api.column(5).footer()).html(PurchaseAmt);
                        $(api.column(6).footer()).html(TotalQty.toFixed(2));
                        $(api.column(7).footer()).html(ClaimAmt.toFixed(2));

                        var hdnGrossPurchaseDist = intVal($(".hdnGrossPurchaseDist").val());
                        $(api.column(8).footer()).html(hdnGrossPurchaseDist.toFixed(2));
                        var PurClaimPerAmt = intVal($(".hdnClaimPurAmtForPer").val());
                        $(api.column(9).footer()).html(PurClaimPerAmt.toFixed(2));

                        var FinalClaimAmt = intVal((intVal(PurClaimPerAmt.toFixed(2)) <= intVal(ClaimAmt.toFixed(2))) ? PurClaimPerAmt.toFixed(2) : ClaimAmt.toFixed(2));
                        $(api.column(10).footer()).html(FinalClaimAmt.toFixed(2));

                        $(".hdnFinalClaimAmt").val(FinalClaimAmt.toFixed(2));
                    }
                });
            }
        }
        function ChangeReportFor(SelType) {

            if ($('.ddlSaleBy').val() == "4") {
                if (SelType == "2") {
                    $('.txtSSCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').removeAttr('style');
                $('.divDealer').attr('style', 'display:none;');
            }
            else if ($('.ddlSaleBy').val() == "2") {
                if (SelType == "2") {
                    $('.txtSSCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').removeAttr('style');
            }

        }


        function _btnCheck() {

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }
        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var ss = "";
            var dist = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            if (CustType == 2)
                dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : ParentID;
            else
                dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : "0";
            sender.set_contextKey("0-0-0-" + ss + "-" + dist + "-" + EmpID);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey("0-0-0-" + ss + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey("0-0-0-" + EmpID);
        }
        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtDistCode").val('');
                $(".txtDealerCode").val('');
                $(".txtSSCode").val('');
            }
        }
        function ClearOtherDistConfig() {
            if ($(".txtDistCode").length > 0) {
                $(".txtDealerCode").val('');
            }
        }
        function ClearOtherSSConfig() {
            if ($(".txtSSCode").length > 0) {
                $(".txtDistCode").val('');
            }
        }
    </script>
    <style type="text/css">
        table.dataTable thead th, table.dataTable thead td {
            padding: 0px 5px !important;
        }

        table {
            table-layout: inherit;
        }

            /*th {
            text-align: center !important;
        }*/

            table.dataTable tbody th, table.dataTable tbody td {
                padding: 0px 4px !important;
            }

            table.dataTable tfoot th {
                padding: 0px 18px 6px 18px !important;
                border-top: 1px solid #111;
            }

            table.dataTable tfoot td {
                padding: 0px 4px !important;
                border-top: 1px solid #111;
            }

        .ui-datepicker-calendar {
            display: none;
        }

        #body_txtDate .hidecalendar {
        }

        table.dataTable.nowrap th {
            white-space: normal !important;
        }

        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        .table > tfoot {
            /*position: -webkit-sticky;*/
            position: sticky;
            bottom: 0;
            z-index: 4;
            /*inset-block-end: 0;*/
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }


        .dtbodyRight {
            text-align: right;
        }

        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            /*padding-left: 4px !important;*/
            /*padding: 0px 0 0 4px !important;*/
            padding: 0px;
            vertical-align: middle !important;
            /*white-space: nowrap;*/
            /*overflow-x: scroll;*/
        }

        #body_gvMasterScheme_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
        }



        #body_gvQPSScheme_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
        }



        #body_gvMachineScheme_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
        }

        #body_gvRateDiff_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
        }

        #body_gvParlourScheme_wrapper .dataTables_scrollHeadInner {
            table-layout: fixed !important;
        }

        #body_gvParlourScheme_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
            margin-left: -104px !important;
        }

        #body_gvVRSDiscount_wrapper .dataTables_scrollHeadInner {
            table-layout: fixed !important;
        }

        #body_gvVRSDiscount_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
        }

        #body_gvSecFreight_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
        }

        #body_gvIOU_wrapper .dataTables_scrollHeadInner {
            width: 100% !important;
            table-layout: fixed !important;
        }

        #body_gvIOU_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
            margin-left: -4px !important;
        }

        #body_gvFOWScheme_wrapper .dataTables_scrollHeadInner {
            width: 100% !important;
            table-layout: fixed !important;
        }

        #body_gvFOWScheme_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
        }

        /*.dataTables_scrollHeadInner {
            width: 100% !important;
        }

         .dataTables_scrollBody {
            width: 100% !important;
        }*/
        .table > tfoot {
            /*position: -webkit-sticky;*/
            position: sticky;
            bottom: 0;
            z-index: 4;
            /*inset-block-end: 0;*/
        }
        /*#body_gvMasterScheme_wrapper .dataTables_scroll .dataTables_scrollBody {
            overflow-y: auto !important;
            overflow-x: hidden !important;
            max-height: none !important;
        }*/

        .dataTables_wrapper .dataTables_scroll {
            clear: both;
            width: 100%;
            /*height: 60vh;*/
        }

        .dataTables_scrollHead, .dataTables_scrollFootInner {
            width: 100% !important;
        }

        .CustName {
            /*overflow: auto;*/
            white-space: nowrap;
            overflow-x: scroll;
            padding-left: 4px !important;
        }

            .CustName::-webkit-scrollbar {
                display: none;
            }

        /* Hide scrollbar for IE, Edge and Firefox */
        .CustName {
            -ms-overflow-style: none; /* IE and Edge */
            scrollbar-width: none; /* Firefox */
        }

        @media (min-width: 768px) {
            .container {
                max-width: 100%;
            }
        }

        @media (min-width: 1200px) {
            .container {
                width: 1073px;
            }
        }

        @media (min-width: 992px) {
            .container {
                max-width: 100%;
            }
        }

        @media (min-width: 1200px) {
            .dataTables_scrollHead {
                width: 1033px !important;
            }

            #body_gvQPSScheme_wrapper .dataTables_scrollHead {
                width: 1051px !important;
            }

            #body_gvMasterScheme_wrapper .dataTables_scrollBody {
                width: 1000px !important;
            }

            #body_gvQPSScheme_wrapper .dataTables_scrollBody {
                width: 1050px !important;
            }

            #body_gvRateDiff_wrapper .dataTables_scrollBody {
                width: 1050px !important;
            }

            #body_gvMachineScheme_wrapper .dataTables_scrollBody {
                width: 950px !important;
            }

            #body_gvParlourScheme_wrapper .dataTables_scrollBody {
                width: 1050px !important;
            }

            #body_gvSecFreight_wrapper .dataTables_scrollBody {
                width: 750px !important;
            }

            #body_gvVRSDiscount_wrapper .dataTables_scrollBody {
                width: 1050px !important;
            }

            #body_gvIOU_wrapper .dataTables_scrollBody {
                width: 1140px !important;
            }

            #body_gvFOWScheme_wrapper .dataTables_scrollBody {
                width: 1050px !important;
            }

            #body_gvRateDiff_wrapper .dataTables_scrollHead {
                width: 100% !important;
            }

            #body_gvSecFreight_wrapper .dataTables_scrollHead {
                width: 750px !important;
            }

            #body_gvVRSDiscount_wrapper .dataTables_scrollHead {
                width: 100% !important;
            }

            #body_gvIOU_wrapper .dataTables_scrollHead {
                width: 1140px !important;
            }

            #body_gvFOWScheme_wrapper .dataTables_scrollHead {
                width: 100% !important;
            }

            #body_gvIOU_wrapper .dataTables_scrollFootInner {
                width: 1140px !important;
            }

            #body_gvIOU_wrapper .dataTables_scrollFoot {
                width: 1140px !important;
            }

            #body_gvSecFreight_wrapper .dataTables_scrollFoot {
                width: 750px !important;
            }

            .dataTables_scrollFoot {
                width: 1050px !important;
            }

            .dataTables_scrollFootInner {
                width: 1050px !important;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
            <div class="row _masterForm">
                <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                <input type="hidden" class="hdnRegionName" id="hdnRegionName" runat="server" />
                <input type="hidden" class="hdnCustType" id="hdnCustType" runat="server" />
                <asp:UpdatePanel ID="up1" runat="server" UpdateMode="Always">
                    <Triggers>
                        <asp:PostBackTrigger ControlID="btnGenerat"/>
                        <asp:PostBackTrigger ControlID="btnSubmit" />
                        <%--<asp:PostBackTrigger ControlID="btnClear" />--%>
                    </Triggers>
                    <ContentTemplate>
                        <%--<div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblDate" runat="server" Text="Month" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDate" TabIndex="1" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="onlymonth form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="5" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                                &nbsp
                        <asp:Button ID="btnSubmit" runat="server" Text="Submit" TabIndex="5" CssClass="btn btn-default" OnClick="btnSubmit_Click" />
                                &nbsp
                        <asp:Button ID="btnClear" runat="server" Text="Clear" TabIndex="5" CssClass="btn btn-default" OnClick="btnClear_Click" />
                                &nbsp;
                            <input type="button" id="btnAddNew" tabindex="1" class="btn btn-default" onclick="myModal();" value="Upload Claim Report" style="display: none" />
                            </div>

                        </div>--%>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblDate" runat="server" Text="Month" CssClass="input-group-addon" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:Label>
                                <asp:TextBox ID="txtDate" TabIndex="1" runat="server" MaxLength="7" CssClass="onlymonth form-control"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label Text="Claim Type" runat="server" CssClass="input-group-addon" />
                                <asp:DropDownList runat="server" ID="ddlMode" CssClass="ddlMode form-control" TabIndex="2">
                                    <asp:ListItem Text="Extra Discount (%) (C01)" Value="M" Selected="True" />
                                    <asp:ListItem Text="QPS Scheme (C06)" Value="S" />
                                    <asp:ListItem Text="Free I/C Scheme - Machine Purchase Dlr. (C33)" Value="D" />
                                    <asp:ListItem Text="Free I/C Scheme For Parlour (C34)" Value="P" />
                                   <%-- <asp:ListItem Text="FOW Electricity (C11)" Value="F" />--%>
                                    <asp:ListItem Text="Outstation Freight Claims (%) (C04)" Value="T" />
                                    <asp:ListItem Text="Free Ice Cream for FOW VRS & Vendor (C61)" Value="V" />
                                    <asp:ListItem Text="Online Rate Difference Claim (C68)" Value="R" />
                                    <asp:ListItem Text="Online IOU Claim (Master/QPS/Free) (C69)" Value="I" />
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-lg-4" id="divEmpCode" runat="server" style="display: none;">
                            <div class="input-group form-group">
                                <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" OnChange="ClearOtherConfig()" TabIndex="3" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServicePath="../Service.asmx"
                                    UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                                    EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4" style="display: none;">
                            <div class="input-group form-group">
                                <asp:Label ID="lblDisplay" runat="server" Text="Display" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlClaimStatus" TabIndex="4" CssClass="form-control">
                                    <asp:ListItem Text="---- Select ----" Value="0" Selected="True" />
                                    <asp:ListItem Text="Pending" Value="1" />
                                    <asp:ListItem Text="Error" Value="2" />
                                    <asp:ListItem Text="Success" Value="3" />
                                    <asp:ListItem Text="InProcess" Value="4" />
                                    <asp:ListItem Text="Delete" Value="6" />
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-lg-4" style="display: none;">
                            <div class="input-group form-group">
                                <asp:Label runat="server" ID="lblSaleBy" Text="Report For" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlSaleBy" TabIndex="5" CssClass="ddlSaleBy form-control" OnChange="ChangeReportFor('2');">
                                    <asp:ListItem Text="Super Stockist" Value="4" />
                                    <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-lg-4 divSS" id="divSS" runat="server">
                            <div class="input-group form-group">
                                <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtSSCode" OnChange="ClearOtherSSConfig()" runat="server" TabIndex="3" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSCode form-control" autocomplete="off"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                                    UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                                    EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSCode">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                            <div class="input-group form-group">
                                <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDistCode" OnChange="ClearOtherDistConfig()" runat="server" TabIndex="3" CssClass="txtDistCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                                    UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                                    EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4 divDealer" id="divDealer" runat="server" style="display: none;">
                            <div class="input-group form-group">
                                <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="4" CssClass="txtDealerCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                                    UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                                    EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4" style="display: none;">
                            <div class="input-group form-group">
                                <asp:Label runat="server" ID="lblItemDetail" Text="Item Detail" CssClass="input-group-addon"></asp:Label>
                                <asp:CheckBox runat="server" ID="chkItemDetail" Checked="true" TabIndex="9" CssClass="form-control" />
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="5" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                                &nbsp
                       <asp:Button ID="btnSubmit" runat="server" Text="Submit" TabIndex="5" CssClass="btn btn-default" OnClick="btnSubmit_Click" Visible="false" />
                                &nbsp
                        <asp:Button ID="btnClear" runat="server" Text="Clear" TabIndex="5" CssClass="btn btn-default" OnClick="btnClear_Click" />

                            </div>
                        </div>


                        <asp:GridView ID="gvMasterScheme" runat="server" CssClass="gvMasterScheme nowrap table" Width="70%"  Style="font-size: 11px;" OnPreRender="gvMasterScheme_PreRender" ShowFooter="True" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr." ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                                        <input type="hidden" id="hdnCustomerID" runat="server" value='<%# Eval("CustomerID") %>' />
                                        <input type="hidden" id="hdnSaleID" runat="server" value='<%# Eval("SaleID") %>' />
                                        <input type="hidden" id="hdnSchemeID" runat="server" value='<%# Eval("SchemeID") %>' />
                                        <input type="hidden" id="hdnSAPReasonItemCode" runat="server" value='<%# Eval("SAPReasonItemCode") %>' />
                                        <input type="hidden" id="hdnCompanyContPer" runat="server" value='<%# Eval("CompanyContPer") %>' />
                                        <input type="hidden" id="hdnDistContPer" runat="server" value='<%# Eval("DistContPer") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Code" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerCode" runat="server" Text='<%# Eval("DealerCode") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Name" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerName" runat="server" Text='<%# Eval("DealerName") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Inv no." HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblInvoiceNumber" runat="server" Text='<%# Eval("InvoiceNumber") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Doc Type" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDocType" runat="server" Text='<%# Eval("DocType") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Claim Amount" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSchemeAmount" runat="server" Text='<%# Eval("SchemeAmount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Company Contri." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblCompanyCont" runat="server" Text='<%# Eval("CompanyCont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Distribution Contribution bared by Company" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDistContTax" runat="server" Text='<%# Eval("DistContTax", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Distributor Contri." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDistCont" runat="server" Text='<%# Eval("DistCont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Company Contri." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblTotalCompanyCont" runat="server" Text='<%# Eval("TotalCompanyCont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Purchase Amount of Dealer" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSalesAmount" runat="server" Text='<%# Eval("SalesAmount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <asp:GridView ID="gvQPSScheme" runat="server" CssClass="gvQPSScheme nowrap table" Width="100%" Visible="false" Style="font-size: 11px;" OnPreRender="gvQPSScheme_PreRender" ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found.">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr." ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                                        <input type="hidden" id="hdnCustomerID" runat="server" value='<%# Eval("CustomerID") %>' />
                                        <input type="hidden" id="hdnSaleID" runat="server" value='<%# Eval("SaleID") %>' />
                                        <input type="hidden" id="hdnSchemeID" runat="server" value='<%# Eval("SchemeID") %>' />
                                        <input type="hidden" id="hdnItemID" runat="server" value='<%# Eval("ItemID") %>' />
                                        <input type="hidden" id="hdnSAPReasonItemCode" runat="server" value='<%# Eval("SAPReasonItemCode") %>' />
                                        <input type="hidden" id="hdnCompanyContPer" runat="server" value='<%# Eval("CompanyContPer") %>' />
                                        <input type="hidden" id="hdnDistContPer" runat="server" value='<%# Eval("DistContPer") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Item Code">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblItemCode" runat="server" Text='<%# Eval("ItemCode") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Item Name" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblItemName" runat="server" Text='<%# Eval("ItemName") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Qty" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblTotalQty" runat="server" Text='<%# Eval("TotalQty", "{0:0}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Code" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerCode" runat="server" Text='<%# Eval("DealerCode") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Name" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerName" runat="server" Text='<%# Eval("DealerName") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Inv no." HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblInvoiceNumber" runat="server" Text='<%# Eval("InvoiceNumber") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Doc Type" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDocType" runat="server" Text='<%# Eval("DocType") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Claim Amount" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblschemeamount" runat="server" Text='<%# Eval("schemeamount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Company Contri." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblcompanycont" runat="server" Text='<%# Eval("companycont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Distribution Contribution Bared by Company" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="lbldistconttax" runat="server" Text='<%# Eval("distconttax", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderText="Distributor Contri.">
                                    <ItemTemplate>
                                        <asp:Literal ID="lbldistcont" runat="server" Text='<%# Eval("distcont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Company Contri." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lbltotalcompanycont" runat="server" Text='<%# Eval("totalcompanycont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Purchase Amount of Dealer" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblsalesamount" runat="server" Text='<%# Eval("salesamount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <asp:GridView ID="gvMachineScheme" runat="server" CssClass="gvMachineScheme nowrap table" Width="100%" Visible="false" Style="font-size: 11px;" OnPreRender="gvMachineScheme_PreRender" ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found.">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr." HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                                        <input type="hidden" id="hdnCustomerID" runat="server" value='<%# Eval("CustomerID") %>' />
                                        <input type="hidden" id="hdnSaleID" runat="server" value='<%# Eval("SaleID") %>' />
                                        <input type="hidden" id="hdnSchemeID" runat="server" value='<%# Eval("SchemeID") %>' />
                                        <input type="hidden" id="hdnSAPReasonItemCode" runat="server" value='<%# Eval("SAPReasonItemCode") %>' />
                                        <input type="hidden" id="hdnCompanyContPer" runat="server" value='<%# Eval("CompanyContPer") %>' />
                                        <input type="hidden" id="hdnDistContPer" runat="server" value='<%# Eval("DistContPer") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Code" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerCode" runat="server" Text='<%# Eval("DealerCode") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Name" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerName" runat="server" Text='<%# Eval("DealerName") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Inv no." HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblInvoiceNumber" runat="server" Text='<%# Eval("InvoiceNumber") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Doc Type" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDocType" runat="server" Text='<%# Eval("DocType") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Claim Amount" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSchemeAmount" runat="server" Text='<%# Eval("SchemeAmount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Company Contri." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblCompanyCont" runat="server" Text='<%# Eval("CompanyCont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Distribution Contribution bared by Company" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDistContTax" runat="server" Text='<%# Eval("DistContTax", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Distributor Contri." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDistCont" runat="server" Text='<%# Eval("DistCont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Company Contri." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblTotalCompanyCont" runat="server" Text='<%# Eval("TotalCompanyCont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Purchase Amount of Dealer" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSalesAmount" runat="server" Text='<%# Eval("SalesAmount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <asp:GridView ID="gvParlourScheme" runat="server" CssClass="gvParlourScheme nowrap table" Width="80%" Visible="false" Style="font-size: 11px;" OnPreRender="gvParlourScheme_PreRender" ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found.">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr." ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                                        <input type="hidden" id="hdnCustomerID" runat="server" value='<%# Eval("CustomerID") %>' />
                                        <input type="hidden" id="hdnSaleID" runat="server" value='<%# Eval("SaleID") %>' />
                                        <input type="hidden" id="hdnSchemeID" runat="server" value='<%# Eval("SchemeID") %>' />
                                        <input type="hidden" id="hdnSAPReasonItemCode" runat="server" value='<%# Eval("SAPReasonItemCode") %>' />
                                        <input type="hidden" id="hdnCompanyContPer" runat="server" value='<%# Eval("CompanyContPer") %>' />
                                        <input type="hidden" id="hdnDistContPer" runat="server" value='<%# Eval("DistContPer") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Code" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerCode" runat="server" Text='<%# Eval("DealerCode") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Name" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerName" runat="server" Text='<%# Eval("DealerName") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Inv no." HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblInvoiceNumber" runat="server" Text='<%# Eval("InvoiceNumber") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Doc Type" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDocType" runat="server" Text='<%# Eval("DocType") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Claim Amount" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSchemeAmount" runat="server" Text='<%# Eval("SchemeAmount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Company Contri." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblCompanyCont" runat="server" Text='<%# Eval("CompanyCont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Distribution Contribution bared by Company" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDistContTax" runat="server" Text='<%# Eval("DistContTax", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Distributor Contri." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDistCont" runat="server" Text='<%# Eval("DistCont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Company Contri." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblTotalCompanyCont" runat="server" Text='<%# Eval("TotalCompanyCont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Purchase Amount of Dealer" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSalesAmount" runat="server" Text='<%# Eval("SalesAmount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <asp:GridView ID="gvVRSDiscount" runat="server" CssClass="gvVRSDiscount nowrap table" Width="80%" Visible="false" Style="font-size: 11px;" OnPreRender="gvVRSDiscount_PreRender" ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found.">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr." ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                                        <input type="hidden" id="hdnCustomerID" runat="server" value='<%# Eval("CustomerID") %>' />
                                        <input type="hidden" id="hdnSaleID" runat="server" value='<%# Eval("SaleID") %>' />
                                        <input type="hidden" id="hdnSchemeID" runat="server" value='<%# Eval("SchemeID") %>' />
                                        <input type="hidden" id="hdnSAPReasonItemCode" runat="server" value='<%# Eval("SAPReasonItemCode") %>' />
                                        <input type="hidden" id="hdnCompanyContPer" runat="server" value='<%# Eval("CompanyContPer") %>' />
                                        <input type="hidden" id="hdnDistContPer" runat="server" value='<%# Eval("DistContPer") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Code">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerCode" runat="server" Text='<%# Eval("DealerCode") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Name" HeaderStyle-Width="250px" ItemStyle-Width="250px" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerName" runat="server" Text='<%# Eval("DealerName") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Inv no." HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblInvoiceNumber" runat="server" Text='<%# Eval("InvoiceNumber") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Doc Type" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDocType" runat="server" Text='<%# Eval("DocType") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Claim Amount" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSchemeAmount" runat="server" Text='<%# Eval("SchemeAmount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Company Contri." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblCompanyCont" runat="server" Text='<%# Eval("CompanyCont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Distribution Contribution bared by Company" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDistContTax" runat="server" Text='<%# Eval("DistContTax", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Distributor Contri." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDistCont" runat="server" Text='<%# Eval("DistCont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Company Contri." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblTotalCompanyCont" runat="server" Text='<%# Eval("TotalCompanyCont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Purchase Amount of Dealer" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSalesAmount" runat="server" Text='<%# Eval("SalesAmount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <asp:GridView ID="gvFOWScheme" runat="server" CssClass="gvFOWScheme nowrap table" Width="99%" Visible="false" Style="font-size: 11px;" OnPreRender="gvFOWScheme_PreRender" ShowFooter="True" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr." ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                                        <input type="hidden" id="hdnCustomerID" runat="server" value='<%# Eval("CustomerID") %>' />
                                        <input type="hidden" id="hdnSAPReasonItemCode" runat="server" value='<%# Eval("SAPReasonItemCode") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Code" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerCode" runat="server" Text='<%# Eval("DealerCode") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Name" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerName" runat="server" Text='<%# Eval("DealerName") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Doc Type" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDocType" runat="server" Text='<%# Eval("DocType") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Master Per." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <%# Eval("Per") %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Master Dis." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <%# Eval("Rs") %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Claim Amount" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSchemeAmount" runat="server" Text='<%# Eval("SchemeAmount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Purchase Amount of Dealer" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSalesAmount" runat="server" Text='<%# Eval("SalesAmount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Bill Count" ItemStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <%# Eval("BillCount") %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <asp:GridView ID="gvSecFreight" runat="server" CssClass="gvSecFreight table" Width="50%" Visible="false" Style="font-size: 11px;" OnPreRender="gvSecFreight_PreRender"
                            ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found.">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr." ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                                        <input type="hidden" id="hdnCustomerID" runat="server" value='<%# Eval("CustomerID") %>' />
                                        <input type="hidden" id="hdnSaleID" runat="server" value='<%# Eval("SaleID") %>' />
                                        <input type="hidden" id="hdnSchemeID" runat="server" value='<%# Eval("SchemeID") %>' />
                                        <input type="hidden" id="hdnSAPReasonItemCode" runat="server" value='<%# Eval("SAPReasonItemCode") %>' />
                                        <input type="hidden" id="hdnCompanyContPer" runat="server" value='<%# Eval("CompanyContPer") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Code" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerCode" runat="server" Text='<%# Eval("DealerCode") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Name" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerName" runat="server" Text='<%# Eval("DealerName") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Inv no." HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblInvoiceNumber" runat="server" Text='<%# Eval("InvoiceNumber") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Doc Type" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDocType" runat="server" Text='<%# Eval("DocType") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Claim Amount" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSchemeAmount" runat="server" Text='<%# Eval("SchemeAmount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Purchase Amount of Dealer" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSalesAmount" runat="server" Text='<%# Eval("SalesAmount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <asp:GridView ID="gvRateDiff" runat="server" CssClass="gvRateDiff table" Width="100%" Visible="false" Style="font-size: 11px;" OnPreRender="gvRateDiff_PreRender"
                            ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found.">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr." HeaderStyle-Width="5%" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                                        <input type="hidden" id="hdnCustomerID" runat="server" value='<%# Eval("CustomerID") %>' />
                                        <input type="hidden" id="hdnSaleID" runat="server" value='<%# Eval("SaleID") %>' />
                                        <input type="hidden" id="hdnSAPReasonItemCode" runat="server" value='<%# Eval("SAPReasonItemCode") %>' />
                                        <input type="hidden" id="hdnCompanyContPer" runat="server" value='<%# Eval("CompContPer") %>' />
                                        <input type="hidden" id="hdnDistContPer" runat="server" value='<%# Eval("DistContPer") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Code" HeaderStyle-Width="10%" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerCode" runat="server" Text='<%# Eval("DealerCode") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Name" HeaderStyle-Width="25%" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerName" runat="server" Text='<%# Eval("DealerName") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Inv no." HeaderStyle-Width="10%" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblInvoiceNumber" runat="server" Text='<%# Eval("InvoiceNumber") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Doc Type" HeaderStyle-Width="8%" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDocType" runat="server" Text='<%# Eval("DocType") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Claim Amount" ItemStyle-CssClass="dtbodyRight" HeaderStyle-CssClass="dtbodyRight" FooterStyle-CssClass="dtbodyRight" HeaderStyle-Width="8%">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSchemeAmount" runat="server" Text='<%# Eval("SchemeAmount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Company Contri." HeaderStyle-Width="10%" ItemStyle-CssClass="dtbodyRight" HeaderStyle-CssClass="dtbodyRight" FooterStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblCompanyCont" runat="server" Text='<%# Eval("CompanyCont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Distributor Contri." HeaderStyle-Width="10%" ItemStyle-CssClass="dtbodyRight" HeaderStyle-CssClass="dtbodyRight" FooterStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDistCont" runat="server" Text='<%# Eval("DistCont", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Purchase Amount of Dealer" HeaderStyle-Width="10%" ItemStyle-CssClass="dtbodyRight" HeaderStyle-CssClass="dtbodyRight" FooterStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSalesAmount" runat="server" Text='<%# Eval("GrossAmt", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <asp:GridView ID="gvIOU" runat="server" CssClass="gvIOU nowrap table" Width="99%" Visible="false" Style="font-size: 11px;" OnPreRender="gvIOU_PreRender"
                            ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found.">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr." HeaderStyle-Width="10px" ItemStyle-Width="10px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                                        <input type="hidden" id="hdnOINVRID" runat="server" value='<%# Eval("OINVRID") %>' />
                                        <input type="hidden" id="hdnCustomerID" runat="server" value='<%# Eval("CustomerID") %>' />
                                        <input type="hidden" id="hdnSAPReasonItemCode" runat="server" value='<%# Eval("SAPReasonItemCode") %>' />
                                        <input type="hidden" id="hdnItemID" runat="server" value='<%# Eval("ItemID") %>' />
                                        <input type="hidden" id="hdnPerClaim" runat="server" value='<%# Eval("PerClaim") %>' />
                                        <input type="hidden" id="hdnPerPurchase" runat="server" value='<%# Eval("PerPurchase") %>' />
                                        <input type="hidden" id="hdnClaimPurAmtForPer" class="hdnClaimPurAmtForPer" runat="server" value='<%# Eval("ClaimPurAmtForPer") %>' />
                                        <input type="hidden" id="hdnFinalClaimAmt" class="hdnFinalClaimAmt" runat="server" value='' />
                                        <input type="hidden" id="hdnGrossPurchaseDist" class="hdnGrossPurchaseDist" runat="server" value='<%# Eval("GrossPurchase") %>' />


                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Code" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerCode" runat="server" Text='<%# Eval("DealerCode") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer Name" HeaderStyle-Width="90px" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblDealerName" runat="server" Text='<%# Eval("DealerName") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Item Code" HeaderStyle-Width="40px" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblItemCode" runat="server" Text='<%# Eval("ItemCode") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Item Name" HeaderStyle-Width="70px" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblItemName" runat="server" Text='<%# Eval("ItemName") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Qty" HeaderStyle-Width="20px" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblTotalQty" runat="server" Text='<%# Eval("Quantity") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dist. Claim Amount" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblSchemeAmount" runat="server" Text='<%# Eval("ClaimAmount", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <%--   <asp:TemplateField HeaderText="Per. Claim" HeaderStyle-Width="150px" ItemStyle-Width="150px" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Literal ID="lblPerClaim" runat="server" Text='<%# Eval("PerClaim", "{0:0.00}") %>'></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>--%>
                                <asp:TemplateField HeaderText="Per. Claim Amt." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Literal ID="lblPerClaimAmt" runat="server" Text='<%# Eval("ClaimAmtForPer", "{0:0.00}") %>'></asp:Literal>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Purchase Amt. of Dist." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <%--<asp:Literal ID="lblGrossPurchase" runat="server" Text='<%# Eval("GrossPurchase", "{0:0.00}") %>'></asp:Literal>--%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <%--<asp:TemplateField HeaderText="Per. Purchase" HeaderStyle-Width="150px" ItemStyle-Width="150px" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Literal ID="lblPerPurchase" runat="server" Text='<%# Eval("PerPurchase", "{0:0.00}") %>'></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>--%>
                                <asp:TemplateField HeaderText="Per. Purchase Amt." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <%--<asp:Literal ID="lblPerPurchaseAmt" runat="server" Text='<%# Eval("ClaimPurAmtForPer", "{0:0.00}") %>'></asp:Literal>--%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Final Claim Amt." ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <%--<asp:Literal ID="lblFinalClaimAmt" runat="server" Text='<%# Eval("FinalClaimAmt", "{0:0.00}") %>'></asp:Literal>--%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
        <div class="embed-responsive embed-responsive-16by9">
            <iframe id="ifmMaterialPurchase" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmMaterialPurchase_Load"></iframe>
        </div>
    </div>
</asp:Content>


