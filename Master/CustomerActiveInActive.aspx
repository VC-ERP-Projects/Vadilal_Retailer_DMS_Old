<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="CustomerActiveInActive.aspx.cs" Inherits="Master_CustomerActiveInActive" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>

    <script type="text/javascript">
        var IpAddress;
        function getUserIP(onNewIP) { //  onNewIp - your listener function for new IPs
            //compatibility for firefox and chrome
            try {
                var myPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
                var pc = new myPeerConnection({
                    iceServers: []
                }),
                noop = function () { },
                localIPs = {},
                ipRegex = /([0-9]{1,3}(\.[0-9]{1,3}){3}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){7})/g,
                key;
            }
            catch (err) {

            }

            function iterateIP(ip) {
                if (!localIPs[ip]) onNewIP(ip);
                localIPs[ip] = true;
            }
            try {
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
            catch (err) {

            }
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

        var availableCustomer = [];

        $(document).ready(function () {

            ClearControls();
            $("#hdnIPAdd").val(IpAddress);
            $("#tblCustomer").tableHeadFixer('77vh');
        });

        function AddMoreRow() {

            $('table#tblCustomer tr#NoROW').remove();  // Remove NO ROW

            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowCustomer').val();
            ind = parseInt(ind) + 1;
            $('#CountRowCustomer').val(ind);

            var str = "";
            str = "<tr id='trItem" + ind + "'>"
                + "<td class='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                + "<td><input type='text' id='AutoCustCode" + ind + "' name='AutoCustCode' class='form-control search' style='background-color: rgb(250, 255, 189);'/></td>"
                + "<td id='tdCity" + ind + "' class='tdCity'></td>"
                + "<td><input type='checkbox' id='chkIsActive" + ind + "' name='chkIsActive' class='checkbox' /></td>"
                + "<td><input type='text' id='txtRemarks" + ind + "' name='txtRemarks' class='form-control search'/></td>"
                + "<input type='hidden' id='hdnCustomerID" + ind + "' name='hdnCustomerID'  /></td>"
                + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' /></tr>";

            $('#tblCustomer > tbody').append(str);

            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);

            $('#AutoCustCode' + ind).autocomplete({
                source: function (Request, Response) {
                    $.ajax({
                        url: 'CustomerActiveInActive.aspx/LoadCustomerByType',
                        type: 'POST',
                        dataType: 'json',
                        data: JSON.stringify({ CustType: $('.ddlCustType').val(), prefixText: Request.term }),
                        async: false,
                        contentType: 'application/json; charset=utf-8',
                        success: function (result) {
                            if (result.d == "") {
                                return false;
                            }
                            else if (result.d[0].indexOf("ERROR=") >= 0) {
                                var ErrorMsg = result.d[0].split('=')[1].trim();
                                ModelMsg(ErrorMsg, 3);
                                return false;
                            }
                            else {
                                Response(result.d[0]);
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            alert('Something is wrong...' + XMLHttpRequest.responseText);
                            return false;
                        }
                    });
                },
                minLength: 0,
                scroll: true
            });

            $('#AutoCustCode' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoCustCode' + ind).val(ui.item.value);
                GetCustomerDetailsByCode(ui.item.value, ind);
            });

            //$('#AutoCustCode' + ind).bind("autocompleteselect", function (event, ui) {
            //    // Remove the element and overwrite the availableCustomer var
            //    //availableCustomer.splice(availableCustomer.indexOf(ui.item.value), 1);
            //    // Re-assign the source
            //    $(this).autocomplete("option", "source", availableCustomer);
            //});


            $('#AutoCustCode' + ind).on('change keyup', function () {
                if ($('#AutoCustCode' + ind).val() == "") {
                    ClearCustomerRow(ind);
                }
            });

            $('#AutoCustCode' + ind).on('blur', function (e, ui) {
                if ($('#AutoCustCode' + ind).val().trim() != "") {
                    if ($('#AutoCustCode' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Customer", 3);
                        $('#AutoCustCode' + ind).val("");
                        $('#hdnCustomerID' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoCustCode' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    CheckDuplicateCustomer($('#AutoCustCode' + ind).val().trim(), ind);
                }
            });

            var lineNum = 1;
            $('#tblCustomer > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });

        }

        function CheckDuplicateCustomer(CustCode, row) {

            var Item = CustCode.split("-")[0].trim();
            var rowCnt_Customer = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblCustomer  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var CustCode = $("input[name='AutoCustCode']", this).val().split("-")[0].trim();
                var LineNum = $("input[name='hdnLineNum']", this).val();

                if (CustCode != "") {
                    if (parseInt(row) != parseInt(LineNum)) {
                        if (Item == CustCode) {
                            cnt = 1;
                            errRow = row;
                            $('#AutoCustCode' + row).val('');
                            $('#chkIsActive' + row).prop('checked', false);
                            $('#chkIsActive' + row).attr("disabled", false);
                            $('#tdCity' + row).text('');
                            errormsg = 'Customer = ' + CustCode + ' is already seleted at row : ' + rowCnt_Customer;
                            return false;
                        }
                    }
                }
                //}

                rowCnt_Customer++;
            });

            if (cnt == 1) {
                $('#AutoCustCode' + row).val('');
                ClearCustomerRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowCustomer').val();
            if (ind == row) {
                AddMoreRow();
            }

        }

        function ClearCustomerRow(row) {

            var rowCnt_Customer = 1;
            var cnt = 0;

            $('#tblCustomer > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var CustCode = $("input[name='AutoCustCode']", this).val();
                if (CustCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Customer++;
            });

            if (cnt > 1) {
                var rowCnt_Customer = 1;
                $('#tblCustomer > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Customer) {
                        var CustCode = $("input[name='AutoCustCode']", this).val();
                        if (CustCode == "") {
                            $(this).remove();
                        }
                    }

                    rowCnt_Customer++;
                });
            }

            var lineNum = 1;
            $('#tblCustomer > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });

        }

        function GetCustomerDetailsByCode(CustCode, row) {

            var CustCode = CustCode.split("-")[0].trim();
            var rowCnt_Material = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblCustomer  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                var Item = $("input[name='AutoCustCode']", this).val().split("-")[0].trim();
                var LineNum = $("input[name='hdnLineNum']", this).val();
                if (CustCode != "") {
                    if (parseInt(row) != parseInt(LineNum)) {
                        if (Item == CustCode) {
                            cnt = 1;
                            errRow = row;
                            return false;
                        }
                    }
                }
                //}

                rowCnt_Material++;
            });

            if (cnt == 1) {
                return false;
            }
            else {

                $.ajax({
                    url: 'CustomerActiveInActive.aspx/GetCustomerDetail',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ CustCode: CustCode }),

                    success: function (result) {
                        if (result == "") {
                            return false;
                        }
                        else if (result.d.indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            $("input[name='AutoCustCode']", this).val() == "";
                            return false;
                        }
                        else {
                            $('#chkIsActive' + row).prop("checked", result.d[0].Active);
                            if (result.d[0].SAPActive == false) {
                                $('#chkIsActive' + row).prop("checked", false);
                                $('#chkIsActive' + row).attr("disabled", true);
                            }
                            else
                                $('#chkIsActive' + row).attr("disabled", false);

                            $('#tdCity' + row).text(result.d[0].City);
                            $('#hdnCustomerID' + row).val(result.d[0].CustomerID);
                            $('#txtRemarks' + row).val(result.d[0].LastRemarks);
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });
            }

            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);
        }

        function GetReport() {

            if ($('.chkIsReport').find('input').is(':checked')) {

                ClearControls();

                $.ajax({
                    url: 'CustomerActiveInActive.aspx/LoadReport',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ strCustType: $('.ddlCustType').val() }),

                    success: function (result) {
                        if (result.d[0] == "") {
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            $("input[name='AutoCustCode']", this).val() == "";
                            return false;
                        }
                        else {

                            var ReportData = JSON.parse(result.d[0]);
                            var str = "";

                            for (var i = 0; i < ReportData.length; i++) {

                                str = "<tr><td>" + ReportData[i].SRNo + "</td>"
                                        + "<td>" + ReportData[i].CustType + "</td>"
                                        + "<td>" + ReportData[i].Code + "</td>"
                                        + "<td>" + ReportData[i].Name + "</td>"
                                        + "<td>" + ReportData[i].City + "</td>"
                                        + "<td>" + ReportData[i].Status + "</td>"
                                        + "<td>" + ReportData[i].SAPStatus + "</td>"
                                        + "<td>" + ReportData[i].Remarks + "</td>"
                                        + "<td>" + ReportData[i].UserID + "</td>"
                                        + "<td>" + ReportData[i].UpdatedOn + "</td>"
                                        + "<td>" + ReportData[i].IPAddress + "</td></tr>"

                                $('.gvCustHistory > tbody').append(str);
                            }

                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });

                if ($('.gvCustHistory tbody tr').length > 0) {

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }
                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "20px", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "60px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "50px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "200px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "60px", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "35px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "35px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "100px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "150px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "60px", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "60px", "aTargets": 10 });


                    $('.gvCustHistory').DataTable({
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '62vh',
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
                                   data += 'Report By,' + $('.ddlCustType option:selected').text() + '\n';
                                   data += 'User Name,' + $('.hdnUserName').val() + '\n';
                                   data += 'Created on,' + jsDate.toString() + '\n'; return data + csv;
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

                                   sheet = ExportXLS(xlsx, 5);

                                   var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                   var r1 = Addrow(2, [{ key: 'A', value: 'Report By' }, { key: 'B', value: $('.ddlCustType option:selected').text() }]);
                                   var r2 = Addrow(3, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                   var r3 = Addrow(4, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                   sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + sheet.childNodes[0].childNodes[1].innerHTML;
                               }
                           },
                           {
                               extend: 'pdfHtml5',
                               orientation: 'portrait', //landscape
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
                                   doc.pageMargins = [20, 55, 20, 30];
                                   doc.defaultStyle.fontSize = 7;
                                   doc.styles.tableHeader.fontSize = 7;
                                   doc.styles.tableFooter.fontSize = 7;
                                   doc['header'] = (function () {
                                       return {
                                           columns: [
                                               {
                                                   alignment: 'left',
                                                   italics: true,
                                                   text: [{ text: 'Report By : ' + ($('.ddlCustType option:Selected').text() + "\n") },
                                                   { text: 'User Name : ' + $('.hdnUserName').val() + "\n" }],
                                                   fontSize: 10,
                                                   height: 350,
                                               },
                                               {
                                                   alignment: 'right',
                                                   fontSize: 14,
                                                   text: $("#lnkTitle").text(),
                                                   height: 350,
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

        }

        function ClearControls() {

            $('.divCustEntry').attr('style', 'display:none;');
            $('.divCustReport').attr('style', 'display:none;');
            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');

            $('#tblCustomer tbody').empty();

            if ($.fn.DataTable.isDataTable('.gvCustHistory')) {
                $('.gvCustHistory').DataTable().destroy();
            }

            $('.gvCustHistory tbody').empty();

            if ($('.chkIsReport').find('input').is(':checked')) {
                $('.divCustReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
            }
            else {
                $('.divCustEntry').removeAttr('style');
                $('.btnSubmit').removeAttr('style');

                $('#CountRowCustomer').val(0);
                AddMoreRow();
            }
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

        function Cancel() {
            window.location = "../Master/CustomerActiveInActive.aspx";
        }

        function btnSubmit_Click() {

            $.blockUI({
                message: '<img src="../Images/loadingbd.gif" />',
                css: {
                    padding: 0,
                    margin: 0,
                    width: '15%',
                    top: '36%',
                    left: '40%',
                    textAlign: 'center',
                    cursor: 'wait'
                }
            });

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();

            if (!IsValid) {
                $.unblockUI();
                return false;
            }

            var TableData_Customer = [];

            var totalItemcnt = 0;
            var cnt = 0;

            rowCnt_Customer = 0;

            $('#tblCustomer  > tbody > tr').each(function (row, tr) {
                var CustCode = $("input[name='AutoCustCode']", this).val();
                if (CustCode != "") {
                    totalItemcnt = 1;
                    var CustomerID = $("input[name='hdnCustomerID']", this).val().trim();
                    var Remarks = $("input[name='txtRemarks']", this).val();
                    var IsActive = $("input[name='chkIsActive']", this).is(':checked');
                    var CustType = $('.ddlCustType').val();
                    var IPAddress = $("#hdnIPAdd").val();

                    var obj = {
                        CustomerID: CustomerID,
                        Remarks: Remarks,
                        IsActive: IsActive,
                        IPAddress: IPAddress
                    };

                    TableData_Customer.push(obj);
                }

                rowCnt_Customer++;
            });

            if (totalItemcnt == 0) {
                $.unblockUI();
                ModelMsg("Please select atleast one Item", 3);
                return false;
            }
            if (cnt == 1) {
                $.unblockUI();
                ModelMsg(errormsg, 3);
                return false;
            }

            var CustomerData = JSON.stringify(TableData_Customer);

            var successMSG = true;

            var sv = $.ajax({
                url: 'CustomerActiveInActive.aspx/SaveData',
                type: 'POST',
                //async: false,
                dataType: 'json',
                // traditional: true,
                data: JSON.stringify({ hidJsonInputCustomer: CustomerData }),
                contentType: 'application/json; charset=utf-8'
            });

            var sendcall = 0;

            sv.success(function (result) {

                if (result.d == "") {
                    $.unblockUI();
                    return false;
                }
                else if (result.d.indexOf("ERROR=") >= 0) {
                    $.unblockUI();
                    var ErrorMsg = result.d.split('=')[1].trim();
                    ModelMsg(ErrorMsg, 2);
                    return false;
                }
                else if (result.d.indexOf("WARNING=") >= 0) {
                    $.unblockUI();
                    var ErrorMsg = result.d.split('=')[1].trim();
                    ModelMsg(ErrorMsg, 3);
                    return false;
                }
                if (result.d.indexOf("SUCCESS=") >= 0) {
                    var SuccessMsg = result.d.split('=')[1].trim();
                    alert(SuccessMsg);
                    location.reload(true);
                    return false;
                }

            });

            sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                $.unblockUI();
                alert('Something is wrong...' + XMLHttpRequest.responseText);
                return false;
            });
        }

    </script>

    <style>
        .txtSrNo {
            text-align: center;
        }

        .dataTables_info {
            margin-left: 85%;
        }

        .table-header-gradient th {
            z-index: 800;
        }

        .table#tblCustomer {
            width: 100%;
            margin-top: 0px !important;
            margin-bottom: 0px !important;
            position: relative;
        }

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

        .ui-menu-item {
            font-size: 12px;
        }

        .search {
            background-color: lightyellow;
            height: 28px;
            font-size: 12px;
        }

        .table#tblCustomer .dataTables_scrollBody {
            max-height: 70vh !important;
        }

        table#gvCustHistory.dataTable tbody th, table.dataTable tbody td {
            padding: 5px 10px;
        }
    </style>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <%--<input type="hidden" id="hidJsonInputCustomer" name="hidJsonInputCustomer" value="" />--%>
                    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
                    <div class="input-group form-group">
                        <label class="input-group-addon">Option</label>
                        <select id="ddlCustType" name="CustType" runat="server" class="ddlCustType form-control" onchange="ClearControls();">
                            <option value="4">Super Stockist</option>
                            <option value="2" selected="selected">Distributor</option>
                            <option value="3">Dealer</option>
                        </select>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">View Report</label>
                        <asp:CheckBox runat="server" CssClass="chkIsReport form-control" onchange="ClearControls();" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" class="btnSubmit btn btn-default" onclick="btnSubmit_Click()" tabindex="18" />
                        <input type="button" id="btnSearch" name="btnSearch" value="Process" class="btnSearch btn btn-default" onclick="GetReport();" tabindex="18" />
                        &nbsp
                        <input type="button" id="btnCancel" name="btnCancel" value="Cancel" onclick="Cancel()" class="btn btn-default" tabindex="19" />
                    </div>
                </div>
            </div>
            <input type="hidden" id="CountRowCustomer" />
            <div id="divCustEntry" class="divCustEntry" runat="server" style="max-height: 80vh; overflow-y: auto;">
                <table id="tblCustomer" class="table" border="1" tabindex="6" style="width: 100%; border-collapse: collapse; font-size: 11px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="width: 4%;">Sr. No</th>
                            <th style="width: 30%;">Customer</th>
                            <th style="width: 15%">City</th>
                            <th style="width: 5%;">Active</th>
                            <th style="width: 50%;">Remarks</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
            <div id="divCustReport" class="divCustReport" >
                <table id="gvCustHistory" class="gvCustHistory table table-bordered" style="width: 100%; font-size: 11px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <%--<th style="width: 4%">SRNo</th>
                            <th style="width: 8%">Dealer/Dist/SS</th>
                            <th style="width: 7%">Code</th>
                            <th style="width: 20%">Name</th>
                            <th style="width: 10%">City</th>
                            <th style="width: 5%">Status</th>
                            <th style="width: 22%">Remarks</th>
                            <th style="width: 15%">User ID</th>
                            <th style="width: 8%">Updated On</th>--%>
                            <th>Sr. No</th>
                            <th>Customer</th>
                            <th>Code</th>
                            <th>Name</th>
                            <th>City</th>
                            <th>DMS Status</th>
                            <th>SAP Status</th>
                            <th>Remarks</th>
                            <th>UserID</th>
                            <th>Updated On</th>
                            <th>IP Address</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>

