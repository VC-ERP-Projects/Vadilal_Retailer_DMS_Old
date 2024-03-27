<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="FSSAIMaster.aspx.cs" Inherits="Master_FSSAIMaster" %>

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
        var ParentID = '<% = ParentID%>';
        var CustType = '<% =CustType%>';
        var Version = '<% = Version%>';
        var IpAddress;
        var imagebase64 = "";
        // var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';
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

        $(document).ready(function () {
            ClearControls();
            $("#tblFSSI").tableHeadFixer('80vh');
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            FillData();
            var clicked = false;
            $(document).on('click', '.btnEdit', function () {
                var checkBoxes = $(this).closest('tr').find('.chkEdit');
                if (checkBoxes.prop("checked") == true) {
                    checkBoxes.prop("checked", false);
                    $(this).closest('tr').find('.search,.checkbox').prop('disabled', false);
                    $(this).val('Update');
                } else {
                    checkBoxes.prop("checked", true);
                    $(this).closest('tr').find('.search,.checkbox').prop('disabled', true);
                    $(this).val('Edit');
                }
            })
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

            $('table#tblFSSI tr#NoROW').remove();  // Remove NO ROW

            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowFSSI').val();
            ind = parseInt(ind) + 1;
            $('#CountRowFSSI').val(ind);

            var str = "";
            str = "<tr id='trFSSI" + ind + "'>"
                + "<td class='txtSrNo' name='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                + "<td><input type='checkbox' id='chkEdit" + ind + "' class='chkEdit' checked/>"
                + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + ind + "' name='btnEdit' value = 'Edit' /></td>"
                + "<td><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + ind + "' name='btnDelete' value = 'Delete' onclick='RemoveFSSIRow(" + ind + ");' /></td>"
                + "<td><input type='text' id='AutoCustCode" + ind + "' name='AutoCustCode' onchange='ChangeData(this);' class='form-control search' /></td>"
                + "<td id='tdCustName" + ind + "' class='tdCustName'></td>"
                + "<td id='tdCustRegion" + ind + "' class='tdCustRegion hideInVehicle'></td>"
                + "<td id='tdCustCity" + ind + "' class='tdCustCity hideInVehicle'></td>"
                + "<td id='tdCustStatus" + ind + "' class='tdCustStatus'></td>"
                + "<td><input type='text' id='txtFSSINo" + ind + "' name='txtFSSINo' maxlength='14' onchange='ChangeData(this);' class='form-control search' /></td>"
                + "<td><input readonly type='text' id='tdFromDate" + ind + "'name='tdFromDate' onchange='ChangeData(this);' class='form-control startdate search dtbodyCenter' onpaste='return false;'/></td>"
                + "<td><input readonly type='text' id='tdToDate" + ind + "'name='tdToDate' onchange='ChangeData(this);' class='form-control enddate search dtbodyCenter' onpaste='return false;'/></td>"
                + "<td id='tdCreateBy" + ind + "' class='tdCreateBy'></td>"
                + "<td id='tdCreateOn" + ind + "' class='tdCreateOn dtbodyCenter'></td>"
                + "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy'></td>"
                + "<td id='tdUpdateOn" + ind + "' class='tdUpdateOn dtbodyCenter'></td>"
                + "<td id='tdEmployee" + ind + "' class='tdEmployee hideInVehicle'></td>"
                + "<input type='hidden' class='hdnFSSIForID' id='hdnFSSIForID" + ind + "' name='hdnFSSIForID' />"
                + "<input type='hidden' class='hdnOFSSIID' id='hdnOFSSIID" + ind + "' name='hdnOFSSIID' /></td>"
                + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' />"
                + "<input type='hidden' id='IsChange" + ind + "' name='IsChange' value='0' /></td>"
                + "<input type='hidden' class='IsDeleted' id='IsDeleted" + ind + "' name='IsDeleted' value='0' /></td>"
                + "<input type='text' id='txtDeleteFlag" + ind + "' name='txtDeleteFlag' style='display:none' value='false' />"

            $('#tblFSSI > tbody').append(str);
            if ($('.ddlType').val() == "5") {
                $("#tblFSSI").find("tr td.hideInVehicle,tr th.hideInVehicle").css("display", "none");
            }
            else {
                $("#tblFSSI").find("tr td.hideInVehicle,tr th.hideInVehicle").css("display", "");
            }
            $('.chkEdit').hide();
            $('.chkEdit').prop("checked", true);
            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);

            $('.startdate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2014, 1, 1)
            });

            $('.enddate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2014, 1, 1)
            });

            //---------------Type wise code selection----------
            $('#AutoCustCode' + ind).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        url: "FSSAIMaster.aspx/" + ($('.ddlType').val() == "2" ? "GetDistributorCurrHierarchy" : $('.ddlType').val() == "4" ? "GetSSCurrHierarchy" : "GetVehicle"),
                        type: 'POST',
                        dataType: "json",
                        data: "{ 'prefixText': '" + request.term + "'}",
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            response($.map(data.d, function (item) {
                                return {
                                    label: item.Text,
                                    value: item.Text,
                                    id: item.Value
                                };
                            }))
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                        }
                    });
                },
                select: function (event, ui) {
                    $('#AutoCustCode' + ind).val(ui.item.value);
                    if ($('.ddlType').val() == "5") {
                        $('#tdCustName' + ind).text(ui.item.value);
                        $('#hdnFSSIForID' + ind).val(ui.item.value);
                        $('#tdCustName' + ind).text(ui.item.value);
                    }
                    else {
                        $('#hdnFSSIForID' + ind).val(ui.item.value.split('-').pop().trim());
                        $('#tdCustName' + ind).text(ui.item.value.split('-')[1].trim());
                    }
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#AutoCustCode' + ind).val("");
                        $('#tdCustName' + ind).text("");
                        $('#hdnFSSIForID' + ind).val(0);
                        if ($('.ddlType').val() == "5") {
                            $('#tdCustName' + ind).text(ui.item.value);
                        }
                    }
                },
                minLength: 1
            });

            $('#AutoCustCode' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoCustCode' + ind).val(ui.item.value);
                GetCustomerDetailsByCode(ui.item.value, ind);
            });
            $('#AutoCustCode' + ind).on('change keyup', function () {
                if ($('#AutoCustCode' + ind).val() == "") {
                    ClearCustRow(ind);
                }
            });

            $('#AutoCustCode' + ind).on('blur', function (e, ui) {
                if ($('#AutoCustCode' + ind).val().trim() != "") {
                    if ($('.ddlType').val() != "5" && $('#AutoCustCode' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Code", 3);
                        $('#AutoCustCode' + ind).val("");
                        $('#hdnFSSIForID' + ind).val(0);
                        return;
                    }
                    var txt = $('#AutoCustCode' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                    CheckDuplicateCust($('#AutoCustCode' + ind).val().trim(), ind);
                }
            });

            var lineNum = 1;
            $('#tblFSSI > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
        }

        function ClearCustRow(row) {

            var rowCnt_Customer = 1;
            var cnt = 0;

            $('#tblFSSI > tbody > tr').each(function (row1, tr) {
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
                $('#tblFSSI > tbody > tr').each(function (row1, tr) {
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
            $('#tblFSSI > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
        }

        function RemoveFSSIRow(row) {
            var OFFSIID = $('table#tblFSSI tr#trFSSI' + row).find(".hdnOFSSIID").val();
            $('table#tblFSSI tr#trFSSI' + row).remove();
            $('table#tblFSSI tr#trFSSI' + row).find(".IsDeleted").val("1");
            var deleteIDs = $('#hdnDeleteIDs').val();
            var deletedIDs = OFFSIID + ",";
            deleteIDs += deletedIDs;
            $('#hdnDeleteIDs').val(deleteIDs);
            $('table#tblFSSI tr#trFSSI' + (row + 1)).focus();
            $('#hdnIsRowDeleted').val("1");
        }

        function CheckDuplicateCust(CustCode, row) {

            var Item = CustCode.split('-')[0].trim();
            var rowCnt_FSSI = 1;
            var cnt = 0;
            var errRow = 0;
            var NewFSSINo = $("#txtFSSINo" + row).val();
            var NewFromDate = $("#tdFromDate" + row).val();
            var NewToDate = $("#tdToDate" + row).val();
            var NewFSSIForID = $("#hdnFSSIForID" + row).val();
            var NewSrID = $("#txtSrNo" + row).text();

            $('#tblFSSI  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                if ($("input[name='AutoCustCode']", this).val() != "") {
                    var CustCode = $("input[name='AutoCustCode']", this).val().split('-')[0].trim();
                    var LineNum = $("input[name='hdnLineNum']", this).val();
                    var StartDate = $("input[name='tdFromDate']", this).val();
                    var EndDate = $("input[name='tdToDate']", this).val();
                    var FSSINo = $("input[name='txtFSSINo']", this).val();
                    var FSSIForID = $("input[name='hdnFSSIForID']", this).val();

                    if (StartDate != '' && EndDate != '') {
                        var Start = StartDate.split("/");
                        var End = EndDate.split("/");
                        var sDate = new Date(Start[2], parseInt(Start[1]) - 1, Start[0]);
                        var eDate = new Date(End[2], parseInt(End[1]) - 1, End[0]);
                        if (sDate != '' && eDate != '' && sDate > eDate) {
                            cnt = 1;
                            errRow = row;
                            errormsg = 'To Date should not be less than to From date at row : ' + LineNum;
                            $("#tdToDate" + LineNum).val('');
                            return false;
                        }
                    }
                    if (CustCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (NewFSSINo != '' && FSSINo != '' && NewFSSINo == FSSINo && NewFSSINo != 'Applied For'  && NewFSSIForID != FSSIForID) {
                                cnt = 1;
                                errRow = row;
                                errormsg = 'FSSAI number is already seleted at row : ' + rowCnt_FSSI;
                                $("#txtFSSINo" + row).val('');
                                return false;
                            }
                            if (NewFSSINo == 'Applied For' && FSSINo != '' && NewFSSIForID == FSSIForID) {
                                cnt = 1;
                                errRow = row;
                                errormsg = 'FSSAI number is already exists so you can not apply at row : ' + rowCnt_FSSI;
                                $("#txtFSSINo" + row).val('');
                                return false;
                            }
                            if (Item == CustCode) {
                                if (StartDate != '' && EndDate != '' && StartDate != undefined && EndDate != undefined) {
                                    var Start = StartDate.split("/");
                                    var End = EndDate.split("/");
                                    var sDate = new Date(Start[2], parseInt(Start[1]) - 1, Start[0]);
                                    var eDate = new Date(End[2], parseInt(End[1]) - 1, End[0]);

                                    if (NewFromDate != '' && NewFromDate != undefined) {
                                        var New = NewFromDate.split("/");
                                        var nDate = new Date(New[2], parseInt(New[1]) - 1, New[0]);

                                        if ((nDate >= sDate && nDate <= eDate) || (nDate <= sDate && nDate >= eDate)) {
                                            cnt = 1;
                                            errRow = row;
                                            errormsg = 'From Date should not be same or in between from the row : ' + rowCnt_FSSI + ' for ' + CustCode + ' at row : ' + NewSrID;
                                            $("#tdFromDate" + row).val('');
                                            return false;
                                        }
                                    }
                                    if (NewToDate != '' && NewToDate != undefined) {
                                        var New = NewToDate.split("/");
                                        var nDate = new Date(New[2], parseInt(New[1]) - 1, New[0]);

                                        if ((nDate >= sDate && nDate <= eDate) || (nDate <= sDate && nDate >= eDate)) {
                                            cnt = 1;
                                            errRow = row;
                                            errormsg = 'To Date should not be same or in between from the row : ' + rowCnt_FSSI + ' for ' + CustCode + ' at row : ' + NewSrID;
                                            $("#tdToDate" + row).val('');
                                            return false;
                                        }
                                    }
                                    if (NewFromDate != '' && NewFromDate != undefined && NewToDate != '' && NewToDate != undefined) {
                                        var nfDate = new Date(NewFromDate.split("/")[2], parseInt(NewFromDate.split("/")[1]) - 1, NewFromDate.split("/")[0]);
                                        var ntDate = new Date(NewToDate.split("/")[2], parseInt(NewToDate.split("/")[1]) - 1, NewToDate.split("/")[0]);

                                        if (nfDate > ntDate) {
                                            cnt = 1;
                                            errRow = row;
                                            errormsg = 'To Date should not be less than to From date at row : ' + NewSrID;
                                            $("#tdToDate" + row).val('');
                                            return false;
                                        }

                                        if ((nfDate >= sDate && ntDate <= eDate) || (ntDate >= sDate && nfDate <= eDate)) {
                                            cnt = 1;
                                            errRow = row;
                                            errormsg = 'From/To Date should not be same or in between from the row : ' + rowCnt_FSSI + ' for ' + CustCode + ' at row : ' + NewSrID;
                                            $("#tdToDate" + row).val('');
                                            return false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                //}

                rowCnt_FSSI++;
            });

            if (cnt == 1) {
                //$('#AutoCustCode' + row).val('');
                ClearCustRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowFSSI').val();
            if (ind == row) {
                AddMoreRow();
            }
        }

        function Cancel() {
            window.location = "../Master/FSSAIMaster.aspx";
        }

        function ChangeData(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
            CheckDuplicateCust($(txt).parent().parent().find("input[name='AutoCustCode']").val(), Number($(txt).parent().parent().find("input[name='hdnLineNum']").val()));
        }

        function btnSubmit_Click() {
            var Type = $('.ddlType').val();
            if (Type > 0) {
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

                var TableData_FSSI = [];

                var totalItemcnt = 0;
                var cnt = 0;

                rowCnt_FSSI = 0;

                $('#tblFSSI  > tbody > tr').each(function (row, tr) {
                    var AutoCustCode = $("input[name='AutoCustCode']", this).val();
                    if (AutoCustCode != "") {
                        totalItemcnt = 1;
                        var FSSIForID = $("input[name='hdnFSSIForID']", this).val();
                        var OFSSIID = $("input[name='hdnOFSSIID']", this).val();
                        var FSSINo = $("input[name='txtFSSINo']", this).val();
                        var FromDate = $("input[name='tdFromDate']", this).val();
                        var ToDate = $("input[name='tdToDate']", this).val();
                        var IsChange = $("input[name='IsChange']", this).val().trim();
                        var IsDeleted = $("input[name='IsDeleted']", this).is(':checked');
                        var CustName = $("input[name='AutoCustCode']", this).val().trim();

                        if (FSSINo == "") {
                            ModelMsg('Please select proper FSSAINo at row : ' + (rowCnt_FSSI + 1), 3);
                            IsValid = false;
                        }

                        if (FromDate == "") {
                            ModelMsg('Please select proper FromDate at row : ' + (rowCnt_FSSI + 1), 3);
                            IsValid = false;
                        }

                        if (ToDate == "") {
                            ModelMsg('Please select proper ToDate at row : ' + (rowCnt_FSSI + 1), 3);
                            IsValid = false;
                        }

                        var obj = {
                            FSSIForID: FSSIForID,
                            OFSSIID: OFSSIID,
                            FSSINo: FSSINo,
                            FromDate: FromDate,
                            ToDate: ToDate,
                            IsChange: IsChange,
                            IsDeleted: IsDeleted,
                            VehicleCode: AutoCustCode,
                            CustName: CustName
                        };
                        TableData_FSSI.push(obj);
                    }
                    rowCnt_FSSI++;
                });

                var FSSIData = JSON.stringify(TableData_FSSI);

                var successMSG = true;

                if (IsValid) {
                    var sv = $.ajax({
                        url: 'FSSAIMaster.aspx/SaveData',
                        type: 'POST',
                        dataType: 'json',
                        data: JSON.stringify({ hidJsonInputFSSI: FSSIData, Type: Type, IsAnyRowDeleted: $('#hdnIsRowDeleted').val(), DeletedIDs: $('#hdnDeleteIDs').val() }),
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
                else {
                    $.unblockUI();
                }
            }
            else {
                alert('Please select proper Type');
                return false;
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

        function GetReport() {

            if ($('.chkIsReport').find('input').is(':checked')) {
                ClearControls();

                $.ajax({
                    url: 'FSSAIMaster.aspx/LoadReport',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: "{ 'strIsHistory': '" + $('.chkIsHistory').find('input').is(':checked') + "','Type': '" + $('.ddlType').val() + "'}",
                    success: function (result) {
                        if (result.d[0] == "" || result.d[0] == undefined) {
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
                                    + "<td>" + ReportData[i].CustomerCode + "</td>"
                                    + "<td>" + ReportData[i].CustomerName + "</td>"
                                    //+ "<td>" + ReportData[i].CityName + "</td>"
                                    + "<td>" + ReportData[i].Status + "</td>"
                                    + "<td>" + ReportData[i].FSSINO + "</td>"
                                    + "<td>" + ReportData[i].StartDate + "</td>"
                                    + "<td>" + ReportData[i].EndDate + "</td>"
                                    + "<td>" + ReportData[i].Deleted + "</td>"
                                    + "<td>" + ReportData[i].CreatedBy + "</td>"
                                    + "<td>" + ReportData[i].CreatedDate + "</td>"
                                    + "<td>" + ReportData[i].UpdatedBy + "</td>"
                                    + "<td>" + ReportData[i].UpdatedDate + "</td> "
                                    + "<td>" + ReportData[i].Employee + "</td></tr>"

                                $('.gvFSSIHistory > tbody').append(str);
                            }

                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });

                if ($('.gvFSSIHistory tbody tr').length > 0) {

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }

                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "190px", "aTargets": 2 });
                    //aryJSONColTable.push({ "width": "60px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "10px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "40px", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyCenter", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyCenter", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "35px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "150px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "90px", "sClass": "dtbodyCenter", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "150px", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "90px", "sClass": "dtbodyCenter", "aTargets": 11 });
                    //aryJSONColTable.push({ "width": "200px", "aTargets": 11 });

                    $('.gvFSSIHistory').DataTable({
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '80vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "bPaginate": false,
                        "bSort": false,
                        "aoColumnDefs": aryJSONColTable,
                        "order": [[0, "asc"]],
                        buttons: [{ extend: 'copy', footer: true },
                        {
                            extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                            customize: function (csv) {
                                var data = $("#lnkTitle").text() + '\n';
                                data += 'Type,' + $('.ddlType option:selected').text() + '\n';
                                data += 'With History,' + ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") + '\n';
                                data += 'UserId,' + $('.hdnUserName').val() + '\n';
                                data += 'Created on,' + jsDate.toString() + '\n';
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

                                sheet = ExportXLS(xlsx, 5);

                                var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                var r1 = Addrow(2, [{ key: 'A', value: 'Type' }, { key: 'B', value: $('.ddlType option:selected').text() }]);
                                var r2 = Addrow(3, [{ key: 'A', value: 'With History' }, { key: 'B', value: ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") }]);
                                var r3 = Addrow(4, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                var r4 = Addrow(5, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + sheet.childNodes[0].childNodes[1].innerHTML;
                            }
                        },
                        {
                            extend: 'pdfHtml5',
                            orientation: 'landscape', //portrait
                            pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                            title: $("#lnkTitle").text(),
                            footer: 'false',
                            exportOptions: {
                                columns: ':visible',
                                search: 'applied',
                                order: 'applied'
                            },
                            customize: function (doc) {
                                doc.content.splice(0, 1);
                                var now = new Date();
                                doc.pageMargins = [20, 70, 20, 30];
                                doc.defaultStyle.fontSize = 8;
                                doc.styles.tableHeader.fontSize = 8;
                                doc.styles.tableFooter.fontSize = 8;
                                doc['header'] = (function () {
                                    return {
                                        columns: [
                                            {
                                                alignment: 'left',
                                                italics: false,
                                                text: [
                                                    { text: $("#lnkTitle").text() + '\n' },
                                                    { text: 'Type : ' + $('.ddlType option:selected').text() + "\n" },
                                                    { text: 'With History : ' + ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") + "\n" },
                                                    { text: 'User Name : ' + $('.hdnUserName').val() + "\n" },
                                                ],
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
                                    doc.content[0].table.body[i][5].alignment = 'center';
                                    doc.content[0].table.body[i][6].alignment = 'center';
                                    doc.content[0].table.body[i][9].alignment = 'center';
                                    doc.content[0].table.body[i][11].alignment = 'center';
                                };
                                doc.content[0].table.body[0][0].alignment = 'center';
                                doc.content[0].table.body[0][1].alignment = 'left';
                                doc.content[0].table.body[0][2].alignment = 'left';
                                doc.content[0].table.body[0][3].alignment = 'left';
                                doc.content[0].table.body[0][4].alignment = 'left';
                                doc.content[0].table.body[0][5].alignment = 'center';
                                doc.content[0].table.body[0][6].alignment = 'center';
                                doc.content[0].table.body[0][7].alignment = 'left';
                                doc.content[0].table.body[0][8].alignment = 'left';
                                doc.content[0].table.body[0][9].alignment = 'center';
                                doc.content[0].table.body[0][10].alignment = 'left';
                                doc.content[0].table.body[0][11].alignment = 'center';
                            }
                        }]
                    });
                }
            }
        }

        function ClearControls() {

            $('.divFSSIEntry').attr('style', 'display:none;');
            $('.divFSSIReport').attr('style', 'display:none;');
            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');
            $('.divViewDetail').attr('style', 'display:none;');
            $('#tblFSSI tbody').empty();

            if ($('.ddlType').val() == "2") {
                $("table").find("tr th.dtTypeCode").text("Dist. Code");
                $("table").find("tr th.dtTypeName").text("Dist. Name");
            }
            else if ($('.ddlType').val() == "4") {
                $("table").find("tr th.dtTypeCode").text("SS Code");
                $("table").find("tr th.dtTypeName").text("SS Name");
            }
            else {
                $("table").find("tr th.dtTypeCode").text("Vehicle Code");
                $("table").find("tr th.dtTypeName").text("Vehicle Name");
            }

            if ($.fn.DataTable.isDataTable('.gvFSSIHistory')) {
                $('.gvFSSIHistory').DataTable().destroy();
            }
            $('.gvFSSIHistory tbody').empty();

            if ($('.chkIsReport').find('input').is(':checked')) {
                $('.divFSSIReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
                $('.divViewDetail').removeAttr('style');
            }
            else {
                $('.divFSSIEntry').removeAttr('style');
                $('.btnSubmit').removeAttr('style');

                $('#CountRowFSSI').val(0);
                AddMoreRow();
                FillData();
            }
        }

        function FillData() {
            var IsValid = true;

            var Type = $('.ddlType option:Selected').val();
            if (Type != '' && $.isNumeric(Type)) {
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

                $.ajax({
                    url: 'FSSAIMaster.aspx/LoadData',
                    type: 'POST',
                    dataType: 'json',
                    data: "{ 'Type': '" + (Type != '' ? Type : 0) + "'}",
                    contentType: 'application/json; charset=utf-8',
                    success: function (result) {
                        $.unblockUI();

                        if (result.d == "") {
                            $.unblockUI();
                            event.preventDefault();
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR#") >= 0) {
                            $.unblockUI();
                            var ErrorMsg = result.d[0].split('#')[1].trim();
                            ModelMsg(ErrorMsg, 3);

                            event.preventDefault();

                            return false;
                        }
                        else {
                            var items = result.d[0];
                            if (items.length > 0) {
                                $('#tblFSSI  > tbody > tr').each(function (row1, tr) {
                                    // post table's data to Submit form using Json Format
                                    $(this).remove();
                                });
                                var row = 1;
                                $('#CountRowFSSI').val(0);
                                //var ind = $('#CountRowFSSI').val();
                                //ind = parseInt(ind) + 1;
                                //$('#CountRowFSSI').val(ind);
                                //var trHTML = '';
                                //var ind = 0;

                                for (var i = 0; i < items.length; i++) {
                                    $('table#tblFSSI tr#NoROW').remove();  // Remove NO ROW
                                    console.log(items[i].FSSINO);
                                    /// Add Dynamic Row to the existing Table
                                    var ind = $('#CountRowFSSI').val();
                                    ind = parseInt(ind) + 1;
                                    $('#CountRowFSSI').val(ind);
                                    var str = "";
                                    str = "<tr id='trFSSI" + ind + "'>"
                                        + "<td class='txtSrNo' name='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                                        + "<td><input type='checkbox' id='chkEdit" + ind + "' class='chkEdit' checked/>"
                                        + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + ind + "' name='btnEdit' value = 'Edit' /></td>"
                                        + "<td><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + ind + "' name='btnDelete' value = 'Delete' onclick='RemoveFSSIRow(" + ind + ");' /></td>"
                                        + "<td><input type='text' id='AutoCustCode" + ind + "' name='AutoCustCode' value='" + items[i].CustDesc + "' onchange='ChangeData(this);' class='form-control search' /></td>"
                                        + "<td id='tdCustName" + ind + "' class='tdCustName'>" + items[i].CustomerName + "</td>"
                                        + "<td id='tdCustRegion" + ind + "' class='tdCustRegion hideInVehicle'>" + items[i].RegionDesc + "</td>"
                                        + "<td id='tdCustCity" + ind + "' class='tdCustCity hideInVehicle'>" + items[i].City + "</td>"
                                        + "<td id='tdCustStatus" + ind + "' class='tdCustStatus'>" + items[i].Status + "</td>"
                                        + "<td><input type='text' id='txtFSSINo" + ind + "' name='txtFSSINo' maxlength='14' onchange='ChangeData(this);' class='form-control search' value=" + items[i].FSSINO + " /></td>"
                                        + "<td><input readonly type='text' id='tdFromDate" + ind + "'name='tdFromDate' onchange='ChangeData(this);' class='form-control startdate search dtbodyCenter' value=" + items[i].StartDate + " onpaste='return false;'/></td>"
                                        + "<td><input readonly type='text' id='tdToDate" + ind + "'name='tdToDate' onchange='ChangeData(this);' class='form-control enddate search dtbodyCenter' value=" + items[i].EndDate + " onpaste='return false;'/></td>"
                                        + "<td id='tdCreateBy" + ind + "' class='tdCreateBy'>" + items[i].CreatedBy + "</td>"
                                        + "<td id='tdCreateOn" + ind + "' class='tdCreateOn dtbodyCenter'>" + items[i].CreatedDate + "</td>"
                                        + "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy'>" + items[i].UpdatedBy + "</td>"
                                        + "<td id='tdUpdateOn" + ind + "' class='tdUpdateOn dtbodyCenter'>" + items[i].UpdatedDate + "</td>"
                                        + "<td id='tdEmployee" + ind + "' class='tdEmployee hideInVehicle'>" + items[i].Employee + "</td>"
                                        + "<input type='hidden' class='hdnFSSIForID' id='hdnFSSIForID" + ind + "' name='hdnFSSIForID' value=" + (Type == 5 ? items[i].CustDesc : items[i].FSSIForID) + " />"
                                        + "<input type='hidden' class='hdnOFSSIID' id='hdnOFSSIID" + ind + "' name='hdnOFSSIID' value=" + items[i].OFSSIID + " />"
                                        + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' />"
                                        + "<input type='hidden' id='IsChange" + ind + "' name='IsChange' value='0' /></td>"
                                        + "<input type='hidden' class='IsDeleted' id='IsDeleted" + ind + "' name='IsDeleted' value='0' /></td>"
                                        + "<input type='text' id='txtDeleteFlag" + ind + "' name='txtDeleteFlag' style='display:none' value='false' />" + '</tr>';

                                    $('#tblFSSI > tbody').append(str);
                                    //---------------Type wise code selection----------

                                    $('#AutoCustCode' + ind).autocomplete({
                                        source: function (request, response) {
                                            $.ajax({
                                                url: "FSSAIMaster.aspx/" + ($('.ddlType').val() == "2" ? "GetDistributorCurrHierarchy" : $('.ddlType').val() == "4" ? "GetSSCurrHierarchy" : "GetVehicle"),
                                                type: 'POST',
                                                dataType: "json",
                                                data: "{ 'prefixText': '" + request.term + "'}",
                                                contentType: "application/json; charset=utf-8",
                                                success: function (data) {
                                                    response($.map(data.d, function (item) {
                                                        return {
                                                            label: item.Text,
                                                            value: item.Text,
                                                            id: item.Value
                                                        };
                                                    }))
                                                },
                                                error: function (XMLHttpRequest, textStatus, errorThrown) {
                                                }
                                            });
                                        },
                                        select: function (event, ui) {
                                            $('#AutoCustCode' + ind).val(ui.item.value);
                                            if ($('.ddlType').val() == "5") {
                                                $('#tdCustName' + ind).text(ui.item.value);
                                                $('#hdnFSSIForID' + ind).val(ui.item.value);
                                                $('#tdCustName' + ind).text(ui.item.value);
                                            }
                                            else {
                                                $('#hdnFSSIForID' + ind).val(ui.item.value.split('-').pop().trim());
                                                $('#tdCustName' + ind).text(ui.item.value.split('-')[1].trim());
                                            }
                                        },
                                        change: function (event, ui) {
                                            if (!ui.item) {
                                                $('#AutoCustCode' + ind).val("");
                                                $('#tdCustName' + ind).text("");
                                                $('#hdnFSSIForID' + ind).val(0);
                                                if ($('.ddlType').val() == "5") {
                                                    $('#tdCustName' + ind).text(ui.item.value);
                                                }
                                            }
                                        },
                                        minLength: 1
                                    });

                                    $('#AutoCustCode' + ind).on('autocompleteselect', function (e, ui) {
                                        $('#AutoCustCode' + ind).val(ui.item.value);
                                        GetCustomerDetailsByCode(ui.item.value, ind);
                                    });
                                    $('#AutoCustCode' + ind).on('change keyup', function () {
                                        if ($('#AutoCustCode' + ind).val() == "") {
                                            ClearCustRow(ind);
                                        }
                                    });

                                    $('#AutoCustCode' + ind).on('blur', function (e, ui) {
                                        if ($('#AutoCustCode' + ind).val().trim() != "") {
                                            if ($('.ddlType').val() != "5" && $('#AutoCustCode' + ind).val().indexOf('-') == -1) {
                                                ModelMsg("Select Proper Code", 3);
                                                $('#AutoCustCode' + ind).val("");
                                                $('#hdnFSSIForID' + ind).val(0);
                                                return;
                                            }
                                            var txt = $('#AutoCustCode' + ind).val().trim();
                                            if (txt == "undefined" || txt == "") {
                                                return false;
                                            }
                                            CheckDuplicateCust($('#AutoCustCode' + ind).val().trim(), ind);
                                        }
                                    });

                                }

                                $('.search,.checkbox').prop('disabled', true);
                                if ($('.ddlType').val() == "5") {
                                    $("#tblFSSI").find("tr td.hideInVehicle,tr th.hideInVehicle").css("display", "none");
                                }
                                else {
                                    $("#tblFSSI").find("tr td.hideInVehicle,tr th.hideInVehicle").css("display", "");
                                }
                                $('.chkEdit').hide();
                                $('.chkEdit').prop("checked", true);
                                $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);

                                $('.startdate').datepicker({
                                    numberOfMonths: 1,
                                    dateFormat: 'dd/mm/yy',
                                    changeMonth: true,
                                    changeYear: true,
                                    minDate: new Date(2014, 1, 1)
                                });

                                $('.enddate').datepicker({
                                    numberOfMonths: 1,
                                    dateFormat: 'dd/mm/yy',
                                    changeMonth: true,
                                    changeYear: true,
                                    minDate: new Date(2014, 1, 1)
                                });

                                var lineNum = 1;
                                $('#tblFSSI > tbody > tr').each(function (row, tr) {
                                    $(".txtSrNo", this).text(lineNum);
                                    lineNum++;
                                });
                            }
                        }
                        AddMoreRow();
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        $.unblockUI();
                        ModelMsg("Select Proper FSSI", 3);
                        $('.txtCode').val("");
                        event.preventDefault();
                        return false;
                    }
                });
            }
            //AddMoreRow();
        }

        function GetCustomerDetailsByCode(CustName, row) {

            var CustID = CustName.split("-").pop().trim();

            if ($('.ddlType').val() == "5") {
                CustID = CustName;
            }
            else {
                CustID = CustName.split("-").pop().trim();
            }

            var rowCnt_Material = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblFSSAIMaster  > tbody > tr').each(function (row1, tr) {
                if ($("input[name='AutoCustCode']", this).val() != "") {
                    // post table's data to Submit form using Json Format
                    var Item = $("input[name='AutoCustCode']", this).val().split("-").pop().trim();
                    var LineNum = $("input[name='hdnLineNum']", this).val();
                    if (CustID != "" && CustID != "0") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == CustID) {
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
                    url: 'FSSAIMaster.aspx/GetCustomerDetail',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ CustID: CustID, ddlType: $('.ddlType').val() }),

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
                            $('#tdCustRegion' + row).text(result.d[0].StateName);
                            $('#tdCustCity' + row).text(result.d[0].City);
                            $('#tdCustStatus' + row).text(result.d[0].Status);
                            $('#tdEmployee' + row).text(result.d[0].Employee);
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

    </script>

    <style>
        .ui-widget {
            font-size: 12px;
        }

        .search {
            font-size: 10px !important;
            height: 25px;
            background-color: rgb(250, 255, 189);
            padding: 6px;
        }

        input.txtCompContri, input.txtDistContri {
            text-align: right;
        }

        td.txtSrNo {
            text-align: center;
        }

        .dtbodyCenter {
            text-align: center;
        }

        .dtbodyLeft {
            text-align: left;
        }

        .dtbodyRight {
            text-align: right;
        }

        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        #page-content-wrapper {
            overflow: hidden;
        }

        .gvMissdata {
            font-size: 11px;
        }

        table.gvFSSIHistory.table.table-bordered.nowrap.no-footer.dataTable {
            width: 100% !important;
            margin: 0;
            table-layout: auto;
        }

        .dataTables_scrollHeadInner {
            width: auto;
        }

        /*#tblFSSI th, #tblFSSI td {
            padding: 10px 5px;
        }*/
        .tableDiv table tbody th, .tableDiv table tbody td, .tableDiv table thead th, .tableDiv table thead td, .tableDiv table tfoot th, .tableDiv table tfoot td {
            padding: 5px !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnIsRowDeleted" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnDeleteIDs" ClientIDMode="Static" Value="" />

    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label Text="Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlType" CssClass="form-control ddlType" TabIndex="1" onchange="ClearControls();">
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Vehicle" Value="5" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-2">
                    <div class="input-group form-group">
                        <label class="input-group-addon">View Report</label>
                        <asp:CheckBox runat="server" CssClass="chkIsReport form-control" TabIndex="2" onchange="ClearControls();" />
                    </div>
                </div>
                <div class="divViewDetail">
                    <div class="col-lg-2">
                        <div class="input-group form-group">
                            <label class="input-group-addon">With History</label>
                            <asp:CheckBox runat="server" ID="chkIsHistory" TabIndex="3" CssClass="chkIsHistory form-control" />
                        </div>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" class="btnSubmit btn btn-default" onclick="btnSubmit_Click()" tabindex="4" />
                        &nbsp
                         <input type="button" id="btnSearch" name="btnSearch" value="Process" class="btnSearch btn btn-default" onclick="GetReport();" tabindex="5" />
                        &nbsp
                        <input type="button" id="btnCancel" name="btnCancel" value="Cancel" onclick="Cancel()" class="btn btn-default" tabindex="6" />&nbsp&nbsp
                    </div>
                </div>
            </div>
            <div class="tableDiv">
                <input type="hidden" id="CountRowFSSI" />
                <div id="divFSSIEntry" class="divFSSIEntry" runat="server" style="max-height: 80vh; overflow-y: auto;">
                    <table id="tblFSSI" class="table table-bordered" border="1" tabindex="7" style="font-size: 11px">
                        <thead>
                            <tr class="table-header-gradient">
                                <th class="dtbodyCenter" style="width: 2%; text-align: center;">Sr</th>
                                <th style="width: 3.5%">Edit</th>
                                <th style="width: 3.5%">Delete</th>
                                <th class="dtbodyLeft dtTypeCode" style="width: 5%">Dist. Code</th>
                                <th class="dtbodyLeft dtTypeName" style="width: 10%">Dist. Name</th>
                                <th class="dtbodyLeft hideInVehicle" style="width: 5%">Region</th>
                                <th class="dtbodyLeft hideInVehicle" style="width: 5.5%">City</th>
                                <th class="dtbodyLeft" style="width: 3%">Status</th>
                                <th class="dtbodyLeft" style="width: 7%">FSSAI Number</th>
                                <th class="dtbodyCenter" style="width: 5.3%">From Date</th>
                                <th class="dtbodyCenter" style="width: 5.3%">To Date</th>
                                <th class="dtbodyLeft" style="width: 6.5%;">Entry By</th>
                                <th class="dtbodyCenter" style="width: 4.2%">Entry Date/Time</th>
                                <th class="dtbodyLeft" style="width: 6.5%">Updated By</th>
                                <th class="dtbodyCenter" style="width: 4.2%">Updated Date/Time</th>
                                <th class="dtbodyLeft hideInVehicle" style="width: 6%">Employee</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div id="divFSSIReport" class="divFSSIReport">
                    <table id="gvFSSIHistory" class="gvFSSIHistory table table-bordered nowrap" style="width: 100%; font-size: 11px;">
                        <thead>
                            <tr class="table-header-gradient">
                                <th class="dtbodyCenter">Sr</th>
                                <th class="dtbodyLeft dtTypeCode">Dist. Code</th>
                                <th class="dtbodyLeft dtTypeName">Dist. Name</th>
                                <th class="dtbodyLeft">Active Status</th>
                                <th class="dtbodyLeft">FSSAI Number</th>
                                <th class="dtbodyCenter">From Date</th>
                                <th class="dtbodyCenter">To Date</th>
                                <th class="dtbodyLeft">Deleted</th>
                                <th class="dtbodyLeft">Entry By</th>
                                <th class="dtbodyCenter">Entry Date/Time</th>
                                <th class="dtbodyLeft">Updated By</th>
                                <th class="dtbodyCenter">Updated Date/Time</th>
                                <th class="dtbodyCenter">Employee</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

