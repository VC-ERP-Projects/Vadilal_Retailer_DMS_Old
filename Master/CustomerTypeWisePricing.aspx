<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="CustomerTypeWisePricing.aspx.cs" Inherits="Master_CustomerTypeWisePricing" %>

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
       // var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';
        var Version = '<% = Version%>';
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
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            });
            $("#hdnIPAdd").val(IpAddress);
            $("#tblCustomerTypeWisePricing").tableHeadFixer('78vh');
        });
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
        function AddMoreRow() {

            $('table#tblCustomerTypeWisePricing tr#NoROW').remove();  // Remove NO ROW

            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowCustomer').val();
            ind = parseInt(ind) + 1;
            $('#CountRowCustomer').val(ind);

            var str = "";
            str = "<tr id='trItem" + ind + "'>"
                + "<td class='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                + "<td><input type='text' id='AutoPriceCode" + ind + "' name='AutoPriceCode' class='form-control search' style='background-color: rgb(250, 255, 189);'/></td>"
                + "<td id='tdPriceDesc" + ind + "' class='tdPriceDesc'></td>"
                + "<td><input type='checkbox' id='chkIsProdSale" + ind + "' name='chkIsProdSale' class='checkbox' /></td>"
                + "<td><input type='checkbox' id='chkIsClaim" + ind + "' name='chkIsClaim' class='checkbox' /></td>"
                + "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy'></td>"
                + "<td id='tdUpdateOn" + ind + "' class='tdUpdateOn'></td>"
                + "<td id='tdIpAdd" + ind + "' class='tdIpAdd'></td>"
                + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' /></td>"
                + "<input type='hidden' id='hdnPriceListID" + ind + "' name='hdnPriceListID'/></tr>";

            $('#tblCustomerTypeWisePricing > tbody').append(str);

            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);

            $('#AutoPriceCode' + ind).autocomplete({
                source: function (Request, Response) {
                    $.ajax({
                        url: 'CustomerTypeWisePricing.aspx/LoadPriceByCustType',
                        type: 'POST',
                        dataType: 'json',
                        data: JSON.stringify({ Division: $('.ddlDivision').val(), CustType: $('.ddlCustType').val(), prefixText: Request.term }),
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

            $('#AutoPriceCode' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoPriceCode' + ind).val(ui.item.value);
                GetPriceGroupDetailsByCode(ui.item.value, ind);
            });

            $('#AutoPriceCode' + ind).on('change keyup', function () {
                if ($('#AutoPriceCode' + ind).val() == "") {
                    ClearPriceGroupRow(ind);
                }
            });

            $('#AutoPriceCode' + ind).on('blur', function (e, ui) {
                if ($('#AutoPriceCode' + ind).val().trim() != "") {
                    if ($('#AutoPriceCode' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Price Group", 3);
                        $('#AutoPriceCode' + ind).val("");
                        $('#hdnPriceListID' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoPriceCode' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    CheckDuplicatePriceGroup($('#AutoPriceCode' + ind).val().trim(), ind);
                }
            });

            var lineNum = 1;
            $('#tblCustomerTypeWisePricing > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
        }

        function CheckDuplicatePriceGroup(PriceGroupName, row) {

            var Item = PriceGroupName.split("-").pop().trim();
            var rowCnt_Customer = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblCustomerTypeWisePricing  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                if ($("input[name='AutoPriceCode']", this).val() != "") {
                    var PriceGroupName = $("input[name='AutoPriceCode']", this).val().split("-")[0].trim();
                    var PriceGroupID = $("input[name='AutoPriceCode']", this).val().split("-").pop().trim();

                    var LineNum = $("input[name='hdnLineNum']", this).val();

                    if (PriceGroupName != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == PriceGroupID) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoPriceCode' + row).val('');
                                $('#chkIsProdSale' + row).prop('checked', false);
                                $('#chkIsProdSale' + row).attr("disabled", false);
                                $('#chkIsClaim' + row).prop('checked', false);
                                $('#chkIsClaim' + row).attr("disabled", false);
                                $('#tdPriceDesc' + row).text('');
                                errormsg = 'Price Group = ' + PriceGroupName + ' is already seleted at row : ' + rowCnt_Customer;
                                return false;
                            }
                        }
                    }
                    //}

                    rowCnt_Customer++;
                }
            });

            if (cnt == 1) {
                $('#AutoPriceCode' + row).val('');
                ClearPriceGroupRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowCustomer').val();
            if (ind == row) {
                AddMoreRow();
            }

        }

        function ClearPriceGroupRow(row) {

            var rowCnt_Customer = 1;
            var cnt = 0;

            $('#tblCustomerTypeWisePricing > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var PriceGroupName = $("input[name='AutoPriceCode']", this).val();
                if (PriceGroupName == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Customer++;
            });

            if (cnt > 1) {
                var rowCnt_Customer = 1;
                $('#tblCustomerTypeWisePricing > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Customer) {
                        var PriceGroupName = $("input[name='AutoPriceCode']", this).val();
                        if (PriceGroupName == "") {
                            $(this).remove();
                        }
                    }

                    rowCnt_Customer++;
                });
            }

            var lineNum = 1;
            $('#tblCustomerTypeWisePricing > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });

        }

        function GetPriceGroupDetailsByCode(PriceGroupName, row) {

            var PriceGroupID = PriceGroupName.split("-").pop().trim();
            var rowCnt_Material = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblCustomerTypeWisePricing  > tbody > tr').each(function (row1, tr) {
                if ($("input[name='AutoPriceCode']", this).val() != "") {
                    // post table's data to Submit form using Json Format
                    var Item = $("input[name='AutoPriceCode']", this).val().split("-").pop().trim();
                    var LineNum = $("input[name='hdnLineNum']", this).val();
                    if (PriceGroupID != "" && PriceGroupID != "0") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == PriceGroupID) {
                                cnt = 1;
                                errRow = row;
                                return false;
                            }
                        }
                    }
                    //}
                    rowCnt_Material++;
                }
            });

            if (cnt == 1) {
                return false;
            }
            else {

                $.ajax({
                    url: 'CustomerTypeWisePricing.aspx/GetPriceGroupDetail',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ PriceGroupID: PriceGroupID, DivisionID: $('.ddlDivision').val() }),

                    success: function (result) {
                        if (result == "") {
                            return false;
                        }
                        else if (result.d.indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            $("input[name='AutoPriceCode']", this).val() == "";
                            return false;
                        }
                        else {
                            $('#tdPriceDesc' + row).text(result.d[0].PriceDesc);

                            $('#chkIsProdSale' + row).prop("checked", result.d[0].IsProductSale);

                            $('#chkIsClaim' + row).prop("checked", result.d[0].IsClaim);

                            $('#tdUpdateBy' + row).text(result.d[0].LastUpdateBy);
                            $('#tdUpdateOn' + row).text(result.d[0].LastUpdateDate);

                            $('#hdnPriceListID' + row).val(result.d[0].PriceListID);
                            $('#tdIpAdd' + row).text(result.d[0].IpAddress);
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

        function ClearControls() {
            $('.divPriceList').attr('style', 'display:none;');
            $('.divPriceReport').attr('style', 'display:none;');
            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');

            $('#tblCustomerTypeWisePricing tbody').empty();

            if ($.fn.DataTable.isDataTable('.gvPriceHistory')) {
                $('.gvPriceHistory').DataTable().destroy();
            }

            $('.gvPriceHistory tbody').empty();

            if ($('.chkIsReport').find('input').is(':checked')) {
                $('.divPriceReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
            }
            else {
                $('.divPriceList').removeAttr('style');
                $('.btnSubmit').removeAttr('style');

                $('#CountRowCustomer').val(0);
                AddMoreRow();
            }
        }

        function Cancel() {
            window.location = "../Master/CustomerTypeWisePricing.aspx";
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

            var TableData_PriceGroup = [];

            var totalItemcnt = 0;
            var cnt = 0;

            rowCnt_PriceGroup = 0;

            $('#tblCustomerTypeWisePricing  > tbody > tr').each(function (row, tr) {
                var PriceGroupName = $("input[name='AutoPriceCode']", this).val();
                if (PriceGroupName != "") {
                    totalItemcnt = 1;
                    var PriceListID = $("input[name='hdnPriceListID']", this).val().trim();
                    var IsProdSale = $("input[name='chkIsProdSale']", this).is(':checked');
                    var IsClaim = $("input[name='chkIsClaim']", this).is(':checked');
                    var IPAddress = $("#hdnIPAdd").val();

                    var obj = {
                        PriceListID: PriceListID,
                        IsProdSale: IsProdSale,
                        IsClaim: IsClaim,
                        IPAddress: IPAddress
                    };

                    TableData_PriceGroup.push(obj);
                }

                rowCnt_PriceGroup++;
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

            var PriceGroupListData = JSON.stringify(TableData_PriceGroup);

            var successMSG = true;

            var sv = $.ajax({
                url: 'CustomerTypeWisePricing.aspx/SaveData',
                type: 'POST',
                //async: false,
                dataType: 'json',
                // traditional: true,
                data: JSON.stringify({ hidJsonInputPriceGroupList: PriceGroupListData, Division: $('.ddlDivision').val(), CustType: $('.ddlCustType').val() }),
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

        function GetReport() {

            if ($('.chkIsReport').find('input').is(':checked')) {

                ClearControls();

                $.ajax({
                    url: 'CustomerTypeWisePricing.aspx/LoadReport',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ strCustType: $('.ddlCustType').val(), strDivision: $('.ddlDivision').val() }),

                    success: function (result) {
                        if (result.d[0] == "") {
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            $("input[name='AutoPriceCode']", this).val() == "";
                            return false;
                        }
                        else {

                            var ReportData = JSON.parse(result.d[0]);
                            var str = "";

                            for (var i = 0; i < ReportData.length; i++) {

                                str = "<tr><td>" + ReportData[i].SRNo + "</td>"
                                        + "<td>" + ReportData[i].Name + "</td>"
                                        + "<td>" + ReportData[i].Description + "</td>"
                                        + "<td>" + ReportData[i].SelectedProductSale + "</td>"
                                        + "<td>" + ReportData[i].OnlineClaim + "</td>"
                                        + "<td>" + ReportData[i].UpdatedBy + "</td>"
                                        + "<td>" + ReportData[i].UpdatedOn + "</td>"
                                        + "<td>" + ReportData[i].IPAddress + "</td></tr>"

                                $('.gvPriceHistory > tbody').append(str);
                            }

                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });

                if ($('.gvPriceHistory tbody tr').length > 0) {

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }
                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "5px", "sClass": "dtbodyCenter", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "120px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "150px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "40px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "35px", "sClass": "dtbodyCenter", "aTargets": 6, "orderable": false });
                    aryJSONColTable.push({ "width": "60px", "aTargets": 7 });

                    $('.gvPriceHistory').DataTable({
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
                                   data += 'Division,' + $('.ddlDivision option:selected').text() + '\n';
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
                                   var r1 = Addrow(2, [{ key: 'A', value: 'Division' }, { key: 'B', value: $('.ddlDivision option:selected').text() }]);
                                   var r2 = Addrow(3, [{ key: 'A', value: 'Report By' }, { key: 'B', value: $('.ddlCustType option:selected').text() }]);
                                   var r3 = Addrow(4, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                   var r4 = Addrow(5, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                   sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + sheet.childNodes[0].childNodes[1].innerHTML;
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
                                   doc.pageMargins = [20, 70, 20, 30];
                                   doc.defaultStyle.fontSize = 7;
                                   doc.styles.tableHeader.fontSize = 7;
                                   doc.styles.tableFooter.fontSize = 7;
                                   doc['content']['0'].table.widths = ['2%', '20%', '24%', '10%', '5%', '14%', '12%', '13%'];
                                   doc['header'] = (function () {
                                       return {
                                           columns: [
                                               {
                                                   alignment: 'left',
                                                   italics: false,
                                                   text: [
                                                      { text: $("#lnkTitle").text() + '\n' },
                                                       { text: 'Division : ' + ($('.ddlDivision option:Selected').text() + "\n") },
                                                       { text: 'Report By : ' + ($('.ddlCustType option:Selected').text() + "\n") },
                                                       { text: 'User Name : ' + $('.hdnUserName').val() + "\n" }],
                                                   fontSize: 10,
                                                   height: 350,
                                               },
                                               {
                                                   alignment: 'right',
                                                   width: 70,
                                                   height: 45,
                                                   image: imagebase64
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
                                   for (i = 1; i < rowCount; i++) {// rows alignment setting by default left
                                       doc.content[0].table.body[i][0].alignment = 'center';
                                       doc.content[0].table.body[i][6].alignment = 'center';
                                   };
                                   doc.content[0].table.body[0][0].alignment = 'center';
                                   doc.content[0].table.body[0][1].alignment = 'left';
                                   doc.content[0].table.body[0][2].alignment = 'left';
                                   doc.content[0].table.body[0][3].alignment = 'left';
                                   doc.content[0].table.body[0][4].alignment = 'left';
                                   doc.content[0].table.body[0][5].alignment = 'left';
                                   doc.content[0].table.body[0][6].alignment = 'center';
                                   doc.content[0].table.body[0][7].alignment = 'left';
                               }
                           }]
                    });
                }
            }
        }

    </script>

    <style>
        .ui-widget {
            font-size: 10px;
        }

        .search {
            font-size: 10px !important;
            height: 25px;
        }

        th.table-header-gradient {
            z-index: 9;
        }

        td.txtSrNo {
            text-align: center;
        }

        .table#tblCustomer .dataTables_scrollBody {
            max-height: 70vh !important;
        }

        table#gvPriceHistory.dataTable tbody th, table.dataTable tbody td {
            padding: 5px 10px;
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

        table#tblCustomerTypeWisePricing .dataTables_scrollBody {
            max-height: 78vh !important;
        }

        table#gvPriceHistory.dataTable tbody th, table.dataTable tbody td {
            padding: 5px 10px;
        }

        .dtbodyCenter {
            text-align: center;
        }

        #page-content-wrapper {
            overflow: hidden;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Division</label>
                        <asp:DropDownList runat="server" ID="ddlDivision" CssClass="ddlDivision form-control" DataTextField="DivisionName" onchange="ClearControls();" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Pricing Group Of</label>
                        <select id="ddlCustType" name="CustType" runat="server" class="ddlCustType form-control" onchange="ClearControls();">
                            <option value="4">Super Stockist</option>
                            <option value="2">Distributor</option>
                            <option value="3" selected="selected">Dealer</option>
                        </select>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <label class="input-group-addon">View Report</label>
                        <asp:CheckBox runat="server" CssClass="chkIsReport form-control" onchange="ClearControls();" />
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" class="btnSubmit btn btn-default" onclick="btnSubmit_Click()" tabindex="2" />
                        <input type="button" id="btnSearch" name="btnSearch" value="Process" class="btnSearch btn btn-default" onclick="GetReport();" tabindex="3" />
                        &nbsp
                        <input type="button" id="btnCancel" name="btnCancel" value="Cancel" onclick="Cancel()" class="btn btn-default" tabindex="4" />
                    </div>
                </div>
            </div>
            <input type="hidden" id="CountRowCustomer" />
            <div id="divPriceList" class="divPriceList" runat="server" style="max-height: 78vh; overflow-y: auto;">
                <table id="tblCustomerTypeWisePricing" class="table table-bordered" tabindex="1" style="font-size: 11px">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="width: 3%; text-align: center;">Sr</th>
                            <th style="width: 26%">Pricing Group</th>
                            <th style="width: 25%">Pricing Group Description</th>
                            <th style="width: 12%">Selected Product Sales</th>
                            <th style="width: 6%">Online Claim</th>
                            <th style="width: 16%">Last Update By</th>
                            <th style="width: 8%">Last Update On</th>
                            <th style="width: 8%">IP Address</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
            <div id="divPriceReport" class="divPriceReport">
                <table id="gvPriceHistory" class="gvPriceHistory table table-bordered" style="width: 100%; font-size: 11px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th>Sr</th>
                            <th>Pricing Group</th>
                            <th>Pricing Group Description</th>
                            <th>Selected Product Sales</th>
                            <th>Online Claim</th>
                            <th>Update By</th>
                            <th>Update On</th>
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

