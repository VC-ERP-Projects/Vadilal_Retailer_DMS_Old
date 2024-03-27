<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="AttendenceRegister.aspx.cs" Inherits="Reports_AttendenceRegister" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/fixedColumns.bootstrap.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.fixedColumns.min.js"></script>

    <script type="text/javascript">

        var UserID = '<% =UserID%>';

        $(function () {
            Reload();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {

            Reload();
        }

        function acettxtEmployeeCode_OnClientPopulating(sender, args) {
            var key = $('.ddlEGroup').val();
            sender.set_contextKey(key);
        }

        function ClearEmp(ddl) {
            $(".txtCode").val('');
        }

        function _btnCheck() {

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
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
                if (value != "" && Array.isArray(value))
                    value = value[0].replace(/&/g, '&amp;') + value[1].replace(/&/g, '&amp;');
                else
                    value = value.replace(/&/g, '&amp;');
                msg += '<t>' + value + '</t>';
                msg += '</is>';
                msg += '</c>';
            }
            msg += '</row>';
            return msg;
        }

        function Reload() {

            var now = new Date();
            Date.prototype.today = function () {
                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
            }
            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

            if ($('.gvattendence thead tr').length > 0) {

                var table = $('.gvattendence').DataTable();
                var colCount = table.columns()[0].length;
                var aryJSONColTable1 = [];

                aryJSONColTable1.push({ "width": "20px", "aTargets": 0 });
                aryJSONColTable1.push({ "width": "200px", "aTargets": 1 });

                for (var i = 2; i < colCount; i++) {

                    aryJSONColTable1.push({
                        "aTargets": [i],
                        "width": "30px"
                    });
                }

                $('.gvattendence').DataTable(
                    {
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '50vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "bPaginate": true,
                        pageLength: 25,
                        "aoColumnDefs": aryJSONColTable1,
                        "aaSorting": [],
                        fixedColumns: {
                            leftColumns: 2
                        },
                        "fnRowCallback": function (nRow, aData, iDisplayIndex, iDisplayIndexFull) {
                            if ($('.hdnIsAdmin').val() == 'True') {
                                for (var i = 2; i < nRow.cells.length; i++) {

                                    $(nRow.cells[i]).css('cursor', 'pointer');

                                    if (aData[i] == "A") {
                                        $(nRow.cells[i]).css('color', 'red');
                                    }
                                    else if (aData[i] == "P") {
                                        $(nRow.cells[i]).css('color', 'green');
                                    }
                                    else if (aData[i] == "HO") {
                                        $(nRow.cells[i]).css('color', 'purple');
                                    }
                                    else if (aData[i] == "W") {
                                        $(nRow.cells[i]).css('color', 'darkblue');
                                    }
                                }
                            }
                        },
                        buttons: [{ extend: 'copy', footer: true },
                            {
                                extend: 'csv', footer: true, header: $("#lnkTitle").text(), filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                customize: function (csv) {
                                    var data = 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                    //if (UserID == 1)
                                    data += 'Employee,' + (($('.txtTtryHead').length > 0 && $('.txtTtryHead').val() != "") ? $('.txtTtryHead').val() : "All Employee") + '\n';
                                    //data += 'Employee Group,' + (($('.ddlEGroup').val() > 0 && $('.ddlEGroup').val() != "") ? $('.ddlEGroup option:Selected').text() : "All Group") + '\n';
                                    //else
                                    //    data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "All Employee") + '\n';
                                    data += 'Employee Type,' + (($('.ddlEmpType').val() > 0 && $('.ddlEmpType').val() != "") ? $('.ddlEmpType option:Selected').text() : "All Employee Type") + '\n';
                                    data += 'User Name,' + $('.hdnUserName').val() + '\n';
                                    data += 'Created on,' + jsDate.toString() + '\n';
                                    return data + csv;
                                },
                                exportOptions: {
                                    format: {
                                        body: function (data, row, column, node) {
                                            //check if type is input using jquery
                                            return (data == "&nbsp;" || data == "") ? " " : data;
                                            var D = data;
                                        }
                                    }
                                }
                            },
                            {
                                extend: 'excel', footer: true, header: $("#lnkTitle").text(), filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                customize: function (xlsx) {
                                    sheet = ExportXLS(xlsx, 6);
                                    //$('row c[r^="A"] ', sheet).each(function () { $(this).attr('s', '20'); });
                                    var r0 = Addrow(1, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                                    //if (UserID == 1)
                                    var r1 = Addrow(2, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtTtryHead').length > 0 && $('.txtTtryHead').val() != "") ? $('.txtTtryHead').val() : "All Employee") }]);
                                    //else
                                    //    //var r3 = Addrow(3, [{ key: 'A', value: 'Employee Group' }, { key: 'B', value: (($('.ddlEGroup').val() > 0 && $('.ddlEGroup').val() != "") ? $('.ddlEGroup option:Selected').text() : "All Group") }]);
                                    //    var r1 = Addrow(2, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "All Employee") }]);
                                    var r2 = Addrow(3, [{ key: 'A', value: 'Employee Type' }, { key: 'B', value: (($('.ddlEmpType').val() > 0 && $('.ddlEmpType').val() != "") ? $('.ddlEmpType option:Selected').text() : "All Employee Type") }]);
                                    var r3 = Addrow(4, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                    var r4 = Addrow(5, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);

                                    sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + sheet.childNodes[0].childNodes[1].innerHTML;
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

                                    doc.pageMargins = [20, 70, 20, 30];
                                    doc.defaultStyle.fontSize = 7;
                                    doc.styles.tableHeader.fontSize = 7;
                                    doc.styles.tableFooter.fontSize = 7;
                                    doc['header'] = (function () {
                                        return {
                                            columns: [
                                                {
                                                    alignment: 'left',
                                                    italics: true,
                                                    fontSize: 10,
                                                    text: [{ text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                    { text: 'Employee : ' + (($('.txtTtryHead').length > 0 && $('.txtTtryHead').val() != "") ? $('.txtTtryHead').val() + "\n" : "All Employee\n") },
                                                    //{ text: ((UserID == 1) ? 'Territory Head : ' + (($('.txtTtryHead').length > 0 && $('.txtTtryHead').val() != "") ? $('.txtTtryHead').val() + "\n" : "All Employee\n") : '') },
                                                    //{ text: ((UserID != 1) ? 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() + "\n" : "All Employee\n") : '') },
                                                    { text: 'Employee Type : ' + (($('.ddlEmpType').val() > 0 && $('.ddlEmpType').val() != "") ? $('.ddlEmpType option:Selected').text() + "\n" : "All Employee Type\n") },
                                                    { text: 'User Name : ' + $('.hdnUserName').val() + "\n" },
                                                    ],
                                                    height: 400,
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 14,
                                                    text: $("#lnkTitle").text(),
                                                    height: 400,
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
                                }
                            }]
                    });
                if ($('.hdnIsAdmin').val() == 'True') {
                    $('.gvattendence').on('click', 'tbody > tr > td', function () {

                        var row = $(this).parent().parent().children().index($(this).parent());
                        var col = $(this).parent().children().index($(this));
                        if (col != 0 && col != 1) {
                            var empcode = $(this).parent().parent().find('tr:eq(' + row + ') > td:eq(1)').text().split("-")[0].trim();
                            var SelctdYr = $('.gvDate').find('tbody > tr > td:eq(' + col + ')').text().substring(0, 4);
                            var SelctdMnth = $('.gvDate').find('tbody > tr > td:eq(' + col + ')').text().substring(4, 6);
                            var SelctdDate = $('.gvDate').find('tbody > tr > td:eq(' + col + ')').text().substring(6, 8);

                            var date = SelctdDate + "/" + SelctdMnth + "/" + SelctdYr;

                            var currentdate = '<%=DateTime.Now.ToString("MM/dd/yyyy")%>';
                            var formatdate = SelctdMnth + "/" + SelctdDate + "/" + SelctdYr;

                            if (new Date(currentdate) < new Date(formatdate)) {
                                alert('Selected Date is greater than Current Date');
                                return;
                            }

                            $.colorbox({
                                width: '95%',
                                height: '95%',
                                iframe: true,
                                href: '../Master/Attendence.aspx?EmpCode=' + empcode + '&Date=' + date,
                                onClosed: function () {
                                    if (sessionStorage.getItem("PostBackFlag") == "1") {
                                        sessionStorage.setItem("PostBackFlag", "0");
                                        __doPostBack('ctl00$body$btnGenerat', null);
                                    }
                                }
                            });
                        }
                    });
                }
            }
            if ($('.gvSummary thead tr').length > 0) {

                var table = $('.gvSummary').DataTable();
                var colCount = table.columns()[0].length;
                var aryJSONColTable1 = [];

                aryJSONColTable1.push({ "width": "3px", "aTargets": 0 });
                aryJSONColTable1.push({ "width": "100px", "aTargets": 1 });

                for (var i = 2; i < colCount; i++) {

                    aryJSONColTable1.push({
                        "aTargets": [i],
                        "width": "5px"
                    });
                }

                $('.gvSummary').DataTable(
                    {
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '50vh',
                        scrollX: true,
                        responsive: true,
                        "aaSorting": [],
                        dom: 'Bfrtip',
                        "bPaginate": true,
                        "aoColumnDefs": aryJSONColTable1,
                        "pageLength": 25,
                        buttons: [{ extend: 'copy', footer: true },
                        {
                            extend: 'csv', footer: true, header: $("#lnkTitle").text(), filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                            customize: function (csv) {
                                var data = 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                //if (UserID == 1)
                                data += 'Employee,' + (($('.txtTtryHead').length > 0 && $('.txtTtryHead').val() != "") ? $('.txtTtryHead').val() : "All Employee") + '\n';
                                //data += 'Employee Group,' + (($('.ddlEGroup').val() > 0 && $('.ddlEGroup').val() != "") ? $('.ddlEGroup option:Selected').text() : "All Group") + '\n';
                                //else
                                //    data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "All Employee") + '\n';
                                data += 'Employee Type,' + (($('.ddlEmpType').val() > 0 && $('.ddlEmpType').val() != "") ? $('.ddlEmpType option:Selected').text() : "All Employee Type") + '\n';
                                data += 'User Name,' + $('.hdnUserName').val() + '\n';
                                data += 'Created on,' + jsDate.toString() + '\n';
                                return data + csv;
                            },
                            exportOptions: {
                                format: {
                                    body: function (data, row, column, node) {
                                        //check if type is input using jquery
                                        return (data == "&nbsp;" || data == "") ? " " : data;
                                        var D = data;
                                    }
                                }
                            }
                        },
                            {
                                extend: 'excel', footer: true, header: $("#lnkTitle").text(), filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                customize: function (xlsx) {
                                    sheet = ExportXLS(xlsx, 6);
                                    //$('row c[r^="A"] ', sheet).each(function () { $(this).attr('s', '20'); });
                                    var r0 = Addrow(1, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                                    //if (UserID == 1)
                                    var r1 = Addrow(2, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtTtryHead').length > 0 && $('.txtTtryHead').val() != "") ? $('.txtTtryHead').val() : "All Employee") }]);
                                    //else
                                    //    //var r3 = Addrow(3, [{ key: 'A', value: 'Employee Group' }, { key: 'B', value: (($('.ddlEGroup').val() > 0 && $('.ddlEGroup').val() != "") ? $('.ddlEGroup option:Selected').text() : "All Group") }]);
                                    //    var r1 = Addrow(2, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "All Employee") }]);
                                    var r2 = Addrow(3, [{ key: 'A', value: 'Employee Type' }, { key: 'B', value: (($('.ddlEmpType').val() > 0 && $('.ddlEmpType').val() != "") ? $('.ddlEmpType option:Selected').text() : "All Employee Type") }]);
                                    var r3 = Addrow(4, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                    var r4 = Addrow(5, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                    sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + sheet.childNodes[0].childNodes[1].innerHTML;
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

                                    doc.pageMargins = [20, 70, 20, 30];
                                    doc.defaultStyle.fontSize = 7;
                                    doc.styles.tableHeader.fontSize = 7;
                                    doc.styles.tableFooter.fontSize = 7;
                                    doc['header'] = (function () {
                                        return {
                                            columns: [
                                                {
                                                    alignment: 'left',
                                                    italics: true,
                                                    fontSize: 10,
                                                    text: [{ text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                   { text: 'Employee : ' + (($('.txtTtryHead').length > 0 && $('.txtTtryHead').val() != "") ? $('.txtTtryHead').val() + "\n" : "All Employee\n") },
                                                    //{ text: ((UserID == 1) ? 'Territory Head : ' + (($('.txtTtryHead').length > 0 && $('.txtTtryHead').val() != "") ? $('.txtTtryHead').val() + "\n" : "All Employee\n") : '') },
                                                    //{ text: ((UserID != 1) ? 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() + "\n" : "All Employee\n") : '') },
                                                    { text: 'Employee Type : ' + (($('.ddlEmpType').val() > 0 && $('.ddlEmpType').val() != "") ? $('.ddlEmpType option:Selected').text() + "\n" : "All Employee Type\n") },
                                                    { text: 'User Name : ' + $('.hdnUserName').val() + "\n" },
                                                    ],
                                                    height: 400,
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 14,
                                                    text: $("#lnkTitle").text(),
                                                    height: 400,
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
                                }
                            }]
                    });
            }
        }

    </script>

    <style type="text/css">
        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        .dataTables_scroll {
            overflow: auto;
        }

        .dtbodyRight {
            text-align: right;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4" hidden="hidden">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblEmpGroup" Text="Employee Group" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlEGroup" CssClass="ddlEGroup form-control" TabIndex="2" DataTextField="EmpGroupName" DataValueField="EmpGroupID" onchange="ClearEmp(this);">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" onfocus="this.blur();" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" onfocus="this.blur();" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Employee Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlEmpType" class="ddlEmpType" runat="server" CssClass="ddlEmpType form-control">
                            <asp:ListItem Text="All Employee" Value="1" Selected="True" />
                            <asp:ListItem Text="Company Employee" Value="2"></asp:ListItem>
                            <asp:ListItem Text="3rd Party Employee" Value="3"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divTHead" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblTtryHead" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtTtryHead" runat="server" CssClass="form-control txtTtryHead" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode1" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtTtryHead">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="4" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <input type="hidden" class="hdnIsAdmin" id="hdnIsAdmin" runat="server" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvattendence" runat="server" CssClass="gvattendence table" Style="font-size: 11px;" Width="100%"
                        OnPreRender="gvattendence_Prerender" ShowHeader="true" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                        EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-8">
                    <asp:GridView ID="gvSummary" runat="server" HeaderStyle-Font-Size="Smaller" RowStyle-Font-Size="Smaller" CssClass="gvSummary table" Width="100%" OnPreRender="gvSummary_PreRender"
                        HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                    </asp:GridView>
                    <asp:GridView ID="gvDate" runat="server" HeaderStyle-Font-Size="Smaller" RowStyle-Font-Size="Smaller" CssClass="gvDate table" Width="100%" OnPreRender="gvDate_PreRender"
                        HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found." Style="display: none">
                    </asp:GridView>
                </div>
                <div class="col-lg-4">
                    <br />
                    <br />
                    <asp:GridView Font-Size="11px" ID="gvLeaveType" runat="server" CssClass="gvLeaveType table tbl nowrap" Width="100%" OnPreRender="gvLeaveType_PreRender"
                        HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

